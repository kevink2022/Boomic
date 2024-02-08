//
//  File.swift
//  
//
//  Created by Kevin Kelly on 2/7/24.
//

import Foundation

public protocol Media: Codable, Identifiable {
    var id: UUID { get }
    var source: MediaSource { get }
}

public typealias MediaID = UUID
public typealias SongID = MediaID
public typealias AlbumID = MediaID
public typealias ArtistID = MediaID

public enum MediaSource : Codable {
    case local(URL)
}

public enum MediaArt : Codable {
    case local(URL)
    case embedded(URL)
}

extension MediaSource {
    public var label: String {
        switch self {
        case .local(let url): return url.lastPathComponent
        }
    }
}
