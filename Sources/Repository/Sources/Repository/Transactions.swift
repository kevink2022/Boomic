//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/23/24.
//

import Foundation
import Models
import Database

extension Repository {
    public func importSongs() async {
        statusKeys.insert(.importSongs)
        
        status = RepositoryStatus(key: .importSongs, message: "Gathering existing files.")
        let existingFiles = basis.allSongs.compactMap { song in
            if case .local(let path) = song.source { return path }
            return nil
        }
        
        status = RepositoryStatus(key: .importSongs, message: "Searching for new files.")
        guard let newFiles = try? fileInterface.allFiles(of: Song.codecs, excluding: Set(existingFiles)) else { return }
        
        status = RepositoryStatus(key: .importSongs, message: "Scanning Metadata for \(newFiles.count) new songs.")
        let newSongs = newFiles.map { Song(from: $0) }
        
        status = RepositoryStatus(key: .importSongs, message: "Adding \(newSongs.count) new songs to library.")
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).addSongs(newSongs)
        }
        
        statusKeys.remove(.importSongs)
    }
    
    public func updateSongs(_ songUpdate: Set<SongUpdate>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateSongs(songUpdate)
        }
    }
    
    public func deleteSongs(_ song: Set<Song>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteSongs(song)
        }
    }
    
    public func updateAlbums(_ albumUpdate: Set<AlbumUpdate>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateAlbums(albumUpdate)
        }
    }
    
    public func deleteAlbums(_ album: Set<Album>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteAlbums(album)
        }
    }
    
    public func updateArtists(_ artistUpdate: Set<ArtistUpdate>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateArtists(artistUpdate)
        }
    }
    
    public func deleteArtists(_ artist: Set<Artist>) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteArtists(artist)
        }
    }
    
    public func addTaglists(_ lists: [Taglist]) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).addTaglists(lists)
        }
    }
    
    public func updateTaglists(_ updates: [TaglistUpdate]) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).updateTaglists(updates)
        }
    }
    
    public func deleteTaglists(_ lists: [Taglist]) async {
        await transactor.commit { basis in
            return await BasisResolver(currentBasis: basis).deleteTaglists(lists)
        }
    }
}
