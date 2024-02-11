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
        case artistName
        case artists
    }
}




