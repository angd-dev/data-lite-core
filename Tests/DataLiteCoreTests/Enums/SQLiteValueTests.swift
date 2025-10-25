import Foundation
import Testing
import DataLiteCore

struct SQLiteValueTests {
    @Test(arguments: [1, 42, 1234])
    func intSQLiteValue(_ value: Int64) {
        let value = SQLiteValue.int(value)
        #expect(value.sqliteLiteral == "\(value)")
        #expect(value.description == value.sqliteLiteral)
    }
    
    @Test(arguments: [12, 0.5, 123.99])
    func realSQLiteValue(_ value: Double) {
        let value = SQLiteValue.real(value)
        #expect(value.sqliteLiteral == "\(value)")
        #expect(value.description == value.sqliteLiteral)
    }
    
    @Test(arguments: [
        ("", "''"),
        ("'hello'", "'''hello'''"),
        ("hello", "'hello'"),
        ("O'Reilly", "'O''Reilly'"),
        ("It's John's \"book\"", "'It''s John''s \"book\"'")
    ])
    func textSQLiteValue(_ value: String, _ expected: String) {
        let value = SQLiteValue.text(value)
        #expect(value.sqliteLiteral == expected)
        #expect(value.description == value.sqliteLiteral)
    }
    
    @Test(arguments: [
        (Data(), "X''"),
        (Data([0x00]), "X'00'"),
        (Data([0x00, 0xAB, 0xCD]), "X'00ABCD'")
    ])
    func blobSQLiteValue(_ value: Data, _ expected: String) {
        let value = SQLiteValue.blob(value)
        #expect(value.sqliteLiteral == expected)
        #expect(value.description == value.sqliteLiteral)
    }
    
    @Test func nullSQLiteValue() {
        let value = SQLiteValue.null
        #expect(value.sqliteLiteral == "NULL")
        #expect(value.description == value.sqliteLiteral)
    }
}
