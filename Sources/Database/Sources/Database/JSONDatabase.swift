//
//  JSONDatabase.swift
//
//
//  Created by Kevin Kelly on 2/12/24.
//

import Foundation
import Models

final public class JSONArrayDatabase: Database {
    
    private var songs = [Song]()
    private var albums = [Album]()
    private var artists = [Artist]()
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let fileManager: FileManager
    
    private let songsURL: URL
    private let albumsURL: URL
    private let artistsURL: URL
    
    public init (
        decoder: JSONDecoder = JSONDecoder()
        , encoder: JSONEncoder = JSONEncoder()
        , fileManager: FileManager = FileManager()
        , songsURL: URL? = nil
        , albumsURL: URL? = nil
        , artistsURL: URL? = nil
    ) throws {
        self.decoder = decoder
        self.encoder = encoder
        self.fileManager = fileManager
        self.songsURL = songsURL ?? JSONArrayDatabase.songsDefaultURL_ios
        self.albumsURL = albumsURL ?? JSONArrayDatabase.albumsDefaultURL_ios
        self.artistsURL = artistsURL ?? JSONArrayDatabase.artistsDefaultURL_ios
        
//        do {
            songs = try initFromURL([Song].self, from: self.songsURL) ?? []
//        } catch {
//            // TODO: errors
//            print("Failed to initialize songs: \(error.localizedDescription)")
//            songs = []
//        }
        
//        do {
            albums = try initFromURL([Album].self, from: self.albumsURL) ?? []
//        } catch {
//            // TODO: errors
//            print("Failed to initialize albums: \(error.localizedDescription)")
//            albums = []
//        }
        
//        do {
            artists = try initFromURL([Artist].self, from: self.artistsURL) ?? []
//        } catch {
//            // TODO: errors
//            print("Failed to initialize artists: \(error.localizedDescription)")
//            artists = []
//        }
    }
    
    private func initFromURL<T: Decodable>(_ type: T.Type, from url: URL) throws -> T? {
        do {
            let data = try Data.init(contentsOf: url)
            return try decoder.decode(T.self, from: data)
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
    
    public func getSongs(_ songIDs: [SongID]? = nil) async throws -> [Song] {
        if let songIDs = songIDs {
            return songs.filter { song in songIDs.contains(song.id) }
        } else {
            return songs
        }
    }
    
    public func getAlbums(_ albumIDs: [AlbumID]? = nil) async throws -> [Album] {
        if let albumIDs = albumIDs {
            return albums.filter { album in albumIDs.contains(album.id) }
        } else {
            return albums
        }
    }
    
    public func getArtists(_ artistIDs: [ArtistID]? = nil) async throws -> [Artist] {
        if let artistIDs = artistIDs {
            return artists.filter { artist in artistIDs.contains(artist.id) }
        } else {
            return artists
        }
    }
    
    public func saveSongs(_ songsToSave: [Song]) async throws {
        var newSongs = [Song]()
        
        songsToSave.forEach { songToSave in
            if let index = songs.firstIndex(where: {song in song == songToSave}) {
                songs[index] = songToSave
            } else {
                newSongs.append(songToSave)
            }
        }
        
        songs += newSongs
        try saveToURL(songs, to: songsURL)
    }
    
    public func saveAlbums(_ albumsToSave: [Album]) async throws {
        var newAlbums = [Album]()
        
        albumsToSave.forEach { albumToSave in
            if let index = albums.firstIndex(where: {album in album == albumToSave}) {
                albums[index] = albumToSave
            } else {
                newAlbums.append(albumToSave)
            }
        }
        
        albums += newAlbums
        try saveToURL(albums, to: albumsURL)
    }
    
    public func saveArtists(_ artistsToSave: [Artist]) async throws {
        var newArtists = [Artist]()
        
        artistsToSave.forEach { artistToSave in
            if let index = artists.firstIndex(where: {artist in artist == artistToSave}) {
                artists[index] = artistToSave
            } else {
                newArtists.append(artistToSave)
            }
        }
        
        artists += newArtists
        try saveToURL(artists, to: artistsURL)
    }
    
    private static let songsDefaultURL_ios = URL.applicationSupportDirectory
        .appending(component: "Database")
        .appending(component: "songs.json")
    private static let albumsDefaultURL_ios = URL.applicationSupportDirectory
        .appending(component: "Database")
        .appending(component: "albums.json")
    private static let artistsDefaultURL_ios = URL.applicationSupportDirectory
        .appending(component: "Database")
        .appending(component: "artists.json")
}
