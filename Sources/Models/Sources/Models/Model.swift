//
//  Model.swift
//
//
//  Created by Kevin Kelly on 2/28/24.
//

import Foundation

public protocol Model: Identifiable, Codable, Equatable {
    var id: UUID { get }
}

public protocol Relational: Model {
    func to<T:Relational>(_ object: T) throws -> [UUID]
}

public enum ModelError: LocalizedError, Equatable {
    case unresolvedModel(Any.Type)
    case unresolvedRelation(Any.Type, Any.Type)
    
    public var errorDescription: String? {
        switch self {
        case .unresolvedModel(let type): return "Type \"\(type)\" has no associated table."
        case .unresolvedRelation(let from, let to): return "Type \"\(from)\" does not map to type \"\(to)\"."
        }
    }
    
    public static func == (lhs: ModelError, rhs: ModelError) -> Bool {
        switch (lhs, rhs) {
        case (.unresolvedModel(let lhsType), .unresolvedModel(let rhsType)):
            return String(describing: lhsType) == String(describing: rhsType)
        case (.unresolvedRelation(let lhsFrom, let lhsTo), .unresolvedRelation(let rhsFrom, let rhsTo)):
            return String(describing: lhsFrom) == String(describing: rhsFrom) && String(describing: lhsTo) == String(describing: rhsTo)
        default:
            return false
        }
    }
}






