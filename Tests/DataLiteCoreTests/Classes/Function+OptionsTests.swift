import Testing
import DataLiteC
import DataLiteCore

struct FunctionOptionsTests {
    @Test func singleOption() {
        #expect(Function.Options.deterministic.rawValue == SQLITE_DETERMINISTIC)
        #expect(Function.Options.directonly.rawValue == SQLITE_DIRECTONLY)
        #expect(Function.Options.innocuous.rawValue == SQLITE_INNOCUOUS)
    }
    
    @Test func multipleOptions() {
        let options: Function.Options = [.deterministic, .directonly]
        #expect(options.contains(.deterministic))
        #expect(options.contains(.directonly))
        #expect(options.contains(.innocuous) == false)
    }
    
    @Test func equalityAndHashability() {
        let options1: Function.Options = [.deterministic, .innocuous]
        let options2: Function.Options = [.deterministic, .innocuous]
        #expect(options1 == options2)
        
        let hash1 = options1.hashValue
        let hash2 = options2.hashValue
        #expect(hash1 == hash2)
    }
    
    @Test func emptyOptions() {
        let options = Function.Options(rawValue: 0)
        #expect(options.contains(.deterministic) == false)
        #expect(options.contains(.directonly) == false)
        #expect(options.contains(.innocuous) == false)
    }
    
    @Test func rawValueInitialization() {
        let rawValue: Int32 = SQLITE_DETERMINISTIC | SQLITE_INNOCUOUS
        let options = Function.Options(rawValue: rawValue)
        
        #expect(options.contains(.deterministic))
        #expect(options.contains(.innocuous))
        #expect(options.contains(.directonly) == false)
    }
    
    @Test func addingAndRemovingOptions() {
        var options: Function.Options = []
        
        options.insert(.deterministic)
        #expect(options.contains(.deterministic))
        
        options.insert(.directonly)
        #expect(options.contains(.directonly))
        
        options.remove(.deterministic)
        #expect(options.contains(.deterministic) == false)
    }
}
