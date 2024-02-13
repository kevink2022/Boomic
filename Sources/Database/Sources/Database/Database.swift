//
//  Database.swift
//
//
//  Created by Kevin Kelly on 2/12/24.
//

import Foundation
import Models

public protocol Database {
    func getSongs(_ songs: [SongID]?) async throws -> [Song]
    func getAlbums(_ albums: [AlbumID]?) async throws -> [Album]
    func getArtists(_ artists: [ArtistID]?) async throws -> [Artist]
    
    func saveSongs(_ songs: [Song]) async throws
    func saveAlbums(_ albums: [Album]) async throws
    func saveArtists(_ artists: [Artist]) async throws
}
