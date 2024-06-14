import XCTest
import Domain
import Models
import ModelsMocks
@testable import Database

private typealias Mocks = ModelsMocks

final class AssertionsTests: XCTestCase {
    
    func test_addApplyUpdate() {
        let song = Song.aCagedPersona
        let addAssertion = Assertion(song)
        let addAssertionSet = KeySet<Assertion>().inserting(addAssertion)
        
        let update = SongUpdate(song: song, title: "an uncaged persona")
        let updateAssertion = Assertion(update)
        let updateAssertionSet = KeySet<Assertion>().inserting(updateAssertion)
        
        let flattenedAssertionSet = Assertion.flatten([addAssertionSet, updateAssertionSet])
        let flattenedAssertion = flattenedAssertionSet[addAssertion]
        
        XCTAssertEqual(flattenedAssertionSet.count, 1)
        XCTAssertEqual(flattenedAssertion?.model, .song)
        XCTAssertEqual(flattenedAssertion?.operation, .add)
        
        guard let addSong = flattenedAssertion?.data as? Song else { XCTFail("Error: Failed to extract assertion."); return }
        
        XCTAssertEqual(addSong.title, "an uncaged persona")
    }
    
    func test_addApplyDelete() {
        let song = Song.aCagedPersona
        let addAssertion = Assertion(song)
        let addAssertionSet = KeySet<Assertion>().inserting(addAssertion)
        
        let delete = DeleteAssertion(Song.aCagedPersona)
        let deleteAssertion = Assertion(delete)
        let deleteAssertionSet = KeySet<Assertion>().inserting(deleteAssertion)
        
        let flattenedAssertionSet = Assertion.flatten([addAssertionSet, deleteAssertionSet])
        let flattenedAssertion = flattenedAssertionSet[addAssertion]
        
        XCTAssertEqual(flattenedAssertionSet.count, 1)
        XCTAssertEqual(flattenedAssertion?.model, .song)
        XCTAssertEqual(flattenedAssertion?.operation, .delete)
        
        guard let deleteSong = flattenedAssertion?.data as? DeleteAssertion else { XCTFail("Error: Failed to extract assertion."); return }

        XCTAssertEqual(deleteSong.id, delete.id)
        XCTAssertEqual(deleteSong.label, delete.label)
    }
    
    func test_updateApplyUpdate() {
        let update = SongUpdate(song: Song.aCagedPersona, title: "an uncaged persona")
        let updateAssertion = Assertion(update)
        let updateAssertionSet = KeySet<Assertion>().inserting(updateAssertion)
        
        let update2 = SongUpdate(song: Song.aCagedPersona, title: "a very uncaged persona")
        let update2Transaction = Assertion(update2)
        let update2TransactionSet = KeySet<Assertion>().inserting(update2Transaction)
        
        let flattenedAssertionSet = Assertion.flatten([updateAssertionSet, update2TransactionSet])
        let flattenedAssertion = flattenedAssertionSet[updateAssertion]
        
        XCTAssertEqual(flattenedAssertionSet.count, 1)
        XCTAssertEqual(flattenedAssertion?.model, .song)
        XCTAssertEqual(flattenedAssertion?.operation, .update)
        
        guard let updateSong = flattenedAssertion?.data as? SongUpdate else { XCTFail("Error: Failed to extract assertion."); return }
        
        XCTAssertEqual(updateSong.title, "a very uncaged persona")
    }
    
    func test_updateApplyDelete() {
        let update = SongUpdate(song: Song.aCagedPersona, title: "an uncaged persona")
        let updateAssertion = Assertion(update)
        let updateAssertionSet = KeySet<Assertion>().inserting(updateAssertion)

        let delete = DeleteAssertion(Song.aCagedPersona)
        let deleteAssertion = Assertion(delete)
        let deleteAssertionSet = KeySet<Assertion>().inserting(deleteAssertion)
        
        let flattenedAssertionSet =  Assertion.flatten([updateAssertionSet, deleteAssertionSet])
        let flattenedAssertion = flattenedAssertionSet[updateAssertion]
        
        XCTAssertEqual(flattenedAssertionSet.count, 1)
        XCTAssertEqual(flattenedAssertion?.model, .song)
        XCTAssertEqual(flattenedAssertion?.operation, .delete)
        
        guard let deleteSong = flattenedAssertion?.data as? DeleteAssertion else { XCTFail("Error: Failed to extract assertion."); return }
        
        XCTAssertEqual(deleteSong.id, delete.id)
        XCTAssertEqual(deleteSong.label, delete.label)
    }
    
    func test_deleteApplyAdd() {
        let song = Song.aCagedPersona
        let addAssertion = Assertion(song)
        let addAssertionSet = KeySet<Assertion>().inserting(addAssertion)
        
        let delete = DeleteAssertion(Song.aCagedPersona)
        let deleteAssertion = Assertion(delete)
        let deleteAssertionSet = KeySet<Assertion>().inserting(deleteAssertion)
        
        let flattenedAssertionSet = Assertion.flatten([deleteAssertionSet, addAssertionSet])
        let flattenedAssertion = flattenedAssertionSet[addAssertion]
        
        XCTAssertEqual(flattenedAssertionSet.count, 1)
        XCTAssertEqual(flattenedAssertion?.model, .song)
        XCTAssertEqual(flattenedAssertion?.operation, .add)
        
        guard let addSong = flattenedAssertion?.data as? Song else { XCTFail("Error: Failed to extract assertion."); return }

        XCTAssertEqual(addSong.title, "a caged persona")
    }
    
    func test_setMerge() {
        let (songs, albums, artists) = Mocks.sampleModels()
        
        let assertionSet1 = KeySet<Assertion>()
            .inserting([
                Assertion(songs[0])
                , Assertion(songs[1])
                , Assertion(songs[2])
                , Assertion(albums[0])
                , Assertion(artists[0])
            ])
        
        let assertionSet2 = KeySet<Assertion>()
            .inserting([
                /* merge with first 5 */
                Assertion(SongUpdate(song: songs[0], title: "an uncaged persona"))
                , Assertion(DeleteAssertion(songs[1]))
                , Assertion(AlbumUpdate(album: albums[0], artistName: "Reimu"))
                /* new */
                , Assertion(SongUpdate(song: songs[19], title: "para la princesa temprano"))
                , Assertion(SongUpdate(song: songs[20], title: "this will be deleted"))
            ])
        
        let assertionSet3 = KeySet<Assertion>()
            .inserting([
                /* merge with new 3 */
                Assertion(DeleteAssertion(songs[20]))
                , Assertion(SongUpdate(song:  songs[19], title: "para la princesa azusa"))
            ])
        
        let sut = Assertion.flatten([assertionSet1, assertionSet2, assertionSet3])
        
        XCTAssertEqual(sut.count, 7)
        XCTAssertEqual(sut.filter{ $0.operation == .add }.count, 4)
        XCTAssertEqual(sut.filter{ $0.operation == .update }.count, 1)
        XCTAssertEqual(sut.filter{ $0.operation == .delete }.count, 2)
        
        guard let song0 = sut[songs[0].id]?.data as? Song else { XCTFail("Error: Failed to extract assertion."); return }
        guard let songUpdate19 = sut[songs[19].id]?.data as? SongUpdate else { XCTFail("Error: Failed to extract assertion."); return }
        guard let songDelete = sut[songs[1].id]?.data as? DeleteAssertion else { XCTFail("Error: Failed to extract assertion."); return }
        guard let album0 = sut[albums[0].id]?.data as? Album else { XCTFail("Error: Failed to extract assertion."); return }
        
        XCTAssertEqual(song0.title, "an uncaged persona")
        XCTAssertEqual(songUpdate19.title, "para la princesa azusa")
        XCTAssertEqual(songDelete.id, songs[1].id)
        XCTAssertEqual(album0.artistName, "Reimu")
    }
}
