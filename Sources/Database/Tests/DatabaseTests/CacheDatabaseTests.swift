import XCTest
import Models
import ModelsMocks
@testable import Database

/// TODO
/// - Sort on update
/// - Object delete
/// - Proper sorting tests
/// - Bulk Tests
/// - Documentation
/// The first two will require the model resolver, so thats what I will work on now,

final class CacheDatabaseTests: XCTestCase {
    
    private let fileManager = FileManager()
    private let decoder = JSONDecoder()
    
    private func initTestDB() throws -> CacheDatabase {
        try CacheDatabase(
            decoder: JSONDecoder()
            , encoder: JSONEncoder()
            , songsURL: C.songsDefaultURL_ios
            , albumsURL: C.albumsDefaultURL_ios
            , artistsURL: C.artistsDefaultURL_ios
        )
    }
    
    // MARK: - DB Persistant State Tests
    
    func test_initNoDB() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try deleteTestDB() }
        
        let sut: CacheDatabase
        do {
            sut = try initTestDB()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return
        }
        
        let songs = sut.getSongs()
        XCTAssertEqual(songs.count, 0)
        let albums = sut.getAlbums()
        XCTAssertEqual(albums.count, 0)
        let artists = sut.getArtists()
        XCTAssertEqual(artists.count, 0)
    }
    
    func test_initEmptyDB() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try createEmptyTestDB() }
        
        let sut: CacheDatabase
        do {
            sut = try initTestDB()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return
        }
        
        let songs = sut.getSongs()
        XCTAssertEqual(songs.count, 0)
        let albums = sut.getAlbums()
        XCTAssertEqual(albums.count, 0)
        let artists = sut.getArtists()
        XCTAssertEqual(artists.count, 0)
    }
    
    func test_initValidDB() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try createValidTestDB() }
        
        let sut: CacheDatabase
        do {
            sut = try initTestDB()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return
        }
        
        let songs = sut.getSongs()
        XCTAssertEqual(songs.count, 21)
        let albums = sut.getAlbums()
        XCTAssertEqual(albums.count, 2)
        let artists = sut.getArtists()
        XCTAssertEqual(artists.count, 7)
    }
    
    func test_initCorruptDB() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try createCorruptTestDB() }
        
        do {
            _ = try initTestDB()
            XCTFail("Database initialized with corrupt data.")
        } catch {
            XCTAssertEqual(error as! DatabaseError, DatabaseError.dataCorrupted(C.songsDefaultURL_ios))
        }
    }
    
    // MARK: - DB Protocol Tests
    
    func test_getAll() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try createValidTestDB() }
        guard let sut = initWrapper({ try initTestDB() }) else { return }
        
        let songs: [Song]
        let albums: [Album]
        let artists: [Artist]
 
        songs = sut.getSongs()
        albums = sut.getAlbums()
        artists = sut.getArtists()
        
        XCTAssertEqual(songs.count, 21)
        XCTAssertEqual(albums.count, 2)
        XCTAssertEqual(artists.count, 7)
    }

    func test_getValid() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try createValidTestDB() }
        guard let sut = initWrapper({ try initTestDB() }) else { return }
        
        let (songs, albums, artists) = sampleModels()
        let song = songs.filter { $0.id == UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d")! }.first!
        let album = albums.filter { $0.id == UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a")! }.first!
        let artist = artists.filter { $0.id == UUID(uuidString: "9eecb26c-3254-4d76-9e02-29f211da7684")! }.first!
        
        do {
            let albumsFromSong: [Album]
            let artistsFromSong: [Artist]

            albumsFromSong = sut.getAlbums(for: song.albums)
            artistsFromSong = sut.getArtists(for: song.artists)
            
            XCTAssertEqual(albumsFromSong.count, 1)
            XCTAssertEqual(artistsFromSong.count, 1)
        }
        
        do {
            let songsFromAlbum: [Song]
            let artistsFromAlbum: [Artist]
 
            songsFromAlbum = sut.getSongs(for: album.songs)
            artistsFromAlbum = sut.getArtists(for: album.artists)
            
            XCTAssertEqual(songsFromAlbum.count, 10)
            XCTAssertEqual(artistsFromAlbum.count, 5)
        }
        
        do {
            let songsFromArtist: [Song]
            let albumsFromArtist: [Album]
 
            songsFromArtist = sut.getSongs(for: artist.songs)
            albumsFromArtist = sut.getAlbums(for: artist.albums)
            
            XCTAssertEqual(songsFromArtist.count, 4)
            XCTAssertEqual(albumsFromArtist.count, 2)
        }
    }

//    func test_getInvalid() async {
//        defer { try? deleteTestDB() }
//        setUpTestDB { try createValidTestDB() }
//        guard let sut = initWrapper({ try initTestDB() }) else { return }
//        
//        let albums = sut.getAlbums()
//        let album = albums.filter { $0.id == UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a")! }.first!
//       
//        do {
//            _ = sut.get(Album.self, from: album)
//            XCTFail("Expected to throw on invalid relationship")
//        } catch {
//            XCTAssertEqual(
//                error as! ModelError,
//                ModelError.unresolvedRelation(Album.self, Album.self))
//        }
//    }
    
    // MARK: - Helpers
    
    private typealias C = TestConstants
    private struct TestConstants {
        private static let directoryString = "TestDatabase/"
        
        static let dbDefaultURL_ios = URL.applicationSupportDirectory
            .appending(component: TestConstants.directoryString)
        static let songsDefaultURL_ios = URL.applicationSupportDirectory
            .appending(component: TestConstants.directoryString)
            .appending(component: "songs.json")
        static let albumsDefaultURL_ios = URL.applicationSupportDirectory
            .appending(component: TestConstants.directoryString)
            .appending(component: "albums.json")
        static let artistsDefaultURL_ios = URL.applicationSupportDirectory
            .appending(component: TestConstants.directoryString)
            .appending(component: "artists.json")
    }
    
    private func initWrapper(_ initFunc: () throws -> CacheDatabase) -> CacheDatabase? {
        do {
            return try initFunc()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func setUpTestDB(_ setUpFunc: () throws -> ()) {
        do {
            try setUpFunc()
        } catch {
            XCTFail("Failed to set up test DB: \(error.localizedDescription)")
        }
    }
    
    private func deleteTestDB() throws {
        let urls = try fileManager.contentsOfDirectory(at: URL.applicationSupportDirectory, includingPropertiesForKeys: nil)
        
        if urls.contains(C.dbDefaultURL_ios) {
            try fileManager.removeItem(at: C.dbDefaultURL_ios)
        }
    }
    
    private func createEmptyTestDB() throws {
        try deleteTestDB()
        try fileManager.createDirectory(at: C.dbDefaultURL_ios, withIntermediateDirectories: false)
        
        let emptyData = "[]".data(using: .utf8)
        try emptyData!.write(to: C.songsDefaultURL_ios)
        try emptyData!.write(to: C.albumsDefaultURL_ios)
        try emptyData!.write(to: C.artistsDefaultURL_ios)
    }
    
    private func createValidTestDB() throws {
        try deleteTestDB()
        try fileManager.createDirectory(at: C.dbDefaultURL_ios, withIntermediateDirectories: false)
        
        let songsData = Song.songsJSON.data(using: .utf8)
        let albumsData = Album.albumsJSON.data(using: .utf8)
        let artistsData = Artist.artistsJSON.data(using: .utf8)
        try songsData!.write(to: C.songsDefaultURL_ios)
        try albumsData!.write(to: C.albumsDefaultURL_ios)
        try artistsData!.write(to: C.artistsDefaultURL_ios)
    }
    
    private func createCorruptTestDB() throws {
        try deleteTestDB()
        try fileManager.createDirectory(at: C.dbDefaultURL_ios, withIntermediateDirectories: false)
        
        let emptyData = "[zoinks, scoob, i think this data's corrupt!]".data(using: .utf8)
        try emptyData!.write(to: C.songsDefaultURL_ios)
        try emptyData!.write(to: C.albumsDefaultURL_ios)
        try emptyData!.write(to: C.artistsDefaultURL_ios)
    }
    
    private func sampleModels() -> ([Song], [Album], [Artist]) {
        let songsData = Song.songsJSON.data(using: .utf8)!
        let albumsData = Album.albumsJSON.data(using: .utf8)!
        let artistsData = Artist.artistsJSON.data(using: .utf8)!
        let songs = try! decoder.decode([Song].self, from: songsData)
        let albums = try! decoder.decode([Album].self, from: albumsData)
        let artists = try! decoder.decode([Artist].self, from: artistsData)
        
        return (songs, albums, artists)
    }
}
