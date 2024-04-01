//
//  File.swift
//  
//
//  Created by Kevin Kelly on 3/31/24.
//

import Foundation
import AVFoundation

public enum EngineStatus {
    case ready
    case idle
    case error
}

public final class AVEngine {
    
    private let player: AVPlayer
    public private(set) var source: URL?
    
    public init(player: AVPlayer = AVPlayer(), source: URL? = nil) {
        self.player = player
        self.source = source
    }
    
    public func setSource(_ source: URL) -> EngineStatus {
        let playerItem = AVPlayerItem(url: source)
        player.replaceCurrentItem(with: playerItem)
        return player.engineStatus
    }
    
    public func play() { player.play() }
    public func pause() { player.pause() }
    public var isPlaying: Bool { player.isPlaying }
}


extension AVPlayer {
    internal var engineStatus: EngineStatus {
        switch self.status {
        case .readyToPlay: 
            return .ready
        case .failed: return .error
        case .unknown: return .idle
        @unknown default:
            return .error
        }
    }
    
    internal var isPlaying: Bool { self.rate != 0 }
}
