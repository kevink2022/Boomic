//
//  Album.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/25/24.
//

import Foundation

public struct Album: Codable, Identifiable {
    public let id: AlbumID
    public let title: String
    
    public let art: MediaArt?
    public let artist: ArtistID?
    public let songs: [SongID]
    
    public init(
        id: AlbumID
        , title: String
        , songs: [SongID]
        , art: MediaArt? = nil
        , artist: ArtistID? = nil
    ) {
        self.id = id
        self.title = title
        self.songs = songs
        self.art = art
        self.artist = artist
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case art
        case artist
        case songs
    }
}




