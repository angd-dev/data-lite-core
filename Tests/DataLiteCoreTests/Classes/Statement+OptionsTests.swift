import Foundation
import Testing
import DataLiteC
import DataLiteCore

struct StatementOptionsTests {
    @Test func testPersistentOptions() {
        #expect(Statement.Options.persistent.rawValue == UInt32(SQLITE_PREPARE_PERSISTENT))
    }
    
    @Test func testNoVtabOptions() {
        #expect(Statement.Options.noVtab.rawValue == UInt32(SQLITE_PREPARE_NO_VTAB))
    }
    
    @Test func testCombineOptions() {
        let options: Statement.Options = [.persistent, .noVtab]
        let expected = UInt32(SQLITE_PREPARE_PERSISTENT | SQLITE_PREPARE_NO_VTAB)
        #expect(options.contains(.persistent))
        #expect(options.contains(.noVtab))
        #expect(options.rawValue == expected)
    }
    
    @Test func testInitWithUInt32RawValue() {
        let raw = UInt32(SQLITE_PREPARE_PERSISTENT)
        let options = Statement.Options(rawValue: raw)
        #expect(options == .persistent)
    }
    
    @Test func testInitWithInt32RawValue() {
        let raw = Int32(SQLITE_PREPARE_NO_VTAB)
        let options = Statement.Options(rawValue: raw)
        #expect(options == .noVtab)
    }
    
    @Test func testEmptySetRawValueIsZero() {
        let empty: Statement.Options = []
        #expect(empty.rawValue == 0)
        #expect(!empty.contains(.persistent))
        #expect(!empty.contains(.noVtab))
    }
}
