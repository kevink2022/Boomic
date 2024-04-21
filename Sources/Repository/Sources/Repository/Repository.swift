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
    private let database: Database
    private let localFileInterface: MediaFileInterface
    
    public init(
        database: Database = CacheDatabase()
        , localFileInterface: MediaFileInterface = LocalMediaFileInterface()
        , artLoader: MediaArtLoader = MediaArtCache()
    ) {
        self.database = database
        self.localFileInterface = localFileInterface
        self.artLoader = artLoader
    }
    
    public func getSongs(for ids: [UUID]?) -> [Models.Song] {
        return database.getSongs(for: ids)
    }
    
    public func getAlbums(for ids: [UUID]?) -> [Models.Album] {
        return database.getAlbums(for: ids)
    }
    
    public func getArtists(for ids: [UUID]?) -> [Models.Artist] {
        return database.getArtists(for: ids)
    }
    
    public func addSongs(_ songs: [Models.Song]) async {
        let existingSongs = database.getSongs(for: nil)
        guard let newSongs = try? await localFileInterface.newSongs(existing: existingSongs) else { return }
        await database.addSongs(newSongs)
    }
    
    
}
