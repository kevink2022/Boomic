//
//  JSONDatabase.swift
//
//
//  Created by Kevin Kelly on 2/12/24.
//

import Foundation
import Models

final public class CacheDatabase: Database {
    
    private var modelCache: ModelCache
    
    private let songsURL: URL
    private let albumsURL: URL
    private let artistsURL: URL
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init (
        decoder: JSONDecoder = JSONDecoder()
        , encoder: JSONEncoder = JSONEncoder()
        , songsURL: URL? = nil
        , albumsURL: URL? = nil
        , artistsURL: URL? = nil
    ) {
        self.decoder = decoder
        self.encoder = encoder
        self.songsURL = songsURL ?? C.songsDefaultURL_ios
        self.albumsURL = albumsURL ?? C.albumsDefaultURL_ios
        self.artistsURL = artistsURL ?? C.artistsDefaultURL_ios
        
        self.modelCache = ModelCache(songs: [], albums: [], artists: [])
        
        // TODO: Handle errors
        // (any guesses on how long until i get to this?)
        let songs = (try? initFromURL([Song].self, from: self.songsURL)) ?? []
        let albums = (try? initFromURL([Album].self, from: self.albumsURL)) ?? []
        let artists = (try? initFromURL([Artist].self, from: self.artistsURL)) ?? []
        
        self.modelCache = ModelCache(songs: songs, albums: albums, artists: artists)
    }
    
    // MARK: - Public
    
    public func getSongs(for ids: [UUID]? = nil) -> [Song] {
        if let ids = ids {
            return ids.compactMap { modelCache.songMap[$0] }
        } else {
            return modelCache.allSongs
        }
    }
    
    public func getAlbums(for ids: [UUID]? = nil) -> [Album] {
        if let ids = ids {
            return ids.compactMap { modelCache.albumMap[$0] }
        } else {
            return modelCache.allAlbums
        }
    }
    
    public func getArtists(for ids: [UUID]? = nil) -> [Artist] {
        if let ids = ids {
            return ids.compactMap { modelCache.artistMap[$0] }
        } else {
            return modelCache.allArtists
        }
    }
    
    public func addSongs(_ songs: [Song]) async {
        let resolver = ModelResolver(currentCache: modelCache)
        
        // TODO: Some kind of queueing probably for any mutation ops.
        modelCache = await resolver.addSongs(songs)
    }

    // MARK: - Private Helpers
    
    private func initFromURL<T: Decodable>(_ type: T.Type, from url: URL) throws -> T? {
        do {
            let data = try Data.init(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        }
        
        catch DecodingError.dataCorrupted {
            throw DatabaseError.dataCorrupted(url)
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSCocoaErrorDomain {
                switch nsError.code {
                case NSFileReadNoSuchFileError: return nil
                default: break
                }
            }
            
            throw error
        }
    }
    
    private func saveToURL(_ object: any Encodable, to url: URL) throws {
        let data = try encoder.encode(object)
        try data.write(to: url)
    }
    
    // MARK: - Mapping conifuguration
    
    private func getURL<T:Model>(for object: T.Type) throws -> URL {
        switch T.self {
        case is Song.Type: return self.songsURL
        case is Album.Type: return self.albumsURL
        case is Artist.Type: return self.artistsURL
        default: throw DatabaseError.unresolvedModel(T.self)
        }
    }
    
    // MARK: - Constants
    
    private typealias C = Constants
    private struct Constants {
        static let songsDefaultURL_ios = URL.applicationSupportDirectory
            .appending(component: "Database/")
            .appending(component: "songs.json")
        static let albumsDefaultURL_ios = URL.applicationSupportDirectory
            .appending(component: "Database/")
            .appending(component: "albums.json")
        static let artistsDefaultURL_ios = URL.applicationSupportDirectory
            .appending(component: "Database/")
            .appending(component: "artists.json")
    }
}

// MARK: - ModelCache -
private final class ModelCache {
    public let songMap: [UUID: Song]
    public let albumMap: [UUID: Album]
    public let artistMap: [UUID: Artist]
    
    public let allSongs: [Song]
    public let allAlbums: [Album]
    public let allArtists: [Artist]
    
    init(
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
private final class ModelResolver {
    
    private let currentCache: ModelCache
    
    private lazy var albumTitles: [String:UUID] = {
        currentCache.allAlbums
            .reduce(into: [String:UUID]()) { dict, album in dict[album.title] = album.id }
    }()
    
    private lazy var artistNames: [String:UUID] = {
        currentCache.allArtists
            .reduce(into: [String:UUID]()) { dict, artist in dict[artist.name] = artist.id }
    }()
    
    init(currentCache: ModelCache) {
        self.currentCache = currentCache
    }
    
    public func addSongs(_ unlinkedSongs: [Song]) async -> ModelCache {
        
        async let albumTitleLinks_await = songsToTitleLinks(unlinkedSongs)
        async let artistNameLinks_await = songsToNameLinks(unlinkedSongs)
        
        let (albumTitleLinks, artistNameLinks) = await (albumTitleLinks_await, artistNameLinks_await)
        
        async let linkedSongs_await = linkSongs(unlinkedSongs, albumTitles: albumTitleLinks, artistNames: artistNameLinks)
        let affectedAlbums = albumTitleLinks.keys.map { $0 as String }
        let affectedArtists = albumTitleLinks.keys.map { $0 as String }
        
        let linkedSongs = await linkedSongs_await
        
        async let linkedAlbums_await = linkAlbums(albumTitleLinks, linkedSongs: linkedSongs)
        async let linkedArtists_await = linkArtists(artistNameLinks, linkedSongs: linkedSongs)
        
        let (linkedAlbums, linkedArtists) = await (linkedAlbums_await, linkedArtists_await)
        let tempCache = ModelCache(songs: linkedSongs, albums: linkedAlbums, artists: linkedArtists)
        
        async let newSongs_await = songDetails(linkedSongs, tempCache)
        async let newAlbums_await = albumDetails(linkedAlbums, tempCache)
        async let newArtists_await = artistDetails(linkedArtists, tempCache)
        
        let (newSongs, newAlbums, newArtists) = await (newSongs_await, newAlbums_await, newArtists_await)
        
        let currentSongMap = currentCache.songMap
        let currentAlbumMap = currentCache.albumMap
        let currentArtistMap = currentCache.artistMap
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
        
        return ModelCache(
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
            
            let album = currentCache.albumMap[albumID] ?? Album(id: albumID, title: title)
            
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
            
            let artist = currentCache.artistMap[artistID] ?? Artist(id: artistID, name: name, songs: [], albums: [])
            
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
    private func songDetails(_ linkedSongs: [Song], _ tempCache: ModelCache) -> [Song] {
        return linkedSongs.map { song in

            let albums = song.albums
                .compactMap { tempCache.albumMap[$0] ?? currentCache.albumMap[$0] }
                .sorted { Album.alphabeticalSort($0, $1) }
                
            
            let artists = song.artists
                .compactMap { tempCache.artistMap[$0] ?? currentCache.artistMap[$0] }
                .sorted { Artist.alphabeticalSort($0, $1) }
                
            
            return Song(
                existingSong: song
                , artists: artists.map { $0.id }
                , albums: albums.map { $0.id }
            )
        }
    }
    
    private func albumDetails(_ linkedAlbums: [Album], _ tempCache: ModelCache) -> [Album] {
        return linkedAlbums.map { album in

            let songs = album.songs
                .compactMap { tempCache.songMap[$0] ?? currentCache.songMap[$0] }
                .sorted { Song.discAndTrackNumberSort($0, $1) }
                
            
            let artists = album.artists
                .compactMap { tempCache.artistMap[$0] ?? currentCache.artistMap[$0] }
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
    
    private func artistDetails(_ linkedArtists: [Artist], _ tempCache: ModelCache) -> [Artist] {
        return linkedArtists.map { artist in

            let songs = artist.songs
                .compactMap { tempCache.songMap[$0] ?? currentCache.songMap[$0] }
                .sorted { Song.discAndTrackNumberSort($0, $1) }
                
            
            let albums = artist.albums
                .compactMap { tempCache.albumMap[$0] ?? currentCache.albumMap[$0] }
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
