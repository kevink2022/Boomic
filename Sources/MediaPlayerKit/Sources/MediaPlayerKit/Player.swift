//
//  File.swift
//  
//
//  Created by Kevin Kelly on 3/31/24.
//

import Foundation
import Observation
import Models

@Observable
public final class SongPlayer: MediaQueueInterface {
    
    public private(set) var song: Song?
    public private(set) var queue: MediaQueue?
    public private(set) var queueOrder: MediaQueueOrder
    public private(set) var repeatState: MediaQueueRepeat
    public private(set) var art: MediaArt?
    public private(set) var isPlaying: Bool

    public var fullscreen: Bool
    
    private var engine: AVEngine
    private var engineStatus: EngineStatus
    
    public init(
        engine: AVEngine = AVEngine()
    ) {
        self.song = nil
        self.queue = nil
        self.engine = engine
        self.engineStatus = .idle
        self.fullscreen = false
        self.queueOrder = .inOrder
        self.repeatState = .noRepeat
        self.isPlaying = false
    }
    
    public func setSong(_ song: Song, context: [Song]? = nil, autoPlay: Bool = true) {
        self.song = song
        self.art = song.art

        engineStatus = {
            switch (song.source) {
            case .local(let url): return engine.setSource(url)
            }
        }()
        
        guard engineStatus != .error else { return }
        
        if autoPlay { play() }
        
        guard let context = context else { return }
        
        queue = AMQueue(song: song, context: context, queueOrder: queueOrder)
    }
    
    public func togglePlayPause() {
        guard engineStatus != .error else { return }
        
        if engine.isPlaying { pause() }
        else { play() }
    }
    
    public func toggleRepeatState() {
        
    }
    
    public func toggleShuffle() { 
        guard let queue = queue else { return }
        queue.toggleShuffle()
        queueOrder = queueOrder == .inOrder ? .shuffle : .inOrder
    }
    
    public func next() {
        guard let queue = queue else { return }
        queue.next()
        setSong(queue.currentSong)
    }
    
    public func previous() {
        guard let queue = queue else { return }
        queue.previous()
        setSong(queue.currentSong)
    }
    
    public func addNext(_ song: Song) { queue?.addNext(song) }
    public func addToEnd(_ song: Song) { queue?.addToEnd(song) }
    
    private func play() {
        engine.play()
        isPlaying = true
    }
    
    private func pause() {
        engine.pause()
        isPlaying = false
    }
}
