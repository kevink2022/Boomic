//
//  Song.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/25/24.
//

import Foundation

public final class Song: Media, Identifiable, Codable, Equatable {
    public let id: UUID
    public let source: MediaSource
    public let duration: TimeInterval
    
    public let title: String?
    public let trackNumber: Int?
    public let discNumber: Int?
    public let art: MediaArt?
    
    public let artistName: String?
    public let artists: [UUID]
    public let albumTitle: String?
    public let albums: [UUID]
    
    public let rating: Int?
    
    public init(
        id: UUID
        , source: MediaSource
        , duration: TimeInterval
        , title: String? = nil
        , trackNumber: Int? = nil
        , discNumber: Int? = nil
        , art: MediaArt? = nil
        , artistName: String? = nil
        , artists: [UUID] = []
        , albumTitle: String? = nil
        , albums: [UUID] = []
        , rating: Int? = nil
    ) {
        self.id = id
        self.source = source
        self.duration = duration
        self.title = title
        self.trackNumber = trackNumber
        self.discNumber = discNumber        
        self.art = art
        self.artistName = artistName
        self.artists = artists
        self.albumTitle = albumTitle
        self.albums = albums
        self.rating = rating
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case source
        case duration
        
        case title
        case trackNumber = "track_number"
        case discNumber = "disc_number"
        case artists
        case albums
        case artistName = "artist_name"
        case albumTitle = "album_title"
        case art
        case rating
    }
    
    public static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}

extension Song {
    public static var codecs: Set<String> = ["mp3", "flac", "m4a"]
    
    public var label: String {
        self.title ?? self.source.label
    }
}

extension Song: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Sorting Functions
extension Song {
    public static func alphabeticalSort(_ songA: Song, _ songB: Song) -> Bool {
        songA.label.compare(songB.label, options: .caseInsensitive) == .orderedAscending
    }
    
    public static func discAndTrackNumberSort(_ songA: Song, _ songB: Song) -> Bool {
        switch (songA.discNumber, songB.discNumber) {
            
        case (let discA?, let discB?):
            if discA == discB { return Song.trackNumberSort(songA, songB) }
            else { return discA < discB }
            
        case (nil, nil): return Song.trackNumberSort(songA, songB)
        
        case (nil, _): return true
        case (_, nil): return false
        }
    }
    
    public static func trackNumberSort(_ songA: Song, _ songB: Song) -> Bool {
        switch (songA.trackNumber, songB.trackNumber) {
            
        case (let discA?, let discB?):
            if discA == discB { return Song.alphabeticalSort(songA, songB) }
            else { return discA < discB }
            
        case (nil, nil): return Song.alphabeticalSort(songA, songB)
        
        case (nil, _): return true
        case (_, nil): return false
        }
    }
}

// MARK: - Initializers
extension Song {
    public convenience init(
        existingSong: Song
        , id: UUID? = nil
        , source: MediaSource? = nil
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
            id: id ?? existingSong.id
            , source: source ?? existingSong.source
            , duration: duration ?? existingSong.duration
            , title: title ?? existingSong.title
            , trackNumber: trackNumber ?? existingSong.trackNumber
            , discNumber: discNumber ?? existingSong.discNumber
            , art: art ?? existingSong.art
            , artistName: artistName ?? existingSong.artistName
            , artists: artists ?? existingSong.artists
            , albumTitle: albumTitle ?? existingSong.albumTitle
            , albums: albums ?? existingSong.albums
            , rating: rating ?? existingSong.rating
        )
    }
    
    public convenience init(
        _ original: Song
        , applying update: SongUpdate
    ) {
        // getting a set of partialkeypaths from the updates strings
        let erasing = SongUpdate.keyPathDecoding(update.erasing) ?? Set<PartialKeyPath<Song>>()
        
        // Song init
        self.init(
            id: original.id
            , source: original.source
            , duration: original.duration
            , title: erasing.contains(\.title) ? nil : update.title ?? original.title
            , trackNumber: erasing.contains(\.trackNumber) ? nil : update.trackNumber ?? original.trackNumber
            , discNumber: erasing.contains(\.discNumber) ? nil : update.discNumber ?? original.discNumber
            , art: erasing.contains(\.art) ? nil : update.art ?? original.art
            , artistName: erasing.contains(\.artistName) ? nil : update.artistName ?? original.artistName
            , artists: update.artists ?? original.artists
            , albumTitle: erasing.contains(\.albumTitle) ? nil : update.albumTitle ?? original.albumTitle
            , albums: update.albums ?? original.albums
            , rating: erasing.contains(\.rating) ? nil : update.rating ?? original.rating
        )
    }
}

// MARK: - Defaults
extension Song {
    public static let none = Song(id: UUID(), source: .local(url: URL.documentsDirectory), duration: 90)
}

// MARK: - Update
public final class SongUpdate: Identifiable, Codable {
    public let songID: UUID
    public var id: UUID { songID }
    public var source: MediaSource
    
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
    
    internal static func keyPathEncoding(_ keyPaths: Set<PartialKeyPath<Song>>?) -> Set<String>? {
        guard let keyPaths = keyPaths else { return nil }
        
        let keyStrings = keyPaths.compactMap { keyPath in
            switch keyPath {
            case \Song.title: "title"
            case \Song.trackNumber: "trackNumber"
            case \Song.discNumber: "discNumber"
            case \Song.art: "art"
            case \Song.artistName: "artistName"
            case \Song.artists: "artists"
            case \Song.albumTitle: "albumTitle"
            case \Song.albums: "albums"
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
}

extension SongUpdate {
    public convenience init(
        song: Song
        , duration: TimeInterval? = nil
        , title: String? = nil
        , trackNumber: Int? = nil
        , discNumber: Int? = nil
        , art: MediaArt? = nil
        , artistName: String? = nil
        , albumTitle: String? = nil
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
            , artists: nil
            , albumTitle: albumTitle
            , albums: nil
            , rating: rating
            , erasing: nil
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
    
    public func updateLinks(artists: [UUID]?, albums: [UUID]?) -> SongUpdate {
        SongUpdate(
            songID: self.id
            , source: self.source
            , title: self.title
            , trackNumber: self.trackNumber
            , discNumber: self.discNumber
            , art: self.art
            , artistName: self.artistName
            , artists: artists
            , albumTitle: self.albumTitle
            , albums: albums
            , rating: self.rating
            , erasing: self.erasing
        )
    }
}
