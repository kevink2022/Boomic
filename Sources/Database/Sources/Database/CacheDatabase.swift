//
//  JSONDatabase.swift
//
//
//  Created by Kevin Kelly on 2/12/24.
//

import Foundation
import Models

private final class ModelCache {
    public let songMap: [UUID: Song]
    public let albumMap: [UUID: Album]
    public let artistMap: [UUID: Artist]
    
    public let allSongs: [Song]
    public let allAlbums: [Album]
    public let allArtists: [Artist]
    
    init(
        songs: [Song]
        , albums: [Album]
        , artists: [Artist]
    ) {
        self.allSongs = songs
        self.allAlbums = albums
        self.allArtists = artists
        
        self.songMap = songs.reduce(into: [:]) { $0[$1.id] = $1 }
        self.albumMap = albums.reduce(into: [:]) { $0[$1.id] = $1 }
        self.artistMap = artists.reduce(into: [:]) { $0[$1.id] = $1 }
    }
}

final public class CacheDatabase: Database {
    
    private var modelCache: ModelCache
    
    private let songsURL: URL
    private let albumsURL: URL
    private let artistsURL: URL
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init (
        decoder: JSONDecoder = JSONDecoder()
        , encoder: JSONEncoder = JSONEncoder()
        , songsURL: URL? = nil
        , albumsURL: URL? = nil
        , artistsURL: URL? = nil
    ) throws {
        self.decoder = decoder
        self.encoder = encoder
        self.songsURL = songsURL ?? C.songsDefaultURL_ios
        self.albumsURL = albumsURL ?? C.albumsDefaultURL_ios
        self.artistsURL = artistsURL ?? C.artistsDefaultURL_ios
        
        self.modelCache = ModelCache(songs: [], albums: [], artists: [])
        
        let songs = try initFromURL([Song].self, from: self.songsURL) ?? []
        let albums = try initFromURL([Album].self, from: self.albumsURL) ?? []
        let artists = try initFromURL([Artist].self, from: self.artistsURL) ?? []
        
        self.modelCache = ModelCache(songs: songs, albums: albums, artists: artists)
    }
    
    // MARK: - Public
    
    public func getSongs(for ids: [UUID]? = nil) -> [Song] {
        if let ids = ids {
            return ids.compactMap { modelCache.songMap[$0] }
        } else {
            return modelCache.allSongs
        }
    }
    
    public func getAlbums(for ids: [UUID]? = nil) -> [Album] {
        if let ids = ids {
            return ids.compactMap { modelCache.albumMap[$0] }
        } else {
            return modelCache.allAlbums
        }
    }
    
    public func getArtists(for ids: [UUID]? = nil) -> [Artist] {
        if let ids = ids {
            return ids.compactMap { modelCache.artistMap[$0] }
        } else {
            return modelCache.allArtists
        }
    }
    
    public func addSongs(_ songs: [Song]) async {
        
    }

    // MARK: - Private Helpers
    
    private func initFromURL<T: Decodable>(_ type: T.Type, from url: URL) throws -> T? {
        do {
            let data = try Data.init(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        }
        
        catch DecodingError.dataCorrupted {
            throw DatabaseError.dataCorrupted(url)
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSCocoaErrorDomain {
                switch nsError.code {
                case NSFileReadNoSuchFileError: return nil
                default: break
                }
            }
            
            throw error
        }
    }
    
    private func saveToURL(_ object: any Encodable, to url: URL) throws {
        let data = try encoder.encode(object)
        try data.write(to: url)
    }
    
    // MARK: - Mapping conifuguration
    
    private func getURL<T:Model>(for object: T.Type) throws -> URL {
        switch T.self {
        case is Song.Type: return self.songsURL
        case is Album.Type: return self.albumsURL
        case is Artist.Type: return self.artistsURL
        default: throw DatabaseError.unresolvedModel(T.self)
        }
    }
    
    // MARK: - Constants
    
    private typealias C = Constants
    private struct Constants {
        static let songsDefaultURL_ios = URL.applicationSupportDirectory
            .appending(component: "Database/")
            .appending(component: "songs.json")
        static let albumsDefaultURL_ios = URL.applicationSupportDirectory
            .appending(component: "Database/")
            .appending(component: "albums.json")
        static let artistsDefaultURL_ios = URL.applicationSupportDirectory
            .appending(component: "Database/")
            .appending(component: "artists.json")
        
        static func songsAlphabeticalSort(_ songA: Song, _ songB: Song) -> Bool {
            songA.label.compare(songB.label, options: .caseInsensitive) == .orderedAscending
        }
        static func albumAlphabeticalSort(_ albumA: Album, _ albumB: Album) -> Bool {
            albumA.title.compare(albumB.title, options: .caseInsensitive) == .orderedAscending
        }
        static func artistAlphabeticalSort(_ artistA: Artist, _ artistB: Artist) -> Bool {
            artistA.name.compare(artistB.name, options: .caseInsensitive) == .orderedAscending
        }
    }
}
