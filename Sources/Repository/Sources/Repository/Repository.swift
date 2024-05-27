// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine

import Models
import Database
import MediaFileKit

public final class Repository {
    
    public let artLoader: MediaArtLoader
    private let fileInterface: FileInterface
       
    private let queryEngine: QueryEngine
    private let transactor: Transactor<KeySet<LibraryTransaction>, DataBasis>
    private var dataBasis: DataBasis { transactor.publisher.value }
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(
        fileInterface: FileInterface = FileInterface(at: URL.documentsDirectory)
        , artLoader: MediaArtLoader = MediaArtCache()
        , queryEngine: QueryEngine = QueryEngine()
        , transactor: Transactor<KeySet<LibraryTransaction>, DataBasis> = Transactor<KeySet<LibraryTransaction>, DataBasis>(
            basePost: DataBasis.empty
            , key: "transactor"
            , inMemory: true
            , coreCommit: { transaction, basis in await BasisResolver(currentBasis: basis).apply(transaction: transaction)}
        )
    ) {
        self.fileInterface = fileInterface
        self.artLoader = artLoader
        
        self.queryEngine = queryEngine
        self.transactor = transactor
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
}

// MARK: - Transactions
extension Repository {
    public func addSongs(_ songs: [Song]) async {
        let existingFiles = queryEngine.getSongs(for: nil, from: dataBasis).compactMap { song in
            if case .local(let url) = song.source { return url }
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
    
    public func getTransactions(last count: Int? = nil) async -> [DataTransaction<KeySet<LibraryTransaction>>] {
        return await transactor.viewTransactions(last: count)
    }
    
    public func deleteLibraryData() async {
        if let lastTransaction = await transactor.viewTransactions().last {
            await transactor.rollbackTo(before: lastTransaction)
        }
    }
}
