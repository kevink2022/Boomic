//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/27/24.
//

import Foundation

public protocol Loggable: Codable, Identifiable {
    var id: UUID { get }
    var timestamp: Date { get }
}

public final class LogStore<Log: Loggable> {
    
    private let storage: SimpleStore<[Log]>
    
    public init(
        key: String
        , cached: Bool = false
        , namespace: String? = nil
        , inMemory: Bool = false
    ) {
        self.storage = SimpleStore(
            key: key
            , cached: cached
            , namespace: namespace
            , inMemory: inMemory
        )
    }
    
    public func save(_ log: Log) async throws {
        let pastLogs = try await storage.load()
        var logs = pastLogs ?? []
        logs.insert(log, at: 0)
        try await storage.save(logs)
    }
    
    public func load(last count: Int? = nil) async throws -> [Log] {
        guard let logs = try await storage.load() else { return [] }
        
        if let count = count {
            return Array(logs.prefix(count))
        }
        
        else { return logs }
    }
    
    public func load(from id: UUID) async throws -> [Log] {
        guard let logs = try await storage.load() else { return [] }
        
        guard let index = logs.firstIndex(where: { $0.id == id }) else { return [] }
        
        return Array(logs[0...index])
    }
    
    public func load(since timestamp: Date) async throws -> [Log] {
        guard let logs = try await storage.load() else { return [] }
        
        if let index = logs.firstIndex(where: { $0.timestamp < timestamp }) {
            return Array(logs[0..<index])
        } else {
            return logs
        }
    }
    
    public func delete(last count: Int? = nil) async throws {
        guard let logs = try await storage.load() else { return }
        
        if let count = count {
            if count >= logs.count-1 {
                try await storage.delete()
            } else {
                try await storage.save(Array(logs[count..<logs.count]))
            }
        }
        
        else { try await storage.delete() }
    }
    
    public func delete(from id: UUID) async throws {
        guard let logs = try await storage.load() else { return }
        
        guard let index = logs.firstIndex(where: { $0.id == id }) else { return }
        
        if index == logs.count-1 {
            try await storage.delete()
        } else {
            try await storage.save(Array(logs[index+1..<logs.count]))
        }
    }
    
    public func delete(since timestamp: Date) async throws {
        guard let logs = try await storage.load() else { return }
        
        guard let index = logs.firstIndex(where: { $0.timestamp < timestamp }) else { return }
        
        try await storage.save(Array(logs[index..<logs.count]))
    }
}
