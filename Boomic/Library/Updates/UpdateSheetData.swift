//
//  UpdateSheetData.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/15/24.
//

import Foundation
import Models

struct WorkingSheetData {
    var working: SheetData
    let base: SheetData
    
    var willModify: Bool { base != working }
    
    func asSongUpdate(on song: Song, multiEdit: Bool = true) -> SongUpdate {
        var erasing = Set<PartialKeyPath<Song>>()
        
        if !multiEdit {
            if eraseTitle(from: song.title) { erasing.insert(\.title) }
            if eraseTrackNumber(from: song.trackNumber) { erasing.insert(\.trackNumber) }
        }
        if eraseDiscNumber(from: song.discNumber) { erasing.insert(\.discNumber) }
        if eraseArt(from: song.art) { erasing.insert(\.art) }
        if eraseArtistName(from: song.title) { erasing.insert(\.artistName) }
        if eraseAlbumTitle(from: song.title) { erasing.insert(\.albumTitle) }
        if eraseRating(from: song.rating) { erasing.insert(\.rating) }
        
        let update = SongUpdate(
            song: song
            , title: !multiEdit ? newTitle(from: song.title) : nil
            , trackNumber: !multiEdit ? newTrackNumber(from: song.trackNumber) : nil
            , discNumber: newDiscNumber(from: song.discNumber)
            , art: newArt(from: song.art)
            , artistName: newArtistName(from: song.artistName)
            , albumTitle: newAlbumTitle(from: song.albumTitle)
            , rating: newRating(from: song.rating)
            , tags: !multiEdit ? newTags(from: song.tags) : working.tags.reduce(into: song.tags, { $0.insert($1) })
            , erasing: erasing.count > 0 ? erasing : nil
        )
        
        return update
    }
    
    func asAlbumUpdate(on album: Album, multiEdit: Bool = true) -> AlbumUpdate {
        var erasing = Set<PartialKeyPath<Album>>()
        
        if !multiEdit {
            if eraseTitle(from: album.title) { erasing.insert(\.title) }
        }
        if eraseArt(from: album.art) { erasing.insert(\.art) }
        if eraseArtistName(from: album.title) { erasing.insert(\.artistName) }
        
        let update = AlbumUpdate(
            album: album
            , title: !multiEdit ? newTitle(from: album.title) : nil
            , art: newArt(from: album.art)
            , artistName: newArtistName(from: album.artistName)
            , erasing: erasing.count > 0 ? erasing : nil
        )
        
        return update
    }
    
    func asArtistUpdate(on artist: Artist, multiEdit: Bool = true) -> ArtistUpdate {
        var erasing = Set<PartialKeyPath<Artist>>()
        
        if !multiEdit {
            if eraseTitle(from: artist.name) { erasing.insert(\.name) }
        }
        if eraseArt(from: artist.art) { erasing.insert(\.art) }
        
        let update = ArtistUpdate(
            artist: artist
            , name: !multiEdit ? newTitle(from: artist.name) : nil
            , art: newArt(from: artist.art)
            , erasing: erasing.count > 0 ? erasing : nil
        )
        
        return update
    }
    
    private func new<T: Equatable>(working: T?, base: T?, model: T?) -> T? {
        if working != base
            && working != nil
            && working != model
        { return working }
        else { return nil }
    }
    
    private func erase<T: Equatable>(working: T?, base: T?, model: T?) -> Bool {
        if working != base
            && working == nil
            && working != model
        { return true }
        else { return false }
    }
    
    private func newTitle(from model: String?) -> String? {
        let working: String? = SheetData.fromSheet(working.title)
        let base: String? = SheetData.fromSheet(base.title)
        return new(working: working, base: base, model: model)
    }
    
    private func newTrackNumber(from model: Int?) -> Int? {
        let working: Int? = SheetData.fromSheet(working.trackNumber)
        let base: Int? = SheetData.fromSheet(base.trackNumber)
        return new(working: working, base: base, model: model)
    }
    
    private func newDiscNumber(from model: Int?) -> Int? {
        let working: Int? = SheetData.fromSheet(working.discNumber)
        let base: Int? = SheetData.fromSheet(base.discNumber)
        return new(working: working, base: base, model: model)
    }
    
    private func newArtistName(from model: String?) -> String? {
        let working: String? = SheetData.fromSheet(working.artistName)
        let base: String? = SheetData.fromSheet(base.artistName)
        return new(working: working, base: base, model: model)
    }
    
    private func newAlbumTitle(from model: String?) -> String? {
        let working: String? = SheetData.fromSheet(working.albumTitle)
        let base: String? = SheetData.fromSheet(base.albumTitle)
        return new(working: working, base: base, model: model)
    }
    
    private func newRating(from rating: Int?) -> Int? {
        new(working: working.rating, base: base.rating, model: rating)
    }
    
    private func newArt(from art: MediaArt?) -> MediaArt? {
        new(working: working.art, base: base.art, model: art)
    }
    
    private func newTags(from tags: Set<Tag>) -> Set<Tag>? {
        new(working: working.tags, base: base.tags, model: tags)
    }
    
    private func eraseTitle(from model: String?) -> Bool {
        let working: String? = SheetData.fromSheet(working.title)
        let base: String? = SheetData.fromSheet(base.title)
        return erase(working: working, base: base, model: model)
    }
    
    private func eraseTrackNumber(from model: Int?) -> Bool {
        let working: Int? = SheetData.fromSheet(working.trackNumber)
        let base: Int? = SheetData.fromSheet(base.trackNumber)
        return erase(working: working, base: base, model: model)
    }
    
    private func eraseDiscNumber(from model: Int?) -> Bool {
        let working: Int? = SheetData.fromSheet(working.discNumber)
        let base: Int? = SheetData.fromSheet(base.discNumber)
        return erase(working: working, base: base, model: model)
    }
    
    private func eraseArtistName(from model: String?) -> Bool {
        let working: String? = SheetData.fromSheet(working.artistName)
        let base: String? = SheetData.fromSheet(base.artistName)
        return erase(working: working, base: base, model: model)
    }
    
    private func eraseAlbumTitle(from model: String?) -> Bool {
        let working: String? = SheetData.fromSheet(working.albumTitle)
        let base: String? = SheetData.fromSheet(base.albumTitle)
        return erase(working: working, base: base, model: model)
    }
    
    private func eraseRating(from rating: Int?) -> Bool {
        erase(working: working.rating, base: base.rating, model: rating)
    }
    
    private func eraseArt(from art: MediaArt?) -> Bool {
        erase(working: working.art, base: base.art, model: art)
    }
}

struct SheetData: Equatable {
    var title: String = ""
    var trackNumber: String = ""
    var discNumber: String = ""
    
    var artistName: String = ""
    var albumTitle: String = ""
    
    var tags: Set<Tag> = []
    
    var rating: Int? { didSet { if rating == 0 {rating = nil} } }
    var art: MediaArt?
    
    init(song: Song) {
        self.title = Self.toSheet(song.title)
        self.trackNumber = Self.toSheet(song.trackNumber)
        self.discNumber = Self.toSheet(song.discNumber)
        self.art = song.art
        self.artistName = Self.toSheet(song.artistName)
        self.albumTitle = Self.toSheet(song.albumTitle)
        self.rating = song.rating
        self.tags = song.tags
    }
    
    // Clear any data that isn't the same between its current data and a new song
    mutating func add(song: Song) {
        if self.title != Self.toSheet(song.title) { self.title = "" }
        if self.trackNumber != Self.toSheet(song.trackNumber) { self.trackNumber = "" }
        if self.discNumber != Self.toSheet(song.discNumber) { self.discNumber = "" }
        if self.art != song.art { self.art = nil }
        if self.artistName != Self.toSheet(song.artistName) { self.artistName = "" }
        if self.albumTitle != Self.toSheet(song.albumTitle) { self.albumTitle = "" }
        if self.rating != song.rating { self.rating = nil }
        if self.tags != song.tags { self.tags = [] }
    }
    
    init(album: Album) {
        self.title = Self.toSheet(album.title)
        self.art = album.art
        self.artistName = Self.toSheet(album.artistName)
    }
    
    mutating func add(album: Album) {
        if self.title != Self.toSheet(album.title) { self.title = "" }
        if self.art != album.art { self.art = nil }
        if self.artistName != Self.toSheet(album.artistName) { self.artistName = "" }
    }
    
    init(artist: Artist) {
        self.title = Self.toSheet(artist.name)
        self.art = artist.art
    }
    
    mutating func add(artist: Artist) {
        if self.title != Self.toSheet(artist.name) { self.title = "" }
        if self.art != artist.art { self.art = nil }
    }
    
    static func == (lhs: SheetData, rhs: SheetData) -> Bool {
        lhs.title == rhs.title
        && lhs.trackNumber ==  rhs.trackNumber
        && lhs.discNumber == rhs.discNumber
        && lhs.art == rhs.art
        && lhs.artistName == rhs.artistName
        && lhs.albumTitle == rhs.albumTitle
        && lhs.rating == rhs.rating
        && lhs.tags == rhs.tags
    }
        
    static func toSheet(_ int: Int?) -> String {
        if let int = int { return String(int) }
        return ""
    }
    
    static func fromSheet(_ string: String) -> Int? {
        if string == "" { return nil }
        return Int(string)
    }
    
    static func toSheet(_ string: String?) -> String {
        if let string = string { return string }
        return ""
    }
    
    static func fromSheet(_ string: String) -> String? {
        if string == "" { return nil }
        return string
    }
}

