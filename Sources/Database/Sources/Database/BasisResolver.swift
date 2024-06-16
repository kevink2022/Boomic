//
//  File.swift
//  
//
//  Created by Kevin Kelly on 5/19/24.
//

import Foundation
import Domain
import Models

public final class BasisResolver {
    
    private let currentBasis: DataBasis
    
    private lazy var currentAlbumTitles: [String:UUID] = {
        currentBasis.allAlbums
            .reduce(into: [String:UUID]()) { dict, album in dict[album.title] = album.id }
    }()
    
    private lazy var currentArtistNames: [String:UUID] = {
        currentBasis.allArtists
            .reduce(into: [String:UUID]()) { dict, artist in dict[artist.name] = artist.id }
    }()
    
    public init(currentBasis: DataBasis) {
        self.currentBasis = currentBasis
    }
    
    public func apply(transaction: LibraryTransaction, to basis: DataBasis? = nil) async -> DataBasis {
        
        let assertions = transaction.assertions
        
        var basis = basis ?? currentBasis
        
        basis = await applyDelete(assertions, to: basis)
        basis = await applyUpdate(assertions, to: basis)
        basis = await applyAdd(assertions, to: basis)
        
        let mappedBasis = basis
        /// TODO: create 'SortedSets' that are ordered array sets, then maintain along with basis
        async let newAllSongs_await = { mappedBasis.songMap.values.sorted{ Song.alphabeticalSort($0, $1) } }()
        async let newAllAlbums_await = { mappedBasis.albumMap.values.sorted{ Album.alphabeticalSort($0, $1) } }()
        async let newAllArtists_await = { mappedBasis.artistMap.values.sorted{ Artist.alphabeticalSort($0, $1) } }()

        let (
            newAllSongs, newAllAlbums, newAllArtists
        ) = await (
            newAllSongs_await, newAllAlbums_await, newAllArtists_await
        )
        
        let finalBasis = DataBasis(
            songMap: mappedBasis.songMap
            , albumMap: mappedBasis.albumMap
            , artistMap: mappedBasis.artistMap
            , allSongs: newAllSongs
            , allAlbums: newAllAlbums
            , allArtists: newAllArtists
        )
        
        return finalBasis
    }
    
    
    private func applyAdd(_ assertions: KeySet<Assertion>, to basis: DataBasis) async -> DataBasis {
        let adds = assertions.filter { $0.operation == .add }
        guard adds.count > 0 else { return basis }
        
        var songMap = basis.songMap
        var albumMap = basis.albumMap
        var artistMap = basis.artistMap
        
        adds.forEach { add in
            switch add.model {
            case .song:
                if let model = add.data as? Song {
                    songMap[model.id] = model
                }
            case .album:
                if let model = add.data as? Album {
                    albumMap[model.id] = model
                }
            case .artist:
                if let model = add.data as? Artist {
                    artistMap[model.id] = model
                }
            }
        }
        
        return DataBasis(
            songMap: songMap
            , albumMap: albumMap
            , artistMap: artistMap
            , allSongs: basis.allSongs
            , allAlbums: basis.allAlbums
            , allArtists: basis.allArtists
        )
    }
    
    private func applyUpdate(_ assertions: KeySet<Assertion>, to basis: DataBasis) async -> DataBasis {
        let updates = assertions.filter { $0.operation == .update }
        guard updates.count > 0 else { return basis }
        
        var songMap = basis.songMap
        var albumMap = basis.albumMap
        var artistMap = basis.artistMap
        
        updates.forEach { update in
            switch update.model {
            case .song:
                if let update = update.data as? SongUpdate {
                    let original = songMap[update.id]
                    songMap[update.id] = original?.apply(update: update)
                }
            case .album:
                if let update = update.data as? AlbumUpdate {
                    let original = albumMap[update.id]
                    albumMap[update.id] = original?.apply(update: update)
                }
            case .artist:
                if let update = update.data as? ArtistUpdate {
                    let original = artistMap[update.id]
                    artistMap[update.id] = original?.apply(update: update)
                }
            }
        }
        
        return DataBasis(
            songMap: songMap
            , albumMap: albumMap
            , artistMap: artistMap
            , allSongs: basis.allSongs
            , allAlbums: basis.allAlbums
            , allArtists: basis.allArtists
        )
    }
    
    private func applyDelete(_ assertions: KeySet<Assertion>, to basis: DataBasis) async -> DataBasis {
        let deletes = assertions.filter { $0.operation == .delete }
        guard deletes.count > 0 else { return basis }

        var songMap = basis.songMap
        var albumMap = basis.albumMap
        var artistMap = basis.artistMap
        
        deletes.forEach {
            guard let delete = $0.data as? DeleteAssertion else { return }
            
            switch delete.model {
            case .song:
                songMap[delete.id] = nil
            case .album:
                albumMap[delete.id] = nil
            case .artist:
                artistMap[delete.id] = nil
            }
        }
        
        return DataBasis(
            songMap: songMap
            , albumMap: albumMap
            , artistMap: artistMap
            , allSongs: basis.allSongs
            , allAlbums: basis.allAlbums
            , allArtists: basis.allArtists
        )
    }
    
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
    
    public func deleteAlbums(_ albums: Set<Album>) async -> LibraryTransaction {
        guard albums.count > 0 else { return .empty }
        
        let label = {
            if albums.count == 1, let album = albums.first, currentBasis.albumMap[album.id] != nil {
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
    
    fileprivate func updateLinks(_ songAssertions: KeySet<Assertion>) async -> KeySet<Assertion> {
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
                    
                 default: return nil
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
