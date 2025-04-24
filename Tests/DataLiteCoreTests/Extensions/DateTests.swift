import XCTest
import DataLiteCore

class DateSQLiteRawRepresentableTests: XCTestCase {
    func testDateToSQLiteRawValue() {
        let date = Date(timeIntervalSince1970: 1609459200) // 2021-01-01 00:00:00 UTC
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        
        XCTAssertEqual(date.sqliteRawValue, .text(dateString))
    }

    func testSQLiteRawValueToDate() {
        let date = Date(timeIntervalSince1970: 1609459200) // 2021-01-01 00:00:00 UTC
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        
        let rawValue = SQLiteRawValue.text(dateString)
        XCTAssertEqual(Date(rawValue), date)
        
        let rawInt = SQLiteRawValue.int(1609459200)
        XCTAssertEqual(Date(rawInt), date)
        
        let rawReal = SQLiteRawValue.real(1609459200)
        XCTAssertEqual(Date(rawReal), date)
        
        // Test invalid cases
        XCTAssertNil(Date(.blob(Data([0x01, 0x02, 0x03])))) // Should be nil for non-date values
        XCTAssertNil(Date(.null)) // Should be nil for null values
        XCTAssertNil(Date(.text("Invalid date format"))) // Should be nil for invalid date format
    }
}
