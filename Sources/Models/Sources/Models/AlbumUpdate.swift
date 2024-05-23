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
            , title: update.title
            , art: erasing.contains(\.art) ? nil : update.art ?? self.art
            , songs: update.songs ?? self.songs
            , artistName: erasing.contains(\.artistName) ? nil : update.artistName ?? self.artistName
            , artists: update.artists ?? self.artists
        )
    }
}

public final class AlbumUpdate: Codable, Identifiable, Hashable {
    public let albumID: UUID
    public var id: UUID { albumID }
    public let title: String
    
    public let art: MediaArt?
    public let songs: [UUID]?
    public let artistName: String?
    public let artists: [UUID]?
    
    public let erasing: Set<String>?
    
    private init(
        albumID: UUID
        , title: String
        , art: MediaArt? = nil
        , songs: [UUID]? = nil
        , artistName: String? = nil
        , artists: [UUID]? = nil
        , erasing: Set<String>? = nil
    ) {
        self.albumID = albumID
        self.title = title
        self.art = art
        self.songs = songs
        self.artistName = artistName
        self.artists = artists
        self.erasing = erasing
    }
    
    enum CodingKeys: String, CodingKey {
        case albumID
        case title
        
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
}

extension AlbumUpdate {
    private convenience init(
        update: AlbumUpdate
        , title: String? = nil
        , art: MediaArt? = nil
        , songs: [UUID]? = nil
        , artistName: String? = nil
        , artists: [UUID]? = nil
        , erasing: Set<String>? = nil
    ) {
        self.init(
            albumID: update.albumID
            , title: title ?? update.title
            , art: art ?? update.art
            , songs: songs ?? update.songs
            , artistName: artistName ?? update.artistName
            , artists: artists ?? update.artists
            , erasing: erasing ?? update.erasing
        )
    }
    
    public convenience init(
        album: Album
        , title: String? = nil
        , art: MediaArt? = nil
        , songs: [UUID]? = nil
        , artistName: String? = nil
        , artists: [UUID]? = nil
    ) {
        self.init(
            albumID: album.id
            , title: title ?? album.title
            , art: art
            , songs: songs
            , artistName: artistName
            , artists: artists
        )
    }
    
    public convenience init(
        album: Album
        , erasing: Set<PartialKeyPath<Album>>? = nil
    ) {
        self.init(
            albumID: album.id
            , title: album.title
            , erasing: AlbumUpdate.keyPathEncoding(erasing)
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

