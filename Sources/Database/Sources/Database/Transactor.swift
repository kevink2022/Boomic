//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/23/24.
//

import Foundation
import Combine

import Models
import Storage


public enum LibraryTransactionData: Codable {
    case addSongs(songs: [Song])
}

public final class LibraryTransaction: Loggable {
    public let id: UUID
    public let timestamp: Date
    public let body: LibraryTransactionData
    
    init(
        _ body: LibraryTransactionData
        , id: UUID = UUID()
        , timestamp: Date = Date.now
    ) {
        self.id = id
        self.timestamp = timestamp
        self.body = body
    }
}

public final class Transactor {
    
    private let storage: LogStore<LibraryTransaction>
    public let publisher = PassthroughSubject<DataBasis, Never>()
    
    public init() {
        self.storage = LogStore(key: "transactions", cached: true, inMemory: true)
    }
    
    public func addSongs(_ songs: [Song], to basis: DataBasis) async {
        let resolver = BasisResolver(currentBasis: basis)
        let transaction = LibraryTransaction(.addSongs(songs: songs))
        
        let saveTask: Task<Void, Error>
        let resolverTask: Task<DataBasis, Never>
        
        do {
            saveTask = Task {
                try await storage.save(transaction)
            }
            
            resolverTask = Task {
                await resolver.addSongs(songs)
            }
            
            try await saveTask.value
            let newBasis = await resolverTask.value
            publisher.send(newBasis)
       } catch {
            resolverTask.cancel()
        }
    }
}
