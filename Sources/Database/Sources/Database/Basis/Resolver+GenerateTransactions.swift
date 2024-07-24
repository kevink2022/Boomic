//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/19/24.
//

import Foundation
import Domain
import Models

extension BasisResolver {
    
    // MARK: - Albums
    public func updateAlbums(_ updates: Set<AlbumUpdate>) async -> LibraryTransaction {
        guard updates.count > 0 else { return .empty }
        
        let label = {
            if updates.count == 1, let update = updates.first, let album = currentBasis.albumMap[update.id] {
                return "Update Album: \(album.title)"
            } else {
                return "Update \(updates.count) Albums"
            }
        }()
        
        var albumUpdateAssertions = KeySet<Assertion>()
        var songUpdateAssertions = KeySet<Assertion>()
        
        updates.forEach { update in
            guard let album = currentBasis.albumMap[update.id] else { return }
            
            albumUpdateAssertions.insert(Assertion(update))
            
            if update.newTitle != nil {
                album.songs.forEach {
                    guard let song = currentBasis.songMap[$0] else { return }
                    
                    let songUpdate = SongUpdate(song: song, albumTitle: update.newTitle)
                    songUpdateAssertions.insert(Assertion(songUpdate))
                }
            }
        }
        
        guard albumUpdateAssertions.count > 0 else { return .empty }
        
        if songUpdateAssertions.count == 0 {
            return albumUpdateAssertions.asTransaction(label: label, level: .normal)
        } else {
            let updateBasis = await self.apply(transaction: albumUpdateAssertions.asTransaction())
            let linkAssertions = await BasisResolver(currentBasis: updateBasis).updateLinks(songUpdateAssertions)
            let finalAssertions = Assertion.flatten([albumUpdateAssertions, linkAssertions])
            return finalAssertions.asTransaction(label: label, level: .significant)
        }
    }
    
    public func deleteAlbums(_ albums: Set<Album>) async -> LibraryTransaction {
        guard albums.count > 0 else { return .empty }
        
        let label = {
            if albums.count == 1
                , let album = albums.first
                , currentBasis.albumMap[album.id] != nil
            {
                return "Delete Album: \(album.title)"
            } else {
                return "Delete \(albums.count) Albums"
            }
        }()
        
        var assertions = KeySet<Assertion>()
        
        albums.forEach { album in
            guard let album = currentBasis.albumMap[album.id] else { return }
            
            album.songs
                .compactMap { currentBasis.songMap[$0] }
                .forEach { assertions.insert(Assertion(DeleteAssertion($0))) }
        }
        
        assertions = await updateLinks(assertions)
        return assertions.asTransaction(label: label, level: .significant)
    }
    
    // MARK: - Artists
    public func updateArtists(_ updates: Set<ArtistUpdate>) async -> LibraryTransaction {
        guard updates.count > 0 else { return .empty }
        
        let label = {
            if updates.count == 1, let update = updates.first, let artist = currentBasis.artistMap[update.id] {
                return "Update Artists: \(artist.name)"
            } else {
                return "Update \(updates.count) Artists"
            }
        }()
        
        var artistUpdateAssertions = KeySet<Assertion>()
        var songUpdateAssertions = KeySet<Assertion>()
        
        updates.forEach { update in
            guard let artist = currentBasis.artistMap[update.id] else { return }
            
            artistUpdateAssertions.insert(Assertion(update))
            
            if update.newName != nil {
                artist.songs.forEach {
                    guard let song = currentBasis.songMap[$0] else { return }
                    
                    let songUpdate = SongUpdate(song: song, artistName: update.newName)
                    songUpdateAssertions.insert(Assertion(songUpdate))
                }
            }
        }
        
        guard artistUpdateAssertions.count > 0 else { return .empty }
        
        if songUpdateAssertions.count == 0 {
            return artistUpdateAssertions.asTransaction(label: label, level: .normal)
        } else {
            let updateBasis = await self.apply(transaction: artistUpdateAssertions.asTransaction())
            let linkAssertions = await BasisResolver(currentBasis: updateBasis).updateLinks(songUpdateAssertions)
            let finalAssertions = Assertion.flatten([artistUpdateAssertions, linkAssertions])
            return finalAssertions.asTransaction(label: label, level: .significant)
        }
    }
    
    public func deleteArtists(_ artists: Set<Artist>) async -> LibraryTransaction {
        guard artists.count > 0 else { return .empty }
        
        let label = {
            if artists.count == 1, let artist = artists.first, currentBasis.artistMap[artist.id] != nil {
                return "Delete Artist: \(artist.name)"
            } else {
                return "Delete \(artists.count) Artist"
            }
        }()
        
        var assertions = KeySet<Assertion>()
        
        artists.forEach { artist in
            guard let artist = currentBasis.artistMap[artist.id] else { return }
            
            artist.songs
                .compactMap { currentBasis.songMap[$0] }
                .forEach { assertions.insert(Assertion(DeleteAssertion($0))) }
        }
        
        assertions = await updateLinks(assertions)
        return assertions.asTransaction(label: label, level: .significant)
    }
    
    // MARK: - Songs
    public func updateSongs(_ updates: Set<SongUpdate>) async -> LibraryTransaction {
        guard updates.count > 0 else { return .empty }
        
        let label = {
            if updates.count == 1, let update = updates.first, let song = currentBasis.songMap[update.id] {
                return "Update Song: \(song.label)"
            } else {
                return "Update \(updates.count) Songs"
            }
        }()
        
        var noLinkAssertions = KeySet<Assertion>()
        var linkAssertions = KeySet<Assertion>()
        
        updates.forEach { update in
            guard let song = currentBasis.songMap[update.id] else { return }
            
            if update.artistName != nil || update.albumTitle != nil {
                linkAssertions.insert(Assertion(update))
            } else {
                noLinkAssertions.insert(Assertion(update))
            }
        }
        
        if linkAssertions.count > 0 {
            linkAssertions = await updateLinks(linkAssertions)
            let finalAssertions = Assertion.flatten([noLinkAssertions, linkAssertions])
            return finalAssertions.asTransaction(label: label, level: .significant)
        } else {
            return noLinkAssertions.asTransaction(label: label, level: .normal)
        }
    }
    
    public func deleteSongs(_ songs: Set<Song>) async -> LibraryTransaction {
        guard songs.count > 0 else { return .empty }
        
        let label = {
            if songs.count == 1, let song = songs.first, currentBasis.songMap[song.id] != nil {
                return "Delete Song: \(song.label)"
            } else {
                return "Delete \(songs.count) Songs"
            }
        }()
        
        var assertions = KeySet<Assertion>()
        songs.forEach { song in
            guard let song = currentBasis.songMap[song.id] else { return }
            
            assertions.insert(Assertion(DeleteAssertion(song)))
        }
        
        assertions = await updateLinks(assertions)
        return assertions.asTransaction(label: label, level: .significant)
    }
    
    public func addSongs(_ unlinkedSongs: [Song]) async -> LibraryTransaction {
        guard unlinkedSongs.count > 0 else { return .empty }
        
        var assertions = KeySet<Assertion>()
        unlinkedSongs.forEach{ assertions.insert(Assertion($0)) }
        
        assertions = await updateLinks(assertions)
        return assertions.asTransaction(label: "Import Songs: \(unlinkedSongs.count) songs", level: .significant)
    }
    
    // MARK: - Taglists
    public func addTaglists(_ lists: [Taglist]) async -> LibraryTransaction {
        guard lists.count > 0 else { return .empty }
        
        let label = {
            if lists.count == 1, let list = lists.first {
                return "Add Taglist: \(list.label)"
            } else {
                return "Add \(lists.count) Taglists"
            }
        }()
        
        var assertions = KeySet<Assertion>()
        lists.forEach{ assertions.insert(Assertion($0)) }
        
        return assertions.asTransaction(label: label, level: .normal)
    }
    
    public func updateTaglists(_ updates: [TaglistUpdate]) async -> LibraryTransaction {
        guard updates.count > 0 else { return .empty }
        
        let label = {
            if updates.count == 1, let update = updates.first, let list = currentBasis.taglistMap[update.id] {
                return "Update Taglist: \(list.label)"
            } else {
                return "Update \(updates.count) Taglists"
            }
        }()
        
        var assertions = KeySet<Assertion>()
        
        
        updates.forEach { update in
            guard let list = currentBasis.taglistMap[update.id] else { return }
            assertions.insert(Assertion(update))
        }
        
        return assertions.asTransaction(label: label, level: .normal)
    }
    
    public func deleteTaglists(_ lists: [Taglist]) async -> LibraryTransaction {
        guard lists.count > 0 else { return .empty }
        
        let label = {
            if lists.count == 1, let list = lists.first, currentBasis.taglistMap[list.id] != nil {
                return "Delete Taglist: \(list.label)"
            } else {
                return "Delete \(lists.count) Songs"
            }
        }()
        
        var assertions = KeySet<Assertion>()
        lists.forEach { list in
            guard let list = currentBasis.taglistMap[list.id] else { return }
            
            assertions.insert(Assertion(DeleteAssertion(list)))
        }
        
        return assertions.asTransaction(label: label, level: .normal)
    }
}
