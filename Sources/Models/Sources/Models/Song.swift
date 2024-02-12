//
//  Song.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/25/24.
//

import Foundation

public struct Song: Media {
    public let id: SongID
    public let source: MediaSource
    public let duration: TimeInterval
    
    public let title: String?
    public let trackNumber: Int?
    public let discNumber: Int?
    public let art: MediaArt?
    
    public let artistName: String?
    public let artists: [ArtistID]
    public let albumTitle: String?
    public let album: AlbumID?
    
    public init(
        id: SongID
        , source: MediaSource
        , duration: TimeInterval
        , title: String? = nil
        , trackNumber: Int? = nil
        , discNumber: Int? = nil
        , art: MediaArt? = nil
        , artistName: String? = nil
        , artists: [ArtistID] = []
        , albumTitle: String? = nil
        , album: AlbumID? = nil
    ) {
        self.id = id
        self.source = source
        self.duration = duration
        self.title = title
        self.trackNumber = trackNumber
        self.discNumber = discNumber        
        self.art = art
        self.artistName = artistName
        self.artists = artists
        self.albumTitle = albumTitle
        self.album = album
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case source
        case duration
        case title
        case trackNumber = "track_number"
        case discNumber = "disc_number"
        case artists
        case album
        case artistName = "artist_name"
        case albumTitle = "album_title"
        case art
    }
}




