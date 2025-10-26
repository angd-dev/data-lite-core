import Testing
@testable import DataLiteCore

struct ConnectionLocationTests {
    @Test func fileLocationPath() {
        let filePath = "/path/to/database.db"
        let location = Connection.Location.file(path: filePath)
        #expect(location.path == filePath)
    }
    
    @Test func inMemoryLocationPath() {
        let inMemoryLocation = Connection.Location.inMemory
        #expect(inMemoryLocation.path == ":memory:")
    }
    
    @Test func temporaryLocationPath() {
        let temporaryLocation = Connection.Location.temporary
        #expect(temporaryLocation.path == "")
    }
}
