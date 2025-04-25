import XCTest
@testable import DataLiteCore

class ConnectionLocationTests: XCTestCase {
    func testFileLocationPath() {
        let filePath = "/path/to/database.db"
        let location = Connection.Location.file(path: filePath)
        XCTAssertEqual(location.path, filePath, "The path for file location should match the provided file path.")
    }
    
    func testInMemoryLocationPath() {
        let inMemoryLocation = Connection.Location.inMemory
        XCTAssertEqual(inMemoryLocation.path, ":memory:", "The path for in-memory location should be ':memory:'.")
    }
    
    func testTemporaryLocationPath() {
        let temporaryLocation = Connection.Location.temporary
        XCTAssertEqual(temporaryLocation.path, "", "The path for temporary location should be an empty string.")
    }
    
    func testFileLocationInitialization() {
        let filePath = "/path/to/database.db"
        let location = Connection.Location.file(path: filePath)
        switch location {
        case .file(let path):
            XCTAssertEqual(path, filePath, "File location should initialize with the correct path.")
        default:
            XCTFail("Expected file location case.")
        }
    }
}
