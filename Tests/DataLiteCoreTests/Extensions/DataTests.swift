import Testing
import Foundation
import DataLiteCore

struct DataSQLiteRawRepresentableTests {
    @Test func testDataToSQLiteRawValue() {
        let data = Data([0x01, 0x02, 0x03])
        #expect(data.sqliteRawValue == .blob(data))
    }
    
    @Test func testSQLiteRawValueToData() {
        let data = Data([0x01, 0x02, 0x03])
        let rawValue = SQLiteRawValue.blob(data)
        
        #expect(Data(rawValue) == data)
        
        #expect(Data(.int(1)) == nil)
        #expect(Data(.real(1.0)) == nil)
        #expect(Data(.text("blob")) == nil)
        #expect(Data(.null) == nil)
    }
}
