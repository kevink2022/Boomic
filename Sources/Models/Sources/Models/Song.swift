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
}

// MARK: - Defaults
extension Song {
    public static let none = Song(id: UUID(), source: .local(url: URL.documentsDirectory), duration: 90)
}

