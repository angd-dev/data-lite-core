import Foundation
import Testing
import DataLiteCore

private struct BindableStub: SQLiteBindable {
    let value: SQLiteValue
    var sqliteValue: SQLiteValue { value }
}

struct SQLiteBindableTests {
    @Test(arguments: [
        SQLiteValue.int(42),
        SQLiteValue.real(0.5),
        SQLiteValue.text("O'Reilly"),
        SQLiteValue.blob(Data([0x00, 0xAB])),
        SQLiteValue.null
    ])
    func testDefaultSqliteLiteralPassThrough(_ value: SQLiteValue) {
        let stub = BindableStub(value: value)
        #expect(stub.sqliteLiteral == value.sqliteLiteral)
    }
}
