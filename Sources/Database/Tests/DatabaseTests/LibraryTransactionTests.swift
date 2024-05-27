import XCTest
import Models
import ModelsMocks
@testable import Database

private typealias Mocks = ModelsMocks

private enum TestError: LocalizedError {
    case extractionFail
    
    var localizedDescription: String {
        switch self {
        case .extractionFail: "Could not extract transaction data"
        }
        
    }
}

final class LibraryTransactionTests: XCTestCase {
    
    func test_addApplyUpdate() {
        let song = Song.aCagedPersona
        let addTransaction = LibraryTransaction.addSong(song)
        let addTransactionSet = KeySet<LibraryTransaction>().inserting(addTransaction)
        
        let update = SongUpdate(song: song, title: "an uncaged persona")
        let updateTransaction = LibraryTransaction.updateSong(update)
        let updateTransactionSet = KeySet<LibraryTransaction>().inserting(updateTransaction)
        
        do {
            let flattenedTransactionSet = try LibraryTransaction.flatten([addTransactionSet, updateTransactionSet])
            let flattenedTransaction = flattenedTransactionSet[addTransaction]
            
            XCTAssertEqual(flattenedTransactionSet.count, 1)
            XCTAssertEqual(flattenedTransaction?.model, .song)
            XCTAssertEqual(flattenedTransaction?.operation, .add)
            
            guard case let .addSong(addSong) = flattenedTransaction else { throw TestError.extractionFail }
            
            XCTAssertEqual(addSong.title, "an uncaged persona")
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_addApplyDelete() {
        let song = Song.aCagedPersona
        let addTransaction = LibraryTransaction.addSong(song)
        let addTransactionSet = KeySet<LibraryTransaction>().inserting(addTransaction)
        
        let delete = Song.aCagedPersona.id
        let deleteTransaction = LibraryTransaction.deleteSong(delete)
        let deleteTransactionSet = KeySet<LibraryTransaction>().inserting(deleteTransaction)
        
        do {
            let flattenedTransactionSet = try LibraryTransaction.flatten([addTransactionSet, deleteTransactionSet])
            let flattenedTransaction = flattenedTransactionSet[addTransaction]
            
            XCTAssertEqual(flattenedTransactionSet.count, 1)
            XCTAssertEqual(flattenedTransaction?.model, .song)
            XCTAssertEqual(flattenedTransaction?.operation, .delete)
            
            guard case let .deleteSong(deleteSong) = flattenedTransaction else { throw TestError.extractionFail }
            
            XCTAssertEqual(deleteSong, delete)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_updateApplyUpdate() {
        let update = SongUpdate(song: Song.aCagedPersona, title: "an uncaged persona")
        let updateTransaction = LibraryTransaction.updateSong(update)
        let updateTransactionSet = KeySet<LibraryTransaction>().inserting(updateTransaction)
        
        let update2 = SongUpdate(song: Song.aCagedPersona, title: "a very uncaged persona")
        let update2Transaction = LibraryTransaction.updateSong(update2)
        let update2TransactionSet = KeySet<LibraryTransaction>().inserting(update2Transaction)
        
        do {
            let flattenedTransactionSet = try LibraryTransaction.flatten([updateTransactionSet, update2TransactionSet])
            let flattenedTransaction = flattenedTransactionSet[updateTransaction]
            
            XCTAssertEqual(flattenedTransactionSet.count, 1)
            XCTAssertEqual(flattenedTransaction?.model, .song)
            XCTAssertEqual(flattenedTransaction?.operation, .update)
            
            guard case let .updateSong(updateSong) = flattenedTransaction else { throw TestError.extractionFail }
            
            XCTAssertEqual(updateSong.title, "a very uncaged persona")
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_updateApplyDelete() {
        let update = SongUpdate(song: Song.aCagedPersona, title: "an uncaged persona")
        let updateTransaction = LibraryTransaction.updateSong(update)
        let updateTransactionSet = KeySet<LibraryTransaction>().inserting(updateTransaction)

        let delete = Song.aCagedPersona.id
        let deleteTransaction = LibraryTransaction.deleteSong(delete)
        let deleteTransactionSet = KeySet<LibraryTransaction>().inserting(deleteTransaction)
        
        do {
            let flattenedTransactionSet = try LibraryTransaction.flatten([updateTransactionSet, deleteTransactionSet])
            let flattenedTransaction = flattenedTransactionSet[updateTransaction]
            
            XCTAssertEqual(flattenedTransactionSet.count, 1)
            XCTAssertEqual(flattenedTransaction?.model, .song)
            XCTAssertEqual(flattenedTransaction?.operation, .delete)
            
            guard case let .deleteSong(deleteSong) = flattenedTransaction else { throw TestError.extractionFail }
            
            XCTAssertEqual(deleteSong, delete)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_deleteApplyAdd() {
        let song = Song.aCagedPersona
        let addTransaction = LibraryTransaction.addSong(song)
        let addTransactionSet = KeySet<LibraryTransaction>().inserting(addTransaction)
        
        let delete = Song.aCagedPersona.id
        let deleteTransaction = LibraryTransaction.deleteSong(delete)
        let deleteTransactionSet = KeySet<LibraryTransaction>().inserting(deleteTransaction)
        
        do {
            let flattenedTransactionSet = try LibraryTransaction.flatten([deleteTransactionSet, addTransactionSet])
            let flattenedTransaction = flattenedTransactionSet[addTransaction]
            
            XCTAssertEqual(flattenedTransactionSet.count, 1)
            XCTAssertEqual(flattenedTransaction?.model, .song)
            XCTAssertEqual(flattenedTransaction?.operation, .add)
            
            guard case let .addSong(addSong) = flattenedTransaction else { throw TestError.extractionFail }
            
            XCTAssertEqual(addSong.title, "a caged persona")
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_setMerge() {
        let (songs, albums, artists) = Mocks.sampleModels()
        
        let transaction1 = KeySet<LibraryTransaction>()
            .inserting([
                .addSong(songs[0])
                , .addSong(songs[1])
                , .addSong(songs[2])
                , .addAlbum(albums[0])
                , .addArtist(artists[0])
            ])
        
        let transaction2 = KeySet<LibraryTransaction>()
            .inserting([
                /* merge with first 5 */
                .updateSong(SongUpdate(song: songs[0], title: "an uncaged persona"))
                , .deleteSong(songs[1].id)
                , .updateAlbum(AlbumUpdate(album: albums[0], artistName: "Reimu"))
                /* new */
                , .updateSong(SongUpdate(song: songs[19], title: "para la princesa temprano"))
                , .updateSong(SongUpdate(song: songs[20], title: "this will be deleted"))
            ])
        
        let transaction3 = KeySet<LibraryTransaction>()
            .inserting([
                /* merge with new 3 */
                .deleteSong(songs[20].id)
                , .updateSong(SongUpdate(song:  songs[19], title: "para la princesa azusa"))
            ])
        
        do {
            let sut = try LibraryTransaction.flatten([transaction1, transaction2, transaction3])
            
            XCTAssertEqual(sut.count, 7)
            XCTAssertEqual(sut.filter{ $0.operation == .add }.count, 4)
            XCTAssertEqual(sut.filter{ $0.operation == .update }.count, 1)
            XCTAssertEqual(sut.filter{ $0.operation == .delete }.count, 2)
            
            guard case let .addSong(song0) = sut[songs[0].id] else { throw TestError.extractionFail }
            guard case let .updateSong(songUpdate19) = sut[songs[19].id] else { throw TestError.extractionFail }
            guard case let .deleteSong(songID1) = sut[songs[1].id] else { throw TestError.extractionFail }
            guard case let .addAlbum(album0) = sut[albums[0].id] else { throw TestError.extractionFail }
            
            XCTAssertEqual(song0.title, "an uncaged persona")
            XCTAssertEqual(songUpdate19.title, "para la princesa azusa")
            XCTAssertEqual(songID1, songs[1].id)
            XCTAssertEqual(album0.artistName, "Reimu")
            
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
}
