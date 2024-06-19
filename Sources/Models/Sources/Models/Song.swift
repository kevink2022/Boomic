//
//  Song.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/25/24.
//

import Foundation
import Domain

public final class Song: Media, Identifiable, Codable, Equatable, Hashable {
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
    public let tags: Set<Tag>
    
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
        , tags: Set<Tag> = []
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
        self.tags = tags
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
        case tags
    }
    
    public static func == (lhs: Song, rhs: Song) -> Bool {
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
        hasher.combine(source)
        hasher.combine(duration)
        hasher.combine(title)
        hasher.combine(trackNumber)
        hasher.combine(discNumber)
        hasher.combine(art)
        hasher.combine(artistName)
        hasher.combine(artists)
        hasher.combine(albumTitle)
        hasher.combine(albums)
        hasher.combine(rating)
        hasher.combine(tags)
    }
}

extension Song {
    public static var codecs: Set<String> = ["mp3", "flac", "m4a"]
    
    public var label: String {
        self.title ?? self.source.label
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

// MARK: - Defaults
extension Song {
    public static let none = Song(id: UUID(), source: .local(path: AppPath(url: URL.documentsDirectory)), duration: 90)
}

