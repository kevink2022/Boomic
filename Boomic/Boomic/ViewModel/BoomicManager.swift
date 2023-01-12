//
//  BoomicManager.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/2/22.
//

import Foundation
import AVFoundation
import MediaPlayer

class BoomicManager : ObservableObject
{
    // MARK: - Model Objects
    @Published var library : BoomicLibrary
    
    // MARK: - Audio Engine Objects
    @Published var player : AVPlayer
    var commandCenter : MPRemoteCommandCenter
    
    // MARK: - Playback State
    @Published var queue : [Song] = []
    var inlineQueue : [Song] = []
    @Published var currentSongIndex : Int? = nil
    @Published var shuffleState : Shuffle = .inOrder
    @Published var repeatState : Repeat = .dontRepeat
    
    // MARK: - View State
    @Published var showCurrentSongSheet : Bool = false
    @Published var showQueueSheet : Bool = false
    @Published var audioLevelSamples : [Float] = []
    
    // MARK: - File Management
    let storage : StorageManager<BoomicLibrary>

    init()
    {
        let _ = BoomicManager.initAudioSession()
        
        player = AVPlayer()
        library = BoomicLibrary(
            songs: [],
            albums: [],
            artists: [],
            playlists: [],
            settings: BoomicSettings(
                songGUI: .classic,
                classicTimeSlider: .classic,
                albumCover: .notGestured
            )
        )
        storage = StorageManager<BoomicLibrary>(fileName: "library")
        
        commandCenter = MPRemoteCommandCenter.shared()
        let _ = initCommandCenter()
        
        let initStartTime = CFAbsoluteTimeGetCurrent()
        
        if let library = storage.modelData
        {
            self.library = library
        }
        else
        {
            BoomicManager.createReadMe()
            library.songs = BoomicManager.scanForSongs()
        }
        
        mapLibrary()
        
        let initTime = CFAbsoluteTimeGetCurrent() - initStartTime
        print("@@@@@ Time elapsed for INIT: \(initTime)s. @@@@@")
                    
        Task { await getAlbumArtwork() }
    }
}
