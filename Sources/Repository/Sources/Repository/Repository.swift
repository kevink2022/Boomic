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
        
        self.transactor.publisher
            .sink { [weak self] basis in
                self?.basis = basis
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

// MARK: - Queries
extension Repository {
    
    public func song(_ song: Song) -> Song? {
        return basis.songMap[song.id]
    }
    
    public func album(_ album: Album) -> Album? {
        return basis.albumMap[album.id]
    }
    
    public func artist(_ artist: Artist) -> Artist? {
        return basis.artistMap[artist.id]
    }
    
    public func songs(_ ids: [UUID]? = nil) -> [Song] {
        if let ids = ids {
            return ids.compactMap { basis.songMap[$0] }
        } else {
            return basis.allSongs
        }
    }
    
    public func albums(_ ids: [UUID]? = nil) -> [Album] {
        if let ids = ids {
            return ids.compactMap { basis.albumMap[$0] }
        } else {
            return basis.allAlbums
        }
    }
    
    public func artists(_ ids: [UUID]? = nil) -> [Artist] {
        if let ids = ids {
            return ids.compactMap { basis.artistMap[$0] }
        } else {
            return basis.allArtists
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
    
    public func updateSong(_ albumUpdate: AlbumUpdate) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateAlbum(albumUpdate)
        }
    }
    
    public func deleteAlbum(_ album: Album) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteAlbum(album)
        }
    }
    
    public func updateArtist(_ artistUpdate: ArtistUpdate) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateArtist(artistUpdate)
        }
    }
    
    public func deleteArtist(_ artist: Artist) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteArtist(artist)
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
