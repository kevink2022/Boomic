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
    
    private lazy var albumTitles: [String:UUID] = {
        currentBasis.allAlbums
            .reduce(into: [String:UUID]()) { dict, album in dict[album.title] = album.id }
    }()
    
    private lazy var artistNames: [String:UUID] = {
        currentBasis.allArtists
            .reduce(into: [String:UUID]()) { dict, artist in dict[artist.name] = artist.id }
    }()
    
    public init(currentBasis: DataBasis) {
        self.currentBasis = currentBasis
    }
    
    public func apply(transaction: KeySet<LibraryTransaction>, to basis: DataBasis? = nil) async -> DataBasis {
        
        var basis = basis ?? currentBasis
        
        basis = await applyDelete(transaction, to: basis)
        basis = await applyUpdate(transaction, to: basis)
        basis = await applyAdd(transaction, to: basis)
        
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
    
    
    private func applyAdd(_ transaction: KeySet<LibraryTransaction>, to basis: DataBasis) async -> DataBasis {
       
        let adds = transaction.filter { $0.operation == .add }
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
    
    private func applyUpdate(_ transaction: KeySet<LibraryTransaction>, to basis: DataBasis) async -> DataBasis {
        
        let updates = transaction.filter { $0.operation == .update }
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
    
    private func applyDelete(_ transaction: KeySet<LibraryTransaction>, to basis: DataBasis) async -> DataBasis {
        
        let deletes = transaction.filter { $0.operation == .delete }
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
    
    public func updateSong(_ update: SongUpdate) async -> KeySet<LibraryTransaction> {
        guard let original = currentBasis.songMap[update.id] else { return KeySet() }
        /*
        var updateTransaction = LibraryTransaction.Update(
            songs: [update]
            , albums: nil
            , artists: nil
        )
        
        /* update artists and albums if they change.
        if let erasing = update.erasing, erasing.contains("artistName") {
            let erasedArtists = original.artists.compactMap { currentBasis.artistMap[$0] }
            
        } else if let artistName = update.artistName {
            
        }
        
        if let erasing = update.erasing, erasing.contains("albumTitle") {
            
        } else if let albumTitle = update.albumTitle {
            
        }
        */
        
        return LibraryTransaction(
            update: updateTransaction
        )
        */
        
        return KeySet()
    }
    
    public func addSongs(_ unlinkedSongs: [Song]) async -> KeySet<LibraryTransaction> {
        guard unlinkedSongs.count > 0 else { return KeySet() }
        
        do {
            async let albumTitleLinks_await = songsToTitleLinks(unlinkedSongs)
            async let artistNameLinks_await = songsToNameLinks(unlinkedSongs)
            
            let (albumTitleLinks, artistNameLinks) = await (albumTitleLinks_await, artistNameLinks_await)
            
            let (linkedNewSongs, newSongsTransaction) = linkNewSongs(unlinkedSongs, albumTitles: albumTitleLinks, artistNames: artistNameLinks)
            
            async let linkedAlbums_await = linkNewAlbums(albumTitleLinks, linkedNewSongs: linkedNewSongs)
            async let linkedArtists_await = linkNewArtists(artistNameLinks, linkedNewSongs: linkedNewSongs)
            
            let (
                (existingAlbumsTransaction, newAlbumsTransaction)
                , (existingArtistsTransaction, newArtistsTransaction)
            ) = await (linkedAlbums_await, linkedArtists_await)
            
            let existingTransaction = try LibraryTransaction.flatten([existingAlbumsTransaction, existingArtistsTransaction])
            let newLinksTransaction = try LibraryTransaction.flatten([newSongsTransaction, newAlbumsTransaction, newArtistsTransaction])
            let linkedBasisTransaction = try LibraryTransaction.flatten([existingTransaction, newLinksTransaction])
            
            let newLinksBasis = await self.apply(transaction: linkedBasisTransaction, to: DataBasis.empty)
            
            async let newSongs_await = songsResolveDetails(newLinksBasis)
            async let newAlbums_await = albumsResolveDetails(newLinksBasis)
            async let newArtists_await = artistsResolveDetails(newLinksBasis)
            
            let (songDetailsTransaction, albumDetailsTransaction, artistDetailsTransaction) = await (newSongs_await, newAlbums_await, newArtists_await)
            
            let detailsTransaction = try LibraryTransaction.flatten([songDetailsTransaction, albumDetailsTransaction, artistDetailsTransaction])
            let finalTransaction = try LibraryTransaction.flatten([newLinksTransaction, detailsTransaction])
            
            return finalTransaction
        } 
        
        catch {
            return KeySet()
        }
    }
    
    // MARK: - String Maps
    private func songsToTitleLinks(_ songs: [Song]) -> [String:UUID] {
        return songs.reduce(into: [String:UUID]()) { dict, song in
            
            guard let songAlbumTitle = song.albumTitle else { return }
            
            if let albumID = albumTitles[songAlbumTitle] {
                dict[songAlbumTitle] = albumID
            } else {
                dict[songAlbumTitle] = UUID()
            }
        }
    }
    
    private func songsToNameLinks(_ songs: [Song]) -> [String:UUID] {
        return songs.reduce(into: [String:UUID]()) { dict, song in
            
            guard let songArtistName = song.artistName else { return }
            
            if let artistID = artistNames[songArtistName] {
                dict[songArtistName] = artistID
            } else {
                dict[songArtistName] = UUID()
            }
        }
    }
    
    // MARK: - Naive Linking
    private func linkNewSongs(_ unlinkedSongs: [Song], albumTitles: [String:UUID], artistNames: [String:UUID]) -> ([Song], KeySet<LibraryTransaction>) {
        var transactions = KeySet<LibraryTransaction>()
        var newSongs = [Song]()
        
        for song in unlinkedSongs {

            let albums: [UUID]? = {
                if let albumTitle = song.albumTitle { return parseAlbums(albumTitle).compactMap{ albumTitles[$0] } }
                else { return nil }
            }()
            
            let artists: [UUID]? = {
                if let artistName = song.artistName { return parseArtists(artistName).compactMap{ artistNames[$0] } }
                else { return nil }
            }()
            
            let linkUpdate = SongUpdate(song: song, artists: artists, albums: albums)
            let linkedSong = song.apply(update: linkUpdate)
            newSongs.append(linkedSong)
            transactions.insert(.addSong(linkedSong))
        }
        
        return (newSongs, transactions)
    }
    
    private func linkNewAlbums(_ affectedAlbums: [String:UUID], linkedNewSongs: [Song]) -> (KeySet<LibraryTransaction>, KeySet<LibraryTransaction>) {
        var baseTransactions = KeySet<LibraryTransaction>()
        var newTransactions = KeySet<LibraryTransaction>()
        
        for (albumTitle, albumID) in affectedAlbums {
            
            let (album, isUpdate) = {
                if let album = currentBasis.albumMap[albumID] { return (album, true) }
                else { return (Album(id: albumID, title: albumTitle), false) }
            }()
            
            let linkedSongsToAlbum = linkedNewSongs.filter { $0.albums.contains(album.id) }
            
            let albumSongs = Array(linkedSongsToAlbum.reduce(into: Set(album.songs)){ $0.insert($1.id ) })
            let albumArtists = Array(linkedSongsToAlbum.reduce(into: Set(album.artists)){ $0.formUnion($1.artists) })
            
            let linkUpdate = AlbumUpdate(album: album, songs: albumSongs, artists: albumArtists)
            
            if isUpdate {
                baseTransactions.insert(.addAlbum(album))
                newTransactions.insert(.updateAlbum(linkUpdate))
            } else {
                newTransactions.insert(.addAlbum(album.apply(update: linkUpdate)))
            }
        }
        
        return (baseTransactions, newTransactions)
    }
    
    private func linkNewArtists(_ affectedArtists: [String:UUID], linkedNewSongs: [Song]) -> (KeySet<LibraryTransaction>, KeySet<LibraryTransaction>) {
        var baseTransactions = KeySet<LibraryTransaction>()
        var newTransactions = KeySet<LibraryTransaction>()
        
        for (artistName, artistID) in affectedArtists {
            
            let (artist, isUpdate) = {
                if let artist = currentBasis.artistMap[artistID] { return (artist, true) }
                else { return (Artist(id: artistID, name: artistName), false) }
            }()
            
            let linkedSongsToArtist = linkedNewSongs.filter { $0.artists.contains(artist.id) }
            
            let artistSongs = Array(linkedSongsToArtist.reduce(into: Set(artist.songs)){ $0.insert($1.id ) })
            let artistAlbums = Array(linkedSongsToArtist.reduce(into: Set(artist.albums)){ $0.formUnion($1.albums) })
            
            let linkUpdate = ArtistUpdate(artist: artist, songs: artistSongs, albums: artistAlbums)
            
            if isUpdate {
                baseTransactions.insert(.addArtist(artist))
                newTransactions.insert(.updateArtist(linkUpdate))
            } else {
                newTransactions.insert(.addArtist(artist.apply(update: linkUpdate)))
            }
        }
        
        return (baseTransactions, newTransactions)
    }
    
    // MARK: - Detail Resolution
    private func songsResolveDetails(_ linkedBasis: DataBasis) -> KeySet<LibraryTransaction> {
        var detailsTransaction = KeySet<LibraryTransaction>()
        
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
    
    private func albumsResolveDetails(_ linkedBasis: DataBasis) -> KeySet<LibraryTransaction> {
        var detailsTransaction = KeySet<LibraryTransaction>()
        
        for album in linkedBasis.allAlbums {

            let songs = album.songs
                .compactMap { linkedBasis.songMap[$0] ?? currentBasis.songMap[$0] }
                .sorted { Song.discAndTrackNumberSort($0, $1) }
                            
            let artists = album.artists
                .compactMap { linkedBasis.artistMap[$0] ?? currentBasis.artistMap[$0] }
                .sorted { Artist.alphabeticalSort($0, $1) }
            
            let art = songs.first(where: { $0.art != nil })?.art
            let artistName = artists.count == 1 ? artists.first?.name : "Various Artists"
            
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
    
    private func artistsResolveDetails(_ linkedBasis: DataBasis) -> KeySet<LibraryTransaction> {
        var detailsTransaction = KeySet<LibraryTransaction>()
        
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
    /// these will likely be moved long term.
    private func parseArtists(_ artistName: String) -> [String] {
        return [artistName]
    }
    
    private func parseAlbums(_ albumTitle: String) -> [String] {
        return [albumTitle]
    }
}
