//
//  Database.swift
//
//
//  Created by Kevin Kelly on 2/12/24.
//

import Foundation
import Models

public protocol Database {
    func getSongs(for ids: [UUID]?) async -> [Song]
    func getAlbums(for ids: [UUID]?) async -> [Album]
    func getArtists(for ids: [UUID]?) async -> [Artist]
    
    func addSongs(_ songs: [Song]) async
}

public enum DatabaseError: LocalizedError, Equatable {
    case dataCorrupted(URL)
    case unresolvedModel(Any.Type)
    case unresolvedRelation(Any.Type, Any.Type)
    
    public var errorDescription: String? {
        switch self {
        case .dataCorrupted(let url): return "Data cannot be read from \(url)"
        case .unresolvedModel(let type): return "Type \"\(type)\" has no associated table."
        case .unresolvedRelation(let from, let to): return "Type \"\(from)\" does not map to type \"\(to)\"."
        }
    }
    
    public static func == (lhs: DatabaseError, rhs: DatabaseError) -> Bool {
        switch (lhs, rhs) {
            case (.dataCorrupted(let lhsURL), .dataCorrupted(let rhsURL)):
                return lhsURL == rhsURL
            case (.unresolvedModel(let lhsType), .unresolvedModel(let rhsType)):
                return String(describing: lhsType) == String(describing: rhsType)
            case (.unresolvedRelation(let lhsFrom, let lhsTo), .unresolvedRelation(let rhsFrom, let rhsTo)):
                return String(describing: lhsFrom) == String(describing: rhsFrom) && String(describing: lhsTo) == String(describing: rhsTo)
            default:
                return false
            }
    }
}


