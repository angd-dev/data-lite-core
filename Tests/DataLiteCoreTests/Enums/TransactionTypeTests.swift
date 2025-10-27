import Testing
import DataLiteCore

struct TransactionTypeTests {
    @Test func description() {
        #expect(TransactionType.deferred.description == "DEFERRED")
        #expect(TransactionType.immediate.description == "IMMEDIATE")
        #expect(TransactionType.exclusive.description == "EXCLUSIVE")
    }
    
    @Test func rawValue() {
        #expect(TransactionType.deferred.rawValue == "DEFERRED")
        #expect(TransactionType.immediate.rawValue == "IMMEDIATE")
        #expect(TransactionType.exclusive.rawValue == "EXCLUSIVE")
    }
    
    @Test func initRawValue() {
        #expect(TransactionType(rawValue: "DEFERRED") == .deferred)
        #expect(TransactionType(rawValue: "deferred") == .deferred)
        
        #expect(TransactionType(rawValue: "IMMEDIATE") == .immediate)
        #expect(TransactionType(rawValue: "immediate") == .immediate)
        
        #expect(TransactionType(rawValue: "EXCLUSIVE") == .exclusive)
        #expect(TransactionType(rawValue: "exclusive") == .exclusive)
        
        #expect(TransactionType(rawValue: "SOME_STR") == nil)
    }
}
