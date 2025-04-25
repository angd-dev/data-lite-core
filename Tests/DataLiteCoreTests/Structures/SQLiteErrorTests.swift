import XCTest
import DataLiteC
@testable import DataLiteCore

class SQLiteErrorTests: XCTestCase {
    func testInitWithConnection() {
        var db: OpaquePointer? = nil
        sqlite3_open(":memory:", &db)
        sqlite3_exec(db, "INVALID SQL", nil, nil, nil)
        let error = SQLiteError(db!)
        
        XCTAssertEqual(error.code, SQLITE_ERROR)
        XCTAssertEqual(error.mesg, "near \"INVALID\": syntax error")
        
        sqlite3_close(db)
    }
    
    func testInitWithCodeAndMessage() {
        let error = SQLiteError(code: 1, mesg: "Test Error Message")
        XCTAssertEqual(error.code, 1)
        XCTAssertEqual(error.mesg, "Test Error Message")
    }
    
    func testDescription() {
        let error = SQLiteError(code: 1, mesg: "Test Error Message")
        XCTAssertEqual(error.description, "SQLiteError code: 1 message: Test Error Message")
    }
}
