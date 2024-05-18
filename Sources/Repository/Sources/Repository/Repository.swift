// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine

import Models
import Database
import MediaFileKit

public final class Repository {
    
    public let artLoader: MediaArtLoader
    private let localFileInterface: MediaFileInterface
       
    private let queryEngine: QueryEngine
    private let transactor: Transactor
    private var dataBasis: DataBasis
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(
        localFileInterface: MediaFileInterface = LocalMediaFileInterface()
        , artLoader: MediaArtLoader = MediaArtCache()
        , queryEngine: QueryEngine = QueryEngine()
        , transactor: Transactor = Transactor()
    ) {
        self.localFileInterface = localFileInterface
        self.artLoader = artLoader
        
        self.dataBasis = .empty
        self.queryEngine = queryEngine
        self.transactor = transactor
        
        transactor.publisher
            .sink(receiveValue: { [weak self] newBasis in
                self?.dataBasis = newBasis
            })
            .store(in: &cancellables)
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
        let existingSongs = queryEngine.getSongs(for: nil, from: dataBasis)
        guard let newSongs = try? await localFileInterface.newSongs(existing: existingSongs), !newSongs.isEmpty else { return }
        
        await transactor.addSongs(newSongs, to: dataBasis)
    }
    
    public func updateSong(_ songUpdate: SongUpdate) async {
        await transactor.updateSong(songUpdate, on: dataBasis)
    }
    
    public func getTransactions(last count: Int? = nil) async -> [LibraryTransaction] {
        return await transactor.getTransactions(last: count)
    }
    
    public func deleteLibraryData() async {
        await transactor.deleteLibraryData()
    }
}
