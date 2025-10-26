import Foundation
import Testing
import DataLiteCore

struct BinaryFloatingPointTests {
    @Test func floatingPointToSQLiteValue() {
        #expect(Float(3.14).sqliteValue == .real(Double(Float(3.14))))
        #expect(Double(3.14).sqliteValue == .real(3.14))
    }
    
    @Test func floatingPointFromSQLiteValue() {
        #expect(Float(SQLiteValue.real(3.14)) == 3.14)
        #expect(Float(SQLiteValue.int(42)) == 42)
        
        #expect(Double(SQLiteValue.real(3.14)) == 3.14)
        #expect(Double(SQLiteValue.int(42)) == 42)
        
        #expect(Float(SQLiteValue.text("42")) == nil)
        #expect(Float(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(Float(SQLiteValue.null) == nil)
        
        #expect(Double(SQLiteValue.text("42")) == nil)
        #expect(Double(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(Double(SQLiteValue.null) == nil)
    }
}
