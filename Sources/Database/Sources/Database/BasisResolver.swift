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
    
    public func apply(transaction: LibraryTransaction) async -> DataBasis {
        
        var basis = currentBasis
        
        if let delete = transaction.delete {
            basis = await applyDelete(delete, to: basis)
        }
        
        if let update = transaction.update {
            basis = await applyUpdate(update, to: basis)
        }
        
        if let add = transaction.add {
            basis = await applyAdd(add, to: basis)
        }
        
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
            songMap: basis.songMap
            , albumMap: basis.albumMap
            , artistMap: basis.artistMap
            , allSongs: newAllSongs
            , allAlbums: newAllAlbums
            , allArtists: newAllArtists
        )
        
        return finalBasis
    }
    
    private func applyAdd(_ add: LibraryTransaction.Add, to basis: DataBasis) async -> DataBasis {
       
        let newSongs = add.songs
        let newAlbums = add.albums
        let newArtists = add.artists
        
        async let newSongMap_await = { newSongs?.reduce(into: basis.songMap) { $0[$1.id] = $1 } }()
        async let newAlbumMap_await = { newAlbums?.reduce(into: basis.albumMap) { $0[$1.id] = $1 } }()
        async let newArtistMap_await = { newArtists?.reduce(into: basis.artistMap) { $0[$1.id] = $1 } }()

        let (
            newSongMap, newAlbumMap, newArtistMap
        ) = await (
            newSongMap_await, newAlbumMap_await, newArtistMap_await
        )
        
        return DataBasis(
            songMap: newSongMap ?? basis.songMap
            , albumMap: newAlbumMap ?? basis.albumMap
            , artistMap: newArtistMap ?? basis.artistMap
            , allSongs: basis.allSongs
            , allAlbums: basis.allAlbums
            , allArtists: basis.allArtists
        )
    }
    
    private func applyUpdate(_ update: LibraryTransaction.Update, to basis: DataBasis) async -> DataBasis {
        
        let newSongs: [Song]? = {
            if let songUpdates = update.songs {
                return songUpdates
                    .map { update in (currentBasis.songMap[update.id], update) }
                    .compactMap { song, update in
                        if let song = song { return song.apply(update: update) }
                        return nil
                    }
            }
            return nil
        }()
        
        let newSongMap = newSongs?.reduce(into: basis.songMap) { $0[$1.id] = $1 }
        
        
        return DataBasis(
            songMap: newSongMap ?? basis.songMap
            , albumMap: basis.albumMap
            , artistMap: basis.artistMap
            , allSongs: basis.allSongs
            , allAlbums: basis.allAlbums
            , allArtists: basis.allArtists
        )
    }
    
    private func applyDelete(_ delete: LibraryTransaction.Delete, to basis: DataBasis) async -> DataBasis {
        
        async let newSongMap_await = { delete.songs?.reduce(into: basis.songMap) { $0[$1] = nil } }()
        async let newAlbumMap_await = { delete.albums?.reduce(into: basis.albumMap) { $0[$1] = nil } }()
        async let newArtistMap_await = { delete.artists?.reduce(into: basis.artistMap) { $0[$1] = nil } }()

        let (
            newSongMap, newAlbumMap, newArtistMap
        ) = await (
            newSongMap_await, newAlbumMap_await, newArtistMap_await
        )
        
        return DataBasis(
            songMap: newSongMap ?? basis.songMap
            , albumMap: newAlbumMap ?? basis.albumMap
            , artistMap: newArtistMap ?? basis.artistMap
            , allSongs: basis.allSongs
            , allAlbums: basis.allAlbums
            , allArtists: basis.allArtists
        )
    }
    
    
    public func updateSong(_ update: SongUpdate) async -> LibraryTransaction? {
        guard let original = currentBasis.songMap[update.id] else { return nil }
        
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
    }
    
    public func addSongs(_ unlinkedSongs: [Song]) async -> LibraryTransaction {
        
        async let albumTitleLinks_await = songsToTitleLinks(unlinkedSongs)
        async let artistNameLinks_await = songsToNameLinks(unlinkedSongs)
        
        let (albumTitleLinks, artistNameLinks) = await (albumTitleLinks_await, artistNameLinks_await)
        
        let linkedNewSongs = linkSongs(unlinkedSongs, albumTitles: albumTitleLinks, artistNames: artistNameLinks)
        
        async let linkedAlbums_await = linkAlbums(albumTitleLinks, linkedNewSongs: linkedNewSongs)
        async let linkedArtists_await = linkArtists(artistNameLinks, linkedNewSongs: linkedNewSongs)
        
        let (linkedAffectedAlbums, linkedAffectedArtists) = await (linkedAlbums_await, linkedArtists_await)
        
        let tempBasis = DataBasis(songs: linkedNewSongs, albums: linkedAffectedAlbums, artists: linkedAffectedArtists)
        
        async let newSongs_await = songsResolveDetails(linkedNewSongs, tempBasis)
        async let newAlbums_await = albumsResolveDetails(linkedAffectedAlbums, tempBasis)
        async let newArtists_await = artistsResolveDetails(linkedAffectedArtists, tempBasis)
        
        let (newSongs, newAlbums, newArtists) = await (newSongs_await, newAlbums_await, newArtists_await)
         
        return LibraryTransaction(
            add: LibraryTransaction.Add(
                songs: Set(newSongs)
                , albums: Set(newAlbums)
                , artists: Set(newArtists)
            )
        )
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
    private func linkSongs(_ unlinkedSongs: [Song], albumTitles: [String:UUID], artistNames: [String:UUID]) -> [Song] {
        
        return unlinkedSongs.map { song in

            let albums: [UUID]? = {
                if let albumTitle = song.albumTitle { return parseAlbums(albumTitle).compactMap{ albumTitles[$0] } }
                else { return nil }
            }()
            
            let artists: [UUID]? = {
                if let artistName = song.artistName { return parseArtists(artistName).compactMap{ artistNames[$0] } }
                else { return nil }
            }()
            
            return Song(
                existingSong: song
                , artists: artists
                , albums: albums
            )
        }
    }
    
    private func linkAlbums(_ affectedAlbums: [String:UUID], linkedNewSongs: [Song]) -> [Album] {
        return affectedAlbums.map { title, albumID in
            
            let album = currentBasis.albumMap[albumID] ?? Album(id: albumID, title: title)
            
            let linkedSongsToAlbum = linkedNewSongs.filter { $0.albums.contains(album.id) }
            
            let albumSongs = Array(linkedSongsToAlbum.reduce(into: Set(album.songs)){ $0.insert($1.id ) })
            let albumArtists = Array(linkedSongsToAlbum.reduce(into: Set(album.artists)){ $0.formUnion($1.artists) })
            
            return Album(
                id: album.id
                , title: album.title
                , songs: albumSongs
                , artists: albumArtists
            )
        }
    }
    
    private func linkArtists(_ affectedArtists: [String:UUID], linkedNewSongs: [Song]) -> [Artist] {
        return affectedArtists.map { name, artistID in
            
            let artist = currentBasis.artistMap[artistID] ?? Artist(id: artistID, name: name, songs: [], albums: [])
            
            let linkedSongsToArtist = linkedNewSongs.filter { $0.artists.contains(artist.id) }
            
            let artistSongs = Array(linkedSongsToArtist.reduce(into: Set(artist.songs)){ $0.insert($1.id ) })
            let artistAlbums = Array(linkedSongsToArtist.reduce(into: Set(artist.albums)){ $0.formUnion($1.albums) })
            
            return Artist(
                id: artist.id
                , name: artist.name
                , songs: artistSongs
                , albums: artistAlbums
            )
        }
    }
    
    // MARK: - Detail Resolution
    private func songsResolveDetails(_ linkedSongs: [Song], _ tempBasis: DataBasis) -> [Song] {
        return linkedSongs.map { song in

            let albums = song.albums
                .compactMap { tempBasis.albumMap[$0] ?? currentBasis.albumMap[$0] }
                .sorted { Album.alphabeticalSort($0, $1) }
                
            let artists = song.artists
                .compactMap { tempBasis.artistMap[$0] ?? currentBasis.artistMap[$0] }
                .sorted { Artist.alphabeticalSort($0, $1) }
                
            
            return Song(
                existingSong: song
                , artists: artists.map { $0.id }
                , albums: albums.map { $0.id }
            )
        }
    }
    
    private func albumsResolveDetails(_ linkedAlbums: [Album], _ tempBasis: DataBasis) -> [Album] {
        return linkedAlbums.map { album in

            let songs = album.songs
                .compactMap { tempBasis.songMap[$0] ?? currentBasis.songMap[$0] }
                .sorted { Song.discAndTrackNumberSort($0, $1) }
                            
            let artists = album.artists
                .compactMap { tempBasis.artistMap[$0] ?? currentBasis.artistMap[$0] }
                .sorted { Artist.alphabeticalSort($0, $1) }
            
            let art = songs.first(where: { $0.art != nil })?.art
            let artistName = artists.count == 1 ? artists.first?.name : "Various Artists"
            
            return Album(
                id: album.id
                , title: album.title
                , art: art
                , songs: songs.map { $0.id }
                , artistName: artistName
                , artists: artists.map { $0.id }
            )
        }
    }
    
    private func artistsResolveDetails(_ linkedArtists: [Artist], _ tempBasis: DataBasis) -> [Artist] {
        return linkedArtists.map { artist in

            let songs = artist.songs
                .compactMap { tempBasis.songMap[$0] ?? currentBasis.songMap[$0] }
                .sorted { Song.alphabeticalSort($0, $1) }
                
            
            let albums = artist.albums
                .compactMap { tempBasis.albumMap[$0] ?? currentBasis.albumMap[$0] }
                .sorted { Album.alphabeticalSort($0, $1) }
                
            
            return Artist(
                id: artist.id
                , name: artist.name
                , songs: songs.map { $0.id }
                , albums: albums.map { $0.id }
            )
        }
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
