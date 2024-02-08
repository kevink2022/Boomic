//
//  File.swift
//  
//
//  Created by Kevin Kelly on 2/7/24.
//

import Foundation
import Models

extension Song {
    static let girlsApartment : [Song] = [
        Song.aCagedPersona
        , Song.labyrinth
        , Song.noMoreNews
        , Song.burningRumTea
    ]

    static let aCagedPersona = Song(
        source: .local(URL.documentsDirectory)
        , duration: 219
        , title: "A Caged Persona"
        , artist: Artist.saxi
        , album: Album.girlsApartment2
        , art: nil
    )
    static let labyrinth = Song(
        source: .local(URL.documentsDirectory)
        , duration: 238
        , title: "Labyrinth"
        , artist: Artist.con
        , album: Album.girlsApartment2
        , art: nil
    )
    static let noMoreNews = Song(
        source: .local(URL.documentsDirectory)
        , duration: 223
        , title: "No More News"
        , artist: Artist.saxi
        , album: Album.girlsApartment2
        , art: nil
    )
    static let burningRumTea = Song(
        source: .local(URL.documentsDirectory)
        , duration: 296
        , title: "Burning Rum Tea"
        , artist: Artist.con
        , album: Album.girlsApartment2
        , art: nil
    )
}

extension Album {
    static let girlsApartment = Album(
        title: "Girls Apartment"
        , songs: []
        , art: nil
        , artist: nil
    )
    // Prevent looping inits in previews
    static let girlsApartment2 = Album(
        title: "Girls Apartment"
        , songs: []
        , art: nil
        , artist: nil
    )
}

extension Artist {
    static let saxi = Artist(
        name: "SaXi"
        , albums: []
    )
    static let con = Artist(
        name: "CON"
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
