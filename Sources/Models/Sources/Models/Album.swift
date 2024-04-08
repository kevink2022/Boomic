//
//  Album.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/25/24.
//

import Foundation

public final class Album: Model {
    public let id: UUID
    public let title: String
    
    public let art: MediaArt?
    public let songs: [UUID]
    
    public let artistName: String?
    public let artists: [UUID]
    
    public init(
        id: UUID
        , title: String
        , art: MediaArt? = nil
        , songs: [UUID] = []
        , artistName: String? = nil
        , artists: [UUID] = []
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

extension Album {
    public static func alphabeticalSort(_ albumA: Album, _ albumB: Album) -> Bool {
        albumA.title.compare(albumB.title, options: .caseInsensitive) == .orderedAscending
    }
}
