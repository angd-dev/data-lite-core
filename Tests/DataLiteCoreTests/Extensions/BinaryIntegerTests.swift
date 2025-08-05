import Testing
import Foundation
import DataLiteCore

struct BinaryIntegerTests {
    @Test func testIntegerToSQLiteRawValue() {
        #expect(Int(42).sqliteRawValue == .int(42))
        #expect(Int8(42).sqliteRawValue == .int(42))
        #expect(Int16(42).sqliteRawValue == .int(42))
        #expect(Int32(42).sqliteRawValue == .int(42))
        #expect(Int64(42).sqliteRawValue == .int(42))
        
        #expect(UInt(42).sqliteRawValue == .int(42))
        #expect(UInt8(42).sqliteRawValue == .int(42))
        #expect(UInt16(42).sqliteRawValue == .int(42))
        #expect(UInt32(42).sqliteRawValue == .int(42))
        #expect(UInt64(42).sqliteRawValue == .int(42))
    }
    
    @Test func testIntegerInitializationFromSQLiteRawValue() {
        #expect(Int(SQLiteRawValue.int(42)) == 42)
        #expect(Int8(SQLiteRawValue.int(42)) == 42)
        #expect(Int16(SQLiteRawValue.int(42)) == 42)
        #expect(Int32(SQLiteRawValue.int(42)) == 42)
        #expect(Int64(SQLiteRawValue.int(42)) == 42)
        
        #expect(UInt(SQLiteRawValue.int(42)) == 42)
        #expect(UInt8(SQLiteRawValue.int(42)) == 42)
        #expect(UInt16(SQLiteRawValue.int(42)) == 42)
        #expect(UInt32(SQLiteRawValue.int(42)) == 42)
        #expect(UInt64(SQLiteRawValue.int(42)) == 42)
    }
    
    @Test func testInvalidIntegerInitialization() {
        #expect(Int(SQLiteRawValue.real(3.14)) == nil)
        #expect(Int8(SQLiteRawValue.text("test")) == nil)
        #expect(UInt32(SQLiteRawValue.blob(Data([0x01, 0x02]))) == nil)
        
        // Out-of-range conversion
        let largeValue = Int64.max
        #expect(Int8(exactly: largeValue) == nil)
    }
}
