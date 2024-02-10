//
//  File.swift
//  
//
//  Created by Kevin Kelly on 2/7/24.
//

import Foundation
import Models

extension Song {
    static let aCagedPersonaJSON = """
    {
      "id": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
      "source": {
        "local": "file:///fakepath/a_caged_persona.mp3"
      },
      "duration": 217,
      "title": "a caged persona",
      "trackNumber": 1,
      "artistName": "TLi-synth",
      "albumTitle": "Girls Apartment"
    }
    """
    
    static let girlsApartmentJSON = """
    [
      {
        "id": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
        "source": "UnknownSource",
        "duration": 217,
        "title": "a caged persona",
        "trackNumber": 1,
        "artistName": "TLi-synth",
        "albumTitle": "Girls Apartment"
      },
      {
        "id": "2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
        "source": "UnknownSource",
        "duration": 219,
        "title": "voyage Gothic Bold",
        "trackNumber": 2,
        "artistName": "flap+frog",
        "albumTitle": "Girls Apartment"
      },
      {
        "id": "3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f",
        "source": "UnknownSource",
        "duration": 260,
        "title": "Fall Coin Sunset",
        "trackNumber": 3,
        "artistName": "OrangeCoffee",
        "albumTitle": "Girls Apartment"
      },
      {
        "id": "4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a",
        "source": "UnknownSource",
        "duration": 233,
        "title": "In The Shade",
        "trackNumber": 4,
        "artistName": "トマト組",
        "albumTitle": "Girls Apartment"
      },
      {
        "id": "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b",
        "source": "UnknownSource",
        "duration": 236,
        "title": "Labyrinth",
        "trackNumber": 5,
        "artistName": "surreacheese",
        "albumTitle": "Girls Apartment"
      },
      {
        "id": "6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c",
        "source": "UnknownSource",
        "duration": 215,
        "title": "tea break",
        "trackNumber": 6,
        "artistName": "OrangeCoffee",
        "albumTitle": "Girls Apartment"
      },
      {
        "id": "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d",
        "source": "UnknownSource",
        "duration": 225,
        "title": "No More News",
        "trackNumber": 7,
        "artistName": "TLi-synth",
        "albumTitle": "Girls Apartment"
      },
      {
        "id": "8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e",
        "source": "UnknownSource",
        "duration": 280,
        "title": "Parfait Amour",
        "trackNumber": 8,
        "artistName": "トマト組",
        "albumTitle": "Girls Apartment"
      },
      {
        "id": "9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f",
        "source": "UnknownSource",
        "duration": 295,
        "title": "Burning Rum Tea",
        "trackNumber": 9,
        "artistName": "surreacheese",
        "albumTitle": "Girls Apartment"
      },
      {
        "id": "0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5g",
        "source": "UnknownSource",
        "duration": 172,
        "title": "Un Fiore Rosso (Take1)",
        "trackNumber": 10,
        "artistName": "flap+frog",
        "albumTitle": "Girls Apartment"
      }
    ]
    """
    
}
//extension Song {
//    static let girlsApartment : [SongID] = [
//        Song.aCagedPersona.id
//        , Song.labyrinth.id
//        , Song.noMoreNews.id
//        , Song.burningRumTea.id
//    ]
//
//    static let aCagedPersona = Song(
//        id: SongID()
//        , source: .local(URL.documentsDirectory)
//        , duration: 219
//        , title: "A Caged Persona"
//        , artist: Artist.saxi.id
//        , album: Album.girlsApartment.id
//        , art: nil
//    )
//    static let labyrinth = Song(
//        id: SongID()
//        , source: .local(URL.documentsDirectory)
//        , duration: 238
//        , title: "Labyrinth"
//        , artist: Artist.con.id
//        , album: Album.girlsApartment.id
//        , art: nil
//    )
//    static let noMoreNews = Song(
//        id: SongID()
//        , source: .local(URL.documentsDirectory)
//        , duration: 223
//        , title: "No More News"
//        , artist: Artist.saxi.id
//        , album: Album.girlsApartment.id
//        , art: nil
//    )
//    static let burningRumTea = Song(
//        id: SongID()
//        , source: .local(URL.documentsDirectory)
//        , duration: 296
//        , title: "Burning Rum Tea"
//        , artist: Artist.con.id
//        , album: Album.girlsApartment.id
//        , art: nil
//    )
//}
//
//extension Album {
//    static let girlsApartment = Album(
//        id: AlbumID()
//        , title: "Girls Apartment"
//        , songs: Song.girlsApartment
//        , art: nil
//        , artist: nil
//    )
//}
//
//extension Artist {
//    static let saxi = Artist(
//        id: ArtistID()
//        , name: "SaXi"
//        , albums: []
//    )
//    static let con = Artist(
//        id: ArtistID()
//        , name: "CON"
//        , albums: []
//    )
//
//}

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
 
1 a caged persona, TLi-synth 3:37
2 voyage Gothic Bold, flap+frog 3:39
3 Fall Coin Sunset, OrangeCoffee 4:20
4 In The Shade, トマト組 3:53
5 Labyrinth, surreacheese 3:56
6 tea break, OrangeCoffee 3:35
7 No More News, TLi-synth 3:45
8 Parfait Amour, トマト組 4:40
9 Burning Rum Tea, surreacheese 4:55
10 Un Fiore Rosso (Take1), flap+frog 2:52
 */
