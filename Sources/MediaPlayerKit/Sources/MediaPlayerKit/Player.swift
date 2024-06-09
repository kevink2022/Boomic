//
//  File.swift
//  
//
//  Created by Kevin Kelly on 3/31/24.
//

import Foundation
import Observation
import Combine
import MediaPlayer

import Models
import Repository
import Database

@Observable
public final class SongPlayer {
    
    // data
    public var song: Song? { songQuery.songs.first ?? baseSong }
    public private(set) var queue: MediaQueue?
    public private(set) var art: MediaArt?
    private var baseSong: Song? {
        didSet {
            if let song = baseSong {
                songQuery = Query.forSong(song)
                repository.addQuery(songQuery)
            }
        }
    }
    private var songQuery: Query
    public var songDuration: TimeInterval { engine?.duration ?? song?.duration ?? 0 }
    
    // behavioral state
    public private(set) var queueOrder: MediaQueueOrder // not derived from the queue itself?
    public private(set) var repeatState: MediaQueueRepeat
    public private(set) var isPlaying: Bool
    private var isPaused: Bool { !(engine?.isPlaying ?? true) }
    public private(set) var time: TimeInterval { didSet { updatePlaybackTime() } }
    private var engineStatus: EngineStatus

    // view state
    public var queueView: Bool = false
    
    // components
    private var engine: AVEngine? { didSet { setupTimeSubscribers() } }
    private let repository: Repository
    private var cancellables: Set<AnyCancellable> = []
       
    public init(
        repository: Repository = Repository(inMemory: true)
    ) {
        //self.song = nil
        self.baseSong = nil
        self.songQuery = Query()
        self.queue = nil
        self.engine = nil
        self.engineStatus = .idle
        self.queueOrder = .inOrder
        self.repeatState = .noRepeat
        self.isPlaying = false
        self.time = 0
        self.repository = repository
        
#if !os(macOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
        }
#endif
        
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
            self.repeatState != .repeatQueue && self.queue?.backwardRolloverWillOccur ?? false
        }
        
        if time > 2 || alwaysReset() { resetSong() }
        else { goToPreviousSong() }
    }
    
    public func addNext(_ song: Song) { queue = queue?.addNext(song) }
    public func addToEnd(_ song: Song) { queue = queue?.addToEnd(song) }
    
    public func swap(_ forwardIndexA: Int, with forwardIndexB: Int) {
        queue = queue?.swap(forwardIndexA, with: forwardIndexB)
    }
    public func remove(forwardIndex: Int) {
        queue = queue?.remove(forwardIndex: forwardIndex)
    }
    
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
    
    public func setSong(_ song: Song, context: [Song], queueName: String = "Queue", autoPlay: Bool = true) {
        setSong(song, autoPlay: autoPlay)
        queue = AMQueue(song: song, context: context, queueOrder: queueOrder, name: queueName)
    }
    
    public func setSong(_ song: Song, forwardQueueIndex: Int, autoPlay: Bool = true) {
        setSong(song, autoPlay: autoPlay)
        queue = queue?.advanceTo(forwardIndex: forwardQueueIndex)
    }
}

// MARK: - Events
// Events called by different triggers.
extension SongPlayer {
    
    private func setSong(_ song: Song, autoPlay: Bool = true) {
        self.baseSong = song
        self.art = song.art
        
        engine = {
            switch (song.source) {
            case .local(let path): AVEngine(source: path.url)
            }
        }()
        
        guard let engine = engine, engine.status != .error else { return }
        
        updateNowPlayingInfo(for: song)
        time = 0
        if autoPlay { play() }
        else { pause() }
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
        let autoPlay = !isPaused
        
        queue = queue?.previous()
        if let song = queue?.currentSong { setSong(song, autoPlay: autoPlay) }
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
        
        if let art = song.art { Task { await updateNowPlayingArt(with: art) } }
    }
    
    private func updateNowPlayingArt(with art: MediaArt) async {
        guard let platformImage = await repository.artLoader.loadPlatformImage(for: art) else { return }
        
        let mpArt = MPMediaItemArtwork(boundsSize: platformImage.size) { size in
            return platformImage
        }
        
        DispatchQueue.main.async {
            guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
            info[MPMediaItemPropertyArtwork] = mpArt
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
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

