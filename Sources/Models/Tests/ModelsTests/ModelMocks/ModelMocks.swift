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
        "local" : {
          "_0": "file:///fakepath/a_caged_persona.mp3"
        }
      },
      "duration": 217,
      "title": "a caged persona",
      "track_number": 1,
      "artist_name": "TLi-synth",
      "album_title": "Girls Apartment"
    }
    """
    
    static let aCagedPersona = Song(
        id: UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d")!
        , source: .local(URL(string: "file:///fakepath/a_caged_persona.mp3")!)
        , duration: 217
        , title: "a caged persona"
        , trackNumber: 1
        , artistName: "TLi-synth"
        , albumTitle: "Girls Apartment"
    )
    
    static let girlsApartmentJSON = """
    [
      {
        "id": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
        "source": "UnknownSource",
        "duration": 217,
        "title": "a caged persona",
        "track_number": 1,
        "artist_name": "TLi-synth",
        "album_title": "Girls Apartment"
      },
      {
        "id": "2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
        "source": "UnknownSource",
        "duration": 219,
        "title": "voyage Gothic Bold",
        "track_number": 2,
        "artist_name": "flap+frog",
        "album_title": "Girls Apartment"
      },
      {
        "id": "3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f",
        "source": "UnknownSource",
        "duration": 260,
        "title": "Fall Coin Sunset",
        "track_number": 3,
        "artist_name": "OrangeCoffee",
        "album_title": "Girls Apartment"
      },
      {
        "id": "4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a",
        "source": "UnknownSource",
        "duration": 233,
        "title": "In The Shade",
        "track_number": 4,
        "artist_name": "トマト組",
        "album_title": "Girls Apartment"
      },
      {
        "id": "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b",
        "source": "UnknownSource",
        "duration": 236,
        "title": "Labyrinth",
        "track_number": 5,
        "artist_name": "surreacheese",
        "album_title": "Girls Apartment"
      },
      {
        "id": "6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c",
        "source": "UnknownSource",
        "duration": 215,
        "title": "tea break",
        "track_number": 6,
        "artist_name": "OrangeCoffee",
        "album_title": "Girls Apartment"
      },
      {
        "id": "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d",
        "source": "UnknownSource",
        "duration": 225,
        "title": "No More News",
        "track_number": 7,
        "artist_name": "TLi-synth",
        "album_title": "Girls Apartment"
      },
      {
        "id": "8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e",
        "source": "UnknownSource",
        "duration": 280,
        "title": "Parfait Amour",
        "track_number": 8,
        "artist_name": "トマト組",
        "album_title": "Girls Apartment"
      },
      {
        "id": "9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f",
        "source": "UnknownSource",
        "duration": 295,
        "title": "Burning Rum Tea",
        "track_number": 9,
        "artist_name": "surreacheese",
        "album_title": "Girls Apartment"
      },
      {
        "id": "0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5g",
        "source": "UnknownSource",
        "duration": 172,
        "title": "Un Fiore Rosso (Take1)",
        "track_number": 10,
        "artist_name": "flap+frog",
        "album_title": "Girls Apartment"
      }
    ]
    """
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
