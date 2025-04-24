import Testing
import Foundation
import DataLiteCore

struct BoolTests {
    @Test func testBoolToSQLiteRawValue() {
        #expect(true.sqliteRawValue == .int(1))
        #expect(false.sqliteRawValue == .int(0))
    }
    
    @Test func testSQLiteRawValueToBool() {
        #expect(Bool(.int(1)) == true)
        #expect(Bool(.int(0)) == false)
        
        #expect(Bool(.int(-1)) == nil)
        #expect(Bool(.int(2)) == nil)
        #expect(Bool(.real(1.0)) == nil)
        #expect(Bool(.text("true")) == nil)
        #expect(Bool(.blob(Data())) == nil)
        #expect(Bool(.null) == nil)
    }
}
