// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine

import Models
import Database
import MediaFileKit
import Storage

@Observable
public final class Repository {
    
    public let artLoader: MediaArtLoader
    private let fileInterface: FileInterface
    
    private let transactor: Transactor<LibraryTransaction, DataBasis>
    private var basis: DataBasis
    
    private var cancellables: Set<AnyCancellable> = []
    
    public var status = RepositoryStatus(key: .none, message: "")
    private var statusKeys = Set<RepositoryStatusKey>()
    
    private var activeSubLibraryTransaction: LibraryTransaction?
    
    public init(
        fileInterface: FileInterface = FileInterface(at: URL.documentsDirectory)
        , artLoader: MediaArtLoader = MediaArtCache()
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
        
        self.transactor = transactor
        self.basis = .empty
        self.activeSubLibraryTransaction = nil
        
        self.transactor.publisher
            .sink { [weak self] basis in
                guard let self = self else { return }
                
                if let transaction = self.activeSubLibraryTransaction {
                    Task { 
                        self.basis = await BasisResolver(currentBasis: basis).apply(transaction: transaction)
                    }
                } else {
                    self.basis = basis
                }
            }
            .store(in: &cancellables)
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

// MARK: - SubLibraries
extension Repository {
    public func setActiveSublibrary(from taglist: Taglist) async {
        let basis = basis
        let songsToRemove = basis.allSongs.filter { !taglist.evaluate($0.tags) }
        let transaction = await BasisResolver(currentBasis: basis).deleteSongs(Set(songsToRemove))
        activeSubLibraryTransaction = transaction
        self.basis = await BasisResolver(currentBasis: basis).apply(transaction: transaction)
        print("set")
    }
    
    public func setGlobalLibrary() {
        activeSubLibraryTransaction = nil
        basis = transactor.publisher.value
    }
}

// MARK: - Queries
extension Repository {
    
    public func song(_ song: Song) -> Song? {
        return basis.songMap[song.id]
    }
    
    public func songs(_ ids: [UUID]? = nil) -> [Song] {
        if let ids = ids {
            return ids.compactMap { basis.songMap[$0] }
        } else {
            return basis.allSongs
        }
    }
    
    public func album(_ album: Album) -> Album? {
        return basis.albumMap[album.id]
    }
    
    public func albums(_ ids: [UUID]? = nil) -> [Album] {
        if let ids = ids {
            return ids.compactMap { basis.albumMap[$0] }
        } else {
            return basis.allAlbums
        }
    }
    
    public func artist(_ artist: Artist) -> Artist? {
        return basis.artistMap[artist.id]
    }
    
    public func artists(_ ids: [UUID]? = nil) -> [Artist] {
        if let ids = ids {
            return ids.compactMap { basis.artistMap[$0] }
        } else {
            return basis.allArtists
        }
    }
    
    public func taglist(_ list: Taglist) -> Taglist? {
        return basis.taglistMap[list.id]
    }
    
    public func taglists(_ ids: [UUID]? = nil) -> [Taglist] {
        if let ids = ids {
            return ids.compactMap { basis.taglistMap[$0] }
        } else {
            return basis.allTaglists
        }
    }
}

// MARK: - Transactions
extension Repository {
    public func importSongs() async {
        statusKeys.insert(.importSongs)
        
        status = RepositoryStatus(key: .importSongs, message: "Gathering existing files.")
        let existingFiles = basis.allSongs.compactMap { song in
            if case .local(let path) = song.source { return path }
            return nil
        }
        
        status = RepositoryStatus(key: .importSongs, message: "Searching for new files.")
        guard let newFiles = try? fileInterface.allFiles(of: Song.codecs, excluding: Set(existingFiles)) else { return }
        
        status = RepositoryStatus(key: .importSongs, message: "Scanning Metadata for \(newFiles.count) new songs.")
        let newSongs = newFiles.map { Song(from: $0) }
        
        status = RepositoryStatus(key: .importSongs, message: "Adding \(newSongs.count) new songs to library.")
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).addSongs(newSongs)
        }
        
        statusKeys.remove(.importSongs)
    }
    
    public func updateSongs(_ songUpdate: Set<SongUpdate>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateSongs(songUpdate)
        }
    }
    
    public func deleteSongs(_ song: Set<Song>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteSongs(song)
        }
    }
    
    public func updateAlbums(_ albumUpdate: Set<AlbumUpdate>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateAlbums(albumUpdate)
        }
    }
    
    public func deleteAlbums(_ album: Set<Album>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteAlbums(album)
        }
    }
    
    public func updateArtists(_ artistUpdate: Set<ArtistUpdate>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateArtists(artistUpdate)
        }
    }
    
    public func deleteArtists(_ artist: Set<Artist>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteArtists(artist)
        }
    }
    
    public func addTaglists(_ lists: [Taglist]) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).addTaglists(lists)
        }
    }
    
    public func updateTaglists(_ updates: [TaglistUpdate]) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateTaglists(updates)
        }
    }
    
    public func deleteTaglists(_ lists: [Taglist]) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteTaglists(lists)
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
        statusKeys.insert(.rollback)
        status = RepositoryStatus(key: .importSongs, message: "Rebuilding Database")
        await transactor.rollbackTo(after: transaction)
        statusKeys.remove(.rollback)
    }
    
    public func rollbackTo(before transaction: DataTransaction<LibraryTransaction>) async {
        statusKeys.insert(.rollback)
        status = RepositoryStatus(key: .importSongs, message: "Rebuilding Database")
        await transactor.rollbackTo(before: transaction)
        statusKeys.remove(.rollback)
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
