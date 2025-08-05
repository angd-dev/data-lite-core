import Foundation
import Testing
import DataLiteC
@testable import DataLiteCore

struct ConnectionErrorTests {
    @Test func testInitWithConnection() {
        var db: OpaquePointer? = nil
        defer { sqlite3_close(db) }
        sqlite3_open(":memory:", &db)
        sqlite3_exec(db, "INVALID SQL", nil, nil, nil)
        
        let error = Connection.Error(db!)
        #expect(error.code == SQLITE_ERROR)
        #expect(error.message == "near \"INVALID\": syntax error")
    }
    
    @Test func testInitWithCodeAndMessage() {
        let error = Connection.Error(code: 1, message: "Test Error Message")
        #expect(error.code == 1)
        #expect(error.message == "Test Error Message")
    }
    
    @Test func testDescription() {
        let error = Connection.Error(code: 1, message: "Test Error Message")
        #expect(error.description == "Connection.Error code: 1 message: Test Error Message")
    }
}
