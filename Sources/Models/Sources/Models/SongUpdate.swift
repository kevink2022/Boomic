//
//  File.swift
//  
//
//  Created by Kevin Kelly on 5/22/24.
//

import Foundation

extension Song {
    public func apply(update: SongUpdate) -> Song {
        guard self.id == update.id else { return self }
        
        let erasing = SongUpdate.keyPathDecoding(update.erasing) ?? Set<PartialKeyPath<Song>>()
        
        return Song(
            id: self.id
            , source: self.source
            , duration: self.duration
            , title: erasing.contains(\.title) ? nil : update.title ?? self.title
            , trackNumber: erasing.contains(\.trackNumber) ? nil : update.trackNumber ?? self.trackNumber
            , discNumber: erasing.contains(\.discNumber) ? nil : update.discNumber ?? self.discNumber
            , art: erasing.contains(\.art) ? nil : update.art ?? self.art
            , artistName: erasing.contains(\.artistName) ? nil : update.artistName ?? self.artistName
            , artists: update.artists ?? self.artists
            , albumTitle: erasing.contains(\.albumTitle) ? nil : update.albumTitle ?? self.albumTitle
            , albums: update.albums ?? self.albums
            , rating: erasing.contains(\.rating) ? nil : update.rating ?? self.rating
        )
    }
}

public final class SongUpdate: Identifiable, Codable, Hashable {
    public let songID: UUID
    public var id: UUID { songID }
    public let source: MediaSource
    
    public let title: String?
    public let trackNumber: Int?
    public let discNumber: Int?
    public let art: MediaArt?
    public let artistName: String?
    public let artists: [UUID]?
    public let albumTitle: String?
    public let albums: [UUID]?
    public let rating: Int?
    
    public let erasing: Set<String>?
    
    private init(
        songID: UUID
        , source: MediaSource
        , title: String? = nil
        , trackNumber: Int? = nil
        , discNumber: Int? = nil
        , art: MediaArt? = nil
        , artistName: String? = nil
        , artists: [UUID]? = nil
        , albumTitle: String? = nil
        , albums: [UUID]? = nil
        , rating: Int? = nil
        , erasing: Set<String>? = nil
    ) {
        self.songID = songID
        self.source = source
        self.title = title
        self.trackNumber = trackNumber
        self.discNumber = discNumber
        self.art = art
        self.artistName = artistName
        self.artists = artists
        self.albumTitle = albumTitle
        self.albums = albums
        self.rating = rating
        self.erasing = erasing
    }
  
    enum CodingKeys: String, CodingKey {
        case songID
        case source
        
        case title
        case trackNumber = "track_number"
        case discNumber = "disc_number"
        case artists
        case albums
        case artistName = "artist_name"
        case albumTitle = "album_title"
        case art
        case rating
        
        case erasing
    }
    
    public var label: String {
        self.title ?? self.source.label
    }
    
    public static func == (lhs: SongUpdate, rhs: SongUpdate) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension SongUpdate {
    public func apply(update: SongUpdate) -> SongUpdate {
        guard self.id == update.id else { return self }
        
        return SongUpdate(
            songID: update.id
            , source: update.source
            , title: update.title ?? self.title
            , trackNumber: update.trackNumber ?? self.trackNumber
            , discNumber: update.discNumber ?? self.discNumber
            , art: update.art ?? self.art
            , artistName: update.artistName ?? self.artistName
            , artists: update.artists ?? self.artists
            , albumTitle: update.albumTitle ?? self.albumTitle
            , albums: update.albums ?? self.albums
            , rating: update.rating ?? self.rating
            , erasing: update.erasing ?? self.erasing
        )
    }
    
    public convenience init(
        song: Song
        , duration: TimeInterval? = nil
        , title: String? = nil
        , trackNumber: Int? = nil
        , discNumber: Int? = nil
        , art: MediaArt? = nil
        , artistName: String? = nil
        , artists: [UUID]? = nil
        , albumTitle: String? = nil
        , albums: [UUID]? = nil
        , rating: Int? = nil
    ) {
        self.init(
            songID: song.id
            , source: song.source
            , title: title
            , trackNumber: trackNumber
            , discNumber: discNumber
            , art: art
            , artistName: artistName
            , artists: artists
            , albumTitle: albumTitle
            , albums: albums
            , rating: rating
        )
    }
    
    public convenience init(
        song: Song
        , erasing: Set<PartialKeyPath<Song>>? = nil
    ) {
        self.init(
            songID: song.id
            , source: song.source
            , erasing: SongUpdate.keyPathEncoding(erasing)
        )
    }
}

extension SongUpdate {
    internal static func keyPathEncoding(_ keyPaths: Set<PartialKeyPath<Song>>?) -> Set<String>? {
        guard let keyPaths = keyPaths else { return nil }
        
        let keyStrings = keyPaths.compactMap { keyPath in
            switch keyPath {
            case \Song.title: "title"
            case \Song.trackNumber: "trackNumber"
            case \Song.discNumber: "discNumber"
            case \Song.art: "art"
            case \Song.artistName: "artistName"
            /*case \Song.artists: "artists"*/
            case \Song.albumTitle: "albumTitle"
            /*case \Song.albums: "albums"*/
            case \Song.rating: "rating"
            default: nil
            }
        }
        
        return Set(keyStrings)
    }
    
    internal static func keyPathDecoding(_ keyStrings: Set<String>?) -> Set<PartialKeyPath<Song>>? {
        guard let keyStrings = keyStrings else { return nil }
        
        let keyPaths: [PartialKeyPath<Song>] = keyStrings.compactMap { keyString in
            switch keyString {
            case "title": return \Song.title
            case "trackNumber": return \Song.trackNumber
            case "discNumber": return \Song.discNumber
            case "art": return \Song.art
            case "artistName": return \Song.artistName
            case "artists": return \Song.artists
            case "albumTitle": return \Song.albumTitle
            case "albums": return \Song.albums
            case "rating": return \Song.rating
            default: return nil
            }
        }
        
        return Set(keyPaths)
    }
}
