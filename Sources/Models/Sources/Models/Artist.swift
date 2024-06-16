//
//  Artist.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/26/24.
//

import Foundation

public final class Artist: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let name: String
    
    public let songs: [UUID]
    public let albums: [UUID]
    
    public let art: MediaArt?
    
    public init(
        id: UUID
        , name: String
        , art: MediaArt? = nil
        , songs: [UUID] = []
        , albums: [UUID] = []
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
    
    public static func == (lhs: Artist, rhs: Artist) -> Bool {
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
        hasher.combine(art)
        hasher.combine(songs)
        hasher.combine(albums)
    }
    
    public static var none = Artist(id: UUID(), name: "None")
}



extension Artist {
    public static func alphabeticalSort(_ artistA: Artist, _ artistB: Artist) -> Bool {
        artistA.name.compare(artistB.name, options: .caseInsensitive) == .orderedAscending
    }
}
