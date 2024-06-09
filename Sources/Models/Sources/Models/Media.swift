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
    case local(url: URL)
    case embedded(url: URL, hash: String)
}

extension MediaSource {
    public var label: String {
        switch self {
        case .local(let url): return url.lastPathComponent
        }
    }
}

public struct AppPath: Codable, Equatable {
    public let relative: String
    
    static let root: URL = URL.homeDirectory
    
    public init(relativePath: String) {
        self.relative = relativePath
    }
    
    init(url: URL) {
        let absolutePath = url.absoluteString
        
        guard absolutePath.hasPrefix(AppPath.root.absoluteString) else { self.relative = ""; return }
        self.relative = String(absolutePath.dropFirst(AppPath.root.absoluteString.count))
    }
    
    public var url: URL {
        return AppPath.root.appending(path: self.relative)
    }
}
