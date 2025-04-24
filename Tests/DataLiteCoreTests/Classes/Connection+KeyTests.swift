import Testing
import Foundation
import DataLiteCore

struct ConnectionKeyTests {
    @Test func testPassphrase() {
        let key = Connection.Key.passphrase("secret123")
        #expect(key.keyValue == "secret123")
        #expect(key.length == 9)
    }
    
    @Test func testRawKey() {
        let keyData = Data([0x01, 0xAB, 0xCD, 0xEF])
        let key = Connection.Key.rawKey(keyData)
        #expect(key.keyValue == "X'01ABCDEF'")
        #expect(key.length == 11)
    }
    
    @Test func testRawKeyLengthConsistency() {
        let rawBytes = Data(repeating: 0x00, count: 32)
        let key = Connection.Key.rawKey(rawBytes)
        let hexPart = key.keyValue.dropFirst(2).dropLast()
        #expect(hexPart.count == 64)
    }
}
