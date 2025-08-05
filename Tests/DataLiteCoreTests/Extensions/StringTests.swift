import Testing
import Foundation
import DataLiteCore

struct StringTests {
    @Test func testStringToSQLiteRawValue() {
        #expect("Hello, SQLite!".sqliteRawValue == .text("Hello, SQLite!"))
    }
    
    @Test func testSQLiteRawValueToString() {
        #expect(String(SQLiteRawValue.text("Hello, SQLite!")) == "Hello, SQLite!")
        
        #expect(String(SQLiteRawValue.int(42)) == nil)
        #expect(String(SQLiteRawValue.blob(Data([0x01, 0x02]))) == nil)
        #expect(String(SQLiteRawValue.null) == nil)
    }
}
