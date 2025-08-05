import Testing
import DataLiteC
import DataLiteCore

struct SQLiteRawTypeTests {
    @Test func testInitializationFromRawValue() {
        #expect(SQLiteRawType(rawValue: SQLITE_INTEGER) == .int)
        #expect(SQLiteRawType(rawValue: SQLITE_FLOAT) == .real)
        #expect(SQLiteRawType(rawValue: SQLITE_TEXT) == .text)
        #expect(SQLiteRawType(rawValue: SQLITE_BLOB) == .blob)
        #expect(SQLiteRawType(rawValue: SQLITE_NULL) == .null)
        #expect(SQLiteRawType(rawValue: -1) == nil)
    }
    
    @Test func testRawValue() {
        #expect(SQLiteRawType.int.rawValue == SQLITE_INTEGER)
        #expect(SQLiteRawType.real.rawValue == SQLITE_FLOAT)
        #expect(SQLiteRawType.text.rawValue == SQLITE_TEXT)
        #expect(SQLiteRawType.blob.rawValue == SQLITE_BLOB)
        #expect(SQLiteRawType.null.rawValue == SQLITE_NULL)
    }
    
    @Test func testInvalidRawValue() {
        let invalidRawValue: Int32 = 9999
        #expect(SQLiteRawType(rawValue: invalidRawValue) == nil)
    }
}
