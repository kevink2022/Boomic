import XCTest
import Models
import ModelsMocks
@testable import Database

private typealias Mocks = ModelsMocks

final class DatabaseTests: XCTestCase {
    
    private let decoder = JSONDecoder()
       
    private func unlinkedSongs() -> [Song] {
        let (songs, _, _) = Mocks.sampleModels()
        return songs.map { $0.apply(update: SongUpdate(song: $0, artists: [], albums: [])) }
    }
    
    private func sampleBasis() async -> DataBasis {
        let unlinkedSongs = unlinkedSongs()
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
            
            XCTAssertEqual(basis1Song.source, basis2Song.source, test)
            XCTAssertEqual(basis1Song.duration, basis2Song.duration, test)
            XCTAssertEqual(basis1Song.title, basis2Song.title, test)
            XCTAssertEqual(basis1Song.trackNumber, basis2Song.trackNumber, test)
            XCTAssertEqual(basis1Song.discNumber, basis2Song.discNumber, test)
            XCTAssertEqual(basis1Song.art, basis2Song.art, test)
            XCTAssertEqual(basis1Song.artistName, basis2Song.artistName, test)
            XCTAssertEqual(basis1Song.artists.count, basis2Song.artists.count, test)
            XCTAssertEqual(basis1Song.albumTitle, basis2Song.albumTitle, test)
            XCTAssertEqual(basis1Song.albums.count, basis2Song.albums.count, test)
            XCTAssertEqual(basis1Song.rating, basis2Song.rating, test)
        }
        
        basis1.allAlbums.forEach { basis1Album in
            guard let basis2Album = basis2.allAlbums.first(where: { basis2Album in basis2Album.title == basis1Album.title })
            else { XCTFail("No Matching Album: \(test)"); return }
            
            XCTAssertEqual(basis1Album.title, basis2Album.title, test)
            XCTAssertEqual(basis1Album.art, basis2Album.art, test)
            XCTAssertEqual(basis1Album.songs.count, basis2Album.songs.count, test)
            XCTAssertEqual(basis1Album.artistName, basis2Album.artistName, test)
            XCTAssertEqual(basis1Album.artists.count, basis2Album.artists.count, test)
        }
        
        basis1.allArtists.forEach { basis1Artist in
            guard let basis2Artist = basis2.allArtists.first(where: { basis2Artist in basis2Artist.name == basis1Artist.name })
            else { XCTFail("No Matching Album: \(test)"); return }
            
            XCTAssertEqual(basis1Artist.name, basis2Artist.name, test)
            XCTAssertEqual(basis1Artist.songs.count, basis2Artist.songs.count, test)
            XCTAssertEqual(basis1Artist.albums.count, basis2Artist.albums.count, test)
            XCTAssertEqual(basis1Artist.art, basis2Artist.art, test)
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
        
        let sample = await sampleBasis()
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
        XCTAssertEqual(evenTransaction.filter({ $0.model == .album && $0.operation == .update}).count, 2)
        XCTAssertEqual(evenTransaction.filter({ $0.model == .artist && $0.operation == .add }).count, 1)
        XCTAssertEqual(evenTransaction.filter({ $0.model == .artist && $0.operation == .update }).count, 5)
        
        XCTAssertEqual(evenBasis.allSongs.count, songs.count)
        XCTAssertEqual(evenBasis.allAlbums.count, albums.count)
        XCTAssertEqual(evenBasis.allArtists.count, artists.count)
        
        let sample = await sampleBasis()
        compare(stable: sample, against: evenBasis, test: #function)
    }
}
