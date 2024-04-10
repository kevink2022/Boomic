import XCTest
@testable import MediaPlayerKit
import Models
import ModelsMocks

final class AMQueueTests: XCTestCase {
    
    private func printQueue(_ amQueue: AMQueue) {
        print(amQueue.currentSong.label)
        print(amQueue.queue.map({ $0.label }))
    }
    
    private let (songs, _, _) = ModelsMocks.sampleModels()
    
    func testInit_inOrder() throws {
        let song = songs[10]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
               
        XCTAssert(sut.queue.firstIndex(of: sut.currentSong) == 10)
    }
    
    func testInit_shuffle() throws {
        let song = songs[10]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .shuffle)
        
        XCTAssert(sut.queue.firstIndex(of: sut.currentSong) == 0)
    }
    
    func test_shuffle() throws {
        let song = songs[10]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        let sut2 = sut1.toggleShuffled()
        
        XCTAssert(sut2.queue.firstIndex(of: sut2.currentSong) == 0)
    }
    
    func test_reorder() throws {
        let song = songs[10]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        let sut2 = sut1.toggleShuffled()
        let sut3 = sut2.toggleShuffled()
        
        XCTAssert(sut3.queue.firstIndex(of: sut3.currentSong) == 10)
    }
    
    func test_next() throws {
        let song = songs[10]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        let sut2 = sut1.next()
        
        XCTAssert(sut2.queue.firstIndex(of: sut2.currentSong) == 11)
    }
    
    func test_nextLoops() throws {
        let song = songs[songs.endIndex - 1]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        let sut2 = sut1.next()
        
        XCTAssert(sut1.forwardRolloverWillOccur == true)
        XCTAssert(sut2.queue.firstIndex(of: sut2.currentSong) == 0)
        XCTAssert(sut2.forwardRolloverWillOccur == false)
    }
    
    func test_shuffleNextUnshuffle() throws {
        let song = songs[10]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        let sut2 = sut1.toggleShuffled()
        let sut3 = sut2.next()
        let sut4 = sut3.toggleShuffled()
        
        XCTAssert(sut4.queue.firstIndex(of: sut4.currentSong) == songs.firstIndex(of: sut4.currentSong))
    }
    
    func test_previous() throws {
        let song = songs[10]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        let sut2 = sut1.previous()
        
        XCTAssert(sut2.queue.firstIndex(of: sut2.currentSong) == 9)
    }
    
    func test_previousLoops() throws {
        let song = songs[0]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        let sut2 = sut1.previous()
        
        XCTAssert(sut1.backwardRolloverWillOccur == true)
        XCTAssert(sut2.queue.firstIndex(of: sut2.currentSong) == songs.endIndex - 1)
        XCTAssert(sut2.backwardRolloverWillOccur == false)

    }
    
    func test_shufflePreviousUnshuffle() throws {
        let song = songs[10]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        let sut2 = sut1.toggleShuffled()
        let sut3 = sut2.previous()
        let sut4 = sut3.toggleShuffled()
        
        XCTAssert(sut4.queue.firstIndex(of: sut4.currentSong) == songs.firstIndex(of: sut4.currentSong))
    }
    
    func test_addNext_inOrder() throws {
        let song = songs[10]
        let nextSong = songs[songs.endIndex - 1]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        let sut2 = sut1.addNext(nextSong)
        let sut3 = sut2.next()
        
        XCTAssert(sut3.currentSong == nextSong)
    }
    
    func test_addNext_shuffle() throws {
        let song = songs[10]
        let nextSong = songs[songs.endIndex - 1]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .shuffle)
        let sut2 = sut1.addNext(nextSong)
        let sut3 = sut2.next()
        
        XCTAssert(sut3.currentSong == nextSong)
        
        let sut4 = sut3.previous()
        let sut5 = sut4.toggleShuffled()
                
        XCTAssert(sut5.queue.firstIndex(of: nextSong) == 11)
    }
    
    func test_addToEnd_inOrder() throws {
        let song = songs[10]
        let nextSong = songs[songs.endIndex - 1]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        let sut2 = sut1.addToEnd(nextSong)
        
        XCTAssert(sut2.queue[sut2.queue.endIndex - 1] == nextSong)
    }
    
    func test_addToEnd_shuffle() throws {
        let song = songs[10]
        let nextSong = songs[0]
        
        let sut1 = AMQueue(song: song, context: songs, queueOrder: .shuffle)
        let sut2 = sut1.addToEnd(nextSong)

        XCTAssert(sut2.queue[sut2.queue.endIndex - 1] == nextSong)
        
        let sut3 = sut2.toggleShuffled()
              
        XCTAssert(sut3.queue[sut3.queue.endIndex - 1] != nextSong)
    }
}
