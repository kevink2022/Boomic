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
    case updateSong(update: SongUpdate)
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

public final class BoomicTransactor {
    
    private let storage: LogStore<LibraryTransaction>
    public let publisher = PassthroughSubject<DataBasis, Never>()
    
    public init(
        key: String = "transactions"
        , namespace: String? = nil
        , cached: Bool = true
        , inMemory: Bool = false
    ) {
        self.storage = LogStore(key: "transactions", cached: true, inMemory: false)
        
        Task { await initBasis() }
    }
    
    private func initBasis() async {
        let tranactions = try? await storage.load()
        
        guard let tranactions = tranactions else { return }
        
        var basis = DataBasis(songs: [], albums: [], artists: [])
        for tranaction in tranactions {
            switch tranaction.body {
            case .addSongs(songs: let songs):
                basis = await BasisResolver(currentBasis: basis).addSongs(songs)
            case .updateSong(update: let song):
                break
            }
        }
        
        publisher.send(basis)
    }
    
    private func commitTransaction(data: LibraryTransactionData, basisUpdate: @escaping () async -> DataBasis) async {
        let transaction = LibraryTransaction(data)
        let saveTask: Task<Void, Error>
        let resolverTask: Task<DataBasis, Never>
        
        do {
            saveTask = Task { try await storage.save(transaction) }
            
            resolverTask = Task { await basisUpdate() }
            
            try await saveTask.value
            let newBasis = await resolverTask.value
            publisher.send(newBasis)
        } catch {
            resolverTask.cancel()
        }
    }
    
    public func addSongs(_ songs: [Song], to basis: DataBasis) async {
        await commitTransaction(
            data: .addSongs(songs: songs)
            , basisUpdate: { await BasisResolver(currentBasis: basis).addSongs(songs) }
        )
    }
    
    public func updateSong(_ songUpdate: SongUpdate, on basis: DataBasis) async {
        await commitTransaction(
            data: .updateSong(update: songUpdate)
            , basisUpdate: { await BasisResolver(currentBasis: basis).updateSong(songUpdate) }
        )
    }
    
    public func deleteLibraryData() async {
        do {
            try await storage.delete()
            publisher.send(DataBasis.empty)
        } catch {
            
        }
    }
}

// MARK: - Viewing Transactions
extension BoomicTransactor {
    public func getTransactions(last count: Int? = nil) async -> [LibraryTransaction] {
        return (try? await storage.load(last: count)) ?? []
    }
}

extension LibraryTransactionData {
    public var decode: String {
        switch self {
        case .addSongs(songs: _): "Add Songs"
        case .updateSong(update: let songUpdate): "Update Song \(songUpdate.label)"
        }
    }
}
