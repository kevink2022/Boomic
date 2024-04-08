import Foundation
import Models

public protocol MediaQueueInterface {
    func toggleShuffle()
    func next()
    func previous()
    func addNext(_ song: Song)
    func addToEnd(_ song: Song)
}

public protocol MediaQueue: MediaQueueInterface {
    init(song: Song, context: [Song], queueOrder: MediaQueueOrder)
    
    var currentSong: Song { get }
    var queue: [Song] { get }
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

public final class AMQueue: MediaQueue {
    
    public private(set) var currentSong: Song
    public private(set) var queue: [Song]
    public private(set) var queueOrder: MediaQueueOrder
    
    private var context: [Song]
    
    public init(
        song: Song
        , context: [Song]
        , queueOrder: MediaQueueOrder
    ) {
        self.currentSong = song
        self.context = context
        self.queue = context
        self.queueOrder = queueOrder
        
        if queueOrder == .shuffle { shuffle() }
    }
    
    private func shuffle() {
        guard let currentSongIndex = context.firstIndex(of: currentSong) else { return }
        
        var contextWithoutCurrentSong = context
        contextWithoutCurrentSong.remove(at: currentSongIndex)
        
        queue = [currentSong] + contextWithoutCurrentSong.shuffled()
        queueOrder = .shuffle
    }
    
    private func unshuffle() {
        queue = context
        queueOrder = .inOrder
    }
    
    private var queueSongIndex: Int? { queue.firstIndex(of: currentSong) }
    private var contextSongIndex: Int? { context.firstIndex(of: currentSong) }
    
    public var backwardRolloverWillOccur: Bool {
        true
    }
    
    public func toggleShuffle() {
        switch (queueOrder) {
        case .inOrder: shuffle()
        case .shuffle: unshuffle()
        }
    }
    
    public func next() {
        guard let currentSongIndex = self.queueSongIndex else { return }
        
        let nextSongIndex = {
            if currentSongIndex == self.queue.endIndex - 1 { return 0 }
            else { return currentSongIndex + 1 }
        }()
        
        currentSong = queue[nextSongIndex]
    }
    
    public func previous() {
        guard let currentSongIndex = self.queueSongIndex else { return }
        
        let nextSongIndex = {
            if currentSongIndex == 0 { return queue.endIndex - 1 }
            else { return currentSongIndex - 1 }
        }()
        
        currentSong = queue[nextSongIndex]
    }
    
    public func addNext(_ song: Song) {
        guard let currentSongIndex = self.queueSongIndex else { return }
        queue.insert(song, at: currentSongIndex + 1)
        
        if queueOrder == .inOrder {
            context.insert(song, at: currentSongIndex + 1)
        } else {
            guard let contextSongIndex = context.firstIndex(of: currentSong) else { return }
            context.insert(song, at: contextSongIndex + 1)
        }
    }
    
    public func addToEnd(_ song: Song) {
        queue.append(song)
        
        if queueOrder == .inOrder {
            context.append(song)
        } else {
            guard let contextSongIndex = context.firstIndex(of: currentSong) else { return }
            context.insert(song, at: contextSongIndex + 1)
        }
    }
}
