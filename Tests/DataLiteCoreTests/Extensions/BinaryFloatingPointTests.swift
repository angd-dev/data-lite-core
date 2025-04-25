import XCTest
import DataLiteCore

class BinaryFloatingPointTests: XCTestCase {
    func testFloatToSQLiteRawValue() {
        let floatValue: Float = 3.14
        let rawValue = floatValue.sqliteRawValue
        XCTAssertEqual(rawValue, .real(Double(floatValue)), "Float should be converted to SQLiteRawValue.real")
    }
    
    func testDoubleToSQLiteRawValue() {
        let doubleValue: Double = 3.14
        let rawValue = doubleValue.sqliteRawValue
        XCTAssertEqual(rawValue, .real(doubleValue), "Double should be converted to SQLiteRawValue.real")
    }
    
    func testFloatInitializationFromSQLiteRawValue() {
        let realValue: SQLiteRawValue = .real(3.14)
        let floatValue = Float(realValue)
        XCTAssertNotNil(floatValue, "Float should be initialized from SQLiteRawValue.real")
        XCTAssertEqual(floatValue, 3.14, "Float value should match the real value")
        
        let intValue: SQLiteRawValue = .int(42)
        let floatFromInt = Float(intValue)
        XCTAssertNotNil(floatFromInt, "Float should be initialized from SQLiteRawValue.int")
        XCTAssertEqual(floatFromInt, 42.0, "Float value should match the integer value converted to float")
    }
    
    func testDoubleInitializationFromSQLiteRawValue() {
        let realValue: SQLiteRawValue = .real(3.14)
        let doubleValue = Double(realValue)
        XCTAssertNotNil(doubleValue, "Double should be initialized from SQLiteRawValue.real")
        XCTAssertEqual(doubleValue, 3.14, "Double value should match the real value")
        
        let intValue: SQLiteRawValue = .int(42)
        let doubleFromInt = Double(intValue)
        XCTAssertNotNil(doubleFromInt, "Double should be initialized from SQLiteRawValue.int")
        XCTAssertEqual(doubleFromInt, 42.0, "Double value should match the integer value converted to double")
    }
    
    func testInitializationFailureFromInvalidSQLiteRawValue() {
        let nullValue: SQLiteRawValue = .null
        XCTAssertNil(Float(nullValue), "Float should not be initialized from SQLiteRawValue.null")
        XCTAssertNil(Double(nullValue), "Double should not be initialized from SQLiteRawValue.null")
        
        let textValue: SQLiteRawValue = .text("Invalid")
        XCTAssertNil(Float(textValue), "Float should not be initialized from SQLiteRawValue.text")
        XCTAssertNil(Double(textValue), "Double should not be initialized from SQLiteRawValue.text")
    }
}
