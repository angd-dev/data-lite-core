import Testing
import DataLiteC

@testable import DataLiteCore

struct SQLiteErrorTests {
    @Test func initWithConnection() {
        var connection: OpaquePointer!
        defer { sqlite3_close(connection) }
        sqlite3_open(":memory:", &connection)
        sqlite3_exec(connection, "INVALID SQL", nil, nil, nil)
        
        let error = SQLiteError(connection)
        #expect(error.code == SQLITE_ERROR)
        #expect(error.message == "near \"INVALID\": syntax error")
    }
    
    @Test func initWithCodeAndMessage() {
        let error = SQLiteError(code: 1, message: "Test Error Message")
        #expect(error.code == 1)
        #expect(error.message == "Test Error Message")
    }
    
    @Test func description() {
        let error = SQLiteError(code: 1, message: "Test Error Message")
        #expect(error.description == "SQLiteError(1): Test Error Message")
    }
    
    @Test func equality() {
        let lhs = SQLiteError(code: 1, message: "First")
        let rhs = SQLiteError(code: 1, message: "First")
        let different = SQLiteError(code: 2, message: "Second")
        #expect(lhs == rhs)
        #expect(lhs != different)
    }
}
