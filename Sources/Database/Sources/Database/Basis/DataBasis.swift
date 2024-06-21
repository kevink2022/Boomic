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
    public let allSongs: [Song]

    public let albumMap: [UUID: Album]
    public let allAlbums: [Album]

    public let artistMap: [UUID: Artist]
    public let allArtists: [Artist]
    
    public let taglistMap: [UUID: Taglist] // Probably not used
    public let allTaglists: [Taglist]
    public let tagsInUse: Set<Tag>
    
    private init(
        songMap: [UUID: Song]
        , allSongs: [Song]
        
        , albumMap: [UUID: Album]
        , allAlbums: [Album]
        
        , artistMap: [UUID: Artist]
        , allArtists: [Artist]
        
        , taglistMap: [UUID: Taglist]
        , allTaglists: [Taglist]
        , tagsInUse: Set<Tag>
    ) {
        self.songMap = songMap
        self.allSongs = allSongs

        self.albumMap = albumMap
        self.allAlbums = allAlbums

        self.artistMap = artistMap
        self.allArtists = allArtists
        
        self.taglistMap = taglistMap
        self.allTaglists = allTaglists
        self.tagsInUse = tagsInUse
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
            , allSongs: songs
            , albumMap: albumMap ?? albums.reduce(into: [:]) { $0[$1.id] = $1 }
            , allAlbums: albums
            , artistMap: artistMap ?? artists.reduce(into: [:]) { $0[$1.id] = $1 }
            , allArtists: artists
            , taglistMap: [:]
            , allTaglists: []
            , tagsInUse: songs.reduce(into: Set<Tag>()) { $0.formUnion($1.tags) }
        )
    }
    
    public convenience init(
        current: DataBasis
        
        , songMap: [UUID : Song]? = nil
        , allSongs: [Song]? = nil
        
        , albumMap: [UUID : Album]? = nil
        , allAlbums: [Album]? = nil
        
        , artistMap: [UUID : Artist]? = nil
        , allArtists: [Artist]? = nil
        
        , taglistMap: [UUID: Taglist]? = nil
        , allTaglists: [Taglist]? = nil
        , tagsInUse: Set<Tag>? = nil
    ) {
        self.init(
            songMap: songMap ?? current.songMap
            , allSongs: allSongs ?? current.allSongs

            , albumMap: albumMap ?? current.albumMap
            , allAlbums: allAlbums ?? current.allAlbums

            , artistMap: artistMap ?? current.artistMap
            , allArtists: allArtists ?? current.allArtists
            
            , taglistMap: taglistMap ?? current.taglistMap
            , allTaglists: allTaglists ?? current.allTaglists
            , tagsInUse: tagsInUse ?? current.tagsInUse
        )
    }
    
    public static let empty = DataBasis(songs: [], albums: [], artists: [])
}

public final class BasisResolver {
    internal let currentBasis: DataBasis
    
    internal lazy var currentAlbumTitles: [String:UUID] = {
        currentBasis.allAlbums
            .reduce(into: [String:UUID]()) { dict, album in dict[album.title] = album.id }
    }()
    
    internal lazy var currentArtistNames: [String:UUID] = {
        currentBasis.allArtists
            .reduce(into: [String:UUID]()) { dict, artist in dict[artist.name] = artist.id }
    }()
    
    public init(currentBasis: DataBasis) {
        self.currentBasis = currentBasis
    }
}
