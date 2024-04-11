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
    public private(set) var time: TimeInterval { didSet { updatePlaybackTime() } }
    
    public var fullscreen: Bool
    
    private var engine: AVEngine? { didSet { setupTimeSubscribers() } }
    private var engineStatus: EngineStatus
    private var cancellables: Set<AnyCancellable> = []
    
    private var isPaused: Bool { !(engine?.isPlaying ?? true) }
    
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
}

// MARK: - Triggers
// Something that happens that causes system events. Event can be executed locally.
extension SongPlayer {
    
    public func togglePlayPause() {
        guard engineStatus != .error else { return }
        
        if isPlaying { pause() }
        else { play() }
    }
    
    public func toggleRepeatState() {
        let states = MediaQueueRepeat.allCases
        let currentStateIndex = states.firstIndex(of: repeatState) ?? 0
        let nextStateIndex = {
            if currentStateIndex == states.endIndex - 1 { return 0 }
            else { return currentStateIndex + 1 }
        }()
        repeatState = states[nextStateIndex]
    }
    
    public func toggleShuffle() {
        queue = queue?.toggleShuffled()
        queueOrder = queue?.queueOrder ?? .inOrder
    }
    
    public func seek(to time: TimeInterval) { engine?.seek(to: time) }
    
    public func next() { goToNextSong() }
    
    public func previous() {
        let alwaysReset = {
            self.repeatState != .repeatQueue && self.queue?.backwardRolloverWillOccur ?? true
        }
        
        if time > 2 || alwaysReset() { resetSong() }
        else { goToPreviousSong() }
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
    
    private func endOfSong() {
        switch repeatState {
        case .noRepeat: goToNextSong()
        case .repeatQueue: goToNextSong()
        case .repeatSong: resetSong(pause: false)
        case .oneSong: resetSong(pause: true)
        }
    }
}

// MARK: - Events
// Events called by different triggers.
extension SongPlayer {
    
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
        time = 0
        if autoPlay { play() }
        else { pause() }
        
        if let context = context {
            queue = AMQueue(song: song, context: context, queueOrder: queueOrder)
        }
    }
    
    private func resetSong(pause: Bool? = nil) {
        if pause == true { self.pause() }
        seek(to: 0)
    }
    
    private func goToNextSong() {
        let pauseForRollover = repeatState != .repeatQueue && queue?.forwardRolloverWillOccur ?? true
        let autoPlay = !(isPaused || pauseForRollover)
        
        queue = queue?.next()
        if let song = queue?.currentSong { setSong(song, autoPlay: autoPlay) }
    }
    
    private func goToPreviousSong() {
        queue = queue?.previous()
        if let song = queue?.currentSong { setSong(song, autoPlay: isPaused) }
    }
}

// MARK: - Subscriptions
extension SongPlayer {
    private func setupTimeSubscribers() {
        cancellables.removeAll()
        guard let engine = engine else { return }
        
        engine.timePublisher
            .sink(receiveValue: { [weak self] time in
                self?.time = time.seconds
            })
            .store(in: &cancellables)
        
        engine.endOfSongPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.endOfSong()
            })
            .store(in: &cancellables)
    }
}

// MARK: - Control Center
extension SongPlayer {
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

