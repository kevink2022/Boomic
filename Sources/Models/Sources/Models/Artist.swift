//
//  Artist.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/26/24.
//

import Foundation

public struct Artist: Model {
    public let id: ArtistID
    public let name: String
    
    public let songs: [SongID]
    public let albums: [AlbumID]
    
    public let art: MediaArt?
    
    public init(
        id: ArtistID
        , name: String
        , songs: [SongID]
        , albums: [AlbumID]
        , art: MediaArt? = nil
    ) {
        self.id = id
        self.name = name
        self.songs = songs
        self.albums = albums
        self.art = art
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case songs
        case albums
        case art
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Artist: Hashable {
    public static func == (lhs: Artist, rhs: Artist) -> Bool {
        lhs.id == rhs.id
    }
}

extension Artist: Relational {
    public func to<T:Relational>(_ object: T) throws -> [UUID] {
        switch T.self {
        
        case is Song.Type:
            return self.songs
        
        case is Album.Type:
            return self.albums
        
        default: throw ModelError.unresolvedRelation(Artist.self, T.self)
        }
    }
}

