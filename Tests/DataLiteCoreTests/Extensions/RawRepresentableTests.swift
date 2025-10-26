import Testing
import Foundation
import DataLiteCore

struct RawRepresentableTests {
    @Test func rawRepresentableToSQLiteValue() {
        #expect(Color.red.sqliteValue == .int(Color.red.rawValue))
        #expect(Color.green.sqliteValue == .int(Color.green.rawValue))
        #expect(Color.blue.sqliteValue == .int(Color.blue.rawValue))
    }
    
    @Test func rawRepresentableFromSQLiteValue() {
        #expect(Color(SQLiteValue.int(0)) == .red)
        #expect(Color(SQLiteValue.int(1)) == .green)
        #expect(Color(SQLiteValue.int(2)) == .blue)
        
        #expect(Color(SQLiteValue.int(42)) == nil)
        #expect(Color(SQLiteValue.real(0)) == nil)
        #expect(Color(SQLiteValue.real(1)) == nil)
        #expect(Color(SQLiteValue.real(2)) == nil)
        #expect(Color(SQLiteValue.real(42)) == nil)
        #expect(Color(SQLiteValue.text("red")) == nil)
        #expect(Color(SQLiteValue.blob(Data([0x01, 0x02]))) == nil)
        #expect(Color(SQLiteValue.null) == nil)
    }
}

private extension RawRepresentableTests {
    enum Color: Int64, SQLiteRepresentable {
        case red
        case green
        case blue
    }
}
