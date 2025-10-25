import Foundation
import Testing
import DataLiteC
import DataLiteCore

struct ConnectionTests {
    @Test func testIsAutocommitInitially() throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        #expect(connection.isAutocommit == true)
    }
    
    @Test func testIsAutocommitDuringTransaction() throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        try connection.beginTransaction()
        #expect(connection.isAutocommit == false)
    }
    
    @Test func testIsAutocommitAfterCommit() throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        try connection.beginTransaction()
        try connection.commitTransaction()
        #expect(connection.isAutocommit == true)
    }
    
    @Test func testIsAutocommitAfterRollback() throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        try connection.beginTransaction()
        try connection.rollbackTransaction()
        #expect(connection.isAutocommit == true)
    }
    
    @Test(arguments: [
        (Connection.Options.readwrite, false),
        (Connection.Options.readonly, true)
    ])
    func testIsReadonly(
        _ opt: Connection.Options,
        _ isReadonly: Bool
    ) throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("sqlite")
        defer { try? FileManager.default.removeItem(at: url) }
        let _ = try Connection(
            location: .file(path: url.path),
            options: [.create, .readwrite]
        )
        let connection = try Connection(
            location: .file(path: url.path),
            options: [opt]
        )
        #expect(connection.isReadonly == isReadonly)
    }
    
    @Test func testBusyTimeout() throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        connection.busyTimeout = 5000
        #expect(try connection.get(pragma: .busyTimeout) == 5000)
        
        try connection.set(pragma: .busyTimeout, value: 1000)
        #expect(connection.busyTimeout == 1000)
    }
    
    @Test func testBusyTimeoutSQLiteBusy() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("sqlite")
        defer { try? FileManager.default.removeItem(at: url) }
        
        let oneConn = try Connection(
            location: .file(path: url.path),
            options: [.create, .readwrite, .fullmutex]
        )
        let twoConn = try Connection(
            location: .file(path: url.path),
            options: [.create, .readwrite, .fullmutex]
        )
        
        try oneConn.execute(sql: """
        CREATE TABLE test (id INTEGER PRIMARY KEY, value TEXT);
        """)
        
        try oneConn.beginTransaction()
        try oneConn.execute(sql: """
        INSERT INTO test (value) VALUES ('first');
        """)
        
        #expect(
            throws: SQLiteError(
                code: SQLITE_BUSY,
                message: "database is locked"
            ),
            performing: {
                twoConn.busyTimeout = 0
                try twoConn.execute(sql: """
                INSERT INTO test (value) VALUES ('second');
                """)
            }
        )
        
        try oneConn.rollbackTransaction()
    }
    
    @Test func testApplicationID() throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        
        #expect(connection.applicationID == 0)
        
        connection.applicationID = 1024
        #expect(try connection.get(pragma: .applicationID) == 1024)
        
        try connection.set(pragma: .applicationID, value: 123)
        #expect(connection.applicationID == 123)
    }
    
    @Test func testForeignKeys() throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        
        #expect(connection.foreignKeys == false)
        
        connection.foreignKeys = true
        #expect(try connection.get(pragma: .foreignKeys) == true)
        
        try connection.set(pragma: .foreignKeys, value: false)
        #expect(connection.foreignKeys == false)
    }
    
    @Test func testJournalMode() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("sqlite")
        defer { try? FileManager.default.removeItem(at: url) }
        
        let connection = try Connection(
            location: .file(path: url.path),
            options: [.create, .readwrite]
        )
        
        connection.journalMode = .delete
        #expect(try connection.get(pragma: .journalMode) == JournalMode.delete)
        
        try connection.set(pragma: .journalMode, value: JournalMode.wal)
        #expect(connection.journalMode == .wal)
    }
    
    @Test func testSynchronous() throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        
        connection.synchronous = .normal
        #expect(try connection.get(pragma: .synchronous) == Synchronous.normal)
        
        try connection.set(pragma: .synchronous, value: Synchronous.full)
        #expect(connection.synchronous == .full)
    }
    
    @Test func testUserVersion() throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        
        connection.userVersion = 42
        #expect(try connection.get(pragma: .userVersion) == 42)
        
        try connection.set(pragma: .userVersion, value: 13)
        #expect(connection.userVersion == 13)
    }
    
    @Test(arguments: [
        (TestScalarFunc.self, TestScalarFunc.name),
        (TestAggregateFunc.self, TestAggregateFunc.name)
    ] as [(Function.Type, String)])
    func testAddFunction(
        _ function: Function.Type,
        _ name: String
    ) throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        try connection.execute(sql: """
        CREATE TABLE items (value INTEGER);
        INSERT INTO items (value) VALUES (1), (2), (NULL), (3);
        """)
        try connection.add(function: function)
        try connection.execute(sql: "SELECT \(name)(value) FROM items")
    }
    
    @Test(arguments: [
        (TestScalarFunc.self, TestScalarFunc.name),
        (TestAggregateFunc.self, TestAggregateFunc.name)
    ] as [(Function.Type, String)])
    func testRemoveFunction(
        _ function: Function.Type,
        _ name: String
    ) throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        try connection.execute(sql: """
        CREATE TABLE items (value INTEGER);
        INSERT INTO items (value) VALUES (1), (2), (NULL), (3);
        """)
        try connection.add(function: function)
        try connection.remove(function: function)
        #expect(
            throws: SQLiteError(
                code: SQLITE_ERROR,
                message: "no such function: \(name)"
            ),
            performing: {
                try connection.execute(sql: """
                SELECT \(name)(value) FROM items
                """)
            }
        )
    }
}

private extension ConnectionTests {
    final class TestScalarFunc: Function.Scalar {
        override class var argc: Int32 { 1 }
        override class var name: String { "TO_STR" }
        override class var options: Options {
            [.deterministic, .innocuous]
        }
        
        override class func invoke(args: any ArgumentsProtocol) throws -> SQLiteRepresentable? {
            args[0].description
        }
    }
    
    final class TestAggregateFunc: Function.Aggregate {
        override class var argc: Int32 { 1 }
        override class var name: String { "MY_COUNT" }
        override class var options: Options {
            [.deterministic, .innocuous]
        }
        
        private var count: Int = 0
        
        override func step(args: any ArgumentsProtocol) throws {
            if args[0] != .null {
                count += 1
            }
        }
        
        override func finalize() throws -> SQLiteRepresentable? {
            count
        }
    }
}
