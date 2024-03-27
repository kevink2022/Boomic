// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Models
import Database
import MediaFileKit

public protocol Repository: Database { }

public final class RepositoryImpl: Repository {
    
    private let database: Database
    private let localFileInterface: MediaFileInterface
    
    public init(
        database: Database = CacheDatabase()
        , localFileInterface: MediaFileInterface = LocalMediaFileInterface()
    ) {
        self.database = database
        self.localFileInterface = localFileInterface
    }
    
    public func getSongs(for ids: [UUID]?) async -> [Models.Song] {
        return await database.getSongs(for: ids)
    }
    
    public func getAlbums(for ids: [UUID]?) async -> [Models.Album] {
        return await database.getAlbums(for: ids)
    }
    
    public func getArtists(for ids: [UUID]?) async -> [Models.Artist] {
        return await database.getArtists(for: ids)
    }
    
    public func addSongs(_ songs: [Models.Song]) async {
        let existingSongs = await database.getSongs(for: nil)
        guard let newSongs = try? await localFileInterface.newSongs(existing: existingSongs) else { return }
        await database.addSongs(newSongs)
    }
    
    
}
