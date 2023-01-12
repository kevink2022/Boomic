//
//  InitMethods.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/4/22.
//

import Foundation
import AVFoundation
import MediaPlayer

extension BoomicManager
{
    /// Connect songs, albums, artists, by reference to allow them to be easilty navigated between
    // TODO: Hashing
    func mapLibrary()
    {
        library.songs.forEach
        {
            song in
            
            if let artistName = song.artistName
            {
                if let artist = library.artists.first(where: {$0.name == artistName})
                {
                    artist.addSong(song)
                }
                else
                {
                    let artist = Artist(name: artistName)
                    artist.addSong(song)
                    library.artists.append(artist)
                }
            }
            
            if let albumTitle = song.albumTitle
            {
                if let album = library.albums.first(where: {$0.title == albumTitle})
                {
                    album.addSong(song)
                }
                else
                {
                    let album = Album(title: albumTitle)
                    album.addSong(song)
                    library.albums.append(album)
                }
            }
        }
        
        /// Sorted alphabetically
        library.songs.sort(by: { $0.titleLabel < $1.titleLabel } )
        library.artists.sort(by: { $0.name < $1.name } )
        library.albums.sort(by: { $0.title < $1.title} )
        
        /// Sort albums by track number:
        ///     - First tracks have track numbers and are sorted that way
        ///     - Rest are sorted alphabetically
        library.albums.forEach { album in
            album.songs.sort(by: { song1, song2 in
                if let trackNo1 = song1.trackNo
                {
                    if let trackNo2 = song2.trackNo
                    {
                        return trackNo1 < trackNo2
                    }
                    else
                    {
                        return true // song1 before song2
                    }
                }
                else if let _ = song2.trackNo
                {
                    return false // song2 before song1
                }
                else
                {
                    return song1.titleLabel < song2.titleLabel // alphabetical
                }
            })
        }
        /// Here is openai's chatbot version
//        library.albums.forEach { album in
//            album.songs.sort(by: { song1, song2 in
//                return (song1.trackNo ?? 0) < (song2.trackNo ?? 0) ||
//                    (song1.trackNo == nil && song2.trackNo == nil && song1.titleLabel < song2.titleLabel)
//            })
//        }
    }
    
    // MARK: - inits
    static func initAudioSession() -> Bool
    {
        let audioSession = AVAudioSession.sharedInstance()
        
        do
        {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        }
        catch
        {
            print("ERROR: Audio Session error")
            return false
        }
        return true
    }
    
    func initCommandCenter() -> Bool
    {
        commandCenter.togglePlayPauseCommand.addTarget
        {
            [unowned self] event in
            
            if let _ = currentSong { togglePlayback() }
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget
        {
            [unowned self] event in
            
            if let _ = currentSong { toNextSong() }
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget
        {
            [unowned self] event in
            
            if let _ = currentSong { toLastSong() }
            return .success
        }
        
        // TODO: Fix this
        // Source: https://stackoverflow.com/questions/34321071/how-can-i-make-the-control-center-slider-editable
        commandCenter.changePlaybackPositionCommand.addTarget
        {
            [unowned self] event in
                  
            if let _ = currentSong
            {
                guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
                
                print(event.positionTime)
                
                player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            }
            return .success
        }
        
        return true
    }
}
