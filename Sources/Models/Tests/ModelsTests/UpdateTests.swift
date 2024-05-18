import XCTest
import ModelsMocks
@testable import Models

final class UpdateTests: XCTestCase {
    
    func test_song_updateField() {
        let song = Song.aCagedPersona
        let update = SongUpdate(song: song, title: "an uncaged persona")
        let newSong = Song(song, applying: update)
        
        XCTAssertEqual(song.title, "a caged persona")
        XCTAssertEqual(newSong.title, "an uncaged persona")
    }
    
    func test_song_eraseField() {
        let song = Song.aCagedPersona
        let update = SongUpdate(song: song, erasing: [\.title])
        let newSong = Song(song, applying: update)
        
        XCTAssertEqual(song.title, "a caged persona")
        XCTAssertEqual(newSong.title, nil)
    }
    
    func test_song_updateMultipleFields() {
        let song = Song.aCagedPersona
        let update = SongUpdate(song: song, title: "an uncaged persona", rating: 5)
        let newSong = Song(song, applying: update)
        
        XCTAssertEqual(song.title, "a caged persona")
        XCTAssertEqual(song.rating, nil)
        XCTAssertEqual(newSong.title, "an uncaged persona")
        XCTAssertEqual(newSong.rating, 5)
    }
    
    func test_song_eraseMultipleFields() {
        let unratedSong = Song.aCagedPersona
        let song = Song(unratedSong, applying: SongUpdate(song: unratedSong, rating: 5))
        
        let update = SongUpdate(song: song, erasing: [\.title, \.rating])
        let newSong = Song(song, applying: update)
        
        XCTAssertEqual(song.title, "a caged persona")
        XCTAssertEqual(song.rating, 5)
        XCTAssertEqual(newSong.title, nil)
        XCTAssertEqual(newSong.rating, nil)
    }
}
