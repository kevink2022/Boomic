//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/23/24.
//

import Foundation
import Models


// MARK: - ModelCache -
public final class DataBasis {
    public let songMap: [UUID: Song]
    public let albumMap: [UUID: Album]
    public let artistMap: [UUID: Artist]
    
    public let allSongs: [Song]
    public let allAlbums: [Album]
    public let allArtists: [Artist]
    
    public init(
        songs: [Song]
        , albums: [Album]
        , artists: [Artist]
        , songMap: [UUID: Song]? = nil
        , albumMap: [UUID: Album]? = nil
        , artistMap: [UUID: Artist]? = nil
    ) {
        self.allSongs = songs
        self.allAlbums = albums
        self.allArtists = artists
        
        self.songMap = songMap ?? songs.reduce(into: [:]) { $0[$1.id] = $1 }
        self.albumMap = albumMap ?? albums.reduce(into: [:]) { $0[$1.id] = $1 }
        self.artistMap = artistMap ?? artists.reduce(into: [:]) { $0[$1.id] = $1 }
    }
}

// MARK: - ModelResolver -
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
    
    public func addSongs(_ unlinkedSongs: [Song]) async -> DataBasis {
        
        async let albumTitleLinks_await = songsToTitleLinks(unlinkedSongs)
        async let artistNameLinks_await = songsToNameLinks(unlinkedSongs)
        
        let (albumTitleLinks, artistNameLinks) = await (albumTitleLinks_await, artistNameLinks_await)
        
        let linkedSongs = linkSongs(unlinkedSongs, albumTitles: albumTitleLinks, artistNames: artistNameLinks)
        
        async let linkedAlbums_await = linkAlbums(albumTitleLinks, linkedSongs: linkedSongs)
        async let linkedArtists_await = linkArtists(artistNameLinks, linkedSongs: linkedSongs)
        
        let (linkedAlbums, linkedArtists) = await (linkedAlbums_await, linkedArtists_await)
        let tempBasis = DataBasis(songs: linkedSongs, albums: linkedAlbums, artists: linkedArtists)
        
        async let newSongs_await = songDetails(linkedSongs, tempBasis)
        async let newAlbums_await = albumDetails(linkedAlbums, tempBasis)
        async let newArtists_await = artistDetails(linkedArtists, tempBasis)
        
        let (newSongs, newAlbums, newArtists) = await (newSongs_await, newAlbums_await, newArtists_await)
        
        let currentSongMap = currentBasis.songMap
        let currentAlbumMap = currentBasis.albumMap
        let currentArtistMap = currentBasis.artistMap
        async let newSongMap_await = { newSongs.reduce(into: currentSongMap) { $0[$1.id] = $1 } }()
        async let newAlbumMap_await = { newAlbums.reduce(into: currentAlbumMap) { $0[$1.id] = $1 } }()
        async let newArtistMap_await = { newArtists.reduce(into: currentArtistMap) { $0[$1.id] = $1 } }()
        
        let (
            newSongMap, newAlbumMap, newArtistMap
        ) = await (
            newSongMap_await, newAlbumMap_await, newArtistMap_await
        )
            
        async let newAllSongs_await = { newSongMap.values.sorted{ Song.alphabeticalSort($0, $1) } }()
        async let newAllAlbums_await = { newAlbumMap.values.sorted{ Album.alphabeticalSort($0, $1) } }()
        async let newAllArtists_await = { newArtistMap.values.sorted{ Artist.alphabeticalSort($0, $1) } }()
        
        let (
            newAllSongs, newAllAlbums, newAllArtists
        ) = await (
            newAllSongs_await, newAllAlbums_await, newAllArtists_await
        )
        
        return DataBasis(
            songs: newAllSongs
            , albums: newAllAlbums
            , artists: newAllArtists
            , songMap: newSongMap
            , albumMap: newAlbumMap
            , artistMap: newArtistMap
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
    
    private func linkAlbums(_ affectedAlbums: [String:UUID], linkedSongs: [Song]) -> [Album] {
        return affectedAlbums.map { title, albumID in
            
            let album = currentBasis.albumMap[albumID] ?? Album(id: albumID, title: title)
            
            let linkedSongs = linkedSongs.filter { $0.albums.contains(album.id) }
            
            let albumSongs = Array(linkedSongs.reduce(into: Set(album.songs)){ $0.insert($1.id ) })
            let albumArtists = Array(linkedSongs.reduce(into: Set(album.artists)){ $0.formUnion($1.artists) })
            
            return Album(
                id: album.id
                , title: album.title
                , songs: albumSongs
                , artists: albumArtists
            )
        }
    }
    
    private func linkArtists(_ affectedArtists: [String:UUID], linkedSongs: [Song]) -> [Artist] {
        return affectedArtists.map { name, artistID in
            
            let artist = currentBasis.artistMap[artistID] ?? Artist(id: artistID, name: name, songs: [], albums: [])
            
            let linkedSongs = linkedSongs.filter { $0.artists.contains(artist.id) }
            
            let artistSongs = Array(linkedSongs.reduce(into: Set(artist.songs)){ $0.insert($1.id ) })
            let artistAlbums = Array(linkedSongs.reduce(into: Set(artist.albums)){ $0.formUnion($1.albums) })
            
            return Artist(
                id: artist.id
                , name: artist.name
                , songs: artistSongs
                , albums: artistAlbums
            )
        }
    }
    
    // MARK: - Detail Resolution
    private func songDetails(_ linkedSongs: [Song], _ tempBasis: DataBasis) -> [Song] {
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
    
    private func albumDetails(_ linkedAlbums: [Album], _ tempBasis: DataBasis) -> [Album] {
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
    
    private func artistDetails(_ linkedArtists: [Artist], _ tempBasis: DataBasis) -> [Artist] {
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
