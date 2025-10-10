import Testing
import Foundation
import DataLiteCore

struct StringTests {
    @Test func testStringToSQLiteRawValue() {
        #expect("Hello, SQLite!".sqliteValue == .text("Hello, SQLite!"))
    }
    
    @Test func testSQLiteRawValueToString() {
        #expect(String(SQLiteValue.text("Hello, SQLite!")) == "Hello, SQLite!")
        
        #expect(String(SQLiteValue.int(42)) == nil)
        #expect(String(SQLiteValue.blob(Data([0x01, 0x02]))) == nil)
        #expect(String(SQLiteValue.null) == nil)
    }
}
