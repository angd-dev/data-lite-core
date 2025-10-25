import Testing
import Foundation
import DataLiteCore

struct DateSQLiteRawRepresentableTests {
    @Test func dateToSQLiteValue() {
        let date = Date(timeIntervalSince1970: 1609459200)
        let dateString = "2021-01-01T00:00:00Z"
        
        #expect(date.sqliteValue == .text(dateString))
    }
    
    @Test func dateFromSQLiteValue() {
        let date = Date(timeIntervalSince1970: 1609459200)
        let dateString = "2021-01-01T00:00:00Z"
        
        #expect(Date(SQLiteValue.text(dateString)) == date)
        #expect(Date(SQLiteValue.int(1609459200)) == date)
        #expect(Date(SQLiteValue.real(1609459200)) == date)
        
        #expect(Date(SQLiteValue.blob(Data([0x01, 0x02, 0x03]))) == nil)
        #expect(Date(SQLiteValue.null) == nil)
        #expect(Date(SQLiteValue.text("Invalid date format")) == nil)
    }
}
