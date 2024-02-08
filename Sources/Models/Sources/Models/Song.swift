//
//  Song.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/25/24.
//

import Foundation

public struct Song: Media {
    public let id: UUID = UUID()
    public let source: MediaSource
    public let duration: TimeInterval
    
    public let title: String?
    public let artist: Artist?
    public let album: Album?
    public let art: MediaArt?
    
    public init(
        source: MediaSource
        , duration: TimeInterval
        , title: String? = nil
        , artist: Artist? = nil
        , album: Album? = nil
        , art: MediaArt? = nil
    ) {
        self.source = source
        self.duration = duration
        self.title = title
        self.artist = artist
        self.album = album
        self.art = art
    }
}




