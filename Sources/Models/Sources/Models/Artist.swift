//
//  Artist.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/26/24.
//

import Foundation

public struct Artist: Model {
    public let id: UUID
    public let name: String
    
    public let songs: [UUID]
    public let albums: [UUID]
    
    public let art: MediaArt?
    
    public init(
        id: UUID
        , name: String
        , songs: [UUID]
        , albums: [UUID]
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
