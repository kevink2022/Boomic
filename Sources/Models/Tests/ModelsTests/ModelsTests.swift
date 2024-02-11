import XCTest
@testable import Models

final class ModelsTests: XCTestCase {
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
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
        XCTAssertEqual(song.source, .local(URL(string: "file:///fakepath/a_caged_persona.mp3")!))
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
        XCTAssertEqual(song.artist, nil)
        XCTAssertEqual(song.albumTitle, "Girls Apartment")
        XCTAssertEqual(song.album, nil)
    }
    
    func test_song_encodeAndDecodeJSON() {
        let jsonData: Data
        
        do {
            jsonData = try encoder.encode(Song.aCagedPersona)
        } catch {
            XCTFail("Failed to encode test model: \(error.localizedDescription)")
            return
        }
        
        let song: Song
        do {
            song = try decoder.decode(Song.self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(song.title, Optional("a caged persona"))
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
        //XCTAssertEqual(album.songs, [])
        XCTAssertEqual(album.artistName, "Various Artists")
        XCTAssertEqual(album.artists, [])
    }
    
    func test_album_encodeAndDecodeJSON() {
        let jsonData: Data
        
        do {
            jsonData = try encoder.encode(Album.girlsApartment)
        } catch {
            XCTFail("Failed to encode test model: \(error.localizedDescription)")
            return
        }
                
        let album: Album
        do {
            album = try decoder.decode(Album.self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(album.title, Optional("Girls Apartment"))
    }
    
//    func test_songArray_decodeJSON_parsesKeys() {
//        XCTFail("Test not yet initialized.")
//        
//        guard let jsonData = Song.aCagedPersonaJSON.data(using: .utf8) else {
//            XCTFail("Failed to convert test data to JSON")
//            return
//        }
//        
//        let song: Song
//        do {
//            song = try decoder.decode(Song.self, from: jsonData)
//        } catch {
//            XCTFail("Failed to decode test data: \(error.localizedDescription)")
//            return
//        }
//        
//        XCTAssertEqual(song.id, UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d"))
//        XCTAssertEqual(song.source, .local(URL(string: "file:///fakepath/a_caged_persona.mp3")!))
//        XCTAssertEqual(song.duration, 217)
//    }
//    
//    func test_songArray_decodeJSON_parsesOptionals() {
//        XCTFail("Test not yet initialized.")
//        
//        guard let jsonData = Song.aCagedPersonaJSON.data(using: .utf8) else {
//            XCTFail("Failed to convert test data to JSON")
//            return
//        }
//        
//        let song: Song
//        do {
//            song = try decoder.decode(Song.self, from: jsonData)
//        } catch {
//            XCTFail("Failed to decode test data: \(error.localizedDescription)")
//            return
//        }
//        
//        XCTAssertEqual(song.title, "a caged persona")
//        XCTAssertEqual(song.trackNumber, 1)
//        XCTAssertEqual(song.artistName, "TLi-synth")
//        XCTAssertEqual(song.albumTitle, "Girls Apartment")
//    }
}
