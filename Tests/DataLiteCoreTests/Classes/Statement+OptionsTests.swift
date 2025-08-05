import Testing
import DataLiteCore
import DataLiteC

struct StatementOptionsTests {
    @Test func testOptionsInitialization() {
        let options: Statement.Options = [.persistent]
        
        #expect(options.contains(.persistent))
        #expect(options.contains(.noVtab) == false)
    }
    
    @Test func testOptionsCombination() {
        var options: Statement.Options = [.persistent]
        
        #expect(options.contains(.persistent))
        #expect(options.contains(.noVtab) == false)
        
        options.insert(.noVtab)
        
        #expect(options.contains(.persistent))
        #expect(options.contains(.noVtab))
    }
    
    @Test func testOptionsRemoval() {
        var options: Statement.Options = [.persistent, .noVtab]
        
        #expect(options.contains(.persistent))
        #expect(options.contains(.noVtab))
        
        options.remove(.noVtab)
        
        #expect(options.contains(.persistent))
        #expect(options.contains(.noVtab) == false)
    }
    
    @Test func testOptionsRawValue() {
        let options: Statement.Options = [.persistent, .noVtab]
        let rawOpts = UInt32(SQLITE_PREPARE_PERSISTENT | SQLITE_PREPARE_NO_VTAB)
        
        #expect(options.rawValue == rawOpts)
        #expect(Statement.Options.persistent.rawValue == UInt32(SQLITE_PREPARE_PERSISTENT))
        #expect(Statement.Options.noVtab.rawValue == UInt32(SQLITE_PREPARE_NO_VTAB))
    }
}
