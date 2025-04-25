import XCTest
import DataLiteCore
import DataLiteC

class StatementOptionsTests: XCTestCase {
    func testOptionsInitialization() {
        let options: Statement.Options = [.persistent]
        
        XCTAssertTrue(options.contains(.persistent), "Persistent option should be set")
        XCTAssertFalse(options.contains(.noVtab), "noVtab option should not be set")
    }
    
    func testOptionsCombination() {
        var options: Statement.Options = [.persistent]
        
        XCTAssertTrue(options.contains(.persistent), "Persistent option should be set initially")
        XCTAssertFalse(options.contains(.noVtab), "noVtab option should not be set initially")
        
        options.insert(.noVtab)
        
        XCTAssertTrue(options.contains(.persistent), "Persistent option should still be set")
        XCTAssertTrue(options.contains(.noVtab), "noVtab option should be set after insertion")
    }
    
    func testOptionsRemoval() {
        var options: Statement.Options = [.persistent, .noVtab]
        
        XCTAssertTrue(options.contains(.persistent), "Persistent option should be set initially")
        XCTAssertTrue(options.contains(.noVtab), "noVtab option should be set initially")
        
        options.remove(.noVtab)
        
        XCTAssertTrue(options.contains(.persistent), "Persistent option should still be set")
        XCTAssertFalse(options.contains(.noVtab), "noVtab option should be removed")
    }
    
    func testOptionsRawValue() {
        let options: Statement.Options = [.persistent, .noVtab]
        let rawOpts = UInt32(SQLITE_PREPARE_PERSISTENT | SQLITE_PREPARE_NO_VTAB)
        
        XCTAssertEqual(options.rawValue, rawOpts, "Raw value should match combined options")
        
        XCTAssertEqual(Statement.Options.persistent.rawValue, UInt32(SQLITE_PREPARE_PERSISTENT))
        XCTAssertEqual(Statement.Options.noVtab.rawValue, UInt32(SQLITE_PREPARE_NO_VTAB))
    }
}
