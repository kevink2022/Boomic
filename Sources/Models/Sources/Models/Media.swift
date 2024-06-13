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
    
    public var label: String {
        switch self {
        case .local(let path): return "(Local) \(path.relative)"
        }
    }
}

public enum MediaArt: Codable, Equatable {
    case local(path: AppPath)
    case embedded(path: AppPath, hash: String)
    
    public var label: String {
        switch self {
        case .local(let path): return "(Local) \(path.relative)"
        case .embedded(let path, _): return "(Embedded) \(path.relative)"
        }
    }
}



