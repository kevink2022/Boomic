//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/23/24.
//

import Foundation
import Models


public final class DataBasis {
    public let songMap: [UUID: Song]
    public let albumMap: [UUID: Album]
    public let artistMap: [UUID: Artist]
    
    public let allSongs: [Song]
    public let allAlbums: [Album]
    public let allArtists: [Artist]
    
    public init(
        songMap: [UUID : Song]
        , albumMap: [UUID : Album]
        , artistMap: [UUID : Artist]
        , allSongs: [Song]
        , allAlbums: [Album]
        , allArtists: [Artist]
    ) {
        self.songMap = songMap
        self.albumMap = albumMap
        self.artistMap = artistMap
        self.allSongs = allSongs
        self.allAlbums = allAlbums
        self.allArtists = allArtists
    }
    
    public convenience init(
        songs: [Song]
        , albums: [Album]
        , artists: [Artist]
        , songMap: [UUID: Song]? = nil
        , albumMap: [UUID: Album]? = nil
        , artistMap: [UUID: Artist]? = nil
    ) {
        self.init(
            songMap: songMap ?? songs.reduce(into: [:]) { $0[$1.id] = $1 }
            , albumMap: albumMap ?? albums.reduce(into: [:]) { $0[$1.id] = $1 }
            , artistMap: artistMap ?? artists.reduce(into: [:]) { $0[$1.id] = $1 }
            , allSongs: songs
            , allAlbums: albums
            , allArtists: artists
        )
    }
    
    public static let empty = DataBasis(songs: [], albums: [], artists: [])
}
