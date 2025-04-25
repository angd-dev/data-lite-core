import XCTest
import DataLiteC
import DataLiteCore

class FunctionOptionsTests: XCTestCase {
    func testSingleOption() {
        let option = Function.Options.deterministic
        XCTAssertEqual(option.rawValue, SQLITE_DETERMINISTIC)
        
        let option2 = Function.Options.directonly
        XCTAssertEqual(option2.rawValue, SQLITE_DIRECTONLY)
        
        let option3 = Function.Options.innocuous
        XCTAssertEqual(option3.rawValue, SQLITE_INNOCUOUS)
    }
    
    func testMultipleOptions() {
        let options: Function.Options = [.deterministic, .directonly]
        XCTAssertTrue(options.contains(.deterministic))
        XCTAssertTrue(options.contains(.directonly))
        XCTAssertFalse(options.contains(.innocuous))
    }
    
    func testEqualityAndHashability() {
        let options1: Function.Options = [.deterministic, .innocuous]
        let options2: Function.Options = [.deterministic, .innocuous]
        XCTAssertEqual(options1, options2)
        
        let hash1 = options1.hashValue
        let hash2 = options2.hashValue
        XCTAssertEqual(hash1, hash2)
    }
    
    func testEmptyOptions() {
        let options = Function.Options(rawValue: 0)
        XCTAssertFalse(options.contains(.deterministic))
        XCTAssertFalse(options.contains(.directonly))
        XCTAssertFalse(options.contains(.innocuous))
    }
    
    func testRawValueInitialization() {
        let rawValue: Int32 = SQLITE_DETERMINISTIC | SQLITE_INNOCUOUS
        let options = Function.Options(rawValue: rawValue)
        
        XCTAssertTrue(options.contains(.deterministic))
        XCTAssertTrue(options.contains(.innocuous))
        XCTAssertFalse(options.contains(.directonly))
    }
    
    func testAddingAndRemovingOptions() {
        var options: Function.Options = []
        
        options.insert(.deterministic)
        XCTAssertTrue(options.contains(.deterministic))
        
        options.insert(.directonly)
        XCTAssertTrue(options.contains(.directonly))
        
        options.remove(.deterministic)
        XCTAssertFalse(options.contains(.deterministic))
    }
}

