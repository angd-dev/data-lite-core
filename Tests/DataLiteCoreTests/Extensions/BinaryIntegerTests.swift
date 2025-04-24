import XCTest
import DataLiteCore

class BinaryIntegerTests: XCTestCase {
    func testIntegerToSQLiteRawValue() {
        XCTAssertEqual(Int(42).sqliteRawValue, .int(42))
        XCTAssertEqual(Int8(42).sqliteRawValue, .int(42))
        XCTAssertEqual(Int16(42).sqliteRawValue, .int(42))
        XCTAssertEqual(Int32(42).sqliteRawValue, .int(42))
        XCTAssertEqual(Int64(42).sqliteRawValue, .int(42))
        
        XCTAssertEqual(UInt(42).sqliteRawValue, .int(42))
        XCTAssertEqual(UInt8(42).sqliteRawValue, .int(42))
        XCTAssertEqual(UInt16(42).sqliteRawValue, .int(42))
        XCTAssertEqual(UInt32(42).sqliteRawValue, .int(42))
        XCTAssertEqual(UInt64(42).sqliteRawValue, .int(42))
    }
    
    func testIntegerInitializationFromSQLiteRawValue() {
        XCTAssertEqual(Int(SQLiteRawValue.int(42)), 42)
        XCTAssertEqual(Int8(SQLiteRawValue.int(42)), 42)
        XCTAssertEqual(Int16(SQLiteRawValue.int(42)), 42)
        XCTAssertEqual(Int32(SQLiteRawValue.int(42)), 42)
        XCTAssertEqual(Int64(SQLiteRawValue.int(42)), 42)
        
        XCTAssertEqual(UInt(SQLiteRawValue.int(42)), 42)
        XCTAssertEqual(UInt8(SQLiteRawValue.int(42)), 42)
        XCTAssertEqual(UInt16(SQLiteRawValue.int(42)), 42)
        XCTAssertEqual(UInt32(SQLiteRawValue.int(42)), 42)
        XCTAssertEqual(UInt64(SQLiteRawValue.int(42)), 42)
    }
    
    func testInvalidIntegerInitialization() {
        // Case when initializing with a non-integer SQLiteRawValue
        XCTAssertNil(Int(SQLiteRawValue.real(3.14)))
        XCTAssertNil(Int8(SQLiteRawValue.text("test")))
        XCTAssertNil(UInt32(SQLiteRawValue.blob(Data([0x01, 0x02]))))
        
        // Test with out-of-range values
        let largeValue = Int64.max
        XCTAssertNil(Int8(exactly: largeValue))
    }
}
