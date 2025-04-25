import XCTest
import DataLiteCore

class StringTests: XCTestCase {
    func testStringToSQLiteRawValue() {
        let stringValue: String = "Hello, SQLite!"
        XCTAssertEqual(stringValue.sqliteRawValue, .text("Hello, SQLite!"))
    }
    
    func testSQLiteRawValueToString() {
        let rawValue = SQLiteRawValue.text("Hello, SQLite!")
        XCTAssertEqual(String(rawValue), "Hello, SQLite!")
        
        let invalidRawValue = SQLiteRawValue.int(42)
        XCTAssertNil(String(invalidRawValue)) // Should be nil for non-text values
        
        XCTAssertNil(String(SQLiteRawValue.blob(Data([0x01, 0x02])))) // Should be nil for blob values
        XCTAssertNil(String(SQLiteRawValue.null)) // Should be nil for null values
    }
}
