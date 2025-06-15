import Testing
@testable import DataLiteCore

struct ConnectionLocationTests {
    @Test func testFileLocationPath() {
        let filePath = "/path/to/database.db"
        let location = Connection.Location.file(path: filePath)
        #expect(location.path == filePath)
    }
    
    @Test func testInMemoryLocationPath() {
        let inMemoryLocation = Connection.Location.inMemory
        #expect(inMemoryLocation.path == ":memory:")
    }
    
    @Test func testTemporaryLocationPath() {
        let temporaryLocation = Connection.Location.temporary
        #expect(temporaryLocation.path == "")
    }
    
    @Test func testFileLocationInitialization() {
        let filePath = "/path/to/database.db"
        let location = Connection.Location.file(path: filePath)
        switch location {
        case .file(let path):
            #expect(path == filePath)
        default:
            Issue.record("Expected `.file` case but got \(location)")
        }
    }
}
