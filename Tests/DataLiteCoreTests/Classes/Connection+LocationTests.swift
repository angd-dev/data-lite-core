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
}
