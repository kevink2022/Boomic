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
       
    private let queryEngine: QueryEngine
    private let transactor: Transactor<LibraryTransaction, DataBasis>
    private var basis: DataBasis
    
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
        let existingFiles = queryEngine.getSongs(for: nil, from: basis).compactMap { song in
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
