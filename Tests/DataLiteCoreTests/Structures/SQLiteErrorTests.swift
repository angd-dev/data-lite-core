import Foundation
import Testing
import DataLiteC
@testable import DataLiteCore

struct SQLiteErrorTests {
    @Test func testInitWithConnection() {
        var db: OpaquePointer? = nil
        defer { sqlite3_close(db) }
        sqlite3_open(":memory:", &db)
        sqlite3_exec(db, "INVALID SQL", nil, nil, nil)
        
        let error = SQLiteError(db!)
        #expect(error.code == SQLITE_ERROR)
        #expect(error.message == "near \"INVALID\": syntax error")
    }
    
    @Test func testInitWithCodeAndMessage() {
        let error = SQLiteError(code: 1, message: "Test Error Message")
        #expect(error.code == 1)
        #expect(error.message == "Test Error Message")
    }
    
    @Test func testDescription() {
        let error = SQLiteError(code: 1, message: "Test Error Message")
        #expect(error.description == "SQLiteError code: 1 message: Test Error Message")
    }
}
