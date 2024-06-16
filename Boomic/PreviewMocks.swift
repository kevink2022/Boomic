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
import Storage


internal class PreviewMocks {
    
    static let shared = PreviewMocks()
    
    private let sharedRepo = Repository(
        fileInterface: FileInterface(at: URL(string: "/Users/kevinkelly/Music/Stuff")!)
        , transactor: Transactor<LibraryTransaction, DataBasis>(
            basePost: DataBasis.empty
            , key: "transactor-preview"
            , inMemory: true
            , coreCommit: { transaction, basis in
                await BasisResolver(currentBasis: basis).apply(transaction: transaction)
            }
            , flatten: { transaction in
                LibraryTransaction.flatten(transaction)
            }
        )
    )
    
    init() {
        Task { await sharedRepo.importSongs() }
    }
    
    public func previewNavigator() -> Navigator { return Navigator() }
    
    public func previewPreferences() -> Preferences { return Preferences(inMemory: true) }

    // MARK: - Repositories
    public func previewRepository() -> Repository {
        return sharedRepo
    }

    public func livePreviewRepository() -> Repository {
        return sharedRepo
    }

    // MARK: - Players
    public func previewPlayer() -> SongPlayer { SongPlayer(repository: sharedRepo) }

    public func previewPlayerWithSong() -> SongPlayer {
        let player = SongPlayer()
        
        player.setSong(previewSong(), context: [PreviewMocks.shared.previewSong()], autoPlay: false)
        
        return player
    }


    // MARK: - Models
    public func previewSong() -> Song { Song.aCagedPersona }

    public func previewAlbum() -> Album { Album.girlsApartment }

    public func previewArtist() -> Artist { Artist.synth }

    public func previewArtists() -> [Artist] {
        return GirlsApartmentDatabase().getArtists(for: nil)
    }

}




