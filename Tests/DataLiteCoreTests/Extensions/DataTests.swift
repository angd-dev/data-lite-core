import XCTest
import DataLiteCore

class DataSQLiteRawRepresentableTests: XCTestCase {
    func testDataToSQLiteRawValue() {
        let data = Data([0x01, 0x02, 0x03])
        XCTAssertEqual(data.sqliteRawValue, .blob(data))
    }
    
    func testSQLiteRawValueToData() {
        let data = Data([0x01, 0x02, 0x03])
        let rawValue = SQLiteRawValue.blob(data)
        
        XCTAssertEqual(Data(rawValue), data)
        
        // Test invalid cases
        XCTAssertNil(Data(.int(1))) // Should be nil for non-blob values
        XCTAssertNil(Data(.real(1.0))) // Should be nil for non-blob values
        XCTAssertNil(Data(.text("blob"))) // Should be nil for non-blob values
        XCTAssertNil(Data(.null)) // Should be nil for null values
    }
}
