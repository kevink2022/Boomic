//
//  Artist.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/26/24.
//

import Foundation

public struct Artist: Codable, Identifiable, Hashable {
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



