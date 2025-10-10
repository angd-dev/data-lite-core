import Testing
import Foundation
import DataLiteCore

struct BinaryIntegerTests {
    @Test func testIntegerToSQLiteValue() {
        #expect(Int(42).sqliteValue == .int(42))
        #expect(Int8(42).sqliteValue == .int(42))
        #expect(Int16(42).sqliteValue == .int(42))
        #expect(Int32(42).sqliteValue == .int(42))
        #expect(Int64(42).sqliteValue == .int(42))
        
        #expect(UInt(42).sqliteValue == .int(42))
        #expect(UInt8(42).sqliteValue == .int(42))
        #expect(UInt16(42).sqliteValue == .int(42))
        #expect(UInt32(42).sqliteValue == .int(42))
        #expect(UInt64(42).sqliteValue == .int(42))
    }
    
    @Test func testIntegerInitializationFromSQLiteValue() {
        #expect(Int(SQLiteValue.int(42)) == 42)
        #expect(Int8(SQLiteValue.int(42)) == 42)
        #expect(Int16(SQLiteValue.int(42)) == 42)
        #expect(Int32(SQLiteValue.int(42)) == 42)
        #expect(Int64(SQLiteValue.int(42)) == 42)
        
        #expect(UInt(SQLiteValue.int(42)) == 42)
        #expect(UInt8(SQLiteValue.int(42)) == 42)
        #expect(UInt16(SQLiteValue.int(42)) == 42)
        #expect(UInt32(SQLiteValue.int(42)) == 42)
        #expect(UInt64(SQLiteValue.int(42)) == 42)
    }
    
    @Test func testInvalidIntegerInitialization() {
        #expect(Int(SQLiteValue.real(3.14)) == nil)
        #expect(Int8(SQLiteValue.text("test")) == nil)
        #expect(UInt32(SQLiteValue.blob(Data([0x01, 0x02]))) == nil)
        
        // Out-of-range conversion
        let largeValue = Int64.max
        #expect(Int8(exactly: largeValue) == nil)
    }
}
