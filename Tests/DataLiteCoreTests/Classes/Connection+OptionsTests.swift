import XCTest
import DataLiteC
import DataLiteCore

final class ConnectionOptionsTests: XCTestCase {
    func testReadOnlyOption() {
        let options: Connection.Options = [.readonly]
        XCTAssertTrue(options.contains(.readonly), "Options should contain readonly.")
        XCTAssertFalse(options.contains(.readwrite), "Options should not contain readwrite.")
    }
    
    func testReadWriteOption() {
        let options: Connection.Options = [.readwrite]
        XCTAssertTrue(options.contains(.readwrite), "Options should contain readwrite.")
        XCTAssertFalse(options.contains(.readonly), "Options should not contain readonly.")
    }
    
    func testCreateOption() {
        let options: Connection.Options = [.create]
        XCTAssertTrue(options.contains(.create), "Options should contain create.")
    }
    
    func testMultipleOptions() {
        let options: Connection.Options = [.readwrite, .create, .memory]
        XCTAssertTrue(options.contains(.readwrite), "Options should contain readwrite.")
        XCTAssertTrue(options.contains(.create), "Options should contain create.")
        XCTAssertTrue(options.contains(.memory), "Options should contain memory.")
        XCTAssertFalse(options.contains(.readonly), "Options should not contain readonly.")
    }
    
    func testNoFollowOption() {
        let options: Connection.Options = [.nofollow]
        XCTAssertTrue(options.contains(.nofollow), "Options should contain nofollow.")
    }
    
    func testAllOptions() {
        let options: Connection.Options = [
            .readonly, .readwrite, .create, .uri, .memory,
            .nomutex, .fullmutex, .sharedcache,
            .privatecache, .exrescode, .nofollow
        ]
        
        XCTAssertTrue(options.contains(.readonly), "Options should contain readonly.")
        XCTAssertTrue(options.contains(.readwrite), "Options should contain readwrite.")
        XCTAssertTrue(options.contains(.create), "Options should contain create.")
        XCTAssertTrue(options.contains(.uri), "Options should contain uri.")
        XCTAssertTrue(options.contains(.memory), "Options should contain memory.")
        XCTAssertTrue(options.contains(.nomutex), "Options should contain nomutex.")
        XCTAssertTrue(options.contains(.fullmutex), "Options should contain fullmutex.")
        XCTAssertTrue(options.contains(.sharedcache), "Options should contain sharedcache.")
        XCTAssertTrue(options.contains(.privatecache), "Options should contain privatecache.")
        XCTAssertTrue(options.contains(.exrescode), "Options should contain exrescode.")
        XCTAssertTrue(options.contains(.nofollow), "Options should contain nofollow.")
    }
    
    func testOptionsRawValue() {
        let options: Connection.Options = [.readwrite, .create]
        let expectedRawValue = Int32(SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
        XCTAssertEqual(options.rawValue, expectedRawValue, "Raw value should match combined options")
        
        XCTAssertEqual(Connection.Options.readonly.rawValue, Int32(SQLITE_OPEN_READONLY))
        XCTAssertEqual(Connection.Options.readwrite.rawValue, Int32(SQLITE_OPEN_READWRITE))
        XCTAssertEqual(Connection.Options.create.rawValue, Int32(SQLITE_OPEN_CREATE))
        XCTAssertEqual(Connection.Options.memory.rawValue, Int32(SQLITE_OPEN_MEMORY))
        XCTAssertEqual(Connection.Options.nomutex.rawValue, Int32(SQLITE_OPEN_NOMUTEX))
        XCTAssertEqual(Connection.Options.fullmutex.rawValue, Int32(SQLITE_OPEN_FULLMUTEX))
        XCTAssertEqual(Connection.Options.sharedcache.rawValue, Int32(SQLITE_OPEN_SHAREDCACHE))
        XCTAssertEqual(Connection.Options.privatecache.rawValue, Int32(SQLITE_OPEN_PRIVATECACHE))
        XCTAssertEqual(Connection.Options.exrescode.rawValue, Int32(SQLITE_OPEN_EXRESCODE))
        XCTAssertEqual(Connection.Options.nofollow.rawValue, Int32(SQLITE_OPEN_NOFOLLOW))
    }
}
