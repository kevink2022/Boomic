//
//  JSONDatabase.swift
//
//
//  Created by Kevin Kelly on 2/12/24.
//

import Foundation
import Models

final public class JSONArrayDatabase: Database {
    
    private var songs = [Song]()
    private var albums = [Album]()
    private var artists = [Artist]()
    
    private var songSort: (Song, Song) -> (Bool)
    private var albumSort: (Album, Album) -> (Bool)
    private var artistSort: (Artist, Artist) -> (Bool)
    
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
        , songSort: ((Song, Song) -> (Bool))? = nil
        , albumSort: ((Album, Album) -> (Bool))? = nil
        , artistSort: ((Artist, Artist) -> (Bool))? = nil
    ) throws {
        self.decoder = decoder
        self.encoder = encoder
        self.songsURL = songsURL ?? C.songsDefaultURL_ios
        self.albumsURL = albumsURL ?? C.albumsDefaultURL_ios
        self.artistsURL = artistsURL ?? C.artistsDefaultURL_ios
        self.songSort = songSort ?? C.songsAlphabeticalSort
        self.albumSort = albumSort ?? C.albumAlphabeticalSort
        self.artistSort = artistSort ?? C.artistAlphabeticalSort
        
        songs = try initFromURL([Song].self, from: self.songsURL) ?? []
        albums = try initFromURL([Album].self, from: self.albumsURL) ?? []
        artists = try initFromURL([Artist].self, from: self.artistsURL) ?? []
    }
    
    // MARK: - Public
    
    public func get<GetT: Model> (_ getT: GetT.Type) async throws -> [GetT] {
        return try getTable(for: getT)
    }
    
    public func get<GetT: Model, FromT: Model> (_ getT: GetT.Type, from object: FromT) async throws -> [GetT] {
        guard
            let getT = getT as? any RelationalModel.Type,
            let object = object as? any RelationalModel
        else {
            throw DatabaseError.unresolvedRelation(FromT.self, GetT.self)
        }
        
        let table = try getTable(for: getT)
        
        let results = try table.filter { item in
            try item.to(object).contains(object.id)
        }
        
        return results as! [GetT]
    }
    
    public func save<T: Model>(_ objects: [T]) async throws {
        var table = try getTable(for: T.self)
        var new = [T]()
        
        objects.forEach { objectToSave in
            if let index = table.firstIndex(where: {row in row.id == objectToSave.id}) {
                table[index] = objectToSave
            } else {
                new.append(objectToSave)
            }
        }
        
        let newSorted = try new.sorted(by: getSort(for: T.self))
        let tableSorted = try merge(table, newSorted)
        try setTable(tableSorted)
        
        let url = try getURL(for: T.self)
        try saveToURL(tableSorted, to: url)
    }
//    
//    public func delete<T: Model>(_ objects: [T]) async throws {
//        var table = try getTable(for: T.self)
//        
//        
//    }
//    
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
    
    /// Adapted from: https://www.kodeco.com/741-swift-algorithm-club-swift-merge-sort/page/2
    func merge<T: Model>(_ left: [T], _ right: [T]) throws -> [T] {
        var leftIndex = 0
        var rightIndex = 0
        let sort = try getSort(for: T.self)

        var orderedArray: [T] = []

        while leftIndex < left.count && rightIndex < right.count {
            let leftElement = left[leftIndex]
            let rightElement = right[rightIndex]

            if sort(leftElement, rightElement) {
                orderedArray.append(leftElement)
                leftIndex += 1
            } else if sort(rightElement, leftElement) {
                orderedArray.append(rightElement)
                rightIndex += 1
            } else {
                orderedArray.append(leftElement)
                leftIndex += 1
                orderedArray.append(rightElement)
                rightIndex += 1
            }
        }
        
        if leftIndex < left.count {
            orderedArray.append(contentsOf: left.suffix(from: leftIndex))
        }

        if rightIndex < right.count {
            orderedArray.append(contentsOf: right.suffix(from: rightIndex))
        }

        return orderedArray
    }
    
    // MARK: - Mapping conifuguration
    
    private func getTable<T:Model>(for object: T.Type) throws -> [T] {
        switch T.self {
        case is Song.Type: return self.songs as! [T]
        case is Album.Type: return self.albums as! [T]
        case is Artist.Type: return self.artists as! [T]
        default: throw DatabaseError.unresolvedModel(T.self)
        }
    }
    
    private func setTable<T:Model>(_ objects: [T]) throws {
        switch T.self {
        case is Song.Type: self.songs = objects as! [Song]
        case is Album.Type: self.albums = objects as! [Album]
        case is Artist.Type: self.artists = objects as! [Artist]
        default: throw DatabaseError.unresolvedModel(T.self)
        }
    }
    
    private func getURL<T:Model>(for object: T.Type) throws -> URL {
        switch T.self {
        case is Song.Type: return self.songsURL
        case is Album.Type: return self.albumsURL
        case is Artist.Type: return self.artistsURL
        default: throw DatabaseError.unresolvedModel(T.self)
        }
    }
    
    private func getSort<T:Model>(for object: T.Type) throws -> (T, T) -> (Bool) {
        switch T.self {
        case is Song.Type: return self.songSort as! (T, T) -> (Bool)
        case is Album.Type: return self.albumSort as! (T, T) -> (Bool)
        case is Artist.Type: return self.artistSort as! (T, T) -> (Bool)
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
        
        static func songsAlphabeticalSort(_ songA: Song, _ songB: Song) -> Bool {
            songA.label.compare(songB.label, options: .caseInsensitive) == .orderedAscending
        }
        static func albumAlphabeticalSort(_ albumA: Album, _ albumB: Album) -> Bool {
            albumA.title.compare(albumB.title, options: .caseInsensitive) == .orderedAscending
        }
        static func artistAlphabeticalSort(_ artistA: Artist, _ artistB: Artist) -> Bool {
            artistA.name.compare(artistB.name, options: .caseInsensitive) == .orderedAscending
        }
    }
}
