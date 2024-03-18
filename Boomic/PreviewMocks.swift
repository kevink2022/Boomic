//
//  PreviewMocks.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import Foundation
import Models
import ModelsMocks
import Database
import DatabaseMocks

func previewDatabase() -> Database { GirlsApartmentDatabase() }
func previewSong() -> Song { Song.aCagedPersona }
func previewAlbum() -> Album { Album.girlsApartment }
func previewArtist() -> Artist { Artist.synth }

