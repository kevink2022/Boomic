import XCTest
import Domain
import Models
import ModelsMocks
@testable import Database

private typealias Mocks = ModelsMocks

final class AssertionsTests: XCTestCase {
    
    func test_addApplyUpdate() {
        let song = Song.aCagedPersona
        let addAssertion = Assertion.addSong(song)
        let addAssertionSet = KeySet<Assertion>().inserting(addAssertion)
        
        let update = SongUpdate(song: song, title: "an uncaged persona")
        let updateAssertion = Assertion.updateSong(update)
        let updateAssertionSet = KeySet<Assertion>().inserting(updateAssertion)
        
        let flattenedAssertionSet = Assertion.flatten([addAssertionSet, updateAssertionSet])
        let flattenedAssertion = flattenedAssertionSet[addAssertion]
        
        XCTAssertEqual(flattenedAssertionSet.count, 1)
        XCTAssertEqual(flattenedAssertion?.model, .song)
        XCTAssertEqual(flattenedAssertion?.operation, .add)
        
        guard case let .addSong(addSong) = flattenedAssertion else { XCTFail("Error: Failed to extract assertion."); return }
        
        XCTAssertEqual(addSong.title, "an uncaged persona")
    }
    
    func test_addApplyDelete() {
        let song = Song.aCagedPersona
        let addAssertion = Assertion.addSong(song)
        let addAssertionSet = KeySet<Assertion>().inserting(addAssertion)
        
        let delete = Song.aCagedPersona.id
        let deleteAssertion = Assertion.deleteSong(delete)
        let deleteAssertionSet = KeySet<Assertion>().inserting(deleteAssertion)
        
        let flattenedAssertionSet = Assertion.flatten([addAssertionSet, deleteAssertionSet])
        let flattenedAssertion = flattenedAssertionSet[addAssertion]
        
        XCTAssertEqual(flattenedAssertionSet.count, 1)
        XCTAssertEqual(flattenedAssertion?.model, .song)
        XCTAssertEqual(flattenedAssertion?.operation, .delete)
        
        guard case let .deleteSong(deleteSong) = flattenedAssertion else { XCTFail("Error: Failed to extract assertion."); return }
        
        XCTAssertEqual(deleteSong, delete)
    }
    
    func test_updateApplyUpdate() {
        let update = SongUpdate(song: Song.aCagedPersona, title: "an uncaged persona")
        let updateAssertion = Assertion.updateSong(update)
        let updateAssertionSet = KeySet<Assertion>().inserting(updateAssertion)
        
        let update2 = SongUpdate(song: Song.aCagedPersona, title: "a very uncaged persona")
        let update2Transaction = Assertion.updateSong(update2)
        let update2TransactionSet = KeySet<Assertion>().inserting(update2Transaction)
        
        let flattenedAssertionSet = Assertion.flatten([updateAssertionSet, update2TransactionSet])
        let flattenedAssertion = flattenedAssertionSet[updateAssertion]
        
        XCTAssertEqual(flattenedAssertionSet.count, 1)
        XCTAssertEqual(flattenedAssertion?.model, .song)
        XCTAssertEqual(flattenedAssertion?.operation, .update)
        
        guard case let .updateSong(updateSong) = flattenedAssertion else { XCTFail("Error: Failed to extract assertion."); return }
        
        XCTAssertEqual(updateSong.title, "a very uncaged persona")
    }
    
    func test_updateApplyDelete() {
        let update = SongUpdate(song: Song.aCagedPersona, title: "an uncaged persona")
        let updateAssertion = Assertion.updateSong(update)
        let updateAssertionSet = KeySet<Assertion>().inserting(updateAssertion)

        let delete = Song.aCagedPersona.id
        let deleteAssertion = Assertion.deleteSong(delete)
        let deleteAssertionSet = KeySet<Assertion>().inserting(deleteAssertion)
        
        let flattenedAssertionSet =  Assertion.flatten([updateAssertionSet, deleteAssertionSet])
        let flattenedAssertion = flattenedAssertionSet[updateAssertion]
        
        XCTAssertEqual(flattenedAssertionSet.count, 1)
        XCTAssertEqual(flattenedAssertion?.model, .song)
        XCTAssertEqual(flattenedAssertion?.operation, .delete)
        
        guard case let .deleteSong(deleteSong) = flattenedAssertion else { XCTFail("Error: Failed to extract assertion."); return }
        
        XCTAssertEqual(deleteSong, delete)
    }
    
    func test_deleteApplyAdd() {
        let song = Song.aCagedPersona
        let addAssertion = Assertion.addSong(song)
        let addAssertionSet = KeySet<Assertion>().inserting(addAssertion)
        
        let delete = Song.aCagedPersona.id
        let deleteAssertion = Assertion.deleteSong(delete)
        let deleteAssertionSet = KeySet<Assertion>().inserting(deleteAssertion)
        
        let flattenedAssertionSet = try Assertion.flatten([deleteAssertionSet, addAssertionSet])
        let flattenedAssertion = flattenedAssertionSet[addAssertion]
        
        XCTAssertEqual(flattenedAssertionSet.count, 1)
        XCTAssertEqual(flattenedAssertion?.model, .song)
        XCTAssertEqual(flattenedAssertion?.operation, .add)
        
        guard case let .addSong(addSong) = flattenedAssertion else { XCTFail("Error: Failed to extract assertion."); return }
        
        XCTAssertEqual(addSong.title, "a caged persona")
    }
    
    func test_setMerge() {
        let (songs, albums, artists) = Mocks.sampleModels()
        
        let assertionSet1 = KeySet<Assertion>()
            .inserting([
                .addSong(songs[0])
                , .addSong(songs[1])
                , .addSong(songs[2])
                , .addAlbum(albums[0])
                , .addArtist(artists[0])
            ])
        
        let assertionSet2 = KeySet<Assertion>()
            .inserting([
                /* merge with first 5 */
                .updateSong(SongUpdate(song: songs[0], title: "an uncaged persona"))
                , .deleteSong(songs[1].id)
                , .updateAlbum(AlbumUpdate(album: albums[0], artistName: "Reimu"))
                /* new */
                , .updateSong(SongUpdate(song: songs[19], title: "para la princesa temprano"))
                , .updateSong(SongUpdate(song: songs[20], title: "this will be deleted"))
            ])
        
        let assertionSet3 = KeySet<Assertion>()
            .inserting([
                /* merge with new 3 */
                .deleteSong(songs[20].id)
                , .updateSong(SongUpdate(song:  songs[19], title: "para la princesa azusa"))
            ])
        
        let sut = Assertion.flatten([assertionSet1, assertionSet2, assertionSet3])
        
        XCTAssertEqual(sut.count, 7)
        XCTAssertEqual(sut.filter{ $0.operation == .add }.count, 4)
        XCTAssertEqual(sut.filter{ $0.operation == .update }.count, 1)
        XCTAssertEqual(sut.filter{ $0.operation == .delete }.count, 2)
        
        guard case let .addSong(song0) = sut[songs[0].id] else { XCTFail("Error: Failed to extract assertion."); return }
        guard case let .updateSong(songUpdate19) = sut[songs[19].id] else { XCTFail("Error: Failed to extract assertion."); return }
        guard case let .deleteSong(songID1) = sut[songs[1].id] else { XCTFail("Error: Failed to extract assertion."); return }
        guard case let .addAlbum(album0) = sut[albums[0].id] else { XCTFail("Error: Failed to extract assertion."); return }
        
        XCTAssertEqual(song0.title, "an uncaged persona")
        XCTAssertEqual(songUpdate19.title, "para la princesa azusa")
        XCTAssertEqual(songID1, songs[1].id)
        XCTAssertEqual(album0.artistName, "Reimu")
    }
}
