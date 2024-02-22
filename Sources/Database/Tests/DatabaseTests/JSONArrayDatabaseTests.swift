import XCTest
import Models
import ModelsMocks
@testable import Database

final class JSONArrayDatabaseTests: XCTestCase {
    
    private static let dbDefaultURL_ios = URL.applicationSupportDirectory
        .appending(component: "TestDatabase")
    private static let songsDefaultURL_ios = URL.applicationSupportDirectory
        .appending(component: "TestDatabase")
        .appending(component: "songs.json")
    private static let albumsDefaultURL_ios = URL.applicationSupportDirectory
        .appending(component: "TestDatabase")
        .appending(component: "albums.json")
    private static let artistsDefaultURL_ios = URL.applicationSupportDirectory
        .appending(component: "TestDatabase")
        .appending(component: "artists.json")
    
    private let fileManager = FileManager()
    
    private func initTestDB() throws -> JSONArrayDatabase {
        try JSONArrayDatabase(
            decoder: JSONDecoder()
            , encoder: JSONEncoder()
            , fileManager: FileManager()
            , songsURL: JSONArrayDatabaseTests.songsDefaultURL_ios
            , albumsURL: JSONArrayDatabaseTests.albumsDefaultURL_ios
            , artistsURL: JSONArrayDatabaseTests.artistsDefaultURL_ios
        )
    }
    
    private func deleteTestDB() throws {
        if fileManager.fileExists(atPath: JSONArrayDatabaseTests.dbDefaultURL_ios.path()) {
            try fileManager.removeItem(at: JSONArrayDatabaseTests.dbDefaultURL_ios)
        }
    }
    
    private func createEmptyTestDB() throws {
        try deleteTestDB()
        //try fileManager.createDirectory(at: JSONArrayDatabaseTests.dbDefaultURL_ios, withIntermediateDirectories: false)
        fileManager.createFile(atPath: JSONArrayDatabaseTests.songsDefaultURL_ios.path(), contents: nil)
        fileManager.createFile(atPath: JSONArrayDatabaseTests.albumsDefaultURL_ios.path(), contents: nil)
        fileManager.createFile(atPath: JSONArrayDatabaseTests.artistsDefaultURL_ios.path(), contents: nil)
        
        print("songs at \(JSONArrayDatabaseTests.songsDefaultURL_ios.path()): \(fileManager.fileExists(atPath: JSONArrayDatabaseTests.songsDefaultURL_ios.path()))")
        print("albums at \(JSONArrayDatabaseTests.albumsDefaultURL_ios.path()): \(fileManager.fileExists(atPath: JSONArrayDatabaseTests.albumsDefaultURL_ios.path()))")
        print("artists at \(JSONArrayDatabaseTests.artistsDefaultURL_ios.path()): \(fileManager.fileExists(atPath: JSONArrayDatabaseTests.artistsDefaultURL_ios.path()))")
    }
    
    private func createValidTestDB() throws {
        try deleteTestDB()
        //try fileManager.createDirectory(at: JSONArrayDatabaseTests.dbDefaultURL_ios, withIntermediateDirectories: false)
        let songsData = Song.songsJSON.data(using: .utf8)
        let albumsData = Album.albumsJSON.data(using: .utf8)
        let artistsData = Artist.artistsJSON.data(using: .utf8)
        
        try songsData!.write(to: JSONArrayDatabaseTests.songsDefaultURL_ios)
        try albumsData!.write(to: JSONArrayDatabaseTests.albumsDefaultURL_ios)
        try artistsData!.write(to: JSONArrayDatabaseTests.artistsDefaultURL_ios)
        
        print("songs at \(JSONArrayDatabaseTests.songsDefaultURL_ios.path()): \(fileManager.fileExists(atPath: JSONArrayDatabaseTests.songsDefaultURL_ios.path()))")
        print("albums at \(JSONArrayDatabaseTests.albumsDefaultURL_ios.path()): \(fileManager.fileExists(atPath: JSONArrayDatabaseTests.albumsDefaultURL_ios.path()))")
        print("artists at \(JSONArrayDatabaseTests.artistsDefaultURL_ios.path()): \(fileManager.fileExists(atPath: JSONArrayDatabaseTests.artistsDefaultURL_ios.path()))")
    }
    
    private func createInvalidTestDB() throws {
        try deleteTestDB()
        //try fileManager.createDirectory(at: JSONArrayDatabaseTests.dbDefaultURL_ios, withIntermediateDirectories: false)
        fileManager.createFile(atPath: JSONArrayDatabaseTests.songsDefaultURL_ios.path(), contents: nil)
        fileManager.createFile(atPath: JSONArrayDatabaseTests.albumsDefaultURL_ios.path(), contents: nil)
        fileManager.createFile(atPath: JSONArrayDatabaseTests.artistsDefaultURL_ios.path(), contents: nil)
    }
    
    // MARK: DB Persistant State Tests
    
    func test_initNoDB() async {
        do {
            try deleteTestDB()
        } catch {
            XCTFail("Failed test set up: \(error.localizedDescription)")
        }
        
        let sut: JSONArrayDatabase
        do {
            sut = try initTestDB()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return
        }
        
        let songs = try? await sut.getSongs()
        XCTAssertEqual(songs!.count, 0)
        let albums = try? await sut.getAlbums()
        XCTAssertEqual(albums!.count, 0)
        let artists = try? await sut.getArtists()
        XCTAssertEqual(artists!.count, 0)
    }
    
    func test_initEmptyDB() async {
        do {
            try createEmptyTestDB()
        } catch {
            XCTFail("Failed test set up: \(error.localizedDescription)")
        }
        
        let sut: JSONArrayDatabase
        do {
            sut = try initTestDB()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return
        }
        
        let songs = try? await sut.getSongs()
        XCTAssertEqual(songs!.count, 0)
        let albums = try? await sut.getAlbums()
        XCTAssertEqual(albums!.count, 0)
        let artists = try? await sut.getArtists()
        XCTAssertEqual(artists!.count, 0)
    }
    
    func test_initValidDB() async {
        do {
            try createValidTestDB()
        } catch {
            XCTFail("Failed test set up: \(error.localizedDescription)")
        }
        
        let sut: JSONArrayDatabase
        do {
            sut = try initTestDB()
        } catch {
            XCTFail("Failed to init Database: \(error.localizedDescription)")
            return
        }
        
        let songs = try? await sut.getSongs()
        XCTAssertEqual(songs!.count, 21)
        let albums = try? await sut.getAlbums()
        XCTAssertEqual(albums!.count, 2)
        let artists = try? await sut.getArtists()
        XCTAssertEqual(artists!.count, 7)
    }
    
    func test_initCorruptDB() async {
        
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
//    func test_getValid() async {
//        
//    }
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
