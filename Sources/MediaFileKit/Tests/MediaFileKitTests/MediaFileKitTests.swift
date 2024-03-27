import XCTest
@testable import MediaFileKit

final class MediaFileKitTests: XCTestCase {
    func testExample() async throws {
        let sut = LocalMediaFileInterface(libraryDirectory: URL(string: "")!)
        
        do {
            let _ = try await sut.newSongs(existing: [])
        } catch {
            print(error.localizedDescription)
            //XCTFail("Error")
        }
    }
}
