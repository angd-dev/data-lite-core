import Testing
import Foundation
import DataLiteCore

struct DateSQLiteRawRepresentableTests {
    @Test func testDateToSQLiteRawValue() {
        let date = Date(timeIntervalSince1970: 1609459200)
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        
        #expect(date.sqliteRawValue == .text(dateString))
    }
    
    @Test func testSQLiteRawValueToDate() {
        let date = Date(timeIntervalSince1970: 1609459200)
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        
        let rawText = SQLiteRawValue.text(dateString)
        #expect(Date(rawText) == date)
        
        let rawInt = SQLiteRawValue.int(1609459200)
        #expect(Date(rawInt) == date)
        
        let rawReal = SQLiteRawValue.real(1609459200)
        #expect(Date(rawReal) == date)
        
        #expect(Date(.blob(Data([0x01, 0x02, 0x03]))) == nil)
        #expect(Date(.null) == nil)
        #expect(Date(.text("Invalid date format")) == nil)
    }
}
