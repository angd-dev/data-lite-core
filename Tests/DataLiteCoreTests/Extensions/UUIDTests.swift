import Testing
import Foundation
import DataLiteCore

struct UUIDTests {
    @Test func testUUIDToSQLiteRawValue() {
        let uuid = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
        #expect(uuid.sqliteValue == .text("123E4567-E89B-12D3-A456-426614174000"))
    }
    
    @Test func testSQLiteRawValueToUUID() {
        let raw = SQLiteValue.text("123e4567-e89b-12d3-a456-426614174000")
        #expect(UUID(raw) == UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000"))
        
        #expect(UUID(.text("invalid-uuid-string")) == nil)
        #expect(UUID(.int(42)) == nil)
        #expect(UUID(.blob(Data([0x01, 0x02]))) == nil)
        #expect(UUID(.null) == nil)
    }
}
