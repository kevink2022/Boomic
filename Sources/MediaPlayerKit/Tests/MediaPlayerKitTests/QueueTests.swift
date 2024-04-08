import XCTest
@testable import MediaPlayerKit
import Models
import ModelsMocks

final class QueueTests: XCTestCase {
    
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
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        sut.toggleShuffle()
        
        XCTAssert(sut.queue.firstIndex(of: sut.currentSong) == 0)
    }
    
    func test_reorder() throws {
        let song = songs[10]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        sut.toggleShuffle()
        sut.toggleShuffle()
        
        XCTAssert(sut.queue.firstIndex(of: sut.currentSong) == 10)
    }
    
    func test_next() throws {
        let song = songs[10]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        sut.next()
        
        XCTAssert(sut.queue.firstIndex(of: sut.currentSong) == 11)
    }
    
    func test_nextLoops() throws {
        let song = songs[songs.endIndex - 1]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        sut.next()
        
        XCTAssert(sut.queue.firstIndex(of: sut.currentSong) == 0)
    }
    
    func test_shuffleNextUnshuffle() throws {
        let song = songs[10]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        sut.toggleShuffle()
        sut.next()
        sut.toggleShuffle()
        
        XCTAssert(sut.queue.firstIndex(of: sut.currentSong) == songs.firstIndex(of: sut.currentSong))
    }
    
    func test_previous() throws {
        let song = songs[10]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        sut.previous()
        
        XCTAssert(sut.queue.firstIndex(of: sut.currentSong) == 9)
    }
    
    func test_previousLoops() throws {
        let song = songs[0]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        sut.previous()
        
        XCTAssert(sut.queue.firstIndex(of: sut.currentSong) == songs.endIndex - 1)
    }
    
    func test_shufflePreviousUnshuffle() throws {
        let song = songs[10]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        sut.toggleShuffle()
        sut.previous()
        sut.toggleShuffle()
        
        XCTAssert(sut.queue.firstIndex(of: sut.currentSong) == songs.firstIndex(of: sut.currentSong))
    }
    
    func test_addNext_inOrder() throws {
        let song = songs[10]
        let nextSong = songs[songs.endIndex - 1]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        sut.addNext(nextSong)
        sut.next()
        
        XCTAssert(sut.currentSong == nextSong)
    }
    
    func test_addNext_shuffle() throws {
        let song = songs[10]
        let nextSong = songs[songs.endIndex - 1]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .shuffle)
        sut.addNext(nextSong)
        sut.next()
        
        XCTAssert(sut.currentSong == nextSong)
        
        sut.previous()
        sut.toggleShuffle()
                
        XCTAssert(sut.queue.firstIndex(of: nextSong) == 11)
    }
    
    func test_addToEnd_inOrder() throws {
        let song = songs[10]
        let nextSong = songs[songs.endIndex - 1]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .inOrder)
        sut.addToEnd(nextSong)
        
        XCTAssert(sut.queue[sut.queue.endIndex - 1] == nextSong)
    }
    
    func test_addToEnd_shuffle() throws {
        let song = songs[10]
        let nextSong = songs[0]
        
        let sut = AMQueue(song: song, context: songs, queueOrder: .shuffle)
        sut.addToEnd(nextSong)

        XCTAssert(sut.queue[sut.queue.endIndex - 1] == nextSong)
        
        sut.toggleShuffle()
              
        XCTAssert(sut.queue[sut.queue.endIndex - 1] != nextSong)
    }
}
