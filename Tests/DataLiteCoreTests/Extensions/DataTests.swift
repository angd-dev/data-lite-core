import Testing
import Foundation
import DataLiteCore

struct DataSQLiteRawRepresentableTests {
    @Test func dataToSQLiteValue() {
        let data = Data([0x01, 0x02, 0x03])
        #expect(data.sqliteValue == .blob(data))
    }
    
    @Test func dataFromSQLiteValue() {
        let data = Data([0x01, 0x02, 0x03])
        #expect(Data(SQLiteValue.blob(data)) == data)
        
        #expect(Data(SQLiteValue.int(1)) == nil)
        #expect(Data(SQLiteValue.real(1.0)) == nil)
        #expect(Data(SQLiteValue.text("blob")) == nil)
        #expect(Data(SQLiteValue.null) == nil)
    }
}
