//
//  Database.swift
//
//
//  Created by Kevin Kelly on 2/12/24.
//

import Foundation
import Models

public protocol Database {
    func getSongs(_ songIDs: [SongID]?) async throws -> [Song]
    func getAlbums(_ albumIDs: [AlbumID]?) async throws -> [Album]
    func getArtists(_ artistIDs: [ArtistID]?) async throws -> [Artist]
    
    func saveSongs(_ songsToSave: [Song]) async throws
    func saveAlbums(_ albumsToSave: [Album]) async throws
    func saveArtists(_ artistsToSave: [Artist]) async throws
}
