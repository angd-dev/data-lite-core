import Testing
import Foundation
import DataLiteCore

struct SQLiteRawValueTests {
    @Test func testIntValue() {
        let value = SQLiteRawValue.int(42)
        #expect(value.description == "42")
    }
    
    @Test func testRealValue() {
        let value = SQLiteRawValue.real(3.14)
        #expect(value.description == "3.14")
    }
    
    @Test func testTextValue() {
        let value = SQLiteRawValue.text("Hello, World!")
        #expect(value.description == "'Hello, World!'")
    }
    
    @Test func testTextValueWithSingleQuote() {
        let value = SQLiteRawValue.text("O'Reilly")
        #expect(value.description == "'O''Reilly'") // Escaped single quote
    }
    
    @Test func testBlobValue() {
        let data = Data([0xDE, 0xAD, 0xBE, 0xEF])
        let value = SQLiteRawValue.blob(data)
        #expect(value.description == "X'DEADBEEF'")
    }
    
    @Test func testNullValue() {
        let value = SQLiteRawValue.null
        #expect(value.description == "NULL")
    }
}
