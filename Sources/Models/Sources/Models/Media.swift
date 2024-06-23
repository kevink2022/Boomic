//
//  Media.swift
//  Boomic
//
//  Created by Kevin Kelly on 2/7/24.
//

import Foundation
import Domain

public protocol Model: Identifiable, Codable, Equatable, Hashable {
    var label: String { get }
    var art: MediaArt? { get }
}

extension Model {
    public static func alphabeticalSort(_ modelA: any Model, _ modelB: any Model) -> Bool {
        modelA.label.compare(modelB.label, options: .caseInsensitive) == .orderedAscending
    }
}

public protocol Update: Identifiable, Codable, Hashable {
    var label: String { get }
}

public protocol Media: Codable, Identifiable {
    var id: UUID { get }
    var source: MediaSource { get }
}

public enum MediaSource: Codable, Equatable, Hashable {
    case local(path: AppPath)
    
    public var label: String {
        switch self {
        case .local(let path): return "(Local) \(path.relative)"
        }
    }
}

public enum MediaArt: Codable, Equatable, Hashable {
    case local(path: AppPath)
    case embedded(path: AppPath, hash: String)
    
    public var label: String {
        switch self {
        case .local(let path): return "(Local) \(path.relative)"
        case .embedded(let path, _): return "(Embedded) \(path.relative)"
        }
    }
}



