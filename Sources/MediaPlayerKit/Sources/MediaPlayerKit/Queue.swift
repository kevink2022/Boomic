//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/9/24.
//

import Foundation
import Models

public protocol MediaQueueInterface {
    func toggleShuffled() -> Self
    
    var forwardRolloverWillOccur: Bool { get }
    var nextSong: Song { get }
    func next() -> Self
    
    var backwardRolloverWillOccur: Bool { get }
    var previousSong: Song { get }
    func previous() -> Self
    
    func advanceTo(forwardIndex: Int) -> Self
    
    func addNext(_ song: Song) -> Self
    func addToEnd(_ song: Song) -> Self
}

public protocol MediaQueue: MediaQueueInterface {
    //init(song: Song, context: [Song], queueOrder: MediaQueueOrder)
    
    var currentSong: Song { get }
    var queue: [Song] { get }
    var restOfQueue: [Song] { get }
    var queueOrder: MediaQueueOrder { get }
}

public enum MediaQueueOrder: CaseIterable {
    case inOrder
    case shuffle
}

public enum MediaQueueRepeat: CaseIterable {
    case noRepeat
    case repeatQueue
    case repeatSong
    case oneSong
}

private final class QueueObject: Identifiable, Equatable {
    public let id: UUID
    public let object: Song
    
    public init(object: Song) {
        self.id = UUID()
        self.object = object
    }
    
    public static func == (lhs: QueueObject, rhs: QueueObject) -> Bool {
        lhs.id == rhs.id
    }
}

public final class AMQueue: MediaQueue {
       
    public var currentSong: Song { currentObject.object }
    private let currentObject: QueueObject
    
    public var queue: [Song] { queueObjects.map { $0.object } }
    private let queueObjects: [QueueObject]
    private let queueIndex: Int
    public var restOfQueue: [Song] {
        guard queueIndex + 1 < queueObjects.count else { return [] }
        return Array(queue[(queueIndex + 1)...])
    }
    
    private let context: [QueueObject]
    private var contextIndex: Int { context.firstIndex(of: currentObject) ?? 0 }
    
    public let queueOrder: MediaQueueOrder
    
    // MARK: - Public
    
    public func toggleShuffled() -> AMQueue {
        switch (queueOrder) {
        case .inOrder: return self.shuffled()
        case .shuffle: return self.unshuffled()
        }
    }
    
    public var forwardRolloverWillOccur: Bool { queueIndex == self.queueObjects.endIndex - 1 }
    public var nextSong: Song { nextObject.object }
    private var nextObject: QueueObject { queueObjects[nextSongIndex] }
    public func next() -> AMQueue { AMQueue(currentQueue: self, currentObject: nextObject, queueIndex: nextSongIndex) }
    
    public var backwardRolloverWillOccur: Bool { queueIndex == 0 }
    public var previousSong: Song { previousObject.object }
    private var previousObject: QueueObject { queueObjects[previousSongIndex] }
    public func previous() -> AMQueue { AMQueue(currentQueue: self, currentObject: previousObject, queueIndex: previousSongIndex) }
    
    public func advanceTo(forwardIndex: Int) -> AMQueue {
        let newSongIndex = queueIndex + forwardIndex + 1
        guard newSongIndex < queueObjects.endIndex else { return self }
        let newSong = queueObjects[newSongIndex]
        return AMQueue(currentQueue: self, currentObject: newSong, queueIndex: newSongIndex)
    }
    
    public func addNext(_ song: Song) -> AMQueue {
        var queue = queueObjects
        var context = context
        let queueObject = QueueObject(object: song)
        
        queue.insert(queueObject, at: nextSongIndex)
        
        if queueOrder == .inOrder {
            context.insert(queueObject, at: nextSongIndex)
        } else {
            context.insert(queueObject, at: contextIndex + 1)
        }
        
        return AMQueue(currentQueue: self, queueObjects: queue, context: context)
    }
    
    public func addToEnd(_ song: Song) -> AMQueue {
        var queue = queueObjects
        var context = context
        let queueObject = QueueObject(object: song)
        
        queue.append(queueObject)
        
        if queueOrder == .inOrder {
            context.append(queueObject)
        } else {
            context.insert(queueObject, at: contextIndex + 1)
        }
        
        return AMQueue(currentQueue: self, queueObjects: queue, context: context)
    }
    
    // MARK: - Private
    
    private func shuffled() -> AMQueue {
        var context = context
        context.remove(at: contextIndex)
        
        let shuffledQueue = [currentObject] + context.shuffled()
        
        return AMQueue(currentQueue: self, queueObjects: shuffledQueue, queueIndex: 0, queueOrder: .shuffle)
    }
    
    private func unshuffled() -> AMQueue {
        return AMQueue(currentQueue: self, queueObjects: context, queueIndex: contextIndex, queueOrder: .inOrder)
    }
    
    private var nextSongIndex: Int {
        if forwardRolloverWillOccur { return 0 }
        else { return queueIndex + 1 }
    }
    
    private var previousSongIndex: Int {
        if backwardRolloverWillOccur { return queueObjects.endIndex - 1 }
        else { return queueIndex - 1 }
    }
    
    // MARK: - Inits
    
    private init(
        currentObject: QueueObject
        , queueObjects: [QueueObject]
        , queueIndex: Int
        , context: [QueueObject]
        , queueOrder: MediaQueueOrder
    ) {
        self.currentObject = currentObject
        self.queueObjects = queueObjects
        self.queueIndex = queueIndex
        self.context = context
        self.queueOrder = queueOrder
    }
    
    private convenience init(
        currentQueue: AMQueue
        , currentObject: QueueObject? = nil
        , queueObjects: [QueueObject]? = nil
        , queueIndex: Int? = nil
        , context: [QueueObject]? = nil
        , queueOrder: MediaQueueOrder? = nil
    ) {
        self.init(
            currentObject: currentObject ?? currentQueue.currentObject
            , queueObjects: queueObjects ?? currentQueue.queueObjects
            , queueIndex: queueIndex ?? currentQueue.queueIndex
            , context: context ?? currentQueue.context
            , queueOrder: queueOrder ?? currentQueue.queueOrder
        )
    }
    
    private convenience init(
        _ currentQueue: AMQueue
    ) {
        self.init(
            currentObject: currentQueue.currentObject
            , queueObjects: currentQueue.queueObjects
            , queueIndex: currentQueue.queueIndex
            , context: currentQueue.context
            , queueOrder: currentQueue.queueOrder
        )
    }
    
    public convenience init(
        song: Song
        , context: [Song]
        , queueOrder: MediaQueueOrder
    ) {
        let contextIndex = context.firstIndex(of: song) ?? 0
        let context = context.map { QueueObject(object: $0) }
        
        let inOrderQueue = AMQueue(
            currentObject: context[contextIndex]
            , queueObjects: context
            , queueIndex: contextIndex
            , context: context
            , queueOrder: .inOrder
        )
        
        if queueOrder == .shuffle { self.init(inOrderQueue.shuffled()) }
        else { self.init(inOrderQueue) }
    }
    
}
