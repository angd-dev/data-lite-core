import Testing
import Foundation
import DataLiteC

@testable import DataLiteCore

struct ConnectionTests {
    @Test(arguments: [
        Connection.Location.inMemory,
        Connection.Location.temporary
    ])
    func initLocation(_ location: Connection.Location) throws {
        let _ = try Connection(location: location, options: [.create, .readwrite])
    }
    
    @Test func initPath() throws {
        let dir = FileManager.default.temporaryDirectory
        let file = UUID().uuidString
        let path = dir.appending(component: file).path
        defer { try? FileManager.default.removeItem(atPath: path) }
        let _ = try Connection(path: path, options: [.create, .readwrite])
    }
    
    @Test func initPathFail() {
        #expect(
            throws: SQLiteError(
                code: SQLITE_CANTOPEN,
                message: "unable to open database file"
            ),
            performing: {
                try Connection(
                    path: "/invalid-path/",
                    options: [.create, .readwrite]
                )
            }
        )
    }
    
    @Test func isAutocommit() throws {
        let connection = try Connection(
            location: .inMemory,
            options: [.create, .readwrite]
        )
        #expect(connection.isAutocommit)
    }
    
    @Test(arguments: [
        (Connection.Options.readwrite, false),
        (Connection.Options.readonly, true)
    ])
    func isReadonly(
        _ options: Connection.Options,
        _ expected: Bool
    ) throws {
        let dir = FileManager.default.temporaryDirectory
        let file = UUID().uuidString
        let path = dir.appending(component: file).path
        defer { try? FileManager.default.removeItem(atPath: path) }
        
        let _ = try Connection(path: path, options: [.create, .readwrite])
        let connection = try Connection(path: path, options: options)
        
        #expect(connection.isReadonly == expected)
    }
    
    @Test func changes() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        
        try connection.execute(sql: "CREATE TABLE t (id INT PRIMARY KEY)")
        #expect(connection.changes == 0)
        
        try connection.execute(sql: "INSERT INTO t (id) VALUES (1),(2)")
        #expect(connection.changes == 2)
        
        try connection.execute(sql: "UPDATE t SET id = 3 WHERE id = 1")
        #expect(connection.changes == 1)
        
        try connection.execute(sql: "DELETE FROM t WHERE id = 2")
        #expect(connection.changes == 1)
        
        try connection.execute(sql: "UPDATE t SET id = 3 WHERE id = -1")
        #expect(connection.changes == 0)
        
        try connection.execute(sql: "INSERT INTO t (id) VALUES (4),(5)")
        try connection.execute(sql: "SELECT * FROM t")
        #expect(connection.changes == 2)
    }
    
    @Test func totalChanges() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        
        try connection.execute(sql: "CREATE TABLE t (id INT PRIMARY KEY)")
        #expect(connection.totalChanges == 0)
        
        try connection.execute(sql: "INSERT INTO t (id) VALUES (1),(2)")
        #expect(connection.totalChanges == 2)
        
        try connection.execute(sql: "UPDATE t SET id = 3 WHERE id = 1")
        #expect(connection.totalChanges == 3)
        
        try connection.execute(sql: "DELETE FROM t WHERE id = 2")
        #expect(connection.totalChanges == 4)
        
        // No-op update — does not increase totalChanges
        try connection.execute(sql: "UPDATE t SET id = 3 WHERE id = -1")
        #expect(connection.totalChanges == 4)
        
        // Read-only statements do not affect totals
        try connection.execute(sql: "SELECT * FROM t")
        #expect(connection.totalChanges == 4)
        
        try connection.execute(sql: "INSERT INTO t (id) VALUES (4),(5)")
        #expect(connection.totalChanges == 6)
        
        try connection.execute(sql: "DELETE FROM t")
        #expect(connection.totalChanges == 9)
    }
    
    @Test func testBusyTimeout() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        connection.busyTimeout = 5000
        #expect(try connection.get(pragma: .busyTimeout) == 5000)
        
        try connection.set(pragma: .busyTimeout, value: 1000)
        #expect(connection.busyTimeout == 1000)
    }
    
    @Test func testApplicationID() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        
        #expect(connection.applicationID == 0)
        
        connection.applicationID = 1024
        #expect(try connection.get(pragma: .applicationID) == 1024)
        
        try connection.set(pragma: .applicationID, value: 123)
        #expect(connection.applicationID == 123)
    }
    
    @Test func testForeignKeys() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        
        #expect(connection.foreignKeys == false)
        
        connection.foreignKeys = true
        #expect(try connection.get(pragma: .foreignKeys) == true)
        
        try connection.set(pragma: .foreignKeys, value: false)
        #expect(connection.foreignKeys == false)
    }
    
    @Test func testJournalMode() throws {
        let dir = FileManager.default.temporaryDirectory
        let file = UUID().uuidString
        let path = dir.appending(component: file).path
        defer { try? FileManager.default.removeItem(atPath: path) }
        
        let connection = try Connection(path: path, options: [.create, .readwrite])
        
        connection.journalMode = .delete
        #expect(try connection.get(pragma: .journalMode) == JournalMode.delete)
        
        try connection.set(pragma: .journalMode, value: JournalMode.wal)
        #expect(connection.journalMode == .wal)
    }
    
    @Test func testSynchronous() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        
        connection.synchronous = .normal
        #expect(try connection.get(pragma: .synchronous) == Synchronous.normal)
        
        try connection.set(pragma: .synchronous, value: Synchronous.full)
        #expect(connection.synchronous == .full)
    }
    
    @Test func testUserVersion() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        
        connection.userVersion = 42
        #expect(try connection.get(pragma: .userVersion) == 42)
        
        try connection.set(pragma: .userVersion, value: 13)
        #expect(connection.userVersion == 13)
    }
    
    @Test(arguments: ["main", nil])
    func applyKeyEncrypt(_ name: String?) throws {
        let dir = FileManager.default.temporaryDirectory
        let file = UUID().uuidString
        let path = dir.appending(component: file).path
        defer { try? FileManager.default.removeItem(atPath: path) }
        
        do {
            let connection = try Connection(path: path, options: [.create, .readwrite])
            try connection.apply(.passphrase("test"), name: name)
            try connection.execute(sql: "CREATE TABLE t (id INT PRIMARY KEY)")
        }
        
        do {
            var connection: OpaquePointer!
            sqlite3_open_v2(path, &connection, SQLITE_OPEN_READONLY, nil)
            let status = sqlite3_exec(
                connection, "SELECT count(*) FROM sqlite_master", nil, nil, nil
            )
            #expect(status == SQLITE_NOTADB)
        }
    }
    
    @Test(arguments: ["main", nil])
    func applyKeyDecrypt(_ name: String?) throws {
        let dir = FileManager.default.temporaryDirectory
        let file = UUID().uuidString
        let path = dir.appending(component: file).path
        defer { try? FileManager.default.removeItem(atPath: path) }
        
        do {
            var connection: OpaquePointer!
            let options = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
            sqlite3_open_v2(path, &connection, options, nil)
            if let name {
                sqlite3_key_v2(connection, name, "test", Int32("test".utf8.count))
            } else {
                sqlite3_key(connection, "test", Int32("test".utf8.count))
            }
            sqlite3_exec(
                connection, "CREATE TABLE t (id INT PRIMARY KEY)", nil, nil, nil
            )
            sqlite3_close_v2(connection)
        }
        
        do {
            let connection = try Connection(path: path, options: [.readwrite])
            try connection.apply(.passphrase("test"), name: name)
            try connection.execute(sql: "SELECT count(*) FROM sqlite_master")
        }
    }
    
    @Test(arguments: ["main", nil])
    func applyKeyInvalid(_ name: String?) throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        #expect(
            throws: SQLiteError(code: SQLITE_MISUSE, message: ""),
            performing: { try connection.apply(.passphrase(""), name: name) }
        )
    }
    
    @Test(arguments: ["main", nil])
    func rekey(_ name: String?) throws {
        let dir = FileManager.default.temporaryDirectory
        let file = UUID().uuidString
        let path = dir.appending(component: file).path
        defer { try? FileManager.default.removeItem(atPath: path) }
        
        do {
            let connection = try Connection(path: path, options: [.create, .readwrite])
            try connection.apply(.passphrase("old-test"), name: name)
            try connection.execute(sql: "CREATE TABLE t (id INT PRIMARY KEY)")
        }
        
        do {
            let connection = try Connection(path: path, options: [.create, .readwrite])
            try connection.apply(.passphrase("old-test"), name: name)
            try connection.rekey(.passphrase("new-test"), name: name)
        }
        
        do {
            let connection = try Connection(path: path, options: [.readwrite])
            try connection.apply(.passphrase("new-test"), name: name)
            try connection.execute(sql: "SELECT count(*) FROM sqlite_master")
        }
    }
    
    @Test(arguments: ["main", nil])
    func rekeyInvalid(_ name: String?) throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        try connection.apply(.passphrase("test"), name: name)
        try connection.execute(sql: "CREATE TABLE t (id INT PRIMARY KEY)")
        
        #expect(
            throws: SQLiteError(code: SQLITE_ERROR, message: ""),
            performing: { try connection.rekey(.passphrase(""), name: name) }
        )
    }
    
    @Test func addDelegate() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        try connection.execute(sql: "CREATE TABLE t (id INT PRIMARY KEY)")
        
        let delegate = ConnectionDelegate()
        connection.add(delegate: delegate)
        
        try connection.execute(sql: "INSERT INTO t (id) VALUES (1)")
        #expect(delegate.didUpdate)
        #expect(delegate.willCommit)
        #expect(delegate.didRollback == false)
        
        delegate.reset()
        delegate.error = SQLiteError(code: -1, message: "")
        
        try? connection.execute(sql: "INSERT INTO t (id) VALUES (2)")
        #expect(delegate.didUpdate)
        #expect(delegate.willCommit)
        #expect(delegate.didRollback)
        
        delegate.reset()
        connection.remove(delegate: delegate)
        
        try connection.execute(sql: "INSERT INTO t (id) VALUES (3)")
        #expect(delegate.didUpdate == false)
        #expect(delegate.willCommit == false)
        #expect(delegate.didRollback == false)
    }
    
    @Test func addTraceDelegate() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        try connection.execute(sql: "CREATE TABLE t (id INT PRIMARY KEY)")
        
        let delegate = ConnectionTraceDelegate()
        connection.add(trace: delegate)
        
        try connection.execute(sql: "INSERT INTO t (id) VALUES (:id)")
        #expect(delegate.expandedSQL == "INSERT INTO t (id) VALUES (NULL)")
        #expect(delegate.unexpandedSQL == "INSERT INTO t (id) VALUES (:id)")
        
        delegate.reset()
        connection.remove(trace: delegate)
        
        try connection.execute(sql: "INSERT INTO t (id) VALUES (:id)")
        #expect(delegate.expandedSQL == nil)
        #expect(delegate.unexpandedSQL == nil)
    }
    
    @Test func addFunction() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        
        try connection.add(function: TestFunction.self)
        #expect(TestFunction.isInstalled)
        
        try connection.remove(function: TestFunction.self)
        #expect(TestFunction.isInstalled == false)
    }
    
    @Test func beginTransaction() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        #expect(connection.isAutocommit)
        
        try connection.beginTransaction()
        #expect(connection.isAutocommit == false)
    }
    
    @Test func commitTransaction() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        #expect(connection.isAutocommit)
        
        try connection.beginTransaction()
        try connection.commitTransaction()
        #expect(connection.isAutocommit)
    }
    
    @Test func rollbackTransaction() throws {
        let connection = try Connection(
            location: .inMemory, options: [.create, .readwrite]
        )
        #expect(connection.isAutocommit)
        
        try connection.beginTransaction()
        try connection.rollbackTransaction()
        #expect(connection.isAutocommit)
    }
}

private extension ConnectionTests {
    final class ConnectionDelegate: DataLiteCore.ConnectionDelegate {
        var error: Error?
        
        var didUpdate = false
        var willCommit = false
        var didRollback = false
        
        func reset() {
            didUpdate = false
            willCommit = false
            didRollback = false
        }
        
        func connection(
            _ connection: any ConnectionProtocol,
            didUpdate action: SQLiteAction
        ) {
            didUpdate = true
        }
        
        func connectionWillCommit(_ connection: any ConnectionProtocol) throws {
            willCommit = true
            if let error { throw error }
        }
        
        func connectionDidRollback(_ connection: any ConnectionProtocol) {
            didRollback = true
        }
    }
    
    final class ConnectionTraceDelegate: DataLiteCore.ConnectionTraceDelegate {
        var expandedSQL: String?
        var unexpandedSQL: String?
        
        func reset() {
            expandedSQL = nil
            unexpandedSQL = nil
        }
        
        func connection(_ connection: any ConnectionProtocol, trace sql: Trace) {
            expandedSQL = sql.expandedSQL
            unexpandedSQL = sql.unexpandedSQL
        }
    }
    
    final class TestFunction: DataLiteCore.Function {
        nonisolated(unsafe) static var isInstalled = false
        
        override class func install(
            db connection: OpaquePointer
        ) throws(SQLiteError) {
            isInstalled = true
        }
        
        override class func uninstall(
            db connection: OpaquePointer
        ) throws(SQLiteError) {
            isInstalled = false
        }
    }
}
