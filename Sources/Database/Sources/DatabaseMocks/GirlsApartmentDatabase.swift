//
//  File.swift
//  
//
//  Created by Kevin Kelly on 3/16/24.
//

import Foundation
import Database
import Models
import ModelsMocks

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


public final class GirlsApartmentDatabase: Database {
    
    private var modelCache: ModelCache
    
    public init() {
        let decoder = JSONDecoder()
        
        let songData = Song.songsJSON.data(using: .utf8)!
        let albumData = Album.albumsJSON.data(using: .utf8)!
        let artistData = Artist.artistsJSON.data(using: .utf8)!
        
        let songs = try! decoder.decode([Song].self, from: songData)
        let albums = try! decoder.decode([Album].self, from: albumData)
        let artists = try! decoder.decode([Artist].self, from: artistData)
        
        self.modelCache = ModelCache(songs: songs, albums: albums, artists: artists)
    }
    
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
}
