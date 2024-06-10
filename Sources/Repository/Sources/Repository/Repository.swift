// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine

import Models
import Database
import MediaFileKit
import Storage

public final class Repository {
    
    public let artLoader: MediaArtLoader
    private let fileInterface: FileInterface
       
    private let queryEngine: QueryEngine
    private let transactor: Transactor<LibraryTransaction, DataBasis>
    private var dataBasis: DataBasis { transactor.publisher.value }
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(
        fileInterface: FileInterface = FileInterface(at: URL.documentsDirectory)
        , artLoader: MediaArtLoader = MediaArtCache()
        , queryEngine: QueryEngine = QueryEngine()
        , transactor: Transactor<LibraryTransaction, DataBasis> = Transactor<LibraryTransaction, DataBasis>(
            basePost: DataBasis.empty
            , key: "transactor"
            , inMemory: false
            , coreCommit: { transaction, basis in
                await BasisResolver(currentBasis: basis).apply(transaction: transaction)
            }
            , flatten: { transaction in
                LibraryTransaction.flatten(transaction)
            }
        )
    ) {
        self.fileInterface = fileInterface
        self.artLoader = artLoader
        
        self.queryEngine = queryEngine
        self.transactor = transactor
    }
    
    public convenience init(inMemory: Bool = false) {
        self.init(
            transactor: Transactor<LibraryTransaction, DataBasis>(
                basePost: DataBasis.empty
                , key: "transactor"
                , inMemory: inMemory
                , coreCommit: { transaction, basis in await
                    BasisResolver(currentBasis: basis).apply(transaction: transaction)
                }
                , flatten: { transaction in
                    LibraryTransaction.flatten(transaction)
                }
            )
        )
    }
}

// MARK: - Queries
extension Repository {
    public func getSongs(for ids: [UUID]?) -> [Song] {
        return queryEngine.getSongs(for: ids, from: dataBasis)
    }
    
    public func getAlbums(for ids: [UUID]?) -> [Album] {
        return queryEngine.getAlbums(for: ids, from: dataBasis)
    }
    
    public func getArtists(for ids: [UUID]?) -> [Artist] {
        return queryEngine.getArtists(for: ids, from: dataBasis)
    }
    
    public func addQuery(_ query: Query) {
        query.addBasis(publisher: transactor.publisher)
    }
}

// MARK: - Transactions
extension Repository {
    public func importSongs() async {
        let existingFiles = queryEngine.getSongs(for: nil, from: dataBasis).compactMap { song in
            if case .local(let path) = song.source { return path }
            return nil
        }
        
        guard let newFiles = try? fileInterface.allFiles(of: Song.codecs, excluding: Set(existingFiles)) else { return }
        
        let newSongs = newFiles.map { Song(from: $0) }
        
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).addSongs(newSongs)
        }
    }
    
    public func updateSong(_ songUpdate: SongUpdate) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateSong(songUpdate)
        }
    }
    
    public func deleteSong(_ song: Song) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteSong(song)
        }
    }
}

// MARK: - Library Management
extension Repository {
    public func getTransactions(last count: Int? = nil) async -> [DataTransaction<LibraryTransaction>] {
        return await transactor.viewTransactions(last: count)
    }
    
    public func deleteLibraryData() async {
        if let lastTransaction = await transactor.viewTransactions().last {
            await transactor.rollbackTo(before: lastTransaction)
        }
    }
    
    public func rollbackTo(after transaction: DataTransaction<LibraryTransaction>) async {
        await transactor.rollbackTo(after: transaction)
    }
    
    public func rollbackTo(before transaction: DataTransaction<LibraryTransaction>) async {
        await transactor.rollbackTo(before: transaction)
    }
    
    
    public func libraryFilesSizeAndAllocatedSize() async -> (String, String) {
        guard let (size, allocatedSize) = try? fileInterface.sizeAndAllocatedSize() else {
            return ("Error Retrieving Data", "Error Retrieving Data")
        }
        return (size.fileSize, allocatedSize.fileSize)
    }
    
    public func libraryDataSizeAndAllocatedSize() async -> (String, String) {
        guard let (size, allocatedSize) = try? await transactor.sizeAndAllocatedSize() else {
            return ("Error Retrieving Data", "Error Retrieving Data")
        }
        return (size.fileSize, allocatedSize.fileSize)
    }
}
