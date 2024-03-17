//
//  File.swift
//  
//
//  Created by Kevin Kelly on 2/7/24.
//

import Foundation
import Models

extension Song {
    public static let aCagedPersonaJSON = """
    {
      "id": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
      "source": {
        "local" : {
          "url": "file:///fakepath/a_caged_persona.mp3"
        }
      },
      "duration": 217,
      "title": "a caged persona",
      "track_number": 1,
      "artist_name": "TLi-synth",
      "album_title": "Girls Apartment",
      "artists": [
        "98a3cb51-319e-4c98-92ce-5047b2ea7536"
      ],
      "albums": [
        "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
      ]
    }
    """
    
    public static let aCagedPersona = Song(
        id: UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d")!
        , source: .local(url: URL(string: "file:///fakepath/a_caged_persona.mp3")!)
        , duration: 217
        , title: "a caged persona"
        , trackNumber: 1
        , artistName: "TLi-synth"
        , albumTitle: "Girls Apartment"
    )
    
    public static let songsJSON = """
    [
      {
        "id": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
        "source": {
          "local" : {
            "url": "file:///fakepath/a_caged_persona.mp3"
          }
        },
        "duration": 217,
        "title": "a caged persona",
        "track_number": 1,
        "artist_name": "TLi-synth",
        "album_title": "Girls Apartment",
        "artists": [
          "98a3cb51-319e-4c98-92ce-5047b2ea7536"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
        "source": {
          "local" : {
            "url": "file:///fakepath/voyage_gothic_bold.mp3"
          }
        },
        "duration": 219,
        "title": "voyage Gothic Bold",
        "track_number": 2,
        "artist_name": "flap+frog",
        "album_title": "Girls Apartment",
        "artists": [
          "9eecb26c-3254-4d76-9e02-29f211da7684"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f",
        "source": {
          "local" : {
            "url": "file:///fakepath/fall_coin_sunset.mp3"
          }
        },
        "duration": 260,
        "title": "Fall Coin Sunset",
        "track_number": 3,
        "artist_name": "OrangeCoffee",
        "album_title": "Girls Apartment",
        "artists": [
          "68482652-ab83-4813-9d5d-60a3b0526ae2"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a",
        "source": {
          "local" : {
            "url": "file:///fakepath/in_the_shade.mp3"
          }
        },
        "duration": 233,
        "title": "In The Shade",
        "track_number": 4,
        "artist_name": "トマト組",
        "album_title": "Girls Apartment",
        "artists": [
          "5c0b4a45-af04-4422-9dec-c07d6d8430e7"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b",
        "source": {
          "local" : {
            "url": "file:///fakepath/labyrinth.mp3"
          }
        },
        "duration": 236,
        "title": "Labyrinth",
        "track_number": 5,
        "artist_name": "surreacheese",
        "album_title": "Girls Apartment",
        "artists": [
          "3ec38329-47db-405e-a71b-be1c452b52c4"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c",
        "source": {
          "local" : {
            "url": "file:///fakepath/tea_break.mp3"
          }
        },
        "duration": 215,
        "title": "tea break",
        "track_number": 6,
        "artist_name": "OrangeCoffee",
        "album_title": "Girls Apartment",
        "artists": [
          "68482652-ab83-4813-9d5d-60a3b0526ae2"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d",
        "source": {
          "local" : {
            "url": "file:///fakepath/no_more_news.mp3"
          }
        },
        "duration": 225,
        "title": "No More News",
        "track_number": 7,
        "artist_name": "TLi-synth",
        "album_title": "Girls Apartment",
        "artists": [
          "98a3cb51-319e-4c98-92ce-5047b2ea7536"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e",
        "source": {
          "local" : {
            "url": "file:///fakepath/parfait_amour.mp3"
          }
        },
        "duration": 280,
        "title": "Parfait Amour",
        "track_number": 8,
        "artist_name": "トマト組",
        "album_title": "Girls Apartment",
        "artists": [
          "5c0b4a45-af04-4422-9dec-c07d6d8430e7"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f",
        "source": {
          "local" : {
            "url": "file:///fakepath/burning_rum_tea.mp3"
          }
        },
        "duration": 295,
        "title": "Burning Rum Tea",
        "track_number": 9,
        "artist_name": "surreacheese",
        "album_title": "Girls Apartment",
        "artists": [
          "3ec38329-47db-405e-a71b-be1c452b52c4"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a",
        "source": {
          "local" : {
            "url": "file:///fakepath/un_fiore_rosso_take1.mp3"
          }
        },
        "duration": 172,
        "title": "Un Fiore Rosso (Take1)",
        "track_number": 10,
        "artist_name": "flap+frog",
        "album_title": "Girls Apartment",
        "artists": [
          "9eecb26c-3254-4d76-9e02-29f211da7684"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "80691b33-c722-44e3-bddc-d8a1234c4a72",
        "source": {
          "local" : {
            "url": "file:///fakepath/un_fiore_rosa_takeb1.mp3"
          }
        },
        "duration": 186,
        "title": "Un Fiore Rosa (TakeB1)",
        "track_number": 1,
        "artist_name": "flap+frog",
        "album_title": "Girls Apartment 2",
        "artists": [
          "9eecb26c-3254-4d76-9e02-29f211da7684"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "81afadc4-1028-492d-b4b6-2b35f6b9af17",
        "source": {
          "local" : {
            "url": "file:///fakepath/sparrowtail.mp3"
          }
        },
        "duration": 239,
        "title": "Sparrowtail",
        "track_number": 2,
        "artist_name": "minimum electric design",
        "album_title": "Girls Apartment 2",
        "artists": [
          "0b7d2acf-31ef-448d-af79-8ce93481ba0c"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "9096eb06-550f-4102-80c5-161d25eef98f",
        "source": {
          "local" : {
            "url": "file:///fakepath/asian_samba.mp3"
          }
        },
        "duration": 187,
        "title": "asian samba",
        "track_number": 3,
        "artist_name": "トマト組",
        "album_title": "Girls Apartment 2",
        "artists": [
          "5c0b4a45-af04-4422-9dec-c07d6d8430e7"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "42a0c0f1-4b16-47b9-b9fc-dad24e4cdf32",
        "source": {
          "local" : {
            "url": "file:///fakepath/lucondium.mp3"
          }
        },
        "duration": 298,
        "title": "Lucondium",
        "track_number": 4,
        "artist_name": "surreacheese",
        "album_title": "Girls Apartment 2",
        "artists": [
          "3ec38329-47db-405e-a71b-be1c452b52c4"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "886c1573-630a-476e-9a2f-2bf59c41a5f7",
        "source": {
          "local" : {
            "url": "file:///fakepath/color_del_amor.mp3"
          }
        },
        "duration": 198,
        "title": "Color del amor",
        "track_number": 5,
        "artist_name": "Driving Kitchen",
        "album_title": "Girls Apartment 2",
        "artists": [
          "1faa9eb3-f6fc-4648-985d-63c4831074d6"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "c5eafedc-f835-4f49-806c-7dddc0da9d07",
        "source": {
          "local" : {
            "url": "file:///fakepath/red_eye.mp3"
          }
        },
        "duration": 180,
        "title": "Red Eye",
        "track_number": 6,
        "artist_name": "トマト組",
        "album_title": "Girls Apartment 2",
        "artists": [
          "5c0b4a45-af04-4422-9dec-c07d6d8430e7"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "cef946c6-f1f2-4a96-b229-d65b329db84d",
        "source": {
          "local" : {
            "url": "file:///fakepath/in_the_room.mp3"
          }
        },
        "duration": 264,
        "title": "in the room",
        "track_number": 7,
        "artist_name": "OrangeCoffee",
        "album_title": "Girls Apartment 2",
        "artists": [
          "68482652-ab83-4813-9d5d-60a3b0526ae2"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "4ec2878b-4ef1-4955-96a0-77bab00b0ada",
        "source": {
          "local" : {
            "url": "file:///fakepath/nestikinz.mp3"
          }
        },
        "duration": 248,
        "title": "Nestikinz",
        "track_number": 8,
        "artist_name": "surreacheese",
        "album_title": "Girls Apartment 2",
        "artists": [
          "3ec38329-47db-405e-a71b-be1c452b52c4"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "dbf5fe26-049a-4de6-bf9d-a638779e8dad",
        "source": {
          "local" : {
            "url": "file:///fakepath/narciso.mp3"
          }
        },
        "duration": 181,
        "title": "narciso",
        "track_number": 9,
        "artist_name": "flap+frog",
        "album_title": "Girls Apartment 2",
        "artists": [
          "9eecb26c-3254-4d76-9e02-29f211da7684"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "691a2c31-9845-4b89-80d3-6441ee8919cb",
        "source": {
          "local" : {
            "url": "file:///fakepath/para_la_princesa_tarde.mp3"
          }
        },
        "duration": 192,
        "title": "Para la princesa tarde",
        "track_number": 10,
        "artist_name": "Driving Kitchen",
        "album_title": "Girls Apartment 2",
        "artists": [
          "1faa9eb3-f6fc-4648-985d-63c4831074d6"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "33731a68-2bcc-4b93-9174-3b3ff4a1a765",
        "source": {
          "local" : {
            "url": "file:///fakepath/sangatsu_yori_nishi_e.mp3"
          }
        },
        "duration": 354,
        "title": "三月より西へ",
        "track_number": 11,
        "artist_name": "OrangeCoffee",
        "album_title": "Girls Apartment 2",
        "artists": [
          "68482652-ab83-4813-9d5d-60a3b0526ae2"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      }
    ]
    """
}

extension Album {
    
    public static let girlsApartmentJSON = """
    {
      "id": "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a",
      "title": "Girls Apartment",
      "songs": [
        "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
        "2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
        "3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f",
        "4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a",
        "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b",
        "6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c",
        "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d",
        "8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e",
        "9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f",
        "0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a"
      ],
      "artist_name": "Various Artists",
      "artists": [
        "98a3cb51-319e-4c98-92ce-5047b2ea7536",
        "9eecb26c-3254-4d76-9e02-29f211da7684",
        "68482652-ab83-4813-9d5d-60a3b0526ae2",
        "5c0b4a45-af04-4422-9dec-c07d6d8430e7",
        "3ec38329-47db-405e-a71b-be1c452b52c4"
      ]
    }
    """
    
    public static let girlsApartment = Album(
        id: UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a")!
        , title: "Girls Apartment"
        , songs: [
            UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d")!
            , UUID(uuidString: "2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e")!
            , UUID(uuidString: "3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f")!
            , UUID(uuidString: "4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a")!
            , UUID(uuidString: "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b")!
            , UUID(uuidString: "6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c")!
            , UUID(uuidString: "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d")!
            , UUID(uuidString: "8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e")!
            , UUID(uuidString: "9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f")!
            , UUID(uuidString: "0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a")!
        ]
        , artistName: "Various Artists"
        , artists: [
            UUID(uuidString: "98a3cb51-319e-4c98-92ce-5047b2ea7536")!
            , UUID(uuidString: "9eecb26c-3254-4d76-9e02-29f211da7684")!
            , UUID(uuidString: "68482652-ab83-4813-9d5d-60a3b0526ae2")!
            , UUID(uuidString: "5c0b4a45-af04-4422-9dec-c07d6d8430e7")!
            , UUID(uuidString: "3ec38329-47db-405e-a71b-be1c452b52c4")!
          ]
    )
    
    public static let albumsJSON = """
    [
      {
        "id": "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a",
        "title": "Girls Apartment",
        "songs": [
          "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
          "2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
          "3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f",
          "4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a",
          "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b",
          "6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c",
          "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d",
          "8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e",
          "9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f",
          "0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a"
        ],
        "artist_name": "Various Artists",
        "artists": [
          "98a3cb51-319e-4c98-92ce-5047b2ea7536",
          "9eecb26c-3254-4d76-9e02-29f211da7684",
          "68482652-ab83-4813-9d5d-60a3b0526ae2",
          "5c0b4a45-af04-4422-9dec-c07d6d8430e7",
          "3ec38329-47db-405e-a71b-be1c452b52c4"
        ]
      },
      {
        "id": "0536d5fe-2435-486c-81a3-2642e6273d70",
        "title": "Girls Apartment 2",
        "songs": [
          "80691b33-c722-44e3-bddc-d8a1234c4a72",
          "81afadc4-1028-492d-b4b6-2b35f6b9af17",
          "9096eb06-550f-4102-80c5-161d25eef98f",
          "42a0c0f1-4b16-47b9-b9fc-dad24e4cdf32",
          "886c1573-630a-476e-9a2f-2bf59c41a5f7",
          "c5eafedc-f835-4f49-806c-7dddc0da9d07",
          "cef946c6-f1f2-4a96-b229-d65b329db84d",
          "4ec2878b-4ef1-4955-96a0-77bab00b0ada",
          "dbf5fe26-049a-4de6-bf9d-a638779e8dad",
          "691a2c31-9845-4b89-80d3-6441ee8919cb",
          "33731a68-2bcc-4b93-9174-3b3ff4a1a765"
        ],
        "artist_name": "Various Artists",
        "artists": [
          "9eecb26c-3254-4d76-9e02-29f211da7684",
          "0b7d2acf-31ef-448d-af79-8ce93481ba0c",
          "5c0b4a45-af04-4422-9dec-c07d6d8430e7",
          "3ec38329-47db-405e-a71b-be1c452b52c4",
          "1faa9eb3-f6fc-4648-985d-63c4831074d6",
          "68482652-ab83-4813-9d5d-60a3b0526ae2"
        ]
      }
    ]
    """
}

extension Artist {
    public static let synthJSON = """
    {
      "id": "98a3cb51-319e-4c98-92ce-5047b2ea7536",
      "name": "TLi-synth",
      "songs": [
        "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
        "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d"
      ],
      "albums": [
        "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
      ]
    }
    """
    
    public static let synth = Artist(
        id: UUID(uuidString: "98a3cb51-319e-4c98-92ce-5047b2ea7536")!
        , name: "TLi-synth"
        , songs: [
            UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d")!
            , UUID(uuidString: "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d")!
        ]
        , albums: [
            UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a")!
        ]
    )
    
    public static let artistsJSON = """
    [
      {
        "id": "98a3cb51-319e-4c98-92ce-5047b2ea7536",
        "name": "TLi-synth",
        "songs": [
          "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
          "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
        ]
      },
      {
        "id": "9eecb26c-3254-4d76-9e02-29f211da7684",
        "name": "flap+frog",
        "songs": [
          "2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
          "0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a",
          "80691b33-c722-44e3-bddc-d8a1234c4a72",
          "dbf5fe26-049a-4de6-bf9d-a638779e8dad"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a",
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "68482652-ab83-4813-9d5d-60a3b0526ae2",
        "name": "OrangeCoffee",
        "songs": [
          "3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f",
          "6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c",
          "cef946c6-f1f2-4a96-b229-d65b329db84d",
          "33731a68-2bcc-4b93-9174-3b3ff4a1a765"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a",
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "5c0b4a45-af04-4422-9dec-c07d6d8430e7",
        "name": "トマト組",
        "songs": [
          "4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a",
          "8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e",
          "9096eb06-550f-4102-80c5-161d25eef98f",
          "c5eafedc-f835-4f49-806c-7dddc0da9d07"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a",
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "3ec38329-47db-405e-a71b-be1c452b52c4",
        "name": "surreacheese",
        "songs": [
          "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b",
          "9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f",
          "42a0c0f1-4b16-47b9-b9fc-dad24e4cdf32",
          "4ec2878b-4ef1-4955-96a0-77bab00b0ada"
        ],
        "albums": [
          "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a",
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "0b7d2acf-31ef-448d-af79-8ce93481ba0c",
        "name": "minimum electric design",
        "songs": [
          "81afadc4-1028-492d-b4b6-2b35f6b9af17"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      },
      {
        "id": "1faa9eb3-f6fc-4648-985d-63c4831074d6",
        "name": "Driving Kitchen",
        "songs": [
          "886c1573-630a-476e-9a2f-2bf59c41a5f7",
          "691a2c31-9845-4b89-80d3-6441ee8919cb"
        ],
        "albums": [
          "0536d5fe-2435-486c-81a3-2642e6273d70"
        ]
      }
    ]
    """
}



/*
ga1
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
 
ga2
1 Un Fiore Rosa (TakeB1), flap+frog 3:06
2 Sparrowtail, minimum electric design 3:59
3 asian samba, トマト組 3:07
4 Lucondium, surreacheese 4:58
5 Color del amor, Driving Kitchen 3:18
6 Red Eye, トマト組 3:00
7 in the room, OrangeCoffee 4:24
8 Nestikinz, surreacheese 4:08
9 narciso, flap+frog 3:01
10 Para la princesa tarde, Driving Kitchen 3:12
11 三月より西へ, OrangeCoffee 5:54

uuids used
 ga1 songs
 "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
 "2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
 "3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f",
 "4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a",
 "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b",
 "6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c",
 "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d",
 "8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e",
 "9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f",
 "0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a",
 
 ga2 songs
 "80691b33-c722-44e3-bddc-d8a1234c4a72",
 "81afadc4-1028-492d-b4b6-2b35f6b9af17",
 "9096eb06-550f-4102-80c5-161d25eef98f",
 "42a0c0f1-4b16-47b9-b9fc-dad24e4cdf32",
 "886c1573-630a-476e-9a2f-2bf59c41a5f7",
 "c5eafedc-f835-4f49-806c-7dddc0da9d07",
 "cef946c6-f1f2-4a96-b229-d65b329db84d",
 "4ec2878b-4ef1-4955-96a0-77bab00b0ada",
 "dbf5fe26-049a-4de6-bf9d-a638779e8dad",
 "691a2c31-9845-4b89-80d3-6441ee8919cb",
 "33731a68-2bcc-4b93-9174-3b3ff4a1a765",
 
 ga1 album
 "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"
 
 ga2 album
 "0536d5fe-2435-486c-81a3-2642e6273d70"
 
 artists
 "98a3cb51-319e-4c98-92ce-5047b2ea7536",
 "9eecb26c-3254-4d76-9e02-29f211da7684",
 "68482652-ab83-4813-9d5d-60a3b0526ae2",
 "5c0b4a45-af04-4422-9dec-c07d6d8430e7",
 "3ec38329-47db-405e-a71b-be1c452b52c4",
 "0b7d2acf-31ef-448d-af79-8ce93481ba0c",
 "1faa9eb3-f6fc-4648-985d-63c4831074d6",
 
uuids to use
 

*/
