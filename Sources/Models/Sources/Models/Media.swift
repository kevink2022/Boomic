//
//  Media.swift
//  Boomic
//
//  Created by Kevin Kelly on 2/7/24.
//

import Foundation
import Domain

public protocol Media: Codable, Identifiable {
    var id: UUID { get }
    var source: MediaSource { get }
}

public enum MediaSource: Codable, Equatable {
    case local(path: AppPath)
}

public enum MediaArt: Codable, Equatable {
    case local(path: AppPath)
    case embedded(path: AppPath, hash: String)
}

extension MediaSource {
    public var label: String {
        switch self {
        case .local(let path): return path.url.lastPathComponent
        }
    }
}


