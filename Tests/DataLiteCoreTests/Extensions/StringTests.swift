import Testing
import Foundation
import DataLiteCore

struct StringTests {
    @Test func stringToSQLiteValue() {
        #expect("Hello, SQLite!".sqliteValue == .text("Hello, SQLite!"))
    }
    
    @Test func stringFromSQLiteValue() {
        #expect(String(SQLiteValue.text("Hello, SQLite!")) == "Hello, SQLite!")
        
        #expect(String(SQLiteValue.int(42)) == nil)
        #expect(String(SQLiteValue.real(42)) == nil)
        #expect(String(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(String(SQLiteValue.null) == nil)
    }
}
