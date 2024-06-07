//
//  File.swift
//  
//
//  Created by Kevin Kelly on 5/19/24.
//

import Foundation
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
        
        async let newSongMap_await = {
            var songMap = basis.songMap
            let addSongs = adds.filter { $0.model == .song }
            addSongs.forEach {
                if case let .addSong(song) = $0 {
                    songMap[song.id] = song
                }
            }
            return songMap
        }()
        
        async let newAlbumMap_await = {
            var albumMap = basis.albumMap
            let addAlbums = adds.filter { $0.model == .album }
            addAlbums.forEach {
                if case let .addAlbum(album) = $0 {
                    albumMap[album.id] = album
                }
            }
            return albumMap
        }()
        
        async let newArtistMap_await = {
            var artistMap = basis.artistMap
            let addArtists = adds.filter { $0.model == .artist }
            addArtists.forEach {
                if case let .addArtist(artist) = $0 {
                    artistMap[artist.id] = artist
                }
            }
            return artistMap
        }()
        
        let (
            newSongMap, newAlbumMap, newArtistMap
        ) = await (
            newSongMap_await, newAlbumMap_await, newArtistMap_await
        )
        
        return DataBasis(
            songMap: newSongMap
            , albumMap: newAlbumMap
            , artistMap: newArtistMap
            , allSongs: basis.allSongs
            , allAlbums: basis.allAlbums
            , allArtists: basis.allArtists
        )
    }
    
    private func applyUpdate(_ assertions: KeySet<Assertion>, to basis: DataBasis) async -> DataBasis {
        let updates = assertions.filter { $0.operation == .update }
        guard updates.count > 0 else { return basis }
        
        async let newSongMap_await = {
            var songMap = basis.songMap
            let updateSongs = updates.filter { $0.model == .song }
            updateSongs.forEach {
                if case let .updateSong(update) = $0 {
                    let original = songMap[update.id]
                    songMap[update.id] = original?.apply(update: update)
                }
            }
            return songMap
        }()
        
        async let newAlbumMap_await = {
            var albumMap = basis.albumMap
            let updateAlbums = updates.filter { $0.model == .album }
            updateAlbums.forEach {
                if case let .updateAlbum(update) = $0 {
                    let original = albumMap[update.id]
                    albumMap[update.id] = original?.apply(update: update)
                }
            }
            return albumMap
        }()
        
        async let newArtistMap_await = {
            var artistMap = basis.artistMap
            let updateArtists = updates.filter { $0.model == .artist }
            updateArtists.forEach {
                if case let .updateArtist(update) = $0 {
                    let original = artistMap[update.id]
                    artistMap[update.id] = original?.apply(update: update)
                }
            }
            return artistMap
        }()
        
        let (
            newSongMap, newAlbumMap, newArtistMap
        ) = await (
            newSongMap_await, newAlbumMap_await, newArtistMap_await
        )
        
        return DataBasis(
            songMap: newSongMap
            , albumMap: newAlbumMap
            , artistMap: newArtistMap
            , allSongs: basis.allSongs
            , allAlbums: basis.allAlbums
            , allArtists: basis.allArtists
        )
    }
    
    private func applyDelete(_ assertions: KeySet<Assertion>, to basis: DataBasis) async -> DataBasis {
        let deletes = assertions.filter { $0.operation == .delete }
        guard deletes.count > 0 else { return basis }
        
        async let newSongMap_await = {
            var songMap = basis.songMap
            let deleteSongs = deletes.filter { $0.model == .song }
            deleteSongs.forEach {
                if case let .deleteSong(id) = $0 {
                    songMap[id] = nil
                }
            }
            return songMap
        }()
        
        async let newAlbumMap_await = {
            var albumMap = basis.albumMap
            let deleteAlbums = deletes.filter { $0.model == .album }
            deleteAlbums.forEach {
                if case let .deleteAlbum(id) = $0 {
                    albumMap[id] = nil
                }
            }
            return albumMap
        }()
        
        async let newArtistMap_await = {
            var artistMap = basis.artistMap
            let deleteArtists = deletes.filter { $0.model == .artist }
            deleteArtists.forEach {
                if case let .deleteArtist(id) = $0 {
                    artistMap[id] = nil
                }
            }
            return artistMap
        }()

        let (
            newSongMap, newAlbumMap, newArtistMap
        ) = await (
            newSongMap_await, newAlbumMap_await, newArtistMap_await
        )
        
        return DataBasis(
            songMap: newSongMap
            , albumMap: newAlbumMap
            , artistMap: newArtistMap
            , allSongs: basis.allSongs
            , allAlbums: basis.allAlbums
            , allArtists: basis.allArtists
        )
    }
    
    public func updateAlbum(_ update: AlbumUpdate) async -> LibraryTransaction {
        guard let album = currentBasis.albumMap[update.id] else { return .empty }
        let label = "Update Album: \(album.title)"
        
        var songUpdateAssertions = KeySet<Assertion>()
        let albumUpdateAssertion = KeySet<Assertion>().inserting(.updateAlbum(update))
        
        if update.newTitle == nil {
            return albumUpdateAssertion.asTransaction(label: label, level: .normal)
        } else {
            album.songs.forEach {
                if let song = currentBasis.songMap[$0] {
                    let songUpdate = SongUpdate(song: song, albumTitle: update.newTitle)
                    songUpdateAssertions.insert(.updateSong(songUpdate))
                }
            }
            let updateBasis = await self.apply(transaction: albumUpdateAssertion.asTransaction())
            let linkAssertions = await BasisResolver(currentBasis: updateBasis).updateLinks(songUpdateAssertions)
            let finalAssertions = Assertion.flatten([albumUpdateAssertion, linkAssertions])
            return finalAssertions.asTransaction(label: label, level: .significant)
        }
    }
    
    public func updateArtist(_ update: ArtistUpdate) async -> LibraryTransaction {
        guard let artist = currentBasis.artistMap[update.id] else { return .empty }
        let label = "Update Artist: \(artist.name)"
        
        var songUpdateAssertions = KeySet<Assertion>()
        let artistUpdateAssertion = KeySet<Assertion>().inserting(.updateArtist(update))
        
        if update.newName == nil {
            return artistUpdateAssertion.asTransaction(label: label, level: .normal)
        } else {
            artist.songs.forEach {
                if let song = currentBasis.songMap[$0] {
                    let songUpdate = SongUpdate(song: song, artistName: update.newName)
                    songUpdateAssertions.insert(.updateSong(songUpdate))
                }
            }
            let updateBasis = await self.apply(transaction: artistUpdateAssertion.asTransaction())
            let linkAssertions = await BasisResolver(currentBasis: updateBasis).updateLinks(songUpdateAssertions)
            let finalAssertions = Assertion.flatten([artistUpdateAssertion, linkAssertions])
            return finalAssertions.asTransaction(label: label, level: .significant)
        }
    }
    
    public func deleteAlbum(_ album: Album) async -> LibraryTransaction {
        guard let album = currentBasis.albumMap[album.id] else { return .empty }
        
        var assertions = KeySet<Assertion>()
        album.songs.forEach { assertions.insert(.deleteSong($0)) }
        
        assertions = await updateLinks(assertions)
        return assertions.asTransaction(label: "Delete Album: \(album.title)", level: .significant)
    }
    
    public func deleteArtist(_ artist: Artist) async -> LibraryTransaction {
        guard let artist = currentBasis.artistMap[artist.id] else { return .empty }
        
        var assertions = KeySet<Assertion>()
        artist.songs.forEach { assertions.insert(.deleteSong($0)) }
        
        assertions = await updateLinks(assertions)
        return assertions.asTransaction(label: "Delete Artist: \(artist.name)", level: .significant)
    }
    
    public func deleteSong(_ song: Song) async -> LibraryTransaction {
        guard let song = currentBasis.songMap[song.id] else { return .empty }
        
        var assertions = KeySet<Assertion>()
        assertions.insert(.deleteSong(song.id))
        
        assertions = await updateLinks(assertions)
        return assertions.asTransaction(label: "Delete Song: \(song.label)", level: .significant)

    }
    
    public func updateSong(_ update: SongUpdate) async -> LibraryTransaction {
        guard let song = currentBasis.songMap[update.id] else { return .empty }
        let label = "Update Song: \(song.label)"
        
        var assertions = KeySet<Assertion>()
        assertions.insert(.updateSong(update))
        
        if update.artistName != nil || update.albumTitle != nil {
            assertions = await updateLinks(assertions)
            return assertions.asTransaction(label: label, level: .significant)
        }

        return assertions.asTransaction(label: label, level: .normal)
    }
    
    public func addSongs(_ unlinkedSongs: [Song]) async -> LibraryTransaction {
        guard unlinkedSongs.count > 0 else { return .empty }
        
        var assertions = KeySet<Assertion>()
        unlinkedSongs.forEach{ assertions.insert(.addSong($0)) }
        
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
    private func songsToTitleLinks(_ songTransaction: KeySet<Assertion>) -> [String:UUID] {
        var affectedAlbums = [String:UUID]()
        
         songTransaction.forEach { songTransaction in
             guard let albumTitles = {
                 switch songTransaction {
                 case .addSong(let song):
                     if let title = song.albumTitle { return Set([title]) }
                 
                 case .updateSong(let update):
                     let songTitle = currentBasis.songMap[update.id]?.albumTitle
                     let updateTitle = update.albumTitle
                     return Set([songTitle, updateTitle].compactMap{ $0 })
                     
                 case .deleteSong(let id):
                     if let title = currentBasis.songMap[id]?.albumTitle { return Set([title]) }
                    
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
    
    private func songsToNameLinks(_ songTransaction: KeySet<Assertion>) -> [String:UUID] {
        var affectedArtists = [String:UUID]()
        
         songTransaction.forEach { songTransaction in
             guard let artistNames = {
                 switch songTransaction {
                 case .addSong(let song):
                     if let name = song.artistName { return Set([name]) }
                 
                 case .updateSong(let update):
                     let songTitle = currentBasis.songMap[update.id]?.artistName
                     let updateTitle = update.artistName
                     return Set([songTitle, updateTitle].compactMap{ $0 })
                     
                 case .deleteSong(let id):
                     if let name = currentBasis.songMap[id]?.artistName { return Set([name]) }
                    
                 default: return nil
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
    
    private func songFromTransaction(_ songTransaction: Assertion, excludeDelete: Bool = false) -> Song? {
        switch songTransaction {
        case .addSong(let song): return song
        case .updateSong(let update): if let song = currentBasis.songMap[update.id] { return song.apply(update: update) }
        case .deleteSong(let id): return excludeDelete ? nil : currentBasis.songMap[id]
        default: return nil
        }
        return nil
    }
    
    // MARK: - Naive Linking
    private func linkNewSongs(_ songTransactions: KeySet<Assertion>, albumTitles: [String:UUID], artistNames: [String:UUID]) -> KeySet<Assertion> {
        var linkUpdatesTransaction = KeySet<Assertion>()
        
        songTransactions.forEach { transaction in
            guard let song = songFromTransaction(transaction, excludeDelete: true) else { return }

            let albums: [UUID]? = {
                if let albumTitle = song.albumTitle { return parseAlbums(albumTitle).compactMap{ albumTitles[$0] } }
                else { return nil }
            }()
            
            let artists: [UUID]? = {
                if let artistName = song.artistName { return parseArtists(artistName).compactMap{ artistNames[$0] } }
                else { return nil }
            }()
            
            let linkUpdate = SongUpdate(song: song, artists: artists, albums: albums)
            linkUpdatesTransaction.insert(.updateSong(linkUpdate))
        }
        
        return linkUpdatesTransaction
    }
    
    private struct Link {
        let songID: UUID
        let albumIDs: [UUID]
        let artistIDs: [UUID]
        
        public static func fromTransaction(_ transaction: Assertion) -> Link? {
            switch transaction {
            case .addSong(let song): return Link(songID: song.id, albumIDs: song.albums, artistIDs: song.artists)
            case .updateSong(let update): return Link(songID: update.id, albumIDs: update.albums ?? [], artistIDs: update.artists ?? [])
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
                newTransactions.insert(.deleteAlbum(album.id))
            } else if isUpdate {
                baseTransactions.insert(.addAlbum(album))
                newTransactions.insert(.updateAlbum(linkUpdate))
            } else {
                newTransactions.insert(.addAlbum(album.apply(update: linkUpdate)))
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
                newTransactions.insert(.deleteArtist(artist.id))
            } else if isUpdate {
                baseTransactions.insert(.addArtist(artist))
                newTransactions.insert(.updateArtist(linkUpdate))
            } else {
                newTransactions.insert(.addArtist(artist.apply(update: linkUpdate)))
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
                
            detailsTransaction.insert(.updateSong(SongUpdate(
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
            
            detailsTransaction.insert(.updateAlbum(AlbumUpdate(
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
                
            detailsTransaction.insert(.updateArtist(ArtistUpdate(
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
