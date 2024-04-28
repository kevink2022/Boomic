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
        
        self.queryEngine = queryEngine
        self.transactor = transactor
        self.dataBasis = DataBasis(songs: [], albums: [], artists: [])
        
        transactor.publisher
            .sink(receiveValue: { [weak self] newBasis in
                self?.dataBasis = newBasis
            })
            .store(in: &cancellables)
    }
    
    public func getSongs(for ids: [UUID]?) -> [Song] {
        return queryEngine.getSongs(for: ids, from: dataBasis)
    }
    
    public func getAlbums(for ids: [UUID]?) -> [Album] {
        return queryEngine.getAlbums(for: ids, from: dataBasis)
    }
    
    public func getArtists(for ids: [UUID]?) -> [Artist] {
        return queryEngine.getArtists(for: ids, from: dataBasis)
    }
    
    public func addSongs(_ songs: [Song]) async {
        let existingSongs = queryEngine.getSongs(for: nil, from: dataBasis)
        guard let newSongs = try? await localFileInterface.newSongs(existing: existingSongs), !newSongs.isEmpty else { return }
        
        await transactor.addSongs(newSongs, to: dataBasis)
    }
}
