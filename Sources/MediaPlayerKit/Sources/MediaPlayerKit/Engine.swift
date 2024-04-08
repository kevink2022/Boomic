//
//  File.swift
//  
//
//  Created by Kevin Kelly on 3/31/24.
//

import Foundation
import AVFoundation
import Combine

public enum EngineStatus {
    case ready
    case idle
    case error
}

public final class AVEngine {
    
    private let player: AVPlayer
    public private(set) var source: URL?
    public private(set) var timePublisher = PassthroughSubject<CMTime, Never>()
    public private(set) var endOfSongPublisher = PassthroughSubject<Void, Never>()
    private var boundaryTimeObserverToken: Any?
    
    public init(
        player: AVPlayer = AVPlayer()
        , source: URL? = nil
        , timeObserverInterval: TimeInterval = 1
    ) {
        self.player = player
        self.source = source
        
        setupPeriodicTimeObserver(interval: timeObserverInterval)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
        }
    }
    
    public func setSource(_ source: URL) -> EngineStatus {
//        if let boundaryTimeObserverToken = boundaryTimeObserverToken {
//            player.removeTimeObserver(boundaryTimeObserverToken)
//            self.boundaryTimeObserverToken = nil
//        }
        
        let playerItem = AVPlayerItem(url: source)
        player.replaceCurrentItem(with: playerItem)
        
        
//        Task {
//            sleep(UInt32(0.2))
//            setupBoundaryTimeObserver(for: playerItem)
//        }
        
        return player.engineStatus
    }
    
    public func play() { player.play() }
    public func pause() { player.pause() }
    public func seek(to time: TimeInterval) {
        let time = CMTime(seconds: time, preferredTimescale: 600)
        let tolerance = CMTime(seconds: 0.1, preferredTimescale: 600)
        
        player.seek(to: time, toleranceBefore: tolerance, toleranceAfter: tolerance)
    }
    
    private func setupPeriodicTimeObserver(interval timeInterval: TimeInterval) {
        let interval = CMTime(seconds: timeInterval, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.timePublisher.send(time)
        }
    }
    
//    private func setupBoundaryTimeObserver(for playerItem: AVPlayerItem) {
//        guard CMTIME_IS_NUMERIC(playerItem.duration) && playerItem.duration != CMTime.indefinite else {
//            print("bad item \(playerItem.duration)")
//            return
//        }
//    
//        print("set new observer")
//
//        let songDuration = playerItem.duration
//        let boundary = CMTimeSubtract(songDuration, CMTimeMake(value: 1, timescale: 1))
//
//        // Add the new boundary time observer
//        boundaryTimeObserverToken = player.addBoundaryTimeObserver(forTimes: [NSValue(time: boundary)], queue: .main) { [weak self] in
//            self?.endOfSongPublisher.send()
//        }
//    }
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
