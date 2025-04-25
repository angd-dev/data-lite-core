import XCTest
import DataLiteCore

enum Color: Int, SQLiteRawRepresentable {
    case red
    case green
    case blue
}

class RawRepresentableTests: XCTestCase {
    func testRawRepresentableToSQLiteRawValue() {
        let color: Color = .green
        XCTAssertEqual(color.sqliteRawValue, .int(1)) // .green corresponds to raw value 1
    }
    
    func testSQLiteRawValueToRawRepresentable() {
        let rawValue = SQLiteRawValue.int(2)
        XCTAssertEqual(Color(rawValue), .blue) // .blue corresponds to raw value 2
        
        let invalidRawValue = SQLiteRawValue.int(42)
        XCTAssertNil(Color(invalidRawValue)) // Should be nil for out-of-bounds raw values
        
        XCTAssertNil(Color(SQLiteRawValue.text("red"))) // Should be nil for non-integer values
        XCTAssertNil(Color(SQLiteRawValue.blob(Data([0x01, 0x02])))) // Should be nil for blob values
        XCTAssertNil(Color(SQLiteRawValue.null)) // Should be nil for null values
    }
}
