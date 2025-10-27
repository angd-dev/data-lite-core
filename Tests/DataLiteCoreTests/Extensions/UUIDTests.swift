import Testing
import Foundation
import DataLiteCore

struct UUIDTests {
    @Test func uuidToSQLiteValue() {
        let uuid = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
        #expect(uuid.sqliteValue == .text("123E4567-E89B-12D3-A456-426614174000"))
    }
    
    @Test func uuidFromSQLiteValue() {
        let raw = SQLiteValue.text("123e4567-e89b-12d3-a456-426614174000")
        #expect(UUID(raw) == UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000"))
        
        #expect(UUID(SQLiteValue.int(42)) == nil)
        #expect(UUID(SQLiteValue.real(42)) == nil)
        #expect(UUID(SQLiteValue.text("42")) == nil)
        #expect(UUID(SQLiteValue.blob(Data([0x42]))) == nil)
        #expect(UUID(SQLiteValue.null) == nil)
    }
}
