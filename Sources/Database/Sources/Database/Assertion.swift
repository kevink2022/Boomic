//
//  File.swift
//  
//
//  Created by Kevin Kelly on 5/25/24.
//

import Foundation
import Models

public enum Assertion: Codable, Equatable {
    case addSong(Song)
    case addAlbum(Album)
    case addArtist(Artist)
    case updateSong(SongUpdate)
    case updateAlbum(AlbumUpdate)
    case updateArtist(ArtistUpdate)
    case deleteSong(UUID)
    case deleteAlbum(UUID)
    case deleteArtist(UUID)
    
    
    /// order matters, the assertions at later indexes will overwrite earlier ones.
    public static func flatten(_ assertions: [KeySet<Assertion>]) -> KeySet<Assertion> {
        let count = assertions.count
        guard count != 0 else { return KeySet() }
        if count == 1 { return assertions.first! }
        
        let middle = count/2
        
        let left = flatten(Array(assertions.prefix(middle)))
        let right = flatten(Array(assertions.suffix(from: middle)))
    
        return union(left: left, right: right)
    }
    
    private static func union(left: KeySet<Assertion>, right: KeySet<Assertion>) -> KeySet<Assertion> {
        
        var merged = KeySet<Assertion>()
        
        left.forEach { leftAssertion in
            if let rightAssertion = right[leftAssertion] {
                merged.insert(combine(left: leftAssertion, right: rightAssertion))
            } else {
                merged.insert(leftAssertion)
            }
        }
        
        right.forEach { rightAssertion in
            if !merged.contains(rightAssertion) {
                merged.insert(rightAssertion)
            }
        }
        
        return merged
    }
    
    private static func combine(left: Assertion, right: Assertion) -> Assertion {
        guard left.id == right.id && left.model == right.model else { return left }
        
        switch left.operation {
        case .add:
            switch right.operation {
            case .add: return right     /* unexpected */
            case .update: return addApplyUpdate(add: left, update: right)
            case .delete: return right
            }
        case .update:
            switch right.operation {
            case .add: return left      /* unexpected */
            case .update: return updateApplyUpdate(left: left, right: right)
            case .delete: return right
            }
        case .delete:
            switch right.operation {
            case .add: return right
            case .update: return left   /* unexpected */
            case .delete: return left   /* unexpected */
            }
        }
    }
    
    private static func addApplyUpdate(add: Assertion, update: Assertion) -> Assertion {
        guard
            add.id == update.id
            && add.model == update.model
            && add.operation == .add
            && update.operation == .update
        else { return add }
        
        switch (add, update) {
        case (.addSong(let addModel), .updateSong(let updateModel)):
            return .addSong(addModel.apply(update: updateModel))
            
        case (.addAlbum(let addModel), .updateAlbum(let updateModel)):
            return .addAlbum(addModel.apply(update: updateModel))
            
        case (.addArtist(let addModel), .updateArtist(let updateModel)):
            return .addArtist(addModel.apply(update: updateModel))
            
        default: break
        }
        
        return add
    }
    
    private static func updateApplyUpdate(left: Assertion, right: Assertion) -> Assertion {
        guard
            left.id == right.id
            && left.model == right.model
            && left.operation == .update
            && right.operation == .update
        else { return left }
        
        switch (left, right) {
        case (.updateSong(let updateLeft), .updateSong(let updateRight)):
            return .updateSong(updateLeft.apply(update: updateRight))
            
        case (.updateAlbum(let updateLeft), .updateAlbum(let updateRight)):
            return .updateAlbum(updateLeft.apply(update: updateRight))
            
        case (.updateArtist(let updateLeft), .updateArtist(let updateRight)):
            return .updateArtist(updateLeft.apply(update: updateRight))
            
        default: break
        }
        
        return left
    }
}

extension Assertion {
    public enum Operation {
        case add
        case update
        case delete
    }
    
    public var operation: Self.Operation {
        switch self {
        case .addSong(_), .addAlbum(_), .addArtist(_): .add
        case .updateSong(_), .updateAlbum(_), .updateArtist(_): .update
        case .deleteSong(_), .deleteAlbum(_), .deleteArtist(_): .delete
        }
    }
    
    public enum Model {
        case song
        case album
        case artist
    }
    
    public var model: Self.Model {
        switch self {
        case .addSong(_), .updateSong(_), .deleteSong(_): .song
        case .addAlbum(_), .updateAlbum(_), .deleteAlbum(_): .album
        case .addArtist(_), .updateArtist(_), .deleteArtist(_): .artist
        }
    }
}

extension Assertion: Identifiable, Hashable {
    
    public var id: UUID {
    switch self {
        case .addSong(let song): song.id
        case .addAlbum(let album): album.id
        case .addArtist(let artist): artist.id
        case .updateSong(let songUpdate): songUpdate.id
        case .updateAlbum(let albumUpdate): albumUpdate.id
        case .updateArtist(let artistUpdate): artistUpdate.id
        case .deleteSong(let uuid), .deleteAlbum(let uuid), .deleteArtist(let uuid): uuid
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Assertion {
    public enum Error: LocalizedError {
        case illegalArgument
    }
}

extension Assertion {
    public func willModify(_ basis: DataBasis) -> Bool {
        switch self {
        case .updateSong(let update): return update.willModify(basis)
        case .updateAlbum(let update): return update.willModify(basis)
        case .updateArtist(let update): return update.willModify(basis)
        case .deleteSong(let id): return basis.songMap[id] != nil
        case .deleteAlbum(let id): return basis.albumMap[id] != nil
        case .deleteArtist(let id): return basis.artistMap[id] != nil
        default: return true
        }
    }
}

extension SongUpdate {
    public func willModify(_ basis: DataBasis) -> Bool {
        guard let song = basis.songMap[self.songID] else { return false }
        return self.willModify(song)
    }
}

extension AlbumUpdate {
    public func willModify(_ basis: DataBasis) -> Bool {
        guard let album = basis.albumMap[self.albumID] else { return false }
        return self.willModify(album)
    }
}

extension ArtistUpdate {
    public func willModify(_ basis: DataBasis) -> Bool {
        guard let artist = basis.artistMap[self.artistID] else { return false }
        return self.willModify(artist)
    }
}
