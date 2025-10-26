import Foundation
import DataLiteC

/// A class representing a connection to an SQLite database.
///
/// The `Connection` class manages the connection to an SQLite database. It provides an interface
/// for preparing SQL queries, managing transactions, and handling errors. This class serves as the
/// main object for interacting with the database.
public final class Connection {
    // MARK: - Private Properties
    
    private let connection: OpaquePointer
    
    fileprivate var delegates = [DelegateBox]() {
        didSet {
            switch (oldValue.isEmpty, delegates.isEmpty) {
            case (true, false):
                let ctx = Unmanaged.passUnretained(self).toOpaque()
                sqlite3_update_hook(connection, updateHookCallback(_:_:_:_:_:), ctx)
                sqlite3_commit_hook(connection, commitHookCallback(_:), ctx)
                sqlite3_rollback_hook(connection, rollbackHookCallback(_:), ctx)
            case (false, true):
                sqlite3_update_hook(connection, nil, nil)
                sqlite3_commit_hook(connection, nil, nil)
                sqlite3_rollback_hook(connection, nil, nil)
            default:
                break
            }
        }
    }
    
    fileprivate var traceDelegates = [TraceDelegateBox]() {
        didSet {
            switch (oldValue.isEmpty, traceDelegates.isEmpty) {
            case (true, false):
                let ctx = Unmanaged.passUnretained(self).toOpaque()
                sqlite3_trace_stmt(connection, traceCallback(_:_:_:_:), ctx)
            case (false, true):
                sqlite3_trace_stmt(connection, nil, nil)
            default:
                break
            }
        }
    }
    
    // MARK: - Inits
    
    /// Initializes a new connection to an SQLite database.
    ///
    /// Opens a connection to the database at the specified `location` using the given `options`.
    ///
    /// ### Example
    ///
    /// ```swift
    /// do {
    ///     let connection = try Connection(
    ///         location: .file(path: "/path/to/sqlite.db"),
    ///         options: .readwrite
    ///     )
    ///     // Use the connection to execute SQL statements
    /// } catch {
    ///     print("Failed to open database: \\(error)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - location: The location of the database. Can represent a file path, an in-memory
    ///     database, or a temporary database.
    ///   - options: Connection options that define behavior such as read-only mode, creation
    ///     flags, and cache type.
    ///
    /// - Throws: ``SQLiteError`` if the connection cannot be opened or initialized due to
    ///   SQLite-related issues such as invalid path, missing permissions, or corruption.
    public init(location: Location, options: Options) throws(SQLiteError) {
        var connection: OpaquePointer! = nil
        let status = sqlite3_open_v2(location.path, &connection, options.rawValue, nil)
        
        guard status == SQLITE_OK, let connection else {
            let error = SQLiteError(connection)
            sqlite3_close_v2(connection)
            throw error
        }
        
        self.connection = connection
    }
    
    /// Initializes a new connection to an SQLite database using a file path.
    ///
    /// Opens a connection to the SQLite database located at the specified `path` using the provided
    ///  `options`. Internally, this method calls the designated initializer to perform the actual
    /// setup and validation.
    ///
    /// ### Example
    ///
    /// ```swift
    /// do {
    ///     let connection = try Connection(
    ///         path: "/path/to/sqlite.db",
    ///         options: .readwrite
    ///     )
    ///     // Use the connection to execute SQL statements
    /// } catch {
    ///     print("Failed to open database: \\(error)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - path: The file system path to the SQLite database file. Can be absolute or relative.
    ///   - options: Options that control how the database is opened, such as access mode and
    ///     cache type.
    ///
    /// - Throws: ``SQLiteError`` if the connection cannot be opened due to SQLite-level errors,
    ///   invalid path, missing permissions, or corruption.
    public convenience init(path: String, options: Options) throws(SQLiteError) {
        try self.init(location: .file(path: path), options: options)
    }
    
    deinit {
        sqlite3_close_v2(connection)
    }
}

// MARK: - ConnectionProtocol

extension Connection: ConnectionProtocol {
    public var isAutocommit: Bool {
        sqlite3_get_autocommit(connection) != 0
    }
    
    public var isReadonly: Bool {
        sqlite3_db_readonly(connection, "main") == 1
    }
    
    public static func initialize() throws(SQLiteError) {
        let status = sqlite3_initialize()
        guard status == SQLITE_OK else {
            throw SQLiteError(code: status, message: "")
        }
    }
    
    public static func shutdown() throws(SQLiteError) {
        let status = sqlite3_shutdown()
        guard status == SQLITE_OK else {
            throw SQLiteError(code: status, message: "")
        }
    }
    
    public func apply(_ key: Key, name: String?) throws(SQLiteError) {
        let status = if let name {
            sqlite3_key_v2(connection, name, key.keyValue, key.length)
        } else {
            sqlite3_key(connection, key.keyValue, key.length)
        }
        guard status == SQLITE_OK else {
            throw SQLiteError(code: status, message: "")
        }
    }
    
    public func rekey(_ key: Key, name: String?) throws(SQLiteError) {
        let status = if let name {
            sqlite3_rekey_v2(connection, name, key.keyValue, key.length)
        } else {
            sqlite3_rekey(connection, key.keyValue, key.length)
        }
        guard status == SQLITE_OK else {
            throw SQLiteError(code: status, message: "")
        }
    }
    
    public func add(delegate: any ConnectionDelegate) {
        if !delegates.contains(where: { $0.delegate === delegate }) {
            delegates.append(.init(delegate: delegate))
            delegates.removeAll { $0.delegate == nil }
        }
    }
    
    public func remove(delegate: any ConnectionDelegate) {
        delegates.removeAll {
            $0.delegate === delegate || $0.delegate == nil
        }
    }
    
    public func add(trace delegate: any ConnectionTraceDelegate) {
        if !traceDelegates.contains(where: { $0.delegate === delegate }) {
            traceDelegates.append(.init(delegate: delegate))
            traceDelegates.removeAll { $0.delegate == nil }
        }
    }
    
    public func remove(trace delegate: any ConnectionTraceDelegate) {
        traceDelegates.removeAll {
            $0.delegate === delegate || $0.delegate == nil
        }
    }
    
    public func add(function: Function.Type) throws(SQLiteError) {
        try function.install(db: connection)
    }
    
    public func remove(function: Function.Type) throws(SQLiteError) {
        try function.uninstall(db: connection)
    }
    
    public func prepare(
        sql query: String, options: Statement.Options
    ) throws(SQLiteError) -> any StatementProtocol {
        try Statement(db: connection, sql: query, options: options)
    }
    
    public func execute(sql script: String) throws(SQLiteError) {
        let status = sqlite3_exec(connection, script, nil, nil, nil)
        guard status == SQLITE_OK else { throw SQLiteError(connection) }
    }
}

// MARK: - DelegateBox

fileprivate extension Connection {
    class DelegateBox {
        weak var delegate: ConnectionDelegate?
        
        init(delegate: ConnectionDelegate) {
            self.delegate = delegate
        }
    }
}

// MARK: - TraceDelegateBox

fileprivate extension Connection {
    class TraceDelegateBox {
        weak var delegate: ConnectionTraceDelegate?
        
        init(delegate: ConnectionTraceDelegate) {
            self.delegate = delegate
        }
    }
}

// MARK: - Functions

private typealias TraceCallback = @convention(c) (
    UInt32,
    UnsafeMutableRawPointer?,
    UnsafeMutableRawPointer?,
    UnsafeMutableRawPointer?
) -> Int32

@discardableResult
private func sqlite3_trace_stmt(
    _ db: OpaquePointer!,
    _ callback: TraceCallback!,
    _ ctx: UnsafeMutableRawPointer!
) -> Int32 {
    sqlite3_trace_v2(db, SQLITE_TRACE_STMT, callback, ctx)
}

@discardableResult
private func sqlite3_trace_v2(
    _ db: OpaquePointer!,
    _ mask: Int32,
    _ callback: TraceCallback!,
    _ ctx: UnsafeMutableRawPointer!
) -> Int32 {
    sqlite3_trace_v2(db, UInt32(mask), callback, ctx)
}

private func traceCallback(
    _ flag: UInt32,
    _ ctx: UnsafeMutableRawPointer?,
    _ p: UnsafeMutableRawPointer?,
    _ x: UnsafeMutableRawPointer?
) -> Int32 {
    guard let ctx,
          let stmt = OpaquePointer(p)
    else { return SQLITE_OK }
    
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    
    let xSql = x?.assumingMemoryBound(to: CChar.self)
    let pSql = sqlite3_expanded_sql(stmt)
    
    defer { sqlite3_free(pSql) }
    
    guard let xSql, let pSql else {
        return SQLITE_OK
    }
    
    let xSqlString = String(cString: xSql)
    let pSqlString = String(cString: pSql)
    let trace = (xSqlString, pSqlString)
    
    for box in connection.traceDelegates {
        box.delegate?.connection(connection, trace: trace)
    }
    
    return SQLITE_OK
}

private func updateHookCallback(
    _ ctx: UnsafeMutableRawPointer?,
    _ action: Int32,
    _ dName: UnsafePointer<CChar>?,
    _ tName: UnsafePointer<CChar>?,
    _ rowID: sqlite3_int64
) {
    guard let ctx else { return }
    
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    
    guard let dName = dName, let tName = tName else { return }
    
    let dbName = String(cString: dName)
    let tableName = String(cString: tName)
    
    let updateAction: SQLiteAction? = switch action {
    case SQLITE_INSERT: .insert(db: dbName, table: tableName, rowID: rowID)
    case SQLITE_UPDATE: .update(db: dbName, table: tableName, rowID: rowID)
    case SQLITE_DELETE: .delete(db: dbName, table: tableName, rowID: rowID)
    default: nil
    }
    
    guard let updateAction else { return }
    
    for box in connection.delegates {
        box.delegate?.connection(connection, didUpdate: updateAction)
    }
}

private func commitHookCallback(
    _ ctx: UnsafeMutableRawPointer?
) -> Int32 {
    guard let ctx = ctx else { return SQLITE_OK }
    
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    
    do {
        for box in connection.delegates {
            try box.delegate?.connectionWillCommit(connection)
        }
        return SQLITE_OK
    } catch {
        return SQLITE_ERROR
    }
}

private func rollbackHookCallback(
    _ ctx: UnsafeMutableRawPointer?
) {
    guard let ctx = ctx else { return }
    
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    
    for box in connection.delegates {
        box.delegate?.connectionDidRollback(connection)
    }
}
