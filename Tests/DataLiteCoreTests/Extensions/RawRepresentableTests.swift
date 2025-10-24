import Testing
import Foundation
import DataLiteCore

struct RawRepresentableTests {
    @Test func testRawRepresentableToSQLiteRawValue() {
        let color: Color = .green
        #expect(color.sqliteValue == .int(1))
    }
    
    @Test func testSQLiteRawValueToRawRepresentable() {
        #expect(Color(.int(2)) == .blue)
        
        #expect(Color(.int(42)) == nil)
        #expect(Color(.text("red")) == nil)
        #expect(Color(.blob(Data([0x01, 0x02]))) == nil)
        #expect(Color(.null) == nil)
    }
}

private extension RawRepresentableTests {
    enum Color: Int, SQLiteRepresentable {
        case red
        case green
        case blue
    }
}
