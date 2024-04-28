//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/23/24.
//

import Foundation

public class DiscInterface<Model: Codable> {
    
    func save(_ model: Model, to key: String) async throws {
        throw DiscInterfaceError.mustOverride
    }
    func load(from key: String) async throws -> Model? {
        throw DiscInterfaceError.mustOverride
    }
    func delete(_ key: String) async throws {
        throw DiscInterfaceError.mustOverride
    }
}

public enum DiscInterfaceError: LocalizedError {
    case mustOverride
    
    public var errorDescription: String? {
        switch self {
        case .mustOverride: "This function must be overridden to be used."
        }
    }
}
