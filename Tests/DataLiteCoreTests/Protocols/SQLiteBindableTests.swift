import Foundation
import Testing
import DataLiteCore

struct SQLiteBindableTests {
    @Test(arguments: [
        SQLiteValue.int(42),
        SQLiteValue.real(0.5),
        SQLiteValue.text("O'Reilly"),
        SQLiteValue.blob(Data([0x00, 0xAB])),
        SQLiteValue.null
    ])
    func sqliteLiteral(_ value: SQLiteValue) {
        let stub = Bindable(value: value)
        #expect(stub.sqliteLiteral == value.sqliteLiteral)
    }
}

private extension SQLiteBindableTests {
    struct Bindable: SQLiteBindable {
        let value: SQLiteValue
        var sqliteValue: SQLiteValue { value }
    }
}
