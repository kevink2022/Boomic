//
//  Database.swift
//
//
//  Created by Kevin Kelly on 2/12/24.
//

import Foundation
import Models

public protocol Database {
    func get<Getting: Model> (_ getting: Getting.Type) async throws -> [Getting]
    func get<Getting: Model, From: Model> (_ getting: Getting.Type, from object: From) async throws -> [Getting]
    func save<T: Model>(_ objects: [T]) async throws
}

public enum DatabaseError: LocalizedError, Equatable {
    case dataCorrupted(URL)
    case unresolvedTable(Any.Type)
    case unresolvedRelation(Any.Type, Any.Type)
    
    public var errorDescription: String? {
        switch self {
        case .dataCorrupted(let url): return "Data cannot be read from \(url)"
        case .unresolvedTable(let type): return "Type \"\(type)\" has no associated table."
        case .unresolvedRelation(let from, let to): return "Type \"\(from)\" does not map to type \"\(to)\"."
        }
    }
    
    public static func == (lhs: DatabaseError, rhs: DatabaseError) -> Bool {
        switch (lhs, rhs) {
            case (.dataCorrupted(let lhsURL), .dataCorrupted(let rhsURL)):
                return lhsURL == rhsURL
            case (.unresolvedTable(let lhsType), .unresolvedTable(let rhsType)):
                return String(describing: lhsType) == String(describing: rhsType)
            case (.unresolvedRelation(let lhsFrom, let lhsTo), .unresolvedRelation(let rhsFrom, let rhsTo)):
                return String(describing: lhsFrom) == String(describing: rhsFrom) && String(describing: lhsTo) == String(describing: rhsTo)
            default:
                return false
            }
    }
}

public protocol Model: Identifiable, Codable {
    var id: UUID { get }
}

extension Song: Model {}
extension Album: Model {}
extension Artist: Model {}

/// Will likely become db implementation specific. So much for saving boilerplate lol.

internal protocol RelationalModel: Model {
    func to<T:RelationalModel>(_ object: T) throws -> [UUID]
}

extension Song: RelationalModel {
    
    internal func to<T:RelationalModel>(_ object: T) throws -> [UUID] {
        switch T.self {
        
        case is Album.Type:
            guard let album = self.album else { return [UUID]() }
            return [album]
        
        case is Artist.Type:
            return self.artists
        
        default: throw DatabaseError.unresolvedRelation(Song.self, T.self)
        }
    }
}

extension Album: RelationalModel {
    
    internal func to<T:RelationalModel>(_ object: T) throws -> [UUID] {
        switch T.self {
        
        case is Song.Type:
            return self.songs
        
        case is Artist.Type: 
            return self.artists
        
        default: throw DatabaseError.unresolvedRelation(Album.self, T.self)
        }
    }
}

extension Artist: RelationalModel {
    
    internal func to<T:RelationalModel>(_ object: T) throws -> [UUID] {
        switch T.self {
        
        case is Song.Type:
            return self.songs
        
        case is Album.Type:
            return self.albums
        
        default: throw DatabaseError.unresolvedRelation(Artist.self, T.self)
        }
    }
}

