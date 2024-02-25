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
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let fileManager: FileManager
    
    private let songsURL: URL
    private let albumsURL: URL
    private let artistsURL: URL
    
    public init (
        decoder: JSONDecoder = JSONDecoder()
        , encoder: JSONEncoder = JSONEncoder()
        , fileManager: FileManager = FileManager()
        , songsURL: URL? = nil
        , albumsURL: URL? = nil
        , artistsURL: URL? = nil
    ) throws {
        self.decoder = decoder
        self.encoder = encoder
        self.fileManager = fileManager
        self.songsURL = songsURL ?? JSONArrayDatabase.songsDefaultURL_ios
        self.albumsURL = albumsURL ?? JSONArrayDatabase.albumsDefaultURL_ios
        self.artistsURL = artistsURL ?? JSONArrayDatabase.artistsDefaultURL_ios
        
        songs = try initFromURL([Song].self, from: self.songsURL) ?? []
        albums = try initFromURL([Album].self, from: self.albumsURL) ?? []
        artists = try initFromURL([Artist].self, from: self.artistsURL) ?? []
    }
    
    public func get<Getting: Model> (_ getting: Getting.Type) async throws -> [Getting] {
        return try table(for: getting)
    }
    
    public func get<Getting: Model, From: Model> (_ getting: Getting.Type, from object: From) async throws -> [Getting] {
        guard
            let getting = getting as? any RelationalModel.Type,
            let object = object as? any RelationalModel
        else {
            throw DatabaseError.unresolvedRelation(From.self, Getting.self)
        }
        
        let table = try table(for: getting)
        
        let results = try table.filter { item in
            try item.to(object).contains(object.id)
        }
        
        return results as! [Getting]
    }
    
    public func save<T: Model>(_ objects: [T]) async throws {
        var table = try table(for: T.self)
        var new = [T]()
        
        objects.forEach { objectToSave in
            if let index = table.firstIndex(where: {row in row.id == objectToSave.id}) {
                table[index] = objectToSave
            } else {
                new.append(objectToSave)
            }
        }
        
        table += new
        try setTable(table)
        
        let url = try url(for: T.self)
        try saveToURL(table, to: url)
    }
    
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
    
    private func table<T:Model>(for object: T.Type) throws -> [T] {
        switch T.self {
        case is Song.Type: return self.songs as! [T]
        case is Album.Type: return self.albums as! [T]
        case is Artist.Type: return self.artists as! [T]
        default: throw DatabaseError.unresolvedTable(T.self)
        }
    }
    
    private func setTable<T:Model>(_ objects: [T]) throws {
        switch T.self {
        case is Song.Type: self.songs = objects as! [Song]
        case is Album.Type: self.albums = objects as! [Album]
        case is Artist.Type: self.artists = objects as! [Artist]
        default: throw DatabaseError.unresolvedTable(T.self)
        }
    }
    
    private func url<T:Model>(for object: T.Type) throws -> URL {
        switch T.self {
        case is Song.Type: return self.songsURL
        case is Album.Type: return self.albumsURL
        case is Artist.Type: return self.artistsURL
        default: throw DatabaseError.unresolvedTable(T.self)
        }
    }
    
    private static let songsDefaultURL_ios = URL.applicationSupportDirectory
        .appending(component: "Database/")
        .appending(component: "songs.json")
    private static let albumsDefaultURL_ios = URL.applicationSupportDirectory
        .appending(component: "Database/")
        .appending(component: "albums.json")
    private static let artistsDefaultURL_ios = URL.applicationSupportDirectory
        .appending(component: "Database/")
        .appending(component: "artists.json")
}
