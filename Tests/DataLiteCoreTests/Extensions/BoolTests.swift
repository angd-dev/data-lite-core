import Testing
import Foundation
import DataLiteCore

struct BoolTests {
    @Test func boolToSQLiteValue() {
        #expect(true.sqliteValue == .int(1))
        #expect(false.sqliteValue == .int(0))
    }
    
    @Test func boolFromSQLiteValue() {
        #expect(Bool(SQLiteValue.int(1)) == true)
        #expect(Bool(SQLiteValue.int(0)) == false)
        
        #expect(Bool(SQLiteValue.int(-1)) == nil)
        #expect(Bool(SQLiteValue.int(2)) == nil)
        #expect(Bool(SQLiteValue.real(1.0)) == nil)
        #expect(Bool(SQLiteValue.text("true")) == nil)
        #expect(Bool(SQLiteValue.blob(Data())) == nil)
        #expect(Bool(SQLiteValue.null) == nil)
    }
}
