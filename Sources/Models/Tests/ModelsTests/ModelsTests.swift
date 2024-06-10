import XCTest
import ModelsMocks
import Domain
@testable import Models

final class ModelsTests: XCTestCase {
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    // MARK: - Single Object
    
    func test_song_decodeJSON_parsesKeys() {
        guard let jsonData = Song.aCagedPersonaJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let song: Song
        do {
            song = try decoder.decode(Song.self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(song.id, UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d"))
        XCTAssertEqual(song.source, .local(path: AppPath(relativePath: "a_caged_persona.mp3")))
        XCTAssertEqual(song.duration, 217)
    }
    
    func test_song_decodeJSON_parsesOptionals() {
        guard let jsonData = Song.aCagedPersonaJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let song: Song
        do {
            song = try decoder.decode(Song.self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(song.title, "a caged persona")
        XCTAssertEqual(song.trackNumber, 1)
        XCTAssertEqual(song.discNumber, nil)
        XCTAssertEqual(song.art, nil)
        XCTAssertEqual(song.artistName, "TLi-synth")
        XCTAssertEqual(song.artists, [UUID(uuidString: "98a3cb51-319e-4c98-92ce-5047b2ea7536")!])
        XCTAssertEqual(song.albumTitle, "Girls Apartment")
        XCTAssertEqual(song.albums, [UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a")!])
    }
      
    func test_album_decodeJSON_parsesKeys() {
        guard let jsonData = Album.girlsApartmentJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let album: Album
        do {
            album = try decoder.decode(Album.self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(album.id, UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"))
        XCTAssertEqual(album.title, "Girls Apartment")
    }
    
    func test_album_decodeJSON_parsesOptionals() {
        guard let jsonData = Album.girlsApartmentJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let album: Album
        do {
            album = try decoder.decode(Album.self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(album.art, nil)
        XCTAssertEqual(album.songs.count, 10)
        XCTAssertEqual(album.songs[0], UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d"))
        XCTAssertEqual(album.songs[4], UUID(uuidString: "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b"))
        XCTAssertEqual(album.songs[6], UUID(uuidString: "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d"))
        XCTAssertEqual(album.songs[8], UUID(uuidString: "9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f"))
        XCTAssertEqual(album.artistName, "Various Artists")
        XCTAssertEqual(album.artists.count, 5)
        XCTAssertEqual(album.artists[0], UUID(uuidString: "98a3cb51-319e-4c98-92ce-5047b2ea7536"))
        XCTAssertEqual(album.artists[2], UUID(uuidString: "68482652-ab83-4813-9d5d-60a3b0526ae2"))
    }
    
    func test_artist_decodeJSON_parsesKeys() {
        guard let jsonData = Artist.synthJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let artist: Artist
        do {
            artist = try decoder.decode(Artist.self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(artist.id, UUID(uuidString: "98a3cb51-319e-4c98-92ce-5047b2ea7536"))
        XCTAssertEqual(artist.name, "TLi-synth")
    }
    
    func test_artist_decodeJSON_parsesOptionals() {
        guard let jsonData = Artist.synthJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let artist: Artist
        do {
            artist = try decoder.decode(Artist.self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(artist.songs.count, 2)
        XCTAssertEqual(artist.songs[0], UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d"))
        XCTAssertEqual(artist.songs[1], UUID(uuidString: "7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d"))
        XCTAssertEqual(artist.albums.count, 1)
        XCTAssertEqual(artist.albums[0], UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"))
        XCTAssertEqual(artist.art, nil)
    }
    
    // MARK: - Array
    
    func test_songArray_decodeJSON_parsesKeys() {
        guard let jsonData = Song.songsJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let songs: [Song]
        do {
            songs = try decoder.decode([Song].self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(songs.count, 21)
        XCTAssertEqual(songs[0].id, UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d"))
        XCTAssertEqual(songs[0].source, .local(path: AppPath(relativePath: "a_caged_persona.mp3")))
        XCTAssertEqual(songs[0].duration, 217)
        XCTAssertEqual(songs[10].id, UUID(uuidString: "80691b33-c722-44e3-bddc-d8a1234c4a72"))
        XCTAssertEqual(songs[10].source, .local(path: AppPath(relativePath: "un_fiore_rosa_takeb1.mp3")))
        XCTAssertEqual(songs[10].duration, 186)
        XCTAssertEqual(songs[20].id, UUID(uuidString: "33731a68-2bcc-4b93-9174-3b3ff4a1a765"))
        XCTAssertEqual(songs[20].source, .local(path: AppPath(relativePath: "sangatsu_yori_nishi_e.mp3")))
        XCTAssertEqual(songs[20].duration, 354)
    }
    
    func test_songArray_decodeJSON_parsesOptionals() {
        guard let jsonData = Song.songsJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let songs: [Song]
        do {
            songs = try decoder.decode([Song].self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(songs.count, 21)
        XCTAssertEqual(songs[10].trackNumber, 1)
        XCTAssertEqual(songs[10].discNumber, nil)
        XCTAssertEqual(songs[10].art, nil)
        XCTAssertEqual(songs[10].artistName, "flap+frog")
        XCTAssertEqual(songs[10].artists, [UUID(uuidString: "9eecb26c-3254-4d76-9e02-29f211da7684")!])
        XCTAssertEqual(songs[10].albumTitle, "Girls Apartment 2")
        XCTAssertEqual(songs[10].albums, [UUID(uuidString: "0536d5fe-2435-486c-81a3-2642e6273d70")])
    }

    
    func test_albumArray_decodeJSON_parsesKeys() {
        guard let jsonData = Album.albumsJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let albums: [Album]
        do {
            albums = try decoder.decode([Album].self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(albums.count, 2)
        XCTAssertEqual(albums[0].id, UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"))
        XCTAssertEqual(albums[0].title, "Girls Apartment")
        XCTAssertEqual(albums[1].id, UUID(uuidString: "0536d5fe-2435-486c-81a3-2642e6273d70"))
        XCTAssertEqual(albums[1].title, "Girls Apartment 2")
    }
    
    func test_albumArray_decodeJSON_parsesOptionals() {
        guard let jsonData = Album.albumsJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let albums: [Album]
        do {
            albums = try decoder.decode([Album].self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(albums.count, 2)
        XCTAssertEqual(albums[1].art, nil)
        XCTAssertEqual(albums[1].songs.count, 11)
        XCTAssertEqual(albums[1].songs[0], UUID(uuidString: "80691b33-c722-44e3-bddc-d8a1234c4a72"))
        XCTAssertEqual(albums[1].songs[4], UUID(uuidString: "886c1573-630a-476e-9a2f-2bf59c41a5f7"))
        XCTAssertEqual(albums[1].songs[6], UUID(uuidString: "cef946c6-f1f2-4a96-b229-d65b329db84d"))
        XCTAssertEqual(albums[1].songs[8], UUID(uuidString: "dbf5fe26-049a-4de6-bf9d-a638779e8dad"))
        XCTAssertEqual(albums[1].artistName, "Various Artists")
        XCTAssertEqual(albums[1].artists.count, 6)
        XCTAssertEqual(albums[1].artists[0], UUID(uuidString: "9eecb26c-3254-4d76-9e02-29f211da7684"))
        XCTAssertEqual(albums[1].artists[2], UUID(uuidString: "5c0b4a45-af04-4422-9dec-c07d6d8430e7"))
    }
    
    func test_artistArray_decodeJSON_parsesKeys() {
        guard let jsonData = Artist.artistsJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let artists: [Artist]
        do {
            artists = try decoder.decode([Artist].self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(artists.count, 7)
        XCTAssertEqual(artists[0].id, UUID(uuidString: "98a3cb51-319e-4c98-92ce-5047b2ea7536"))
        XCTAssertEqual(artists[0].name, "TLi-synth")
        XCTAssertEqual(artists[4].id, UUID(uuidString: "3ec38329-47db-405e-a71b-be1c452b52c4"))
        XCTAssertEqual(artists[4].name, "surreacheese")
    }
    
    func test_artistArray_decodeJSON_parsesOptionals() {
        guard let jsonData = Artist.artistsJSON.data(using: .utf8) else {
            XCTFail("Failed to convert test data to JSON")
            return
        }
        
        let artists: [Artist]
        do {
            artists = try decoder.decode([Artist].self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(artists.count, 7)
        XCTAssertEqual(artists[0].songs.count, 2)
        XCTAssertEqual(artists[0].songs[0], UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d"))
        XCTAssertEqual(artists[0].albums.count, 1)
        XCTAssertEqual(artists[0].albums[0], UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"))
        XCTAssertEqual(artists[4].songs.count, 4)
        XCTAssertEqual(artists[4].songs[0], UUID(uuidString: "5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b"))
        XCTAssertEqual(artists[4].albums.count, 2)
        XCTAssertEqual(artists[4].albums[0], UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"))
    }
}
