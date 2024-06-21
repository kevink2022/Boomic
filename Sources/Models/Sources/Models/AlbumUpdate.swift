//
//  File.swift
//  
//
//  Created by Kevin Kelly on 5/22/24.
//

import Foundation

extension Album {
    public func apply(update: AlbumUpdate) -> Album {
        guard self.id == update.id else { return self }
        
        let erasing = AlbumUpdate.keyPathDecoding(update.erasing) ?? Set<PartialKeyPath<Album>>()
        
        return Album(
            id: self.id
            , title: update.newTitle ?? update.originalTitle
            , art: erasing.contains(\.art) ? nil : update.art ?? self.art
            , songs: update.songs ?? self.songs
            , artistName: erasing.contains(\.artistName) ? nil : update.artistName ?? self.artistName
            , artists: update.artists ?? self.artists
        )
    }
}

public final class AlbumUpdate: Update {
    public let albumID: UUID
    public var id: UUID { albumID }
    public let originalTitle: String
    
    public let newTitle: String?
    public let art: MediaArt?
    public let songs: [UUID]?
    public let artistName: String?
    public let artists: [UUID]?
    
    public let erasing: Set<String>?
    
    private init(
        albumID: UUID
        , originalTitle: String
        , newTitle: String? = nil
        , art: MediaArt? = nil
        , songs: [UUID]? = nil
        , artistName: String? = nil
        , artists: [UUID]? = nil
        , erasing: Set<String>? = nil
    ) {
        self.albumID = albumID
        self.originalTitle = originalTitle
        self.newTitle = newTitle
        self.art = art
        self.songs = songs
        self.artistName = artistName
        self.artists = artists
        self.erasing = erasing
    }
    
    enum CodingKeys: String, CodingKey {
        case albumID
        case originalTitle = "original_title"
        
        case newTitle = "new_title"
        case art
        case songs
        case artistName = "artist_name"
        case artists
        
        case erasing
    }
    
    public static func == (lhs: AlbumUpdate, rhs: AlbumUpdate) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var label: String { originalTitle }
    
    public func willModify(_ album: Album) -> Bool {
        guard self.id == album.id else { return false }
        
        if let newTitle = self.newTitle, newTitle != album.title { return true }
        else if let art = self.art, art != album.art { return true }
        else if let artistName = self.artistName, artistName != album.artistName { return true }
        else if let songs = self.songs, songs != album.songs { return true }
        else if let artistName = self.artistName, artistName != album.artistName { return true }
        else if let artists = self.artists, artists != album.artists { return true }
        else { return erasingWillModify(album) }
    }

    private func erasingWillModify(_ album: Album) -> Bool {
        let erasing = Self.keyPathDecoding(self.erasing) ?? Set<PartialKeyPath<Album>>()
        
        if erasing.contains(\.art), album.art != nil { return true }
        else if erasing.contains(\.artistName), album.artistName != nil { return true }
        else { return false }
    }
}

extension AlbumUpdate {
    public func apply(update: AlbumUpdate) -> AlbumUpdate {
        guard self.id == update.id else { return self }
        
        return AlbumUpdate(
            albumID: update.id
            , originalTitle: update.originalTitle
            , newTitle: update.newTitle ?? self.newTitle
            , art: update.art ?? self.art
            , songs: update.songs ?? self.songs
            , artistName: update.artistName ?? self.artistName
            , artists: update.artists ?? self.artists
            , erasing: update.erasing ?? self.erasing
        )
    }
    
    public convenience init(
        album: Album
        , title: String? = nil
        , art: MediaArt? = nil
        , songs: [UUID]? = nil
        , artistName: String? = nil
        , artists: [UUID]? = nil
        , erasing: Set<PartialKeyPath<Album>>? = nil
    ) {
        self.init(
            albumID: album.id
            , originalTitle: album.title
            , newTitle: title
            , art: art
            , songs: songs
            , artistName: artistName
            , artists: artists
            , erasing: Self.keyPathEncoding(erasing)
        )
    }
    
    public convenience init(
        album: Album
        , erasing: Set<PartialKeyPath<Album>>? = nil
    ) {
        self.init(
            albumID: album.id
            , originalTitle: album.title
            , erasing: Self.keyPathEncoding(erasing)
        )
    }
}

extension AlbumUpdate {
    internal static func keyPathEncoding(_ keyPaths: Set<PartialKeyPath<Album>>?) -> Set<String>? {
        guard let keyPaths = keyPaths else { return nil }
        
        let keyStrings = keyPaths.compactMap { keyPath in
            switch keyPath {
            /*case \Album.title: "title"*/
            case \Album.art: "art"
            /*case \Album.songs: "songs"*/
            case \Album.artistName: "artistName"
            /*case \Album.artists: "artists"*/
            default: nil
            }
        }
        
        return Set(keyStrings)
    }
    
    internal static func keyPathDecoding(_ keyStrings: Set<String>?) -> Set<PartialKeyPath<Album>>? {
        guard let keyStrings = keyStrings else { return nil }
        
        let keyPaths: [PartialKeyPath<Album>] = keyStrings.compactMap { keyString in
            switch keyString {
            case "art": return \Album.art
            case "songs": return \Album.songs
            case "artistName": return \Album.artistName
            case "artists": return \Album.artists
            default: return nil
            }
        }
        
        return Set(keyPaths)
    }
}

