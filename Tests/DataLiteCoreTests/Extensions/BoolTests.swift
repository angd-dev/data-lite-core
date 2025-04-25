import XCTest
import DataLiteCore

class BoolTests: XCTestCase {
    func testBoolToSQLiteRawValue() {
        XCTAssertEqual(true.sqliteRawValue, .int(1))
        XCTAssertEqual(false.sqliteRawValue, .int(0))
    }
    
    func testSQLiteRawValueToBool() {
        // Test conversion from SQLiteRawValue to Bool
        XCTAssertEqual(Bool(.int(1)), true)
        XCTAssertEqual(Bool(.int(0)), false)
        
        // Test invalid cases
        XCTAssertNil(Bool(.int(-1)))
        XCTAssertNil(Bool(.int(2)))
        XCTAssertNil(Bool(.real(1.0))) // Should be nil for non-integer values
        XCTAssertNil(Bool(.text("true"))) // Should be nil for non-integer values
        XCTAssertNil(Bool(.blob(Data()))) // Should be nil for non-integer values
        XCTAssertNil(Bool(.null)) // Should be nil for null values
    }
}
