// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Models
import Database
import MediaFileKit

public protocol Repository: Database {
    var artLoader: MediaArtLoader { get }
}

public final class RepositoryImpl: Repository {
    
    public let artLoader: MediaArtLoader
    private let localFileInterface: MediaFileInterface
       
    private let queryEngine: QueryEngine
    private let transactor: Transactor
    private var dataBasis: DataBasis
    
    public init(
        localFileInterface: MediaFileInterface = LocalMediaFileInterface()
        , artLoader: MediaArtLoader = MediaArtCache()
        , queryEngine: QueryEngine = QueryEngine()
        , transactor: Transactor = Transactor()
    ) {
        self.localFileInterface = localFileInterface
        self.artLoader = artLoader
        
        self.queryEngine = QueryEngine()
        self.transactor = Transactor()
        self.dataBasis = DataBasis(songs: [], albums: [], artists: [])
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
        guard let newSongs = try? await localFileInterface.newSongs(existing: existingSongs) else { return }
        dataBasis = await transactor.addSongs(newSongs, to: dataBasis)
    }
    
    
}
