//
//  MediaControls.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/4/22.
//

import Foundation
import AVFoundation

// MARK: - Playback State
extension BoomicManager
{
    /// If a song's file is moved or deleted, then promt user and don't allow playback
    var songExists : Bool { player.currentItem != nil }
    var isPlaying : Bool { player.rate != 0 }
    
    var currentSong : Song?
    {
        if let index = currentSongIndex {
            return queue[index]
        } else {
            return nil
        }
    }
    
    var songProgress : Double
    {
        get
        {
            let curr = player.currentTime()
            
            if let dur = player.currentItem?.duration
            {
                let progress = CMTimeGetSeconds(curr) / CMTimeGetSeconds(dur)
                if progress >= 1 { onSongEnd() }
                return progress
            }
            else { return 0 }
        }
        set
        {
            if let dur = player.currentItem?.duration
            {
                let seekTo = CMTime(seconds: newValue * CMTimeGetSeconds(dur), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                player.seek(to: seekTo)
            }
        }
    }
    
    var volume : Double
    {
        get { Double(player.volume) }
        set { player.volume = Float(newValue) }
    }
}

// MARK: - Playback Controls
extension BoomicManager
{
    func togglePlayback() { isPlaying ? pause() : play() }
    func play() { player.play(); objectWillChange.send() }
    func pause() { player.pause(); objectWillChange.send() }
}

// MARK: - Next and Last Songs
extension BoomicManager
{
    var nextSongIndex : Int?
    {
        if let index = currentSongIndex
        {
            if index + 1 == queue.count
            {
                return 0
            }
            else
            {
                return index + 1
            }
        }
        else { return nil }
    }
    
    var nextSong : Song?
    {
        if let index = nextSongIndex
        {
            return queue[index]
        }
        else { return nil }
    }
    
    func toNextSong()
    {
//        if currentSongIndex! + 1 == queue.count
//        {
//            currentSongIndex! = 0
//        }
//        else
//        {
//            currentSongIndex! += 1
//        }
        
        if let index = nextSongIndex
        {
            currentSongIndex = index
            
            if index == 0 && repeatState != .repeatQueue
            { startNewSong(paused: true) }
            else
            { startNewSong(paused: !isPlaying) }
        }
    }
    
    var lastSongIndex : Int?
    {
        if let index = currentSongIndex
        {
            if index == 0
            {
                return repeatState == .repeatQueue ? queue.count - 1 : 0
            }
            else
            {
                return index - 1
            }
        }
        else { return nil }
    }
    
    var lastSong : Song?
    {
        if let index = lastSongIndex
        {
            return queue[index]
        }
        else { return nil }
    }
    
    func toLastSong()
    {
        // TODO: Implement restarting song
//        if currentSongIndex! == 0
//        {
//
//        }
//        else
//        {
//            currentSongIndex! -= 1
//        }
        
        if let index = lastSongIndex
        {
            currentSongIndex = index
            startNewSong(paused: !isPlaying)
        }
        
    }
}

// MARK: - Changing Songs
extension BoomicManager
{
    func onSongEnd()
    {
        if repeatState == .singleSong || repeatState == .repeatSong
        {
            startNewSong(paused: repeatState == .singleSong ? true : false)
        }
        else if currentSongIndex! + 1 == queue.count
        {
            currentSongIndex! = 0
            startNewSong(paused: repeatState == .dontRepeat ? true : false)
        }
        else
        {
            currentSongIndex! += 1
            startNewSong()
        }
    }
    
    func queueSelectSong(index: Int)
    {
        currentSongIndex = index
        startNewSong(paused: !isPlaying)
    }
    
    func selectSong(queue newQueue: [Song], queueIndex: Int)
    {
        inlineQueue = newQueue
        
        queue = inlineQueue
        currentSongIndex = queueIndex
        
        if shuffleState == .shuffle { shuffleQueue() }
        startNewSong()
    }
    
    /// Create the player instance and prepare system for playback
    func startNewSong(paused: Bool = false)
    {
        if let song = currentSong
        {
            print(song.source)
            player.replaceCurrentItem(with: AVPlayerItem(url: song.source))
            setupNowPlaying()
            addPeriodicTimeObserver()
            songProgress = 0.0
            audioLevelSamples = [Float](repeating: 0.0, count: Int(ceil(song.duration ?? 50.0)))
            if !paused { play() }
            Task { await setAudioLevels() }
        }
    }
    
    /// Source: https://developer.apple.com/documentation/avfoundation/media_playback/observing_the_playback_time
    /// The only thing that really need constant updates are the time slider (and eventhually an audio visuslizer,
    /// so timers will be added to those specific objects
    func addPeriodicTimeObserver()
    {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.05, preferredTimescale: timeScale)

        player.addPeriodicTimeObserver(forInterval: time, queue: .main)
        {
            [weak self] time in
            // update player transport UI
            self!.objectWillChange.send()
        }
    }
}

//MARK: - Shuffling and Repeat
extension BoomicManager
{
    enum Shuffle
    {
        case inOrder, shuffle
    }
    
    func toggleShuffle()
    {
        switch shuffleState
        {
        case .inOrder : shuffleState = .shuffle; shuffleQueue()
        case .shuffle : shuffleState = .inOrder; unshuffleQueue()
        }
    }
    
    func shuffleQueue()
    {
        if let index = currentSongIndex
        {
            var oldQueue = inlineQueue
            let song = oldQueue.remove(at: index)
            let newQueue = [song] + oldQueue.shuffled()
            queue = newQueue
            currentSongIndex = 0
        }
    }
    
    func unshuffleQueue()
    {
        if let _ = currentSongIndex
        {
            let inlineIndex = inlineQueue.firstIndex(where: {$0.id == currentSong!.id})
    
            queue = inlineQueue
            currentSongIndex = inlineIndex
        }
    }
    
    enum Repeat
    {
        case dontRepeat     // Pause music at the end of the queue
        case repeatQueue    // Loop back to beginning of queue
        case repeatSong     // Play single song on repeat
        case singleSong     // Pause at the end of a song, returning to beginning of song
    }
    
    func toggleRepeat()
    {
        switch repeatState
        {
        case .dontRepeat : repeatState = .repeatQueue
        case .repeatQueue: repeatState = .repeatSong
        case .repeatSong : repeatState = .singleSong
        case .singleSong : repeatState = .dontRepeat
        }
    }
}
