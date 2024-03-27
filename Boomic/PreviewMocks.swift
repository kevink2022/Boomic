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
import Repository

func previewRepository() -> Repository { RepositoryImpl(database: GirlsApartmentDatabase() )}

func previewSong() -> Song { Song.aCagedPersona }

func previewAlbum() -> Album { Album.girlsApartment }

func previewArtist() -> Artist { Artist.synth }

func previewArtists() -> [Artist] {
    return GirlsApartmentDatabase().getArtists(for: nil)
}

