// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine

import Domain
import Models
import Database
import MediaFileKit
import Storage

@Observable
public final class Repository {
    
    public let artLoader: MediaArtLoader
    internal let fileInterface: FileInterface
    
    internal let transactor: Transactor<LibraryTransaction, DataBasis>
    internal var basis: DataBasis
    
    internal var cancellables: Set<AnyCancellable> = []
    
    public var status = RepositoryStatus(key: .none, message: "")
    internal var statusKeys = Set<RepositoryStatusKey>()
    
    public internal(set) var tagViews: SortedSet<Taglist> { didSet { Task { try await tagViewStore.save(tagViews) } } }
    private let tagViewStore: SimpleStore<SortedSet<Taglist>>
    
    public internal(set) var activeTagView: Taglist? { didSet { Task { try await activeTagViewStore.save(activeTagView) } } }
    private let activeTagViewStore: SimpleStore<Taglist?>
    
    internal var activeTagViewTransaction: LibraryTransaction?
    
    public init(
        fileInterface: FileInterface = FileInterface(at: URL.documentsDirectory)
        , artLoader: MediaArtLoader = MediaArtCache()
        , transactor: Transactor<LibraryTransaction, DataBasis> = Transactor<LibraryTransaction, DataBasis>(
            key: Repository.transactorKey
            , basePost: DataBasis.empty
            , inMemory: false
            , coreCommit: { transaction, basis in
                await BasisResolver(currentBasis: basis).apply(transaction: transaction)
            }
            , flatten: { transaction in
                LibraryTransaction.flatten(transaction)
            }
        )
        , inMemory: Bool = false
    ) {
        self.fileInterface = fileInterface
        self.artLoader = artLoader
        
        self.transactor = transactor
        self.basis = .empty
        
        self.tagViews = SortedSet()
        self.activeTagView = nil
        self.activeTagViewTransaction = nil
        
        self.tagViewStore = SimpleStore<SortedSet<Taglist>>(
            key: Repository.tagViewsKey
            , cached: false
            , inMemory: inMemory
        )
        
        self.activeTagViewStore = SimpleStore<Taglist?>(
            key: Repository.activeTagViewKey
            , cached: false
            , inMemory: inMemory
        )
        
        self.transactor.publisher
            .sink { [weak self] basis in
                guard let self = self else { return }
                
                if let transaction = self.activeTagViewTransaction {
                    print("basis load: \(basis.allSongs.count)")
                    print("active: \(self.activeTagViewTransaction?.assertions.count)")
                    Task {
                        self.basis = await BasisResolver(currentBasis: basis).apply(transaction: transaction)
                        if transaction.assertions.count == 0 { await self.refreshActiveView() }
                    }
                } else {
                    print("basis no view: \(basis.allSongs.count)")
                    self.basis = basis
                }
            }
            .store(in: &cancellables)
        
        Task {
            let tagViews = await (try? tagViewStore.load())
            self.tagViews = tagViews ?? SortedSet()
            
            if let activeViewLoad = await (try? activeTagViewStore.load()), let activeView = activeViewLoad {
                await self.setActiveTagView(to: activeView)
            }
        }
    }
    
    public convenience init(inMemory: Bool = false) {
        self.init(
            transactor: Transactor<LibraryTransaction, DataBasis>(
                key: Repository.transactorKey
                , basePost: DataBasis.empty
                , inMemory: inMemory
                , coreCommit: { transaction, basis in await
                    BasisResolver(currentBasis: basis).apply(transaction: transaction)
                }
                , flatten: { transaction in
                    LibraryTransaction.flatten(transaction)
                }
            )
            , inMemory: inMemory
        )
    }
}

public struct RepositoryStatus: Equatable {
    public let key: RepositoryStatusKey
    public let message: String
}

public enum RepositoryStatusKey: String {
    case importSongs
    case rollback
    case none
}

// MARK: - Status
extension Repository {
    public func statusActive(for key: RepositoryStatusKey) -> Bool {
        return statusKeys.contains(key)
    }
}

// MARK: - TagViews
extension Repository {
    public func setActiveTagView(to taglist: Taglist) async {
        let basis = basis
        let songsToRemove = basis.allSongs.filter { !taglist.evaluate($0.tags) }
        let transaction = await BasisResolver(currentBasis: basis).deleteSongs(Set(songsToRemove))
        activeTagView = taglist
        activeTagViewTransaction = transaction
        self.basis = await BasisResolver(currentBasis: basis).apply(transaction: transaction)
        print("view set: \(transaction.assertions.count)")
    }
    
    public func refreshActiveView() async {
        guard let tagView = activeTagView else { return }
        let songsToRemove = basis.allSongs.filter { !tagView.evaluate($0.tags) }
        let transaction = await BasisResolver(currentBasis: basis).deleteSongs(Set(songsToRemove))
        activeTagViewTransaction = transaction
        self.basis = await BasisResolver(currentBasis: basis).apply(transaction: transaction)
        print("view refreshed: \(transaction.assertions.count)")
    }
    
    public func resetToGlobalTagView() {
        activeTagView = nil
        activeTagViewTransaction = nil
        basis = transactor.publisher.value
    }
    
    public func saveTagView(_ taglist: Taglist) {
        tagViews.insert(taglist)
    }
    
    public func deleteTagView(_ taglist: Taglist) {
        tagViews.remove(taglist)
    }
}

