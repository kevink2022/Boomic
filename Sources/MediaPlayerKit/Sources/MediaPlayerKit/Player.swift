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
public final class SongPlayer {
    
    public private(set) var song: Song?
    public var fullscreen: Bool
    private var engine: AVEngine
    private var engineStatus: EngineStatus
    
    public init(
        song: Song? = nil
        , engine: AVEngine = AVEngine()
    ) {
        self.song = nil
        self.engine = engine
        self.engineStatus = .idle
        self.fullscreen = false
    }
    
    public func setSong(_ song: Song, autoPlay: Bool = true) {
        self.song = song

        engineStatus = {
            switch (song.source) {
            case .local(let url): return engine.setSource(url)
            }
        }()

        guard engineStatus != .error else { return }
        
        if autoPlay { engine.play() }
    }
    
    public func togglePlayPause() {
        guard engineStatus != .error else { return }
        if engine.isPlaying { engine.pause() }
        else { engine.play() }
    }
    
    public var isPlaying: Bool { engine.isPlaying }

}
