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
    func peekNext() -> Song
    func next() -> Self
    
    var backwardRolloverWillOccur: Bool { get }
    func peekPrevious() -> Song
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

public final class AMQueue : MediaQueue {
       
    public let currentSong: Song
    
    public let queue: [Song]
    private let queueIndex: Int
    public var restOfQueue: [Song] {
        guard queueIndex + 1 < queue.count else { return [] }
        return Array(queue[(queueIndex + 1)...])
    }
    
    private let context: [Song]
    private var contextIndex: Int { context.firstIndex(of: currentSong) ?? 0 }
    
    public let queueOrder: MediaQueueOrder
    
    // MARK: - Public
    
    public func toggleShuffled() -> AMQueue {
        switch (queueOrder) {
        case .inOrder: return self.shuffled()
        case .shuffle: return self.unshuffled()
        }
    }
    
    public var forwardRolloverWillOccur: Bool { queueIndex == self.queue.endIndex - 1 }
    public func peekNext() -> Song { return queue[nextSongIndex] }
    public func next() -> AMQueue { AMQueue(currentQueue: self, currentSong: peekNext(), queueIndex: nextSongIndex) }
    
    public var backwardRolloverWillOccur: Bool { queueIndex == 0 }
    public func peekPrevious() -> Song { queue[previousSongIndex] }
    public func previous() -> AMQueue { AMQueue(currentQueue: self, currentSong: peekPrevious(), queueIndex: previousSongIndex) }
    
    public func advanceTo(forwardIndex: Int) -> AMQueue {
        let newSongIndex = queueIndex + forwardIndex + 1
        guard newSongIndex < queue.endIndex else { return self }
        let newSong = queue[newSongIndex]
        return AMQueue(currentQueue: self, currentSong: newSong, queueIndex: newSongIndex)
    }
    
    public func addNext(_ song: Song) -> AMQueue {
        var queue = queue
        var context = context
        
        queue.insert(song, at: nextSongIndex)
        
        if queueOrder == .inOrder {
            context.insert(song, at: nextSongIndex)
        } else {
            context.insert(song, at: contextIndex + 1)
        }
        
        return AMQueue(currentQueue: self, queue: queue, context: context)
    }
    
    public func addToEnd(_ song: Song) -> AMQueue {
        var queue = queue
        var context = context
        
        queue.append(song)
        
        if queueOrder == .inOrder {
            context.append(song)
        } else {
            context.insert(song, at: contextIndex + 1)
        }
        
        return AMQueue(currentQueue: self, queue: queue, context: context)
    }
    
    // MARK: - Private
    
    private func shuffled() -> AMQueue {
        var context = context
        context.remove(at: contextIndex)
        
        let shuffledQueue = [currentSong] + context.shuffled()
        
        return AMQueue(currentQueue: self, queue: shuffledQueue, queueIndex: 0, queueOrder: .shuffle)
    }
    
    private func unshuffled() -> AMQueue {
        return AMQueue(currentQueue: self, queue: context, queueIndex: contextIndex, queueOrder: .inOrder)
    }
    
    private var nextSongIndex: Int {
        if forwardRolloverWillOccur { return 0 }
        else { return queueIndex + 1 }
    }
    
    private var previousSongIndex: Int {
        if backwardRolloverWillOccur { return queue.endIndex - 1 }
        else { return queueIndex - 1 }
    }
    
    // MARK: - Inits
    
    private init(
        currentSong: Song
        , queue: [Song]
        , queueIndex: Int
        , context: [Song]
        , queueOrder: MediaQueueOrder
    ) {
        self.currentSong = currentSong
        self.queue = queue
        self.queueIndex = queueIndex
        self.context = context
        self.queueOrder = queueOrder
    }
    
    private convenience init(
        currentQueue: AMQueue
        , currentSong: Song? = nil
        , queue: [Song]? = nil
        , queueIndex: Int? = nil
        , context: [Song]? = nil
        , queueOrder: MediaQueueOrder? = nil
    ) {
        self.init(
            currentSong: currentSong ?? currentQueue.currentSong
            , queue: queue ?? currentQueue.queue
            , queueIndex: queueIndex ?? currentQueue.queueIndex
            , context: context ?? currentQueue.context
            , queueOrder: queueOrder ?? currentQueue.queueOrder
        )
    }
    
    private convenience init(
        _ currentQueue: AMQueue
    ) {
        self.init(
            currentSong: currentQueue.currentSong
            , queue: currentQueue.queue
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
        
        let inOrderQueue = AMQueue(
            currentSong: song
            , queue: context
            , queueIndex: contextIndex
            , context: context
            , queueOrder: .inOrder
        )
        
        if queueOrder == .shuffle { self.init(inOrderQueue.shuffled()) }
        else { self.init(inOrderQueue) }
    }
    
}
