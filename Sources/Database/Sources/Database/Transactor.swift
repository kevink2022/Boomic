//
//  File.swift
//  
//
//  Created by Kevin Kelly on 5/18/24.
//

import Foundation
import Combine
import AsyncAlgorithms

import Storage

public final class DataTransaction<Data: Codable>: Loggable {
    public let id: UUID
    public let timestamp: Date
    public let data: Data
    
    public init(
        _ body: Data
        , id: UUID = UUID()
        , timestamp: Date = Date.now
    ) {
        self.id = id
        self.timestamp = timestamp
        self.data = body
    }
}

public final class Transactor<TransactionData: Codable, Post> {
    
    private let storage: LogStore<DataTransaction<TransactionData>>
    private let coreCommit: (TransactionData, Post) async -> (Post)
    private let queue: AsyncChannel<() async -> ()>
    private var base: Post
    public let publisher: CurrentValueSubject<Post, Never>
    
    public init (
        basePost: Post
        , key: String = "transactions-generic"
        , inMemory: Bool = false
        , coreCommit: @escaping (TransactionData, Post) async -> (Post)
    ) {
        self.storage = LogStore<DataTransaction<TransactionData>>(key: key, inMemory: inMemory)
        self.publisher = CurrentValueSubject<Post, Never>(basePost)
        self.coreCommit = coreCommit
        self.queue = AsyncChannel<() async -> ()>()
        self.base = basePost
        
        Task {
            if let tranactions = try? await storage.load() {
                await build(from: basePost, with: tranactions.map{ $0.data })
            }
            await monitorQueue()
        }
    }
    
    private func build(from base: Post, with data: [TransactionData]) async {
        var post = base
        for transaction in data {
            post = (await coreCommit(transaction, post))
        }
        publisher.send(post)
    }
    
    private func commitAndSave(transaction data: TransactionData) async {
        let saveTask: Task<Void, Error>
        let commitTask: Task<Post, Never>
        
        do {
            saveTask = Task { try await storage.save(DataTransaction(data)) }
            commitTask = Task { await coreCommit(data, publisher.value) }
            
            try await saveTask.value
            let newPost = await commitTask.value
            publisher.send(newPost)
        } catch {
            commitTask.cancel()
        }
    }
    
    private func monitorQueue() async {
        for await transaction in queue {
            await transaction()
        }
    }
    
    public func commit(transaction data: TransactionData) async {
        await queue.send {
            await self.commitAndSave(transaction: data)
        }
    }
    
    public func commit(generateTransaction: @escaping (Post) async -> (TransactionData)) async {
        await queue.send {
            let transaction = await generateTransaction(self.publisher.value)
            await self.commitAndSave(transaction: transaction)
        }
    }
    
    public func viewTransactions(last count: Int? = nil) async -> [DataTransaction<TransactionData>] {

        return (try? await storage.load(last: count)) ?? []
    }
    
    public func viewTransactions(since timestamp: Date) async -> [DataTransaction<TransactionData>] {

        return (try? await storage.load(since: timestamp)) ?? []
    }
    
    public func rollbackTo(after transaction: DataTransaction<TransactionData>) async {
        await queue.send { [self] in
            try? await storage.delete(after: transaction.id)
            if let transactions = try? await storage.load() {
                await build(from: base, with: transactions.map{$0.data})
            }
        }
    }
    
    public func rollbackTo(before transaction: DataTransaction<TransactionData>) async {
        await queue.send { [self] in
            try? await storage.delete(including: transaction.id)
            if let transactions = try? await storage.load() {
                await build(from: base, with: transactions.map{$0.data})
            }
        }
    }
}



