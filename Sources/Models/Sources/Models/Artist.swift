//
//  Artist.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/26/24.
//

import Foundation

public struct Artist: Codable, Identifiable {
    public let id: ArtistID
    public let name: String
    
    public let albums: [AlbumID]
    
    public init(
        id: ArtistID
        , name: String
        , albums: [AlbumID]
    ) {
        self.id = id
        self.name = name
        self.albums = albums
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case albums
    }
}



