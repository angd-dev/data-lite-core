import Foundation
import Testing
import DataLiteCore

struct ArgumentsProtocolTests {
    @Test func typedSubscript() {
        let arguments: Arguments = [
            .text("one"),
            .text("two"),
            .int(42)
        ]

        #expect(arguments[0] == TestModel.one)
        #expect(arguments[1] == TestModel.two)
        #expect(arguments[2] as TestModel? == nil)
    }
}

private extension ArgumentsProtocolTests {
    enum TestModel: String, SQLiteRepresentable {
        case one, two
    }
    
    struct Arguments: ArgumentsProtocol, ExpressibleByArrayLiteral {
        private let values: [SQLiteValue]
        
        var startIndex: Int { values.startIndex }
        var endIndex: Int { values.endIndex }
        
        init(_ values: [SQLiteValue]) {
            self.values = values
        }
        
        init(arrayLiteral elements: SQLiteValue...) {
            self.values = elements
        }
        
        subscript(index: Int) -> SQLiteValue {
            values[index]
        }
        
        func index(after i: Int) -> Int {
            values.index(after: i)
        }
    }
}
