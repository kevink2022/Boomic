//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/27/24.
//

import Foundation

public final class SimpleStore<Model: Codable> {
    
    private let key: String
    private let cached: Bool
    private var cachedValue: Model?
    private let discInterface: DiscInterface<Model>
    
    public init(
        key: String
        , cached: Bool
        , namespace: String? = nil
        , inMemory: Bool = false
    ) {
        self.cachedValue = nil
        self.cached = cached
        self.key = key
        
        if inMemory {
            discInterface = MemoryDiscInterface<Model>(namespace: namespace)
        } else {
            discInterface = JSONDiscInterface<Model>(namespace: namespace)
        }
    }
    
    public func save(_ model: Model) async throws {
        try await discInterface.save(model, to: key)
        if cached { cachedValue = model }
    }
    
    public func load() async throws -> Model? {
        if let cachedValue = cachedValue { return cachedValue }
        return try await discInterface.load(from: key)
    }
    
    public func delete() async throws {
        try await discInterface.delete(key)
        if cached { cachedValue = nil }
    }
}
