import XCTest
import Models
import ModelsMocks
@testable import Database

final class DatabaseTests: XCTestCase {
    
    private let decoder = JSONDecoder()
    
    private func sampleModels() -> ([Song], [Album], [Artist]) {
        let songsData = Song.songsJSON.data(using: .utf8)!
        let albumsData = Album.albumsJSON.data(using: .utf8)!
        let artistsData = Artist.artistsJSON.data(using: .utf8)!
        let songs = try! decoder.decode([Song].self, from: songsData)
        let albums = try! decoder.decode([Album].self, from: albumsData)
        let artists = try! decoder.decode([Artist].self, from: artistsData)
        
        return (songs, albums, artists)
    }
    
    private func unlinkedSongs() -> [Song] {
        let (songs, _, _) = sampleModels()
        return songs.map { $0.apply(update: SongUpdate(song: $0, artists: [], albums: [])) }
    }
      
    func test_addSongsToEmpty() async {
        let (songs, albums, artists) = sampleModels()
        let unlinkedSongs = unlinkedSongs()
        
        XCTAssertEqual(unlinkedSongs[0].artists, [])
        XCTAssertEqual(unlinkedSongs[0].albums, [])
        
        let sut = BasisResolver(currentBasis: DataBasis.empty)
        
        let transaction = await sut.addSongs(unlinkedSongs)
        
        XCTAssertEqual(transaction.add?.songs?.count, songs.count)
        XCTAssertEqual(transaction.add?.albums?.count, albums.count)
        XCTAssertEqual(transaction.add?.artists?.count, artists.count)
    }
    
    func test_emptyAddTransaction() async {
        let (songs, albums, artists) = sampleModels()
        let unlinkedSongs = unlinkedSongs()
        
        let transaction = await BasisResolver(currentBasis: DataBasis.empty).addSongs(unlinkedSongs)
        let sut = BasisResolver(currentBasis: DataBasis.empty)
        
        let newBasis = await sut.apply(transaction: transaction)
        
        XCTAssertEqual(newBasis.allSongs.count, songs.count)
        XCTAssertEqual(newBasis.allAlbums.count, albums.count)
        XCTAssertEqual(newBasis.allArtists.count, artists.count)
    }
    
    func test_addSongsByAlbum() async {
        
        let (songs, albums, artists) = sampleModels()
        let unlinkedSongs = unlinkedSongs()
        let ga1_songs = unlinkedSongs.filter { $0.albumTitle == "Girls Apartment" }
        let ga2_songs = unlinkedSongs.filter { $0.albumTitle == "Girls Apartment 2" }
               
        let ga1_basis = await BasisResolver(currentBasis: DataBasis.empty)
            .apply(transaction: BasisResolver(currentBasis: DataBasis.empty).addSongs(ga1_songs))
        
        let sut = BasisResolver(currentBasis: ga1_basis)
        
        let ga2_transaction = await sut.addSongs(ga2_songs)
        let ga2_basis = await sut.apply(transaction: ga2_transaction)
        
        
        XCTAssertEqual(ga2_transaction.add?.songs?.count, ga2_songs.count)
        XCTAssertEqual(ga2_transaction.add?.albums?.count, 1)
        XCTAssertEqual(ga2_transaction.add?.artists?.count, 2)
        XCTAssertEqual(ga2_transaction.update?.artists?.count, 4)
        
        XCTAssertEqual(ga2_basis.allSongs.count, songs.count)
        XCTAssertEqual(ga2_basis.allAlbums.count, albums.count)
        XCTAssertEqual(ga2_basis.allArtists.count, artists.count)
    }
    
}
