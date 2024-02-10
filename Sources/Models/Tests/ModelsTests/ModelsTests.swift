import XCTest
@testable import Models

final class ModelsTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    func test_decodeJSON_parsesKeyInformation() {
        
        guard let jsonData = Song.aCagedPersonaJSON.data(using: .utf8),
              let song = try? decoder.decode([Song].self, from: jsonData).first else {
            XCTFail("Failed to decode test data")
            return
        }
        
        XCTAssertEqual(song.id, UUID(uuidString: "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d"))
    }
}
