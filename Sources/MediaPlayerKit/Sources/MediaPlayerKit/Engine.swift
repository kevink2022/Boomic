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
    
    public let source: URL?
    private let player: AVPlayer
    
    public private(set) var timePublisher = PassthroughSubject<CMTime, Never>()
    public private(set) var endOfSongPublisher = PassthroughSubject<Void, Never>()
    
    private var periodicTimeOberserToken: Any?
    private var boundaryTimeObserverToken: Any?

    public var status: EngineStatus { player.engineStatus }
    public var isPlaying: Bool { player.isPlaying }
    
    public init(
        player: AVPlayer = AVPlayer()
        , source: URL
        , timeObserverInterval: TimeInterval = 0.2
        , endOfSongInterval: TimeInterval = 0.01
    ) {
        self.player = player
        self.source = source
        
        let assetOptions = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let asset = AVURLAsset(url: source, options: assetOptions)
        let playerItem = AVPlayerItem(asset: asset)
        
        self.player.replaceCurrentItem(with: playerItem)
        
        setupPeriodicTimeObserver(interval: timeObserverInterval)
        Task { setupBoundaryTimeObserver(for: playerItem, interval: endOfSongInterval) }
    }
    
    public func play() { player.play() }
    public func pause() { player.pause() }
    public func seek(to time: TimeInterval) {
        let time = CMTime(seconds: time, preferredTimescale: 600)
        let tolerance = CMTime.zero // CMTime(seconds: 0.1, preferredTimescale: 600)
        
        player.seek(to: time, toleranceBefore: tolerance, toleranceAfter: tolerance)
    }
    
    private func setupPeriodicTimeObserver(interval timeInterval: TimeInterval) {
        let interval = CMTime(seconds: timeInterval, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        periodicTimeOberserToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.timePublisher.send(time)
        }
    }
    
    private func setupBoundaryTimeObserver(for playerItem: AVPlayerItem, interval timeInterval: TimeInterval) {
        var itemStatusObserver: NSKeyValueObservation? = nil
        
        itemStatusObserver = playerItem.observe(\.status, options: [.new, .initial]) { [weak self, weak playerItem] _, _ in
            guard let self = self, let playerItem = playerItem else { return }
            
            guard playerItem.status == .readyToPlay, CMTIME_IS_NUMERIC(playerItem.duration) && playerItem.duration != CMTime.indefinite else {
                return
            }
            
            let songDuration = playerItem.duration
            let boundary = CMTimeSubtract(songDuration, CMTimeMake(value: Int64(timeInterval*1000), timescale: 1000))

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
        guard periodicTimeOberserToken != nil else { return }
        
        player.removeTimeObserver(periodicTimeOberserToken!)
        periodicTimeOberserToken = nil
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
        case .readyToPlay: return .ready
        case .failed: return .error
        case .unknown: return .idle
        @unknown default: return .error
        }
    }
    
    internal var isPlaying: Bool { self.rate != 0 }
}
