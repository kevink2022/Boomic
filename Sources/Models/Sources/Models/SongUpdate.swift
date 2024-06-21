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
            , tags: update.tags ?? self.tags
        )
    }
}

public final class SongUpdate: Update {
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
    public let tags: Set<Tag>?
    
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
        , tags: Set<Tag>? = nil
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
        self.tags = tags
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
        case tags
        
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
    
    public func willModify(_ song: Song) -> Bool {
        guard self.id == song.id else { return false }
        
        if let title = self.title, title != song.title { return true }
        else if let trackNumber = self.trackNumber, trackNumber != song.trackNumber { return true }
        else if let discNumber = self.discNumber, discNumber != song.discNumber { return true }
        else if let art = self.art, art != song.art { return true }
        else if let artistName = self.artistName, artistName != song.artistName { return true }
        else if let artists = self.artists, artists != song.artists { return true }
        else if let albumTitle = self.albumTitle, albumTitle != song.albumTitle { return true }
        else if let albums = self.albums, albums != song.albums { return true }
        else if let rating = self.rating, rating != song.rating { return true }
        else if let tags = self.tags, tags != song.tags { return true }
        else { return erasingWillModify(song) }
    }
    
    private func erasingWillModify(_ song: Song) -> Bool {
        let erasing = Self.keyPathDecoding(self.erasing) ?? Set<PartialKeyPath<Song>>()
        
        if erasing.contains(\.title), song.title != nil { return true }
        else if erasing.contains(\.trackNumber), song.trackNumber != nil { return true }
        else if erasing.contains(\.discNumber) , song.discNumber != nil { return true }
        else if erasing.contains(\.art), song.art != nil { return true }
        else if erasing.contains(\.artistName), song.artistName != nil { return true }
        else if erasing.contains(\.albumTitle), song.albumTitle != nil { return true }
        else if erasing.contains(\.rating), song.rating != nil { return true }
        else { return false }
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
            , tags: update.tags ?? self.tags
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
        , tags: Set<Tag>? = nil
        , erasing: Set<PartialKeyPath<Song>>? = nil
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
            , tags: tags
            , erasing: Self.keyPathEncoding(erasing)
        )
    }
    
    public convenience init(
        song: Song
        , erasing: Set<PartialKeyPath<Song>>? = nil
    ) {
        self.init(
            songID: song.id
            , source: song.source
            , erasing: Self.keyPathEncoding(erasing)
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
            case \Song.tags: "tags"
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
            case "tags": return \Song.tags
            default: return nil
            }
        }
        
        return Set(keyPaths)
    }
}
