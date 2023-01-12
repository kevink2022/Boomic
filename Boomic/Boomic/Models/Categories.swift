//
//  Categories.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/14/22.
//

import Foundation

enum Categories: String, CaseIterable, Identifiable
{
    case playlists, songs, albums, artists
    
    var id : String {self.rawValue}
}

struct Category
{
    let category : Categories
    let image : ImageSource
    let label : String
    
    static let playlists = Category(
        category: .playlists,
        image: .systemName("music.note.list"),
        label: "Playlists"
    )
    
    static let songs = Category(
        category: .songs,
        image: .systemName("music.note"),
        label: "Songs"
    )
    
    static let albums = Category(
        category: .albums,
        image: .systemName("opticaldisc"),
        label: "Albums"
    )
    
    static let artists = Category(
        category: .artists,
        image: .systemName("person"),
        label: "Artists"
    )
}

extension BoomicManager
{
    func categoryInfo(_ category: Categories) -> Category
    {
        switch category
        {
        case .playlists: return Category.playlists
        case .songs:     return Category.songs
        case .albums:    return Category.albums
        case .artists:   return Category.artists
        }
    }
}

