//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/13/24.
//

import Foundation
import Models

extension Song: AddAssertable {
    public typealias Update = SongUpdate
    public var model: AssertionModel { .song }
    public var code: AssertionCode { .addSong(self) }
    public func willModify(_ basis: DataBasis) -> Bool { true }
}

extension SongUpdate: UpdateAssertable {
    public var model: AssertionModel { .song }
    public var code: AssertionCode { .updateSong(self) }
    
    public func willModify(_ basis: DataBasis) -> Bool {
        guard let song = basis.songMap[self.songID] else { return false }
        return self.willModify(song)
    }
}

extension Album: AddAssertable {
    public typealias Update = AlbumUpdate
    public var model: AssertionModel { .album }
    public var code: AssertionCode { .addAlbum(self) }
    public func willModify(_ basis: DataBasis) -> Bool { true }
}

extension AlbumUpdate: UpdateAssertable {
    public var model: AssertionModel { .album }
    public var code: AssertionCode { .updateAlbum(self) }
    
    public func willModify(_ basis: DataBasis) -> Bool {
        guard let album = basis.albumMap[self.albumID] else { return false }
        return self.willModify(album)
    }
}

extension Artist: AddAssertable {
    public typealias Update = ArtistUpdate
    public var model: AssertionModel { .artist }
    public var code: AssertionCode { .addArtist(self) }
    public func willModify(_ basis: DataBasis) -> Bool { true }
}

extension ArtistUpdate: UpdateAssertable {
    public var model: AssertionModel { .artist }
    public var code: AssertionCode { .updateArtist(self) }
    
    public func willModify(_ basis: DataBasis) -> Bool {
        guard let artist = basis.artistMap[self.artistID] else { return false }
        return self.willModify(artist)
    }
}
