import Testing
import DataLiteC
import DataLiteCore

struct ConnectionOptionsTests {
    @Test func testReadOnlyOption() {
        let options: Connection.Options = [.readonly]
        #expect(options.contains(.readonly))
    }
    
    @Test func testReadWriteOption() {
        let options: Connection.Options = [.readwrite]
        #expect(options.contains(.readwrite))
    }
    
    @Test func testCreateOption() {
        let options: Connection.Options = [.create]
        #expect(options.contains(.create))
    }
    
    @Test func testMultipleOptions() {
        let options: Connection.Options = [.readwrite, .create, .memory]
        #expect(options.contains(.readwrite))
        #expect(options.contains(.create))
        #expect(options.contains(.memory))
    }
    
    @Test func testNoFollowOption() {
        let options: Connection.Options = [.nofollow]
        #expect(options.contains(.nofollow))
    }
    
    @Test func testAllOptions() {
        let options: Connection.Options = [
            .readonly, .readwrite, .create, .uri, .memory,
            .nomutex, .fullmutex, .sharedcache,
            .privatecache, .exrescode, .nofollow
        ]
        
        #expect(options.contains(.readonly))
        #expect(options.contains(.readwrite))
        #expect(options.contains(.create))
        #expect(options.contains(.uri))
        #expect(options.contains(.memory))
        #expect(options.contains(.nomutex))
        #expect(options.contains(.fullmutex))
        #expect(options.contains(.sharedcache))
        #expect(options.contains(.privatecache))
        #expect(options.contains(.exrescode))
        #expect(options.contains(.nofollow))
    }
    
    @Test func testOptionsRawValue() {
        let options: Connection.Options = [.readwrite, .create]
        let expectedRawValue = Int32(SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
        #expect(options.rawValue == expectedRawValue)
        
        #expect(Connection.Options.readonly.rawValue == SQLITE_OPEN_READONLY)
        #expect(Connection.Options.readwrite.rawValue == SQLITE_OPEN_READWRITE)
        #expect(Connection.Options.create.rawValue == SQLITE_OPEN_CREATE)
        #expect(Connection.Options.memory.rawValue == SQLITE_OPEN_MEMORY)
        #expect(Connection.Options.nomutex.rawValue == SQLITE_OPEN_NOMUTEX)
        #expect(Connection.Options.fullmutex.rawValue == SQLITE_OPEN_FULLMUTEX)
        #expect(Connection.Options.sharedcache.rawValue == SQLITE_OPEN_SHAREDCACHE)
        #expect(Connection.Options.privatecache.rawValue == SQLITE_OPEN_PRIVATECACHE)
        #expect(Connection.Options.exrescode.rawValue == SQLITE_OPEN_EXRESCODE)
        #expect(Connection.Options.nofollow.rawValue == SQLITE_OPEN_NOFOLLOW)
    }
}
