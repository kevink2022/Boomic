//
//  Media.swift
//  Boomic
//
//  Created by Kevin Kelly on 2/7/24.
//

import Foundation

public protocol Media: Codable, Identifiable {
    var id: UUID { get }
    var source: MediaSource { get }
}

public enum MediaSource: Codable, Equatable {
    case local(url: URL)
}

public enum MediaArt: Codable, Equatable {
    case local(URL)
    case embedded
}

extension MediaSource {
    public var label: String {
        switch self {
        case .local(let url): return url.lastPathComponent
        }
    }
}
