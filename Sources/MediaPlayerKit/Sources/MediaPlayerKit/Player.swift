//
//  File.swift
//  
//
//  Created by Kevin Kelly on 3/31/24.
//

import Foundation
import Observation
import Models
import Combine
import MediaPlayer

@Observable
public final class SongPlayer {
    
    public private(set) var song: Song?
    public private(set) var queue: MediaQueue?
    public private(set) var queueOrder: MediaQueueOrder
    public private(set) var repeatState: MediaQueueRepeat
    public private(set) var art: MediaArt?
    public private(set) var isPlaying: Bool
    public private(set) var time: TimeInterval
    
    public var fullscreen: Bool
    
    private var engine: AVEngine? { didSet { setupTimeSubscribers() } }
    private var engineStatus: EngineStatus
    private var cancellables: Set<AnyCancellable> = []
    
    public init() {
        self.song = nil
        self.queue = nil
        self.engine = nil
        self.engineStatus = .idle
        self.fullscreen = false
        self.queueOrder = .inOrder
        self.repeatState = .noRepeat
        self.isPlaying = false
        self.time = 0
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
        }
        setupRemoteTransportControls()
        
        setupTimeSubscribers()
    }
    
    // MARK: - Media Controls
    
    public func setSong(_ song: Song, context: [Song]? = nil, autoPlay: Bool = true) {
        self.song = song
        self.art = song.art

        engine = {
            switch (song.source) {
            case .local(let url): AVEngine(source: url)
            }
        }()
        
        guard let engine = engine, engine.status != .error else { return }
        
        updateNowPlayingInfo(for: song)
        if autoPlay { play() }
        
        if let context = context {
            queue = AMQueue(song: song, context: context, queueOrder: queueOrder)
        }
    }
    
    public func togglePlayPause() {
        guard engineStatus != .error else { return }
        
        if isPlaying { pause() }
        else { play() }
    }
    
    public func seek(to time: TimeInterval) { engine?.seek(to: time) }
    
    public func toggleRepeatState() {
        
    }
    
    public func toggleShuffle() { 
        queue = queue?.toggleShuffled()
        queueOrder = queue?.queueOrder ?? .inOrder
    }
    
    public func next() {
        queue = queue?.next()
        if let song = queue?.currentSong { setSong(song) }
    }
    
    public func previous() {
        queue = queue?.previous()
        if let song = queue?.currentSong { setSong(song) }
    }
    
    public func addNext(_ song: Song) { queue = queue?.addNext(song) }
    public func addToEnd(_ song: Song) { queue = queue?.addToEnd(song) }
    
    private func play() {
        engine?.play()
        isPlaying = engine?.isPlaying ?? false
    }
    
    private func pause() {
        engine?.pause()
        isPlaying = engine?.isPlaying ?? false
    }
    
    // MARK: - Subscriptions
    
    private func setupTimeSubscribers() {
        cancellables.removeAll()
        guard let engine = engine else { return }
        
        engine.timePublisher
            .sink(receiveValue: { [weak self] time in
                self?.time = time.seconds
                self?.updatePlaybackTime()
            })
            .store(in: &cancellables)
              
        engine.endOfSongPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.next()
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Control Center

    private func updateNowPlayingInfo(for song: Song) {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = song.label
        info[MPMediaItemPropertyArtist] = song.artistName
        info[MPMediaItemPropertyAlbumTitle] = song.albumTitle
        info[MPMediaItemPropertyPlaybackDuration] = song.duration
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.pause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            self?.next()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            self?.previous()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            
            guard let playbackEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            
            self?.seek(to: playbackEvent.positionTime)
            return .success
        }
    }
    
    private func updatePlaybackTime() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

}

