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
        XCTAssertEqual(song.artistName, "TLi-synth")
        XCTAssertEqual(song.albumTitle, "Girls Apartment")
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
        print("\(String(describing: String(data: jsonData, encoding: .utf8)))")
        
        do {
            song = try decoder.decode(Song.self, from: jsonData)
        } catch {
            XCTFail("Failed to decode test data: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(song.title, Optional("a caged persona"))
    }
    
    func test_album_decodeJSON_parsesKeys() {
        guard let jsonData = Song.aCagedPersonaJSON.data(using: .utf8) else {
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
    }
    
    func test_songArray_decodeJSON_parsesKeys() {
        XCTFail("Test not yet initialized.")
        
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
    
    func test_songArray_decodeJSON_parsesOptionals() {
        XCTFail("Test not yet initialized.")
        
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
        XCTAssertEqual(song.artistName, "TLi-synth")
        XCTAssertEqual(song.albumTitle, "Girls Apartment")
    }
}
