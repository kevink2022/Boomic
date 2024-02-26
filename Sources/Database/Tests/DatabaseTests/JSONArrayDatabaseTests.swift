import XCTest
import Models
import ModelsMocks
@testable import Database



final class JSONArrayDatabaseTests: XCTestCase {
    
    private let fileManager = FileManager()
    private let decoder = JSONDecoder()
    
    private func initTestDB() throws -> JSONArrayDatabase {
        try JSONArrayDatabase(
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
        setUpTestDB { try createEmptyTestDB() }
        
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
        setUpTestDB { try createValidTestDB() }
        
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
        
        do {
            songs = try await sut.get(Song.self)
            albums = try await sut.get(Album.self)
            artists = try await sut.get(Artist.self)
        } catch {
            XCTFail("Failed to get: \(error.localizedDescription)")
            return
        }
        
        XCTAssertEqual(songs.count, 21)
        XCTAssertEqual(albums.count, 2)
        XCTAssertEqual(artists.count, 7)
    }

    func test_getValid() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try createValidTestDB() }
        guard let sut = initWrapper({ try initTestDB() }) else { return }
        
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

    func test_getInvalid() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try createValidTestDB() }
        guard let sut = initWrapper({ try initTestDB() }) else { return }
        
        let albums = try! await sut.get(Album.self)
        let album = albums.first!
       
        do {
            _ = try await sut.get(Album.self, from: album)
            XCTFail("Expected to throw on invalid relationship")
        } catch {
            XCTAssertEqual(
                error as! DatabaseError,
                DatabaseError.unresolvedRelation(Album.self, Album.self))
        }
    }

    func test_saveEmpty() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try createEmptyTestDB() }
        let (songs, albums, artists) = sampleModels()
        
        // Test same session
        do {
            guard let sut = initWrapper({ try initTestDB() }) else { return }
            
            do {
                try await sut.save(songs)
                try await sut.save(albums)
                try await sut.save(artists)
            } catch {
                XCTFail("Failed to execute save")
                return
            }
            
            let songs = try! await sut.get(Song.self)
            let albums = try! await sut.get(Album.self)
            let artists = try! await sut.get(Artist.self)
            XCTAssertEqual(songs.count, 21)
            XCTAssertEqual(albums.count, 2)
            XCTAssertEqual(artists.count, 7)
        }
        
        // Test new session
        do {
            guard let sut2 = initWrapper({ try initTestDB() }) else { return }
            
            let songs = try! await sut2.get(Song.self)
            let albums = try! await sut2.get(Album.self)
            let artists = try! await sut2.get(Artist.self)
            XCTAssertEqual(songs.count, 21)
            XCTAssertEqual(albums.count, 2)
            XCTAssertEqual(artists.count, 7)
        }
    }

    func test_saveNew() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try createEmptyTestDB() }
        let (songs, albums, artists) = sampleModels()
        
        let firstAlbum = albums.filter { $0.id == UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a")! }
        let firstAlbumSongs = songs.filter { $0.album == UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a")! }
        let firstAlbumAtrists = artists.filter { $0.albums.contains(UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a")!) }
        
        let secondAlbum = albums.filter { $0.id == UUID(uuidString: "0536d5fe-2435-486c-81a3-2642e6273d70")! }
        let secondAlbumSongs = songs.filter { $0.album == UUID(uuidString: "0536d5fe-2435-486c-81a3-2642e6273d70")! }
        let secondAlbumAtrists = artists.filter { $0.albums.contains(UUID(uuidString: "0536d5fe-2435-486c-81a3-2642e6273d70")!) }
        
        // Test same session
        do {
            guard let sut = initWrapper({ try initTestDB() }) else { return }
            
            do {
                try await sut.save(firstAlbumSongs)
                try await sut.save(firstAlbum)
                try await sut.save(firstAlbumAtrists)
            } catch {
                XCTFail("Failed to execute save")
                return
            }
            
            let songs = try! await sut.get(Song.self)
            let albums = try! await sut.get(Album.self)
            let artists = try! await sut.get(Artist.self)
            XCTAssertEqual(songs.count, 10)
            XCTAssertEqual(albums.count, 1)
            XCTAssertEqual(albums[0].id, UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"))
            XCTAssertEqual(artists.count, 5)
            
            do {
                try await sut.save(secondAlbumSongs)
                try await sut.save(secondAlbum)
                try await sut.save(secondAlbumAtrists)
            } catch {
                XCTFail("Failed to execute save")
                return
            }
            
            let songs2 = try! await sut.get(Song.self)
            let albums2 = try! await sut.get(Album.self)
            let artists2 = try! await sut.get(Artist.self)
            XCTAssertEqual(songs2.count, 21)
            XCTAssertEqual(albums2.count, 2)
            XCTAssertEqual(albums2[1].id, UUID(uuidString: "0536d5fe-2435-486c-81a3-2642e6273d70"))
            XCTAssertEqual(artists2.count, 7)
        }
        
        // Test different sessions
        setUpTestDB { try createEmptyTestDB() }
        
        do {
            guard let sut = initWrapper({ try initTestDB() }) else { return }
            
            do {
                try await sut.save(firstAlbumSongs)
                try await sut.save(firstAlbum)
                try await sut.save(firstAlbumAtrists)
            } catch {
                XCTFail("Failed to execute save")
                return
            }
            
            let songs = try! await sut.get(Song.self)
            let albums = try! await sut.get(Album.self)
            let artists = try! await sut.get(Artist.self)
            XCTAssertEqual(songs.count, 10)
            XCTAssertEqual(albums.count, 1)
            XCTAssertEqual(albums[0].id, UUID(uuidString: "2d3e4f5a-6b7c-8d9e-0f1a-2b3c4d5e6f7a"))
            XCTAssertEqual(artists.count, 5)
        }
        
        do {
            guard let sut = initWrapper({ try initTestDB() }) else { return }
            
            do {
                try await sut.save(secondAlbumSongs)
                try await sut.save(secondAlbum)
                try await sut.save(secondAlbumAtrists)
            } catch {
                XCTFail("Failed to execute save")
                return
            }
            
            let songs2 = try! await sut.get(Song.self)
            let albums2 = try! await sut.get(Album.self)
            let artists2 = try! await sut.get(Artist.self)
            XCTAssertEqual(songs2.count, 21)
            XCTAssertEqual(albums2.count, 2)
            XCTAssertEqual(albums2[1].id, UUID(uuidString: "0536d5fe-2435-486c-81a3-2642e6273d70"))
            XCTAssertEqual(artists2.count, 7)
        }
        
    }
    
    func test_saveOverwrite() async {
        defer { try? deleteTestDB() }
        setUpTestDB { try createEmptyTestDB() }
        let (songs, _, _) = sampleModels()
        
        let aCagedPersona = songs.first(where: { $0.id == UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d")})!
        
        let aCagedPersonaNew = Song(
            id: aCagedPersona.id
            , source: aCagedPersona.source
            , duration: aCagedPersona.duration
            , title: "An Uncaged Persona!"
            , trackNumber: 100
            , artistName: aCagedPersona.artistName
            , artists: aCagedPersona.artists
            , albumTitle: aCagedPersona.albumTitle
            , album: aCagedPersona.album
        )
        
        // Test same session
        do {
            guard let sut = initWrapper({ try initTestDB() }) else { return }
            
            do {
                try await sut.save(songs)
            } catch {
                XCTFail("Failed to execute save")
                return
            }
            
            let songs = try! await sut.get(Song.self)
            XCTAssertEqual(songs.count, 21)
            let aCagedPersona = songs.first(where: { $0.id == UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d")})!
            XCTAssertEqual(aCagedPersona.title, "a caged persona")
            XCTAssertEqual(aCagedPersona.trackNumber, 1)
            
            do {
                try await sut.save([aCagedPersonaNew])
            } catch {
                XCTFail("Failed to execute save")
                return
            }
            
            let songsEdited = try! await sut.get(Song.self)
            XCTAssertEqual(songsEdited.count, 21)
            let aCagedPersonaNew = songsEdited.first(where: { $0.id == UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d")})!
            XCTAssertEqual(aCagedPersonaNew.title, "An Uncaged Persona!")
            XCTAssertEqual(aCagedPersonaNew.trackNumber, 100)
        }
        
        // Test different sessions
        setUpTestDB { try createEmptyTestDB() }
        
        do {
            guard let sut = initWrapper({ try initTestDB() }) else { return }
            
            do {
                try await sut.save(songs)
            } catch {
                XCTFail("Failed to execute save")
                return
            }
            
            let songs = try! await sut.get(Song.self)
            XCTAssertEqual(songs.count, 21)
            let aCagedPersona = songs.first(where: { $0.id == UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d")})!
            XCTAssertEqual(aCagedPersona.title, "a caged persona")
            XCTAssertEqual(aCagedPersona.trackNumber, 1)
        }
        
        do {
            guard let sut = initWrapper({ try initTestDB() }) else { return }
            
            do {
                try await sut.save([aCagedPersonaNew])
            } catch {
                XCTFail("Failed to execute save")
                return
            }
            
            let songs = try! await sut.get(Song.self)
            XCTAssertEqual(songs.count, 21)
            let aCagedPersona = songs.first(where: { $0.id == UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d")})!
            XCTAssertEqual(aCagedPersona.title, "An Uncaged Persona!")
            XCTAssertEqual(aCagedPersona.trackNumber, 100)
        }
    }
    
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
    
    private func initWrapper(_ initFunc: () throws -> JSONArrayDatabase) -> JSONArrayDatabase? {
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
