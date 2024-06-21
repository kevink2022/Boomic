//
//  Album.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/25/24.
//

import Foundation
import Domain

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
        var lhsHasher = Hasher()
        lhs.hash(into: &lhsHasher)
        let lhsHash = lhsHasher.finalize()
        
        var rhsHasher = Hasher()
        rhs.hash(into: &rhsHasher)
        let rhsHash = rhsHasher.finalize()
        
        return lhsHash == rhsHash
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(art)
        hasher.combine(artistName)
        hasher.combine(artists)
    }
    
    public static let none = Album(id: UUID(), title: "None")
    
    public var label: String { title }
}

//extension Album {
//    public static func alphabeticalSort(_ albumA: Album, _ albumB: Album) -> Bool {
//        albumA.title.compare(albumB.title, options: .caseInsensitive) == .orderedAscending
//    }
//}



