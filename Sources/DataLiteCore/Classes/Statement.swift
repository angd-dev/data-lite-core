import Foundation
import DataLiteC

/// A prepared SQLite statement used to execute SQL commands.
///
/// `Statement` encapsulates the lifecycle of a compiled SQL statement, including parameter binding,
/// execution, and result retrieval. The statement is finalized automatically when the instance is
/// deallocated.
///
/// This class serves as a thin, type-safe wrapper over the SQLite C API, providing a Swift
/// interface for managing prepared statements.
///
/// ## Topics
///
/// ### Statement Options
///
/// - ``Options``
public final class Statement {
    // MARK: - Private Properties
    
    private let statement: OpaquePointer
    private let connection: OpaquePointer
    
    // MARK: - Inits
    
    init(
        db connection: OpaquePointer,
        sql query: String,
        options: Options
    ) throws(SQLiteError) {
        var statement: OpaquePointer! = nil
        let status = sqlite3_prepare_v3(
            connection, query, -1,
            options.rawValue, &statement, nil
        )
        
        if status == SQLITE_OK, let statement {
            self.statement = statement
            self.connection = connection
        } else {
            sqlite3_finalize(statement)
            throw SQLiteError(connection)
        }
    }
    
    deinit {
        sqlite3_finalize(statement)
    }
}

// MARK: - StatementProtocol

extension Statement: StatementProtocol {
    public func parameterCount() -> Int32 {
        sqlite3_bind_parameter_count(statement)
    }
    
    public func parameterIndexBy(_ name: String) -> Int32 {
        sqlite3_bind_parameter_index(statement, name)
    }
    
    public func parameterNameBy(_ index: Int32) -> String? {
        sqlite3_bind_parameter_name(statement, index)
    }
    
    public func bind(_ value: SQLiteValue, at index: Int32) throws(SQLiteError) {
        let status = switch value {
        case .int(let value):   sqlite3_bind_int64(statement, index, value)
        case .real(let value):  sqlite3_bind_double(statement, index, value)
        case .text(let value):  sqlite3_bind_text(statement, index, value)
        case .blob(let value):  sqlite3_bind_blob(statement, index, value)
        case .null:             sqlite3_bind_null(statement, index)
        }
        if status != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    public func clearBindings() throws(SQLiteError) {
        if sqlite3_clear_bindings(statement) != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    @discardableResult
    public func step() throws(SQLiteError) -> Bool {
        switch sqlite3_step(statement) {
        case SQLITE_ROW:    true
        case SQLITE_DONE:   false
        default: throw SQLiteError(connection)
        }
    }
    
    public func reset() throws(SQLiteError) {
        if sqlite3_reset(statement) != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    public func columnCount() -> Int32 {
        sqlite3_column_count(statement)
    }
    
    public func columnName(at index: Int32) -> String? {
        sqlite3_column_name(statement, index)
    }
    
    public func columnValue(at index: Int32) -> SQLiteValue {
        switch sqlite3_column_type(statement, index) {
        case SQLITE_INTEGER:    .int(sqlite3_column_int64(statement, index))
        case SQLITE_FLOAT:      .real(sqlite3_column_double(statement, index))
        case SQLITE_TEXT:       .text(sqlite3_column_text(statement, index))
        case SQLITE_BLOB:       .blob(sqlite3_column_blob(statement, index))
        default:                .null
        }
    }
}

// MARK: - Constants

let SQLITE_STATIC = unsafeBitCast(
    OpaquePointer(bitPattern: 0),
    to: sqlite3_destructor_type.self
)

let SQLITE_TRANSIENT = unsafeBitCast(
    OpaquePointer(bitPattern: -1),
    to: sqlite3_destructor_type.self
)

// MARK: - Private Sunctions

private func sqlite3_bind_parameter_name(_ stmt: OpaquePointer!, _ index: Int32) -> String? {
    guard let cString = DataLiteC.sqlite3_bind_parameter_name(stmt, index) else { return nil }
    return String(cString: cString)
}

private func sqlite3_bind_text(_ stmt: OpaquePointer!, _ index: Int32, _ string: String) -> Int32 {
    sqlite3_bind_text(stmt, index, string, -1, SQLITE_TRANSIENT)
}

private func sqlite3_bind_blob(_ stmt: OpaquePointer!, _ index: Int32, _ data: Data) -> Int32 {
    data.withUnsafeBytes {
        sqlite3_bind_blob(stmt, index, $0.baseAddress, Int32($0.count), SQLITE_TRANSIENT)
    }
}

private func sqlite3_column_name(_ stmt: OpaquePointer!, _ iCol: Int32) -> String? {
    guard let cString = DataLiteC.sqlite3_column_name(stmt, iCol) else {
        return nil
    }
    return String(cString: cString)
}

private func sqlite3_column_text(_ stmt: OpaquePointer!, _ iCol: Int32) -> String {
    String(cString: DataLiteC.sqlite3_column_text(stmt, iCol))
}

private func sqlite3_column_blob(_ stmt: OpaquePointer!, _ iCol: Int32) -> Data {
    Data(
        bytes: sqlite3_column_blob(stmt, iCol),
        count: Int(sqlite3_column_bytes(stmt, iCol))
    )
}
