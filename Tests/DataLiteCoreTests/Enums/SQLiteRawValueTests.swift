import XCTest
import DataLiteCore

class SQLiteRawValueTests: XCTestCase {
    func testIntValue() {
        let value = SQLiteRawValue.int(42)
        XCTAssertEqual(value.description, "42")
    }
    
    func testRealValue() {
        let value = SQLiteRawValue.real(3.14)
        XCTAssertEqual(value.description, "3.14")
    }
    
    func testTextValue() {
        let value = SQLiteRawValue.text("Hello, World!")
        XCTAssertEqual(value.description, "'Hello, World!'")
    }
    
    func testTextValueWithSingleQuote() {
        let value = SQLiteRawValue.text("O'Reilly")
        XCTAssertEqual(value.description, "'O''Reilly'") // Escaped single quote
    }
    
    func testBlobValue() {
        let data = Data([0xDE, 0xAD, 0xBE, 0xEF])
        let value = SQLiteRawValue.blob(data)
        XCTAssertEqual(value.description, "X'DEADBEEF'")
    }
    
    func testNullValue() {
        let value = SQLiteRawValue.null
        XCTAssertEqual(value.description, "NULL")
    }
}
