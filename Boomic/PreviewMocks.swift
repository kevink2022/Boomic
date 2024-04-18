//
//  PreviewMocks.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import Foundation
import Models
import ModelsMocks
import DatabaseMocks
import Database
import MediaFileKit
import Repository
import MediaPlayerKit


// MARK: - Repositories
func previewRepository() -> Repository { RepositoryImpl(database: GirlsApartmentDatabase() )}

func livePreviewRepository() -> Repository {
    
    let liveLibraryDirectory = URL(string: "/Users/kevinkelly/Music/Stuff")!
    
    let repo = RepositoryImpl(
        database: CacheDatabase()
        , localFileInterface: LocalMediaFileInterface(libraryDirectory: liveLibraryDirectory)
    )
    
    return repo
}

// MARK: - Players
func previewPlayer() -> SongPlayer { SongPlayer() }

func previewPlayerWithSong() -> SongPlayer {
    let player = SongPlayer()
    
    player.setSong(previewSong(), context: [previewSong()], autoPlay: false)
    
    return player
}


// MARK: - Models
func previewSong() -> Song { Song.aCagedPersona }

func previewAlbum() -> Album { Album.girlsApartment }

func previewArtist() -> Artist { Artist.synth }

func previewArtists() -> [Artist] {
    return GirlsApartmentDatabase().getArtists(for: nil)
}



