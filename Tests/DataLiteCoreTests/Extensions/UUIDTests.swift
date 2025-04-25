import XCTest
import DataLiteCore

class UUIDTests: XCTestCase {
    func testUUIDToSQLiteRawValue() {
        let uuid = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
        XCTAssertEqual(uuid.sqliteRawValue, .text("123E4567-E89B-12D3-A456-426614174000"))
    }
    
    func testSQLiteRawValueToUUID() {
        let rawValue = SQLiteRawValue.text("123e4567-e89b-12d3-a456-426614174000")
        XCTAssertEqual(UUID(rawValue), UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000"))
        
        let invalidRawValue = SQLiteRawValue.text("invalid-uuid-string")
        XCTAssertNil(UUID(invalidRawValue)) // Should be nil for invalid UUID strings
        
        XCTAssertNil(UUID(SQLiteRawValue.int(42))) // Should be nil for non-text values
        XCTAssertNil(UUID(SQLiteRawValue.blob(Data([0x01, 0x02])))) // Should be nil for blob values
        XCTAssertNil(UUID(SQLiteRawValue.null)) // Should be nil for null values
    }
}
