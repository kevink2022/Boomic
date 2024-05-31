import XCTest
import Models
import ModelsMocks
@testable import Database

private typealias Mocks = ModelsMocks

final class DatabaseTests: XCTestCase {
    
    private let decoder = JSONDecoder()
       
    private func unlinkedSongs(_ songs: [Song]? = nil) -> [Song] {
        let songs = songs ?? Mocks.sampleModels().0
        return songs.map { $0.apply(update: SongUpdate(song: $0, artists: [], albums: [])) }
    }
    
    private func stableBasis(songs: [Song]? = nil) async -> DataBasis {
        let unlinkedSongs = unlinkedSongs(songs)
        let transaction = await BasisResolver(currentBasis: DataBasis.empty).addSongs(unlinkedSongs)
        return await BasisResolver(currentBasis: DataBasis.empty).apply(transaction: transaction)
    }
    
    private func compare(stable basis1: DataBasis, against basis2: DataBasis, test: String) {
        XCTAssertEqual(basis1.allSongs.count, basis2.allSongs.count, test)
        XCTAssertEqual(basis1.allAlbums.count, basis2.allAlbums.count, test)
        XCTAssertEqual(basis1.allArtists.count, basis2.allArtists.count, test)
        
        basis1.allSongs.forEach { basis1Song in
            guard let basis2Song = basis2.allSongs.first(where: { basis2Song in basis2Song.source == basis1Song.source })
            else { XCTFail("No Matching Song: \(test)"); return }
            
            XCTAssertEqual(basis1Song.source, basis2Song.source, basis2Song.label)
            XCTAssertEqual(basis1Song.duration, basis2Song.duration, basis2Song.label)
            XCTAssertEqual(basis1Song.title, basis2Song.title, basis2Song.label)
            XCTAssertEqual(basis1Song.trackNumber, basis2Song.trackNumber, basis2Song.label)
            XCTAssertEqual(basis1Song.discNumber, basis2Song.discNumber, basis2Song.label)
            XCTAssertEqual(basis1Song.art, basis2Song.art, basis2Song.label)
            XCTAssertEqual(basis1Song.artistName, basis2Song.artistName, basis2Song.label)
            XCTAssertEqual(basis1Song.artists.count, basis2Song.artists.count, basis2Song.label)
            XCTAssertEqual(basis1Song.albumTitle, basis2Song.albumTitle, basis2Song.label)
            XCTAssertEqual(basis1Song.albums.count, basis2Song.albums.count, basis2Song.label)
            XCTAssertEqual(basis1Song.rating, basis2Song.rating, basis2Song.label)
        }
        
        basis1.allAlbums.forEach { basis1Album in
            guard let basis2Album = basis2.allAlbums.first(where: { basis2Album in basis2Album.title == basis1Album.title })
            else { XCTFail("No Matching Album: \(test)"); return }
            
            XCTAssertEqual(basis1Album.title, basis2Album.title, basis2Album.title)
            XCTAssertEqual(basis1Album.art, basis2Album.art, basis2Album.title)
            XCTAssertEqual(basis1Album.songs.count, basis2Album.songs.count, basis2Album.title)
            XCTAssertEqual(basis1Album.artistName, basis2Album.artistName, basis2Album.title)
            XCTAssertEqual(basis1Album.artists.count, basis2Album.artists.count, basis2Album.title)
        }
        
        basis1.allArtists.forEach { basis1Artist in
            guard let basis2Artist = basis2.allArtists.first(where: { basis2Artist in basis2Artist.name == basis1Artist.name })
            else { XCTFail("No Matching Album: \(test)"); return }
            
            XCTAssertEqual(basis1Artist.name, basis2Artist.name, basis2Artist.name)
            XCTAssertEqual(basis1Artist.songs.count, basis2Artist.songs.count, basis2Artist.name)
            XCTAssertEqual(basis1Artist.albums.count, basis2Artist.albums.count, basis2Artist.name)
            XCTAssertEqual(basis1Artist.art, basis2Artist.art, basis2Artist.name)
        }
    }
      
    func test_addSongsToEmpty() async {
        let (songs, albums, artists) = Mocks.sampleModels()
        let unlinkedSongs = unlinkedSongs()
        
        XCTAssertEqual(unlinkedSongs[0].artists, [])
        XCTAssertEqual(unlinkedSongs[0].albums, [])
        
        let sut = BasisResolver(currentBasis: DataBasis.empty)
        
        let transaction = await sut.addSongs(unlinkedSongs)
        
        XCTAssertEqual(transaction.filter({ $0.model == .song }).count, songs.count)
        XCTAssertEqual(transaction.filter({ $0.model == .album }).count, albums.count)
        XCTAssertEqual(transaction.filter({ $0.model == .artist }).count, artists.count)
        XCTAssertEqual(transaction.filter({ $0.operation == .add }).count, songs.count + albums.count + artists.count)
    }
    
    func test_emptyAddTransaction() async {
        let (songs, albums, artists) = Mocks.sampleModels()
        let unlinkedSongs = unlinkedSongs()
        
        let transaction = await BasisResolver(currentBasis: DataBasis.empty).addSongs(unlinkedSongs)
        let sut = BasisResolver(currentBasis: DataBasis.empty)
        
        let newBasis = await sut.apply(transaction: transaction)
        
        XCTAssertEqual(newBasis.allSongs.count, songs.count)
        XCTAssertEqual(newBasis.allAlbums.count, albums.count)
        XCTAssertEqual(newBasis.allArtists.count, artists.count)
        
        XCTAssertEqual(newBasis.allSongs[0].albums.count, 1)
        XCTAssertEqual(newBasis.allSongs[0].artists.count, 1)
        XCTAssertEqual(newBasis.allAlbums[0].songs.count, 10)
        XCTAssertEqual(newBasis.allAlbums[1].songs.count, 11)
        XCTAssertEqual(newBasis.allAlbums[0].artists.count, 5)
        XCTAssertEqual(newBasis.allAlbums[1].artists.count, 6)
    }
    
    func test_addSongsByAlbum() async {
        
        let (songs, albums, artists) = Mocks.sampleModels()
        let unlinkedSongs = unlinkedSongs()
        let ga1_songs = unlinkedSongs.filter { $0.albumTitle == "Girls Apartment" }
        let ga2_songs = unlinkedSongs.filter { $0.albumTitle == "Girls Apartment 2" }
               
        let ga1_basis = await BasisResolver(currentBasis: DataBasis.empty)
            .apply(transaction: BasisResolver(currentBasis: DataBasis.empty).addSongs(ga1_songs))
        
        let sut = BasisResolver(currentBasis: ga1_basis)
        
        let ga2_transaction = await sut.addSongs(ga2_songs)
        let ga2_basis = await sut.apply(transaction: ga2_transaction)
        
        XCTAssertEqual(ga2_transaction.filter({ $0.model == .song }).count, ga2_songs.count)
        XCTAssertEqual(ga2_transaction.filter({ $0.model == .album }).count, 1)
        XCTAssertEqual(ga2_transaction.filter({ $0.model == .artist && $0.operation == .add }).count, 2)
        XCTAssertEqual(ga2_transaction.filter({ $0.model == .artist && $0.operation == .update }).count, 4)
        
        XCTAssertEqual(ga2_basis.allSongs.count, songs.count)
        XCTAssertEqual(ga2_basis.allAlbums.count, albums.count)
        XCTAssertEqual(ga2_basis.allArtists.count, artists.count)
        
        let sample = await stableBasis()
        compare(stable: sample, against: ga2_basis, test: #function)
    }
    
    func test_addSongsByNumber() async {
        
        let (songs, albums, artists) = Mocks.sampleModels()
        let unlinkedSongs = unlinkedSongs()
        let evenSongs = unlinkedSongs.filter { $0.trackNumber! % 2 == 0 }
        let oddSongs = unlinkedSongs.filter { $0.trackNumber! % 2 == 1 }
               
        let oddBasis = await BasisResolver(currentBasis: DataBasis.empty)
            .apply(transaction: BasisResolver(currentBasis: DataBasis.empty).addSongs(oddSongs))
        
        let sut = BasisResolver(currentBasis: oddBasis)
        
        let evenTransaction = await sut.addSongs(evenSongs)
        let evenBasis = await sut.apply(transaction: evenTransaction)
        
        XCTAssertEqual(evenTransaction.filter({ $0.model == .song && $0.operation == .add }).count, evenSongs.count)
        XCTAssertEqual(evenTransaction.filter({ $0.model == .album && $0.operation == .update }).count, 2)
        XCTAssertEqual(evenTransaction.filter({ $0.model == .artist && $0.operation == .add }).count, 1)
        XCTAssertEqual(evenTransaction.filter({ $0.model == .artist && $0.operation == .update }).count, 5)
        
        XCTAssertEqual(evenBasis.allSongs.count, songs.count)
        XCTAssertEqual(evenBasis.allAlbums.count, albums.count)
        XCTAssertEqual(evenBasis.allArtists.count, artists.count)
        
        let sample = await stableBasis()
        compare(stable: sample, against: evenBasis, test: #function)
    }
    
    func test_updateSongNoLinks() async {
        let testBasis = await stableBasis()
        let expectedSongs = unlinkedSongs().map { song in
            if song.title == "a caged persona" {
                song.apply(update: SongUpdate(song: song, title: "an uncaged persona"))
            } else {
                song
            }
        }
        let expectedStableBasis = await stableBasis(songs: expectedSongs)
        
        let sut = BasisResolver(currentBasis: testBasis)
        guard let songToUpdate = testBasis.allSongs.first(where: { $0.title == "a caged persona" }) 
        else { XCTFail("Test model not found"); return }
        let update = SongUpdate(song: songToUpdate, title: "an uncaged persona")
        let transaction = await sut.updateSong(update)
        let newBasis = await sut.apply(transaction: transaction)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .add }).count, 0)
        XCTAssertEqual(transaction.filter({ $0.operation == .update }).count, 1)
        XCTAssertEqual(transaction.filter({ $0.operation == .delete }).count, 0)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .song }).count, 1)
        
        compare(stable: expectedStableBasis, against: newBasis, test: #function)
    }
    
    func test_updateSongLinks() async {
        let testBasis = await stableBasis()
        let expectedSongs = unlinkedSongs().map { song in
            if song.title == "Sparrowtail" {
                song.apply(update: SongUpdate(song: song, artistName: "maximum electric design"))
            } else {
                song
            }
        }
        let expectedStableBasis = await stableBasis(songs: expectedSongs)
        
        let sut = BasisResolver(currentBasis: testBasis)
        guard let songToUpdate = testBasis.allSongs.first(where: { $0.title == "Sparrowtail" })
        else { XCTFail("Test model not found"); return }
        let update = SongUpdate(song: songToUpdate, artistName: "maximum electric design")
        let transaction = await sut.updateSong(update)
        let newBasis = await sut.apply(transaction: transaction)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .add }).count, 1)
        XCTAssertEqual(transaction.filter({ $0.operation == .update }).count, 2)
        XCTAssertEqual(transaction.filter({ $0.operation == .delete }).count, 1)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .song }).count, 1) // update a caged persona
        XCTAssertEqual(transaction.filter({ $0.operation == .add && $0.model == .artist }).count, 1) // add maximum
        XCTAssertEqual(transaction.filter({ $0.operation == .delete && $0.model == .artist }).count, 1) // delete minimum
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .album }).count, 1) // update ga2 to link to max
        
        compare(stable: expectedStableBasis, against: newBasis, test: #function)
    }
    
    func test_deleteSong() async {
        let testBasis = await stableBasis()
        let expectedSongs: [Song] = unlinkedSongs().compactMap { song in
            if song.title != "a caged persona" { song }
            else { nil }
        }
        let expectedStableBasis = await stableBasis(songs: expectedSongs)
        
        let sut = BasisResolver(currentBasis: testBasis)
        guard let songToDelete = testBasis.allSongs.first(where: { $0.title == "a caged persona" })
        else { XCTFail("Test model not found"); return }
        let transaction = await sut.deleteSong(songToDelete)
        let newBasis = await sut.apply(transaction: transaction)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .add }).count, 0)
        XCTAssertEqual(transaction.filter({ $0.operation == .update }).count, 2)
        XCTAssertEqual(transaction.filter({ $0.operation == .delete }).count, 1)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .delete && $0.model == .song }).count, 1) // delete a caged persona
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .album }).count, 1) // update its album
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .artist }).count, 1) // update its artist
        
        compare(stable: expectedStableBasis, against: newBasis, test: #function)
    }
    
    func test_updateAlbumNoLinks() async {
        let testBasis = await stableBasis()
        
        let sut = BasisResolver(currentBasis: testBasis)
        guard let albumToUpdate = testBasis.allAlbums.first(where: { $0.title == "Girls Apartment" })
        else { XCTFail("Test model not found"); return }
        let update = AlbumUpdate(album: albumToUpdate, artistName: "Various Touhou Girls")
        let transaction = await sut.updateAlbum(update)
        let newBasis = await sut.apply(transaction: transaction)
        guard let updatedAlbum = newBasis.albumMap[albumToUpdate.id]
        else { XCTFail("Updated model not found"); return }
        
        XCTAssertEqual(transaction.filter({ $0.operation == .add }).count, 0)
        XCTAssertEqual(transaction.filter({ $0.operation == .update }).count, 1)
        XCTAssertEqual(transaction.filter({ $0.operation == .delete }).count, 0)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .album }).count, 1) // update girls apartment
        
        XCTAssertEqual(updatedAlbum.artistName, "Various Touhou Girls")
    }
    
    func test_updateAlbumLinks() async {
        let testBasis = await stableBasis()
        let expectedSongs = unlinkedSongs().map { song in
            if song.albumTitle == "Girls Apartment" {
                song.apply(update: SongUpdate(song: song, albumTitle: "Reimu's Apartment"))
            } else {
                song
            }
        }
        let expectedStableBasis = await stableBasis(songs: expectedSongs)
        
        let sut = BasisResolver(currentBasis: testBasis)
        guard let albumToUpdate = testBasis.allAlbums.first(where: { $0.title == "Girls Apartment" })
        else { XCTFail("Test model not found"); return }
        let update = AlbumUpdate(album: albumToUpdate, title: "Reimu's Apartment")
        let transaction = await sut.updateAlbum(update)
        let newBasis = await sut.apply(transaction: transaction)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .add }).count, 0)
        XCTAssertEqual(transaction.filter({ $0.operation == .update }).count, 15)
        XCTAssertEqual(transaction.filter({ $0.operation == .delete }).count, 0)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .album }).count, 1) // update girls apartment
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .song }).count, 10) // update girls apartment songs
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .artist }).count, 4) // artists albums sorted alphbetically, update sorting
        
        XCTAssertEqual(newBasis.albumMap[albumToUpdate.id]?.id, albumToUpdate.id)
        
        compare(stable: expectedStableBasis, against: newBasis, test: #function)
    }
    
    func test_deleteAlbum() async {
        let testBasis = await stableBasis()
        let expectedSongs = unlinkedSongs().compactMap { song in
            if song.albumTitle != "Girls Apartment" { song }
            else { nil }
        }
        let expectedStableBasis = await stableBasis(songs: expectedSongs)
        
        let sut = BasisResolver(currentBasis: testBasis)
        guard let albumToDelete = testBasis.allAlbums.first(where: { $0.title == "Girls Apartment" })
        else { XCTFail("Test model not found"); return }
        let transaction = await sut.deleteAlbum(albumToDelete)
        let newBasis = await sut.apply(transaction: transaction)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .add }).count, 0)
        XCTAssertEqual(transaction.filter({ $0.operation == .update }).count, 4)
        XCTAssertEqual(transaction.filter({ $0.operation == .delete }).count, 12)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .delete && $0.model == .album }).count, 1) // delete girls apartment
        XCTAssertEqual(transaction.filter({ $0.operation == .delete && $0.model == .song }).count, 10) // delete girls apartment songs
        XCTAssertEqual(transaction.filter({ $0.operation == .delete && $0.model == .artist }).count, 1) // delete girls apartment only artist (tli-synth)
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .artist }).count, 4) // update artists on both albums
        
        compare(stable: expectedStableBasis, against: newBasis, test: #function)
    }
    
    func test_updateArtistNoLinks() async {
        let testBasis = await stableBasis()
        
        let sut = BasisResolver(currentBasis: testBasis)
        guard let artistToUpdate = testBasis.allArtists.first(where: { $0.name == "flap+frog" })
        else { XCTFail("Test model not found"); return }
        let update = ArtistUpdate(artist: artistToUpdate, art: MediaArt.test)
        let transaction = await sut.updateArtist(update)
        let newBasis = await sut.apply(transaction: transaction)
        guard let updatedArtist = newBasis.artistMap[artistToUpdate.id]
        else { XCTFail("Updated model not found"); return }
        
        XCTAssertEqual(transaction.filter({ $0.operation == .add }).count, 0)
        XCTAssertEqual(transaction.filter({ $0.operation == .update }).count, 1)
        XCTAssertEqual(transaction.filter({ $0.operation == .delete }).count, 0)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .artist }).count, 1) // update flap+frog
        
        XCTAssertEqual(updatedArtist.art, MediaArt.test)
    }
    
    func test_updateArtistLinks() async {
        let testBasis = await stableBasis()
        let expectedSongs = unlinkedSongs().map { song in
            if song.artistName == "flap+frog" {
                song.apply(update: SongUpdate(song: song, artistName: "Reimu"))
            } else {
                song
            }
        }
        let expectedStableBasis = await stableBasis(songs: expectedSongs)
        
        let sut = BasisResolver(currentBasis: testBasis)
        guard let artistToUpdate = testBasis.allArtists.first(where: { $0.name == "flap+frog" })
        else { XCTFail("Test model not found"); return }
        let update = ArtistUpdate(artist: artistToUpdate, name: "Reimu")
        let transaction = await sut.updateArtist(update)
        let newBasis = await sut.apply(transaction: transaction)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .add }).count, 0)
        XCTAssertEqual(transaction.filter({ $0.operation == .update }).count, 7)
        XCTAssertEqual(transaction.filter({ $0.operation == .delete }).count, 0)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .artist }).count, 1) // update flap+frog
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .song }).count, 4) // update flap+frog songs
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .album }).count, 2) // album artists sorting update
        
        compare(stable: expectedStableBasis, against: newBasis, test: #function)
    }
    
    func test_deleteArtist() async {
        let testBasis = await stableBasis()
        let expectedSongs = unlinkedSongs().compactMap { song in
            if song.artistName != "flap+frog" { song }
            else { nil }
        }
        let expectedStableBasis = await stableBasis(songs: expectedSongs)
        
        let sut = BasisResolver(currentBasis: testBasis)
        guard let artistToUpdate = testBasis.allArtists.first(where: { $0.name == "flap+frog" })
        else { XCTFail("Test model not found"); return }
        let transaction = await sut.deleteArtist(artistToUpdate)
        let newBasis = await sut.apply(transaction: transaction)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .add }).count, 0)
        XCTAssertEqual(transaction.filter({ $0.operation == .update }).count, 2)
        XCTAssertEqual(transaction.filter({ $0.operation == .delete }).count, 5)
        
        XCTAssertEqual(transaction.filter({ $0.operation == .delete && $0.model == .artist }).count, 1) // delete flap+frog
        XCTAssertEqual(transaction.filter({ $0.operation == .delete && $0.model == .song }).count, 4) // delete flap+frog songs
        XCTAssertEqual(transaction.filter({ $0.operation == .update && $0.model == .album }).count, 2) // update flap+frog albums
        
        compare(stable: expectedStableBasis, against: newBasis, test: #function)
    }
}
