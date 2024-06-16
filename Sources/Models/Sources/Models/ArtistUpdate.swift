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
            , name: update.newName ?? update.originalName
            , art: erasing.contains(\.art) ? nil : update.art ?? self.art
            , songs: update.songs ?? self.songs
            , albums: update.albums ?? self.albums
        )
    }
}

public final class ArtistUpdate: Codable, Identifiable, Hashable {
    public let artistID: UUID
    public var id: UUID { artistID }
    public let originalName: String
    
    public let newName: String?
    public let songs: [UUID]?
    public let albums: [UUID]?
    
    public let art: MediaArt?
    
    public let erasing: Set<String>?
    
    private init(
        artistID: UUID
        , originalName: String
        , newName: String? = nil
        , art: MediaArt? = nil
        , songs: [UUID]? = nil
        , albums: [UUID]? = nil
        , erasing: Set<String>? = nil
    ) {
        self.artistID = artistID
        self.originalName = originalName
        self.newName = newName
        self.songs = songs
        self.albums = albums
        self.art = art
        self.erasing = erasing
    }
    
    enum CodingKeys: String, CodingKey {
        case artistID
        case originalName = "original_name"
        
        case newName = "new_name"
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
    
    public func willModify(_ artist: Artist) -> Bool {
        guard self.id == artist.id else { return false }
        
        if let newName = self.newName, newName != artist.name { return true }
        else if let art = self.art, art != artist.art { return true }
        else if let songs = self.songs, songs != artist.songs { return true }
        else if let albums = self.albums, albums != artist.albums { return true }
        else { return erasingWillModify(artist) }
    }

    private func erasingWillModify(_ artist: Artist) -> Bool {
        let erasing = Self.keyPathDecoding(self.erasing) ?? Set<PartialKeyPath<Artist>>()
        
        if erasing.contains(\.art), artist.art != nil { return true }
        else { return false }
    }
}

extension ArtistUpdate {
    public func apply(update: ArtistUpdate) -> ArtistUpdate {
        guard self.id == update.id else { return self }
        
        return ArtistUpdate(
            artistID: self.artistID
            , originalName: self.originalName
            , newName: update.newName ?? self.newName
            , art: update.art ?? self.art
            , songs:  update.songs ?? self.songs
            , albums: update.albums ?? self.albums
            , erasing: update.erasing ?? self.erasing
        )
    }
    
    public convenience init(
        artist: Artist
        , name: String? = nil
        , art: MediaArt? = nil
        , songs: [UUID]? = nil
        , albums: [UUID]? = nil
        , erasing: Set<PartialKeyPath<Artist>>? = nil
    ) {
        self.init(
            artistID: artist.id
            , originalName: artist.name
            , newName: name
            , art: art
            , songs: songs 
            , albums: albums
            , erasing: Self.keyPathEncoding(erasing)
        )
    }
    
    public convenience init(
        artist: Artist
        , erasing: Set<PartialKeyPath<Artist>>? = nil
    ) {
        self.init(
            artistID: artist.id
            , originalName: artist.name
            , erasing: Self.keyPathEncoding(erasing)
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

