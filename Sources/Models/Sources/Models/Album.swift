//
//  Album.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/25/24.
//

import Foundation

public struct Album {
    public let id: UUID = UUID()
    public let title: String
    public let art: MediaArt?
    public let artist: Artist?
    
    public typealias SongID = UUID
    public let songs: [SongID]
    
    public init(
        title: String
        , songs: [SongID]
        , art: MediaArt? = nil
        , artist: Artist? = nil
    ) {
        self.title = title
        self.songs = songs
        self.art = art
        self.artist = artist
    }
}




