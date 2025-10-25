import Foundation
import Testing
import DataLiteCore

struct FunctionRegexpTests {
    @Test func metadata() {
        #expect(Regexp.argc == 2)
        #expect(Regexp.name == "REGEXP")
        #expect(Regexp.options == [.deterministic, .innocuous])
    }
    
    @Test func invalidArguments() {
        let arguments: Arguments = [.int(1), .text("value")]
        #expect(
            performing: {
                try Regexp.invoke(args: arguments)
            },
            throws: {
                switch $0 {
                case Regexp.Error.invalidArguments:
                    return true
                default:
                    return false
                }
            }
        )
    }
    
    @Test func invalidPattern() {
        let arguments: Arguments = [.text("("), .text("value")]
        #expect(
            performing: {
                try Regexp.invoke(args: arguments)
            },
            throws: {
                switch $0 {
                case Regexp.Error.regexError:
                    return true
                default:
                    return false
                }
            }
        )
    }
    
    @Test func matchesPattern() throws {
        let arguments: Arguments = [.text("foo.*"), .text("foobar")]
        #expect(try Regexp.invoke(args: arguments) as? Bool == true)
    }
    
    @Test func doesNotMatchPattern() throws {
        let arguments: Arguments = [.text("bar.*"), .text("foobar")]
        #expect(try Regexp.invoke(args: arguments) as? Bool == false)
    }
}

private extension FunctionRegexpTests {
    typealias Regexp = Function.Regexp
    
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
