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
    
    private var perodicTimeOberserToken: Any?
    private var boundaryTimeObserverToken: Any?
    
    public init(
        player: AVPlayer = AVPlayer()
        , source: URL? = nil
        , timeObserverInterval: TimeInterval = 1
    ) {
        self.player = player
        self.source = source
        
        setupPeriodicTimeObserver(interval: timeObserverInterval)
    }
    
    public func setSource(_ source: URL) -> EngineStatus {
        removeBoundaryTimeObserver()
        let playerItem = AVPlayerItem(url: source)
        player.replaceCurrentItem(with: playerItem)
        
        Task { setupBoundaryTimeObserver(for: playerItem) }
        
        return player.engineStatus
    }
    
    public func play() { player.play() }
    public func pause() { player.pause() }
    public func seek(to time: TimeInterval) {
        let time = CMTime(seconds: time, preferredTimescale: 600)
        let tolerance = CMTime.zero // CMTime(seconds: 0.1, preferredTimescale: 600)
        
        player.seek(to: time, toleranceBefore: tolerance, toleranceAfter: tolerance)
    }
    
    private func setupPeriodicTimeObserver(interval timeInterval: TimeInterval) {
        let interval = CMTime(seconds: 0.2, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        perodicTimeOberserToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.timePublisher.send(time)
        }
    }
    
    private func setupBoundaryTimeObserver(for playerItem: AVPlayerItem) {
        var itemStatusObserver: NSKeyValueObservation? = nil
        
        itemStatusObserver = playerItem.observe(\.status, options: [.new, .initial]) { [weak self, weak playerItem] playerItem, _ in
            guard let self = self else { return }
            
            guard playerItem.status == .readyToPlay, CMTIME_IS_NUMERIC(playerItem.duration) && playerItem.duration != CMTime.indefinite else {
                return
            }
            
            let songDuration = playerItem.duration
            let boundary = CMTimeSubtract(songDuration, CMTimeMake(value: 10, timescale: 1000))

            boundaryTimeObserverToken = player.addBoundaryTimeObserver(forTimes: [NSValue(time: boundary)], queue: .main) { [weak self] in
                self?.endOfSongPublisher.send()
            }
            
            itemStatusObserver?.invalidate()
        }
    }
    
    deinit {
        removePeriodicTimeObserver()
        removeBoundaryTimeObserver()
    }
    
    private func removePeriodicTimeObserver() {
        guard perodicTimeOberserToken != nil else { return }
        
        player.removeTimeObserver(perodicTimeOberserToken!)
        perodicTimeOberserToken = nil
    }
    
    private func removeBoundaryTimeObserver() {
        guard boundaryTimeObserverToken != nil else { return }
        
        player.removeTimeObserver(boundaryTimeObserverToken!)
        boundaryTimeObserverToken = nil
    }
    
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
