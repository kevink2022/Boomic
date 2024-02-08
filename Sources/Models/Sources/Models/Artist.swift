//
//  Artist.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/26/24.
//

import Foundation

public struct Artist {
    public let id: UUID = UUID()
    public let name: String
    public let albums: [Album]
    
    public init(
        name: String
        , albums: [Album]
    ) {
        self.name = name
        self.albums = albums
    }
}



