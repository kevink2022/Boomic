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
    internal func updateLinks(_ songAssertions: KeySet<Assertion>) async -> KeySet<Assertion> {
        let songs = songAssertions.filter { $0.model == .song }
        
        async let albumTitleLinks_await = songsToTitleLinks(songs)
        async let artistNameLinks_await = songsToNameLinks(songs)
        
        let (albumTitleLinks, artistNameLinks) = await (albumTitleLinks_await, artistNameLinks_await)
        
        let songLinkingAssertions = linkNewSongs(songs, albumTitles: albumTitleLinks, artistNames: artistNameLinks)
        let songLinksAppliedAssertions = Assertion.flatten([songAssertions, songLinkingAssertions])
        
        async let linkedAlbums_await = linkNewAlbums(albumTitleLinks, songLinkTransaction: songLinksAppliedAssertions)
        async let linkedArtists_await = linkNewArtists(artistNameLinks, songLinkTransaction: songLinksAppliedAssertions)
        
        let (
            (existingAlbumsAssertions, newAlbumsAssertions)
            , (existingArtistsAssertions, newArtistsAssertions)
        ) = await (linkedAlbums_await, linkedArtists_await)
        
        let buildDetailsBaseAssertion = Assertion.flatten([existingAlbumsAssertions, existingArtistsAssertions])
        let newLinksAssertions = Assertion.flatten([songAssertions, songLinkingAssertions, newAlbumsAssertions, newArtistsAssertions])
        let linkedUnorganizedAssertions = Assertion.flatten([buildDetailsBaseAssertion, newLinksAssertions])
        
        let linkedUnorganizedBasis = await self.apply(transaction: linkedUnorganizedAssertions.asTransaction(), to: DataBasis.empty)
        
        async let newSongs_await = songsResolveDetails(linkedUnorganizedBasis)
        async let newAlbums_await = albumsResolveDetails(linkedUnorganizedBasis)
        async let newArtists_await = artistsResolveDetails(linkedUnorganizedBasis)
        
        let (songDetailsTransaction, albumDetailsTransaction, artistDetailsTransaction) = await (newSongs_await, newAlbums_await, newArtists_await)
        
        let resolveDetailsAssertions = Assertion.flatten([songDetailsTransaction, albumDetailsTransaction, artistDetailsTransaction])
        let finalAssertions = Assertion.flatten([newLinksAssertions, resolveDetailsAssertions])
        
        return finalAssertions.filter { $0.willModify(currentBasis) }
    }
    
    // MARK: - String Maps
    private func songsToTitleLinks(_ songAssertions: KeySet<Assertion>) -> [String:UUID] {
        var affectedAlbums = [String:UUID]()
        
         songAssertions.forEach { assertion in
             guard let albumTitles = {
                 switch assertion.operation {
                 case .add:
                     guard let song = assertion.data as? Song else { break }
                     if let title = song.albumTitle { return Set([title]) }
                 
                 case .update:
                     guard let update = assertion.data as? SongUpdate else { break }
                     let songTitle = currentBasis.songMap[update.id]?.albumTitle
                     let updateTitle = update.albumTitle
                     return Set([songTitle, updateTitle].compactMap{ $0 })
                     
                /* we need the deletes titles so they will be relinked. */
                 case .delete:
                     guard let delete = assertion.data as? DeleteAssertion else { break }
                     if let title = currentBasis.songMap[delete.id]?.albumTitle { return Set([title]) }
                    
                 }
                 return nil
            }() else { return }
             
            albumTitles.forEach { title in
                parseAlbums(title).forEach { title in
                    if let albumID = currentAlbumTitles[title] {
                        affectedAlbums[title] = albumID
                    } else {
                        affectedAlbums[title] = UUID()
                    }
                }
            }
        }
        
        return affectedAlbums
    }
    
    private func songsToNameLinks(_ songAssertions: KeySet<Assertion>) -> [String:UUID] {
        var affectedArtists = [String:UUID]()
        
        songAssertions.forEach { assertion in
             guard let artistNames = {
                 switch assertion.operation {
                 case .add:
                     guard let song = assertion.data as? Song else { break }
                     if let name = song.artistName { return Set([name]) }
                 
                 case .update:
                     guard let update = assertion.data as? SongUpdate else { break }
                     let songTitle = currentBasis.songMap[update.id]?.artistName
                     let updateTitle = update.artistName
                     return Set([songTitle, updateTitle].compactMap{ $0 })
                     
                /* we need the delete titles so they will be relinked. */
                 case .delete:
                     guard let delete = assertion.data as? DeleteAssertion else { break }
                     if let name = currentBasis.songMap[delete.id]?.artistName { return Set([name]) }
                    
                 }
                 return nil
            }() else { return }
            
            artistNames.forEach { name in
                parseArtists(name).forEach { name in
                    if let artistID = currentArtistNames[name] {
                        affectedArtists[name] = artistID
                    } else {
                        affectedArtists[name] = UUID()
                    }
                }
            }
        }
        
        return affectedArtists
    }
    
    private func songFromAssertion(_ assertion: Assertion, excludeDelete: Bool = false) -> Song? {
        guard assertion.model == .song else { return nil }
        
        switch assertion.operation {
        
        case .add:
            if let song = assertion.data as? Song { return song }
            return nil
        
        case .update:
            guard let update = assertion.data as? SongUpdate else { return nil }
            if let song = currentBasis.songMap[update.id] { return song.apply(update: update) }
            return nil
        
        case .delete:
            guard let delete = assertion.data as? DeleteAssertion else { return nil }
            return excludeDelete ? nil : currentBasis.songMap[delete.id]
        
        }
    }
    
    // MARK: - Naive Linking
    private func linkNewSongs(_ songTransactions: KeySet<Assertion>, albumTitles: [String:UUID], artistNames: [String:UUID]) -> KeySet<Assertion> {
        var linkUpdatesTransaction = KeySet<Assertion>()
        
        songTransactions.forEach { transaction in
            guard let song = songFromAssertion(transaction, excludeDelete: true) else { return }

            let albums: [UUID]? = {
                if let albumTitle = song.albumTitle { return parseAlbums(albumTitle).compactMap{ albumTitles[$0] } }
                else { return nil }
            }()
            
            let artists: [UUID]? = {
                if let artistName = song.artistName { return parseArtists(artistName).compactMap{ artistNames[$0] } }
                else { return nil }
            }()
            
            let linkUpdate = SongUpdate(song: song, artists: artists, albums: albums)
            linkUpdatesTransaction.insert(Assertion(linkUpdate))
        }
        
        return linkUpdatesTransaction
    }
    
    private struct Link {
        let songID: UUID
        let albumIDs: [UUID]
        let artistIDs: [UUID]
        
        public static func fromTransaction(_ assertion: Assertion) -> Link? {
            guard assertion.model == .song else { return nil }
            
            switch (assertion.operation) {
            case .add:
                guard let song = assertion.data as? Song else { return nil }
                return Link(songID: song.id, albumIDs: song.albums, artistIDs: song.artists)
            case .update:
                guard let update = assertion.data as? SongUpdate else { return nil }
                return Link(songID: update.id, albumIDs: update.albums ?? [], artistIDs: update.artists ?? [])
            default: return nil
            }
            
        }
    }
    
    private func linkNewAlbums(_ affectedAlbums: [String:UUID], songLinkTransaction: KeySet<Assertion>) -> (KeySet<Assertion>, KeySet<Assertion>) {
        var baseTransactions = KeySet<Assertion>()
        var newTransactions = KeySet<Assertion>()
        
        let links = songLinkTransaction.values.compactMap { Link.fromTransaction($0) }
        
        for (albumTitle, albumID) in affectedAlbums {
            
            let (album, isUpdate) = {
                if let album = currentBasis.albumMap[albumID] { return (album, true) }
                else { return (Album(id: albumID, title: albumTitle), false) }
            }()
            
            let albumLinks = links
                .filter { link in link.albumIDs.contains(album.id) }
            
            let albumBaseSongs = Set(
                album.songs.filter { songID in
                    // if the song has been relinked, reevaluate it with new link info
                    if case songID = songLinkTransaction[songID]?.id { return false }
                    else { return true } }
            )
            
            let albumSongs = Array(albumLinks.reduce(into: albumBaseSongs){ albumSongs, link in
                albumSongs.insert(link.songID)
            })
            
            let albumBaseArtists = albumBaseSongs.reduce(into: Set<UUID>()) { albumArtists, songID in
                if let artists = currentBasis.songMap[songID]?.artists { albumArtists.formUnion(artists) }
            }
                        
            let albumArtists = Array(albumLinks.reduce(into: albumBaseArtists){ albumArtists, link in
                albumArtists.formUnion(link.artistIDs)
            })
            
            let linkUpdate = AlbumUpdate(album: album, songs: albumSongs, artists: albumArtists)
            
            if albumSongs.count == 0 {
                newTransactions.insert(Assertion(DeleteAssertion(album)))
            } else if isUpdate {
                baseTransactions.insert(Assertion(album))
                newTransactions.insert(Assertion(linkUpdate))
            } else {
                newTransactions.insert(Assertion(album.apply(update: linkUpdate)))
            }
        }
        
        return (baseTransactions, newTransactions)
    }
    
    private func linkNewArtists(_ affectedArtists: [String:UUID], songLinkTransaction: KeySet<Assertion>) -> (KeySet<Assertion>, KeySet<Assertion>) {
        var baseTransactions = KeySet<Assertion>()
        var newTransactions = KeySet<Assertion>()
        
        let links = songLinkTransaction.values.compactMap { Link.fromTransaction($0) }
        
        for (artistName, artistID) in affectedArtists {
            
            let (artist, isUpdate) = {
                if let artist = currentBasis.artistMap[artistID] { return (artist, true) }
                else { return (Artist(id: artistID, name: artistName), false) }
            }()
            
            let artistLinks = links
                .filter { link in link.artistIDs.contains(artist.id) }
            
            let artistBaseSongs = Set(
                artist.songs.filter { songID in
                    // if the song has been relinked, reevaluate it with new link info
                    if case songID = songLinkTransaction[songID]?.id { return false }
                    else { return true }
                }
            )
            
            let artistSongs = Array(artistLinks.reduce(into: artistBaseSongs){ artistSongs, link in
                artistSongs.insert(link.songID)
            })
            
            let artistBaseAlbums = artistBaseSongs.reduce(into: Set<UUID>()) { artistAlbums, songID in
                if let albums = currentBasis.songMap[songID]?.albums { artistAlbums.formUnion(albums) }
            }
            
            let artistAlbums = Array(artistLinks.reduce(into: artistBaseAlbums){ artistAlbums, link in
                artistAlbums.formUnion(link.albumIDs)
            })
            
            let linkUpdate = ArtistUpdate(artist: artist, songs: artistSongs, albums: artistAlbums)
            
            if artistSongs.count == 0 {
                newTransactions.insert(Assertion(DeleteAssertion(artist)))
            } else if isUpdate {
                baseTransactions.insert(Assertion(artist))
                newTransactions.insert(Assertion(linkUpdate))
            } else {
                newTransactions.insert(Assertion(artist.apply(update: linkUpdate)))
            }
        }
        
        return (baseTransactions, newTransactions)
    }
    
    // MARK: - Detail Resolution
    private func songsResolveDetails(_ linkedBasis: DataBasis) -> KeySet<Assertion> {
        var detailsTransaction = KeySet<Assertion>()
        
        for song in linkedBasis.allSongs {
            let albums = song.albums
                .compactMap { linkedBasis.albumMap[$0] ?? currentBasis.albumMap[$0] }
                .sorted { Album.alphabeticalSort($0, $1) }
                
            let artists = song.artists
                .compactMap { linkedBasis.artistMap[$0] ?? currentBasis.artistMap[$0] }
                .sorted { Artist.alphabeticalSort($0, $1) }
                
            detailsTransaction.insert(Assertion(SongUpdate(
                song: song
                , artists: artists.map { $0.id }
                , albums: albums.map { $0.id }
            )))
        }
        
        return detailsTransaction
    }
    
    private func albumsResolveDetails(_ linkedBasis: DataBasis) -> KeySet<Assertion> {
        var detailsTransaction = KeySet<Assertion>()
        
        for album in linkedBasis.allAlbums {

            let songs = album.songs
                .compactMap { linkedBasis.songMap[$0] ?? currentBasis.songMap[$0] }
                .sorted { Song.discAndTrackNumberSort($0, $1) }
                            
            let artists = album.artists
                .compactMap { linkedBasis.artistMap[$0] ?? currentBasis.artistMap[$0] }
                .sorted { Artist.alphabeticalSort($0, $1) }
            
            let art = songs.first(where: { $0.art != nil })?.art
            
            let artistName: String? = {
                if let artistName = album.artistName { return artistName }
                switch artists.count {
                case 0: return "Unknown Artist"
                case 1: return artists.first?.name
                default: return "Various Artists"
                }
            }()
            
            detailsTransaction.insert(Assertion(AlbumUpdate(
                album: album
                , art: art
                , songs: songs.map { $0.id }
                , artistName: artistName
                , artists: artists.map { $0.id }
            )))
        }
        
        return detailsTransaction
    }
    
    private func artistsResolveDetails(_ linkedBasis: DataBasis) -> KeySet<Assertion> {
        var detailsTransaction = KeySet<Assertion>()
        
        for artist in linkedBasis.allArtists {

            let songs = artist.songs
                .compactMap { linkedBasis.songMap[$0] ?? currentBasis.songMap[$0] }
                .sorted { Song.alphabeticalSort($0, $1) }
                
            
            let albums = artist.albums
                .compactMap { linkedBasis.albumMap[$0] ?? currentBasis.albumMap[$0] }
                .sorted { Album.alphabeticalSort($0, $1) }
                
            detailsTransaction.insert(Assertion(ArtistUpdate(
                artist: artist
                , songs: songs.map { $0.id }
                , albums: albums.map { $0.id }
            )))
        }
        
        return detailsTransaction
    }
    
    // MARK: - Parsers
    /// Used to seperate artists like 'A feat. B' to two seperate A and B artists
    private func parseArtists(_ artistName: String) -> [String] {
        [artistName]
    }
    
    private func parseAlbums(_ albumTitle: String) -> [String] {
        [albumTitle]
    }
}
