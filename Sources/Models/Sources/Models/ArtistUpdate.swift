//
//  File.swift
//  
//
//  Created by Kevin Kelly on 5/22/24.
//

import Foundation

extension Artist {
    public func apply(update: ArtistUpdate) -> Artist {
        guard self.id == update.id else { return self }
        
        let erasing = ArtistUpdate.keyPathDecoding(update.erasing) ?? Set<PartialKeyPath<Artist>>()
        
        return Artist(
            id: self.id
            , name: update.name
            , art: erasing.contains(\.art) ? nil : update.art ?? self.art
            , songs: update.songs ?? self.songs
            , albums: update.albums ?? self.albums
        )
    }
}

public final class ArtistUpdate: Codable, Identifiable, Hashable {
    public let artistID: UUID
    public var id: UUID { artistID }
    public let name: String
    
    public let songs: [UUID]?
    public let albums: [UUID]?
    
    public let art: MediaArt?
    
    public let erasing: Set<String>?
    
    private init(
        artistID: UUID
        , name: String
        , art: MediaArt? = nil
        , songs: [UUID]? = nil
        , albums: [UUID]? = nil
        , erasing: Set<String>? = nil
    ) {
        self.artistID = artistID
        self.name = name
        self.songs = songs
        self.albums = albums
        self.art = art
        self.erasing = erasing
    }
    
    enum CodingKeys: String, CodingKey {
        case artistID
        case name
        
        case songs
        case albums
        case art
        
        case erasing
    }
    
    public static func == (lhs: ArtistUpdate, rhs: ArtistUpdate) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ArtistUpdate {
    private convenience init(
        update: ArtistUpdate
        , name: String? = nil
        , art: MediaArt? = nil
        , songs: [UUID]? = nil
        , albums: [UUID]? = nil
        , erasing: Set<String>? = nil
    ) {
        self.init(
            artistID: update.artistID
            , name: name ?? update.name
            , art: art ?? update.art
            , songs: songs ?? update.songs
            , albums: albums ?? update.albums
            , erasing: erasing ?? update.erasing
        )
    }
    
    public convenience init(
        artist: Artist
        , name: String? = nil
        , art: MediaArt? = nil
        , songs: [UUID]? = nil
        , albums: [UUID]? = nil
        , erasing: Set<String>? = nil
    ) {
        self.init(
            artistID: artist.id
            , name: name ?? artist.name
            , art: art
            , songs: songs 
            , albums: albums
            , erasing: erasing
        )
    }
    
    public convenience init(
        artist: Artist
        , erasing: Set<PartialKeyPath<Artist>>? = nil
    ) {
        self.init(
            artistID: artist.id
            , name: artist.name
            , erasing: ArtistUpdate.keyPathEncoding(erasing)
        )
    }
}

extension ArtistUpdate {
    internal static func keyPathEncoding(_ keyPaths: Set<PartialKeyPath<Artist>>?) -> Set<String>? {
        guard let keyPaths = keyPaths else { return nil }
        
        let keyStrings = keyPaths.compactMap { keyPath in
            switch keyPath {
            /*case \Artist.name: "name"*/
            case \Artist.art: "art"
            /*case \Artist.songs: "songs"*/
            /*case \Artist.albums: "albums"*/
            default: nil
            }
        }
        
        return Set(keyStrings)
    }
    
    internal static func keyPathDecoding(_ keyStrings: Set<String>?) -> Set<PartialKeyPath<Artist>>? {
        guard let keyStrings = keyStrings else { return nil }
        
        let keyPaths: [PartialKeyPath<Artist>] = keyStrings.compactMap { keyString in
            switch keyString {
            case "art": return \Artist.art
            case "songs": return \Artist.songs
            case "albums": return \Artist.albums
            default: return nil
            }
        }
        
        return Set(keyPaths)
    }
}

