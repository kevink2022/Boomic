import XCTest
import ModelsMocks
@testable import Models

final class UpdateTests: XCTestCase {
    
    func test_song_updateField() {
        let song = Song.aCagedPersona
        let sut = SongUpdate(song: song, title: "an uncaged persona")
        let newSong = song.apply(update: sut)
        
        XCTAssertEqual(song.title, "a caged persona")
        XCTAssertEqual(newSong.title, "an uncaged persona")
    }
    
    func test_song_eraseField() {
        let song = Song.aCagedPersona
        let sut = SongUpdate(song: song, erasing: [\.title])
        let newSong = song.apply(update: sut)
        
        XCTAssertEqual(song.title, "a caged persona")
        XCTAssertEqual(newSong.title, nil)
    }
    
    func test_song_updateMultipleFields() {
        let song = Song.aCagedPersona
        let sut = SongUpdate(song: song, title: "an uncaged persona", rating: 5)
        let newSong = song.apply(update: sut)
        
        XCTAssertEqual(song.title, "a caged persona")
        XCTAssertEqual(song.rating, nil)
        XCTAssertEqual(newSong.title, "an uncaged persona")
        XCTAssertEqual(newSong.rating, 5)
    }
    
    func test_song_eraseMultipleFields() {
        let unratedSong = Song.aCagedPersona
        let song = unratedSong.apply(update: SongUpdate(song: unratedSong, rating: 5))
        let sut = SongUpdate(song: song, erasing: [\.title, \.rating])
        let newSong = song.apply(update: sut)
        
        XCTAssertEqual(song.title, "a caged persona")
        XCTAssertEqual(song.rating, 5)
        XCTAssertEqual(newSong.title, nil)
        XCTAssertEqual(newSong.rating, nil)
    }
    
    func test_song_mergeUpdates() {
        let song = Song.aCagedPersona
        let update1 = SongUpdate(song: song, title: "an uncaged persona")
        let update2 = SongUpdate(song: song, rating: 5)
        let sut = update1.apply(update: update2)
        let newSong = song.apply(update: sut)
        
        XCTAssertEqual(newSong.title, "an uncaged persona")
        XCTAssertEqual(newSong.rating, 5)
    }
    
    func test_song_overwriteUpdates() {
        let song = Song.aCagedPersona
        let update1 = SongUpdate(song: song, title: "an uncaged persona")
        let update2 = SongUpdate(song: song, title: "a very uncaged persona")
        let sut = update1.apply(update: update2)
        let newSong = song.apply(update: sut)
        
        XCTAssertEqual(newSong.title, "a very uncaged persona")
    }
    
    func test_album_updateField() {
        let album = Album.girlsApartment
        let sut = AlbumUpdate(album: album, artistName: "Reimu")
        let newAlbum = album.apply(update: sut)
        
        XCTAssertEqual(album.artistName, "Various Artists")
        XCTAssertEqual(newAlbum.artistName, "Reimu")
    }
    
    func test_album_eraseField() {
        let album = Album.girlsApartment
        let sut = AlbumUpdate(album: album, erasing: [\.artistName])
        let newAlbum = album.apply(update: sut)
        
        XCTAssertEqual(album.artistName, "Various Artists")
        XCTAssertEqual(newAlbum.artistName, nil)
    }
    
    func test_album_updateMultipleFields() {
        let album = Album.girlsApartment
        let sut = AlbumUpdate(album: album, title: "Reimu's Apartment", artistName: "Reimu")
        let newAlbum = album.apply(update: sut)
        
        XCTAssertEqual(album.title, "Girls Apartment")
        XCTAssertEqual(album.artistName, "Various Artists")
        XCTAssertEqual(newAlbum.title, "Reimu's Apartment")
        XCTAssertEqual(newAlbum.artistName, "Reimu")
    }
    
    func test_album_eraseMultipleFields() {
        let noArtAlbum = Album.girlsApartment
        let album = noArtAlbum.apply(update: AlbumUpdate(album: noArtAlbum, art: .test))
        let sut = AlbumUpdate(album: album, erasing: [\.artistName, \.art])
        let newAlbum = album.apply(update: sut)
        
        XCTAssertEqual(album.artistName, "Various Artists")
        XCTAssertEqual(album.art, .test)
        XCTAssertEqual(newAlbum.artistName, nil)
        XCTAssertEqual(newAlbum.art, nil)
    }
    
    func test_album_mergeUpdates() {
        let album = Album.girlsApartment
        let update1 = AlbumUpdate(album: album, title: "Reimu's Apartment")
        let update2 = AlbumUpdate(album: album, artistName: "Reimu")
        let sut = update1.apply(update: update2)
        let newAlbum = album.apply(update: sut)
        
        XCTAssertEqual(newAlbum.title, "Reimu's Apartment")
        XCTAssertEqual(newAlbum.artistName, "Reimu")
    }
    
    func test_album_overwriteUpdates() {
        let album = Album.girlsApartment
        let update1 = AlbumUpdate(album: album, title: "Reimu's Apartment")
        let update2 = AlbumUpdate(album: album, title: "Reimu's Mansion")
        let sut = update1.apply(update: update2)
        let newAlbum = album.apply(update: sut)
        
        XCTAssertEqual(newAlbum.title, "Reimu's Mansion")
    }
    
    func test_artist_updateField() {
        let artist = Artist.synth
        let sut = ArtistUpdate(artist: artist, art: .test)
        let newArtist = artist.apply(update: sut)
        
        XCTAssertEqual(artist.art, nil)
        XCTAssertEqual(newArtist.art, .test)
    }
    
    func test_artist_eraseField() {
        let noArtArtist = Artist.synth
        let artist = noArtArtist.apply(update: ArtistUpdate(artist: noArtArtist, art: .test))
        let sut = ArtistUpdate(artist: artist, erasing: [\.art])
        let newArtist = artist.apply(update: sut)
        
        XCTAssertEqual(artist.art, .test)
        XCTAssertEqual(newArtist.art, nil)
    }
    
    func test_artist_updateMultipleFields() {
        let artist = Artist.synth
        let sut = ArtistUpdate(artist: artist, name: "SaXi", art: .test)
        let newArtist = artist.apply(update: sut)
        
        XCTAssertEqual(artist.name, "TLi-synth")
        XCTAssertEqual(artist.art, nil)
        XCTAssertEqual(newArtist.name, "SaXi")
        XCTAssertEqual(newArtist.art, .test)
    }
    
    /*func test_artist_eraseMultipleFields() {
    
    }*/
    
    func test_artist_mergeUpdates() {
        let artist = Artist.synth
        let update1 = ArtistUpdate(artist: artist, name: "SaXi")
        let update2 = ArtistUpdate(artist: artist, art: .test)
        let sut = update1.apply(update: update2)
        let newArtist = artist.apply(update: sut)
        
        XCTAssertEqual(newArtist.name, "SaXi")
        XCTAssertEqual(newArtist.art, .test)
    }
    
    func test_artist_overwriteUpdates() {
        let artist = Artist.synth
        let update1 = ArtistUpdate(artist: artist, name: "SaXi")
        let update2 = ArtistUpdate(artist: artist, name: "sAxI")
        let sut = update1.apply(update: update2)
        let newArtist = artist.apply(update: sut)
        
        XCTAssertEqual(newArtist.name, "sAxI")
    }
}
