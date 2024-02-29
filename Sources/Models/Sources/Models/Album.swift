//
//  Album.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/25/24.
//

import Foundation

public struct Album: Model {
    public let id: AlbumID
    public let title: String
    
    public let art: MediaArt?
    public let songs: [SongID]
    
    public let artistName: String?
    public let artists: [ArtistID]
    
    public init(
        id: AlbumID
        , title: String
        , art: MediaArt? = nil
        , songs: [SongID] = []
        , artistName: String? = nil
        , artists: [ArtistID] = []
    ) {
        self.id = id
        self.title = title
        self.songs = songs
        self.art = art
        self.artistName = artistName
        self.artists = artists
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case art
        case songs
        case artistName = "artist_name"
        case artists
    }
    
    public static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.id == rhs.id
    }
}

extension Album: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Album: Relational {
    public func to<T:Relational>(_ object: T) throws -> [UUID] {
        switch T.self {
        
        case is Song.Type:
            return self.songs
        
        case is Artist.Type:
            return self.artists
        
        default: throw ModelError.unresolvedRelation(Album.self, T.self)
        }
    }
}



