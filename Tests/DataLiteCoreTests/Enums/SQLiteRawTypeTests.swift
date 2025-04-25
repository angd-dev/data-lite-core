import XCTest
import DataLiteC
import DataLiteCore

class SQLiteRawTypeTests: XCTestCase {
    func testInitializationFromRawValue() {
        XCTAssertEqual(SQLiteRawType(rawValue: SQLITE_INTEGER), .int)
        XCTAssertEqual(SQLiteRawType(rawValue: SQLITE_FLOAT), .real)
        XCTAssertEqual(SQLiteRawType(rawValue: SQLITE_TEXT), .text)
        XCTAssertEqual(SQLiteRawType(rawValue: SQLITE_BLOB), .blob)
        XCTAssertEqual(SQLiteRawType(rawValue: SQLITE_NULL), .null)
        XCTAssertNil(SQLiteRawType(rawValue: -1))
    }
    
    func testRawValue() {
        XCTAssertEqual(SQLiteRawType.int.rawValue, SQLITE_INTEGER)
        XCTAssertEqual(SQLiteRawType.real.rawValue, SQLITE_FLOAT)
        XCTAssertEqual(SQLiteRawType.text.rawValue, SQLITE_TEXT)
        XCTAssertEqual(SQLiteRawType.blob.rawValue, SQLITE_BLOB)
        XCTAssertEqual(SQLiteRawType.null.rawValue, SQLITE_NULL)
    }
    
    func testInvalidRawValue() {
        let invalidRawValue: Int32 = 9999
        XCTAssertNil(SQLiteRawType(rawValue: invalidRawValue))
    }
}
