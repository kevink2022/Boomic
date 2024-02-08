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
    public let art: MediaArt?
    
    public let artist: ArtistID?
    public let album: AlbumID?
    
    public init(
        id: SongID
        , source: MediaSource
        , duration: TimeInterval
        , title: String? = nil
        , artist: ArtistID? = nil
        , album: AlbumID? = nil
        , art: MediaArt? = nil
    ) {
        self.id = id
        self.source = source
        self.duration = duration
        self.title = title
        self.artist = artist
        self.album = album
        self.art = art
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case source
        case duration
        case title
        case artist
        case album
        case art
    }
}




