import Testing
import Foundation
import DataLiteCore

struct BinaryIntegerTests {
    @Test func integerToSQLiteValue() {
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
    
    @Test func integerFromSQLiteValue() {
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
        
        #expect(Int(SQLiteValue.real(42)) == nil)
        #expect(Int(SQLiteValue.text("42")) == nil)
        #expect(Int(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(Int(SQLiteValue.null) == nil)
        
        #expect(Int8(SQLiteValue.real(42)) == nil)
        #expect(Int8(SQLiteValue.text("42")) == nil)
        #expect(Int8(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(Int8(SQLiteValue.null) == nil)
        #expect(Int8(SQLiteValue.int(Int64.max)) == nil)
        
        #expect(Int16(SQLiteValue.real(42)) == nil)
        #expect(Int16(SQLiteValue.text("42")) == nil)
        #expect(Int16(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(Int16(SQLiteValue.null) == nil)
        #expect(Int16(SQLiteValue.int(Int64.max)) == nil)
        
        #expect(Int32(SQLiteValue.real(42)) == nil)
        #expect(Int32(SQLiteValue.text("42")) == nil)
        #expect(Int32(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(Int32(SQLiteValue.null) == nil)
        #expect(Int32(SQLiteValue.int(Int64.max)) == nil)
        
        #expect(Int64(SQLiteValue.real(42)) == nil)
        #expect(Int64(SQLiteValue.text("42")) == nil)
        #expect(Int64(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(Int64(SQLiteValue.null) == nil)
        
        #expect(UInt(SQLiteValue.real(42)) == nil)
        #expect(UInt(SQLiteValue.text("42")) == nil)
        #expect(UInt(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(UInt(SQLiteValue.null) == nil)
        
        #expect(UInt8(SQLiteValue.real(42)) == nil)
        #expect(UInt8(SQLiteValue.text("42")) == nil)
        #expect(UInt8(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(UInt8(SQLiteValue.null) == nil)
        #expect(UInt8(SQLiteValue.int(Int64.max)) == nil)
        
        #expect(UInt16(SQLiteValue.real(42)) == nil)
        #expect(UInt16(SQLiteValue.text("42")) == nil)
        #expect(UInt16(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(UInt16(SQLiteValue.null) == nil)
        #expect(UInt16(SQLiteValue.int(Int64.max)) == nil)
        
        #expect(UInt32(SQLiteValue.real(42)) == nil)
        #expect(UInt32(SQLiteValue.text("42")) == nil)
        #expect(UInt32(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(UInt32(SQLiteValue.null) == nil)
        #expect(UInt32(SQLiteValue.int(Int64.max)) == nil)
        
        #expect(UInt64(SQLiteValue.real(42)) == nil)
        #expect(UInt64(SQLiteValue.text("42")) == nil)
        #expect(UInt64(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(UInt64(SQLiteValue.null) == nil)
    }
}
