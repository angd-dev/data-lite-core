import Foundation
import DataLiteC

public final class Connection: ConnectionProtocol {
    // MARK: - Private Properties
    
    private let connection: OpaquePointer
    
    // MARK: - Delegation
    
    public weak var delegate: (any ConnectionDelegate)?
    
    // MARK: - Connection State
    
    public var isAutocommit: Bool {
        sqlite3_get_autocommit(connection) != 0
    }
    
    public var isReadonly: Bool {
        sqlite3_db_readonly(connection, "main") == 1
    }
    
    public var busyTimeout: Int32 {
        get { try! get(pragma: .busyTimeout) ?? 0 }
        set { try! set(pragma: .busyTimeout, value: newValue) }
    }
    
    // MARK: - Inits
    
    public init(location: Location, options: Options) throws {
        if case let Location.file(path) = location, !path.isEmpty {
            try FileManager.default.createDirectory(
                at: URL(fileURLWithPath: path).deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
        }
        
        var connection: OpaquePointer! = nil
        let status = sqlite3_open_v2(location.path, &connection, options.rawValue, nil)
        
        if status == SQLITE_OK, let connection = connection {
            self.connection = connection
            
            let ctx = Unmanaged.passUnretained(self).toOpaque()
            sqlite3_trace_v2(connection, UInt32(SQLITE_TRACE_STMT), traceCallback(_:_:_:_:), ctx)
            sqlite3_update_hook(connection, updateHookCallback(_:_:_:_:_:), ctx)
            sqlite3_commit_hook(connection, commitHookCallback(_:), ctx)
            sqlite3_rollback_hook(connection, rollbackHookCallback(_:), ctx)
        } else {
            let error = Error(connection)
            sqlite3_close_v2(connection)
            throw error
        }
    }
    
    public convenience init(path: String, options: Options) throws {
        try self.init(location: .file(path: path), options: options)
    }
    
    deinit {
        sqlite3_close_v2(connection)
    }
    
    // MARK: - Custom SQL Functions
    
    public func add(function: Function.Type) throws(Error) {
        try function.install(db: connection)
    }
    
    public func remove(function: Function.Type) throws(Error) {
        try function.uninstall(db: connection)
    }
    
    // MARK: - Statement Preparation
    
    public func prepare(sql query: String, options: Statement.Options = []) throws(Error) -> Statement {
        try Statement(db: connection, sql: query, options: options)
    }
    
    // MARK: - Script Execution
    
    public func execute(raw sql: String) throws(Error) {
        let status = sqlite3_exec(connection, sql, nil, nil, nil)
        if status != SQLITE_OK {
            throw Error(connection)
        }
    }
    
    // MARK: - Encryption Keys
    
    public func apply(_ key: Key, name: String? = nil) throws(Error) {
        let status = if let name {
            sqlite3_key_v2(connection, name, key.keyValue, key.length)
        } else {
            sqlite3_key(connection, key.keyValue, key.length)
        }
        if status != SQLITE_OK {
            throw Error(connection)
        }
    }
    
    public func rekey(_ key: Key, name: String? = nil) throws(Error) {
        let status = if let name {
            sqlite3_rekey_v2(connection, name, key.keyValue, key.length)
        } else {
            sqlite3_rekey(connection, key.keyValue, key.length)
        }
        if status != SQLITE_OK {
            throw Error(connection)
        }
    }
}

// MARK: - Functions

private func traceCallback(
    _ flag: UInt32,
    _ ctx: UnsafeMutableRawPointer?,
    _ p: UnsafeMutableRawPointer?,
    _ x: UnsafeMutableRawPointer?
) -> Int32 {
    guard let ctx = ctx else { return SQLITE_OK }
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    
    if let delegate = connection.delegate {
        guard let stmt = OpaquePointer(p),
              let pSql = sqlite3_expanded_sql(stmt),
              let xSql = x?.assumingMemoryBound(to: CChar.self)
        else { return SQLITE_OK }
        
        let pSqlString = String(cString: pSql)
        let xSqlString = String(cString: xSql)
        let trace = (xSqlString, pSqlString)
        delegate.connection(connection, trace: trace)
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
    guard let ctx = ctx else { return }
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    
    if let delegate = connection.delegate {
        guard let dName = dName, let tName = tName else { return }
        
        let dbName = String(cString: dName)
        let tableName = String(cString: tName)
        let updateAction: SQLiteAction
        
        switch action {
        case SQLITE_INSERT:
            updateAction = .insert(db: dbName, table: tableName, rowID: rowID)
        case SQLITE_UPDATE:
            updateAction = .update(db: dbName, table: tableName, rowID: rowID)
        case SQLITE_DELETE:
            updateAction = .delete(db: dbName, table: tableName, rowID: rowID)
        default:
            return
        }
        
        delegate.connection(connection, didUpdate: updateAction)
    }
}

private func commitHookCallback(_ ctx: UnsafeMutableRawPointer?) -> Int32 {
    do {
        guard let ctx = ctx else { return SQLITE_OK }
        let connection = Unmanaged<Connection>
            .fromOpaque(ctx)
            .takeUnretainedValue()
        if let delegate = connection.delegate {
            try delegate.connectionDidCommit(connection)
        }
        return SQLITE_OK
    } catch {
        return SQLITE_ERROR
    }
}

private func rollbackHookCallback(_ ctx: UnsafeMutableRawPointer?) {
    guard let ctx = ctx else { return }
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    if let delegate = connection.delegate {
        delegate.connectionDidRollback(connection)
    }
}
