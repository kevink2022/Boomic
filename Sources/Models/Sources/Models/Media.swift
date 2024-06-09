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

public struct AppPath: Codable, Equatable {
    public let relative: String
    
    static let root: URL = URL.homeDirectory
    
    public init(relativePath: String) {
        self.relative = relativePath
    }
    
    public init(url: URL) {
        let absolutePath = String(url.path(percentEncoded: false).dropFirst("/private".count))
        let rootPath = AppPath.root.path(percentEncoded: false)
        
        if absolutePath.hasPrefix(rootPath) {
            self.relative = String(absolutePath.dropFirst(rootPath.count))
        } else { 
            self.relative = ""
        }
    }
    
    public var url: URL {
        return AppPath.root.appending(path: self.relative)
    }
}
