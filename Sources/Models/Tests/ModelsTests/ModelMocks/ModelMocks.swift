//
//  File.swift
//  
//
//  Created by Kevin Kelly on 2/7/24.
//

import Foundation
import Models

extension Song {
    static let girlsApartment : [SongID] = [
        Song.aCagedPersona.id
        , Song.labyrinth.id
        , Song.noMoreNews.id
        , Song.burningRumTea.id
    ]

    static let aCagedPersona = Song(
        id: SongID()
        , source: .local(URL.documentsDirectory)
        , duration: 219
        , title: "A Caged Persona"
        , artist: Artist.saxi.id
        , album: Album.girlsApartment.id
        , art: nil
    )
    static let labyrinth = Song(
        id: SongID()
        , source: .local(URL.documentsDirectory)
        , duration: 238
        , title: "Labyrinth"
        , artist: Artist.con.id
        , album: Album.girlsApartment.id
        , art: nil
    )
    static let noMoreNews = Song(
        id: SongID()
        , source: .local(URL.documentsDirectory)
        , duration: 223
        , title: "No More News"
        , artist: Artist.saxi.id
        , album: Album.girlsApartment.id
        , art: nil
    )
    static let burningRumTea = Song(
        id: SongID()
        , source: .local(URL.documentsDirectory)
        , duration: 296
        , title: "Burning Rum Tea"
        , artist: Artist.con.id
        , album: Album.girlsApartment.id
        , art: nil
    )
}

extension Album {
    static let girlsApartment = Album(
        id: AlbumID()
        , title: "Girls Apartment"
        , songs: Song.girlsApartment
        , art: nil
        , artist: nil
    )
}

extension Artist {
    static let saxi = Artist(
        id: ArtistID()
        , name: "SaXi"
        , albums: []
    )
    static let con = Artist(
        id: ArtistID()
        , name: "CON"
        , albums: []
    )

}

/*
1 A Caged Persona 3:39
2 Voyage Gothic Bold 3:37
3 Fall Coin Sunset 4:22
4 In the Shade 3:53
5 Labyrinth 3:58
6 Tea Break 3:37
7 No More News 3:43
8 Parfait amour 4:39
9 Burning Rum Tea 4:56
10 Un fiore rosso (Take1) 2:52
 */
