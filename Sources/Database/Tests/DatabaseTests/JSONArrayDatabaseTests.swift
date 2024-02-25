import XCTest
import Models
import ModelsMocks
@testable import Database



final class JSONArrayDatabaseTests: XCTestCase {
    
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
    
   
    
    private let fileManager = FileManager()
    
    private func initTestDB() throws -> JSONArrayDatabase {
        try JSONArrayDatabase(
            decoder: JSONDecoder()
            , encoder: JSONEncoder()
            , fileManager: FileManager()
            , songsURL: C.songsDefaultURL_ios
            , albumsURL: C.albumsDefaultURL_ios
            , artistsURL: C.artistsDefaultURL_ios
        )
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
        
        let emptyData = "[zoinks, scoob]".data(using: .utf8)
        try emptyData!.write(to: C.songsDefaultURL_ios)
        try emptyData!.write(to: C.albumsDefaultURL_ios)
        try emptyData!.write(to: C.artistsDefaultURL_ios)
    }
    
    // MARK: DB Persistant State Tests
    
    func test_initNoDB() async {
        defer { try? deleteTestDB() }
        
        do {
            try deleteTestDB()
        } catch {
            XCTFail("Failed to set up test: \(error.localizedDescription)")
        }
        
        let sut: JSONArrayDatabase
        do {
            sut = try initTestDB()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return
        }
        
        let songs = try? await sut.get(Song.self)
        XCTAssertEqual(songs!.count, 0)
        let albums = try? await sut.get(Album.self)
        XCTAssertEqual(albums!.count, 0)
        let artists = try? await sut.get(Artist.self)
        XCTAssertEqual(artists!.count, 0)
    }
    
    func test_initEmptyDB() async {
        defer { try? deleteTestDB() }
        
        do {
            try createEmptyTestDB()
        } catch {
            XCTFail("Failed to set up test: \(error.localizedDescription)")
        }
        
        let sut: JSONArrayDatabase
        do {
            sut = try initTestDB()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return
        }
        
        let songs = try? await sut.get(Song.self)
        XCTAssertEqual(songs!.count, 0)
        let albums = try? await sut.get(Album.self)
        XCTAssertEqual(albums!.count, 0)
        let artists = try? await sut.get(Artist.self)
        XCTAssertEqual(artists!.count, 0)
    }
    
    func test_initValidDB() async {
        defer { try? deleteTestDB() }
        
        do {
            try createValidTestDB()
        } catch {
            XCTFail("Failed to set up test: \(error.localizedDescription)")
        }
        
        let sut: JSONArrayDatabase
        do {
            sut = try initTestDB()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return
        }
        
        let songs = try? await sut.get(Song.self)
        XCTAssertEqual(songs!.count, 21)
        let albums = try? await sut.get(Album.self)
        XCTAssertEqual(albums!.count, 2)
        let artists = try? await sut.get(Artist.self)
        XCTAssertEqual(artists!.count, 7)
    }
    
    func test_initCorruptDB() async {
        defer { try? deleteTestDB() }
        
        do {
            try createCorruptTestDB()
        } catch {
            XCTFail("Failed to set up test: \(error.localizedDescription)")
        }
        
        do {
            _ = try initTestDB()
            XCTFail("Database initialized with corrupt data.")
        } catch {
            XCTAssertEqual(error as! DatabaseError, DatabaseError.dataCorrupted(C.songsDefaultURL_ios))
        }
    }
    
    // MARK: DB Protocol Tests
    
//    func test_getAll() async {
//        
//    }
//    
//    func test_saveAll() async {
//        
//    }
//    
    func test_getValid() async {
        defer { try? deleteTestDB() }
        
        do {
            try createValidTestDB()
        } catch {
            XCTFail("Failed to set up test: \(error.localizedDescription)")
        }
        
        let sut: JSONArrayDatabase
        do {
            sut = try initTestDB()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return
        }
        
        let albums = try! await sut.get(Album.self)
        
        let album = albums.first!
        let artists: [Artist]
        let songs: [Song]
        do {
            artists = try await sut.get(Artist.self, from: album)
            songs = try await sut.get(Song.self, from: album)
        } catch {
            XCTFail("Failed to get: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(artists.count, 5)
        XCTAssertEqual(songs.count, 10)
    }
//    
//    func test_saveValid() async {
//        
//    }
//    
//    func test_getInvalid() async {
//        
//    }
//    
//    func test_saveInvalid() async {
//        
//    }
}
