import Foundation
import DataLiteC

/// A protocol that defines the interface for a database connection.
///
/// This protocol specifies the requirements for managing a connection
/// to an SQLite database, including connection state, configuration via PRAGMA,
/// executing SQL statements and scripts, transaction control, and encryption support.
///
/// It also includes support for delegation to handle connection-related events.
///
/// ## See Also
///
/// - ``Connection``
///
/// ## Topics
///
/// ### Connection State
///
/// - ``isAutocommit``
/// - ``isReadonly``
/// - ``busyTimeout``
///
/// ### PRAGMA Accessors
///
/// - ``applicationID``
/// - ``foreignKeys``
/// - ``journalMode``
/// - ``synchronous``
/// - ``userVersion``
///
/// ### Delegation
///
/// - ``addDelegate(_:)``
/// - ``removeDelegate(_:)``
///
/// ### SQLite Lifecycle
///
/// - ``initialize()``
/// - ``shutdown()``
///
/// ### Custom SQL Functions
///
/// - ``add(function:)``
/// - ``remove(function:)``
///
/// ### Statement Preparation
///
/// - ``prepare(sql:options:)``
///
/// ### Script Execution
///
/// - ``execute(sql:)``
/// - ``execute(raw:)``
///
/// ### PRAGMA Execution
///
/// - ``get(pragma:)``
/// - ``set(pragma:value:)``
///
/// ### Transactions
///
/// - ``beginTransaction(_:)``
/// - ``commitTransaction()``
/// - ``rollbackTransaction()``
///
/// ### Encryption Keys
///
/// - ``Connection/Key``
/// - ``apply(_:name:)``
/// - ``rekey(_:name:)``
public protocol ConnectionProtocol: AnyObject {
    // MARK: - Connection State
    
    /// Indicates whether the database connection is in autocommit mode.
    ///
    /// Autocommit mode is enabled by default. It remains enabled as long as no
    /// explicit transactions are active. Executing `BEGIN` disables autocommit mode,
    /// and executing `COMMIT` or `ROLLBACK` re-enables it.
    ///
    /// - Returns: `true` if the connection is in autocommit mode; otherwise, `false`.
    /// - SeeAlso: [sqlite3_get_autocommit()](https://sqlite.org/c3ref/get_autocommit.html)
    var isAutocommit: Bool { get }
    
    /// Indicates whether the database connection is read-only.
    ///
    /// This property reflects the access mode of the main database for the connection.
    /// It returns `true` if the database was opened with read-only access,
    /// and `false` if it allows read-write access.
    ///
    /// - Returns: `true` if the main database is read-only; otherwise, `false`.
    /// - SeeAlso: [sqlite3_db_readonly()](https://www.sqlite.org/c3ref/db_readonly.html)
    var isReadonly: Bool { get }
    
    /// The busy timeout duration in milliseconds for the database connection.
    ///
    /// This value determines how long SQLite will wait for a locked database to become available
    /// before returning a `SQLITE_BUSY` error. A value of zero disables the timeout and causes
    /// operations to fail immediately if the database is locked.
    ///
    /// - SeeAlso: [sqlite3_busy_timeout()](https://www.sqlite.org/c3ref/busy_timeout.html)
    var busyTimeout: Int32 { get set }
    
    // MARK: - PRAGMA Accessors
    
    /// The application ID stored in the database header.
    ///
    /// This 32-bit integer is used to identify the application that created or manages the database.
    /// It is stored at a fixed offset within the database file header and can be read or modified
    /// using the `application_id` pragma.
    ///
    /// - SeeAlso: [PRAGMA application_id](https://www.sqlite.org/pragma.html#pragma_application_id)
    var applicationID: Int32 { get set }
    
    /// Indicates whether foreign key constraints are enforced.
    ///
    /// This property enables or disables enforcement of foreign key constraints
    /// by the database connection. When set to `true`, constraints are enforced;
    /// when `false`, they are ignored.
    ///
    /// - SeeAlso: [PRAGMA foreign_keys](https://www.sqlite.org/pragma.html#pragma_foreign_keys)
    var foreignKeys: Bool { get set }
    
    /// The journal mode used by the database connection.
    ///
    /// The journal mode determines how SQLite manages rollback journals,
    /// impacting durability, concurrency, and performance.
    ///
    /// Setting this property updates the journal mode using the corresponding SQLite PRAGMA.
    ///
    /// - SeeAlso: [PRAGMA journal_mode](https://www.sqlite.org/pragma.html#pragma_journal_mode)
    var journalMode: JournalMode { get set }
    
    /// The synchronous mode used by the database connection.
    ///
    /// This property controls how rigorously SQLite waits for data to be
    /// physically written to disk, influencing durability and performance.
    ///
    /// Setting this property updates the synchronous mode using the
    /// corresponding SQLite PRAGMA.
    ///
    /// - SeeAlso: [PRAGMA synchronous](https://www.sqlite.org/pragma.html#pragma_synchronous)
    var synchronous: Synchronous { get set }
    
    /// The user version number stored in the database.
    ///
    /// This 32-bit integer is stored as the `user_version` pragma and
    /// is typically used by applications to track the schema version
    /// or migration state of the database.
    ///
    /// Setting this property updates the corresponding SQLite PRAGMA.
    ///
    /// - SeeAlso: [PRAGMA user_version](https://www.sqlite.org/pragma.html#pragma_user_version)
    var userVersion: Int32 { get set }
    
    // MARK: - Delegation
    
    /// Adds a delegate to receive connection events.
    ///
    /// - Parameter delegate: The delegate to add.
    func addDelegate(_ delegate: ConnectionDelegate)
    
    /// Removes a delegate from receiving connection events.
    ///
    /// - Parameter delegate: The delegate to remove.
    func removeDelegate(_ delegate: ConnectionDelegate)
    
    // MARK: - SQLite Lifecycle
    
    /// Initializes the SQLite library.
    ///
    /// This method sets up the global state required by SQLite. It must be called before using
    /// any other SQLite interface, unless SQLite is initialized automatically.
    ///
    /// A successful call has an effect only the first time it is invoked during the lifetime of
    /// the process, or the first time after a call to ``shutdown()``. All other calls are no-ops.
    ///
    /// - Throws: ``Connection/Error`` if the initialization fails.
    /// - SeeAlso: [sqlite3_initialize()](https://www.sqlite.org/c3ref/initialize.html)
    static func initialize() throws(Connection.Error)

    /// Shuts down the SQLite library.
    ///
    /// This method releases global resources used by SQLite and reverses the effects of a successful
    /// call to ``initialize()``. It must be called exactly once for each successful call to
    /// ``initialize()``, and only after all database connections are closed.
    ///
    /// - Throws: ``Connection/Error`` if the shutdown process fails.
    /// - SeeAlso: [sqlite3_shutdown()](https://www.sqlite.org/c3ref/initialize.html)
    static func shutdown() throws(Connection.Error)
    
    // MARK: - Custom SQL Functions
    
    /// Registers a custom SQL function with the connection.
    ///
    /// This allows adding user-defined functions callable from SQL queries.
    ///
    /// - Parameter function: The type of the custom SQL function to add.
    /// - Throws: ``Connection/Error`` if the function registration fails.
    func add(function: Function.Type) throws(Connection.Error)
    
    /// Removes a previously registered custom SQL function from the connection.
    ///
    /// - Parameter function: The type of the custom SQL function to remove.
    /// - Throws: ``Connection/Error`` if the function removal fails.
    func remove(function: Function.Type) throws(Connection.Error)
    
    // MARK: - Statement Preparation
    
    /// Prepares an SQL statement for execution.
    ///
    /// Compiles the provided SQL query into a ``Statement`` object that can be executed or stepped through.
    ///
    /// - Parameters:
    ///   - query: The SQL query string to prepare.
    ///   - options: Options that affect statement preparation.
    /// - Returns: A prepared ``Statement`` ready for execution.
    /// - Throws: ``Connection/Error`` if statement preparation fails.
    /// - SeeAlso: [sqlite3_prepare_v3()](https://www.sqlite.org/c3ref/prepare.html)
    func prepare(sql query: String, options: Statement.Options) throws(Connection.Error) -> Statement
    
    // MARK: - Script Execution
    
    /// Executes a sequence of SQL statements.
    ///
    /// Processes the given SQL script by executing each individual statement in order.
    ///
    /// - Parameter script: A collection of SQL statements to execute.
    /// - Throws: ``Connection/Error`` if any statement execution fails.
    func execute(sql script: SQLScript) throws(Connection.Error)
    
    /// Executes a raw SQL string.
    ///
    /// Executes the provided raw SQL string as a single operation.
    ///
    /// - Parameter sql: The raw SQL string to execute.
    /// - Throws: ``Connection/Error`` if the execution fails.
    func execute(raw sql: String) throws(Connection.Error)
    
    // MARK: - PRAGMA Execution
    
    /// Retrieves the value of a PRAGMA setting from the database.
    ///
    /// - Parameter pragma: The PRAGMA setting to retrieve.
    /// - Returns: The current value of the PRAGMA, or `nil` if the value is not available.
    /// - Throws: ``Connection/Error`` if the operation fails.
    func get<T: SQLiteRawRepresentable>(pragma: Pragma) throws(Connection.Error) -> T?
    
    /// Sets the value of a PRAGMA setting in the database.
    ///
    /// - Parameters:
    ///   - pragma: The PRAGMA setting to modify.
    ///   - value: The new value to assign to the PRAGMA.
    /// - Returns: The resulting value after the assignment, or `nil` if unavailable.
    /// - Throws: ``Connection/Error`` if the operation fails.
    @discardableResult
    func set<T: SQLiteRawRepresentable>(pragma: Pragma, value: T) throws(Connection.Error) -> T?
    
    // MARK: - Transactions
    
    /// Begins a database transaction of the specified type.
    ///
    /// - Parameter type: The type of transaction to begin (e.g., deferred, immediate, exclusive).
    /// - Throws: ``Connection/Error`` if starting the transaction fails.
    /// - SeeAlso: [BEGIN TRANSACTION](https://www.sqlite.org/lang_transaction.html)
    func beginTransaction(_ type: TransactionType) throws(Connection.Error)
    
    /// Commits the current database transaction.
    ///
    /// - Throws: ``Connection/Error`` if committing the transaction fails.
    /// - SeeAlso: [COMMIT](https://www.sqlite.org/lang_transaction.html)
    func commitTransaction() throws(Connection.Error)
    
    /// Rolls back the current database transaction.
    ///
    /// - Throws: ``Connection/Error`` if rolling back the transaction fails.
    /// - SeeAlso: [ROLLBACK](https://www.sqlite.org/lang_transaction.html)
    func rollbackTransaction() throws(Connection.Error)
    
    // MARK: - Encryption Keys
    
    /// Applies an encryption key to the database connection.
    ///
    /// - Parameters:
    ///   - key: The encryption key to apply.
    ///   - name: An optional name identifying the database to apply the key to.
    /// - Throws: ``Connection/Error`` if applying the key fails.
    func apply(_ key: Connection.Key, name: String?) throws(Connection.Error)
    
    /// Changes the encryption key for the database connection.
    ///
    /// - Parameters:
    ///   - key: The new encryption key to set.
    ///   - name: An optional name identifying the database to rekey.
    /// - Throws: ``Connection/Error`` if rekeying fails.
    func rekey(_ key: Connection.Key, name: String?) throws(Connection.Error)
}

// MARK: - PRAGMA Accessors

public extension ConnectionProtocol {
    var applicationID: Int32 {
        get { try! get(pragma: .applicationID) ?? 0 }
        set { try! set(pragma: .applicationID, value: newValue) }
    }
    
    var foreignKeys: Bool {
        get { try! get(pragma: .foreignKeys) ?? false }
        set { try! set(pragma: .foreignKeys, value: newValue) }
    }
    
    var journalMode: JournalMode {
        get { try! get(pragma: .journalMode) ?? .off }
        set { try! set(pragma: .journalMode, value: newValue) }
    }
    
    var synchronous: Synchronous {
        get { try! get(pragma: .synchronous) ?? .off }
        set { try! set(pragma: .synchronous, value: newValue) }
    }
    
    var userVersion: Int32 {
        get { try! get(pragma: .userVersion) ?? 0 }
        set { try! set(pragma: .userVersion, value: newValue) }
    }
}

// MARK: - SQLite Lifecycle

public extension ConnectionProtocol {
    static func initialize() throws(Connection.Error) {
        let status = sqlite3_initialize()
        if status != SQLITE_OK {
            throw Connection.Error(code: status, message: "")
        }
    }
    
    static func shutdown() throws(Connection.Error) {
        let status = sqlite3_shutdown()
        if status != SQLITE_OK {
            throw Connection.Error(code: status, message: "")
        }
    }
}

// MARK: - Script Execution

public extension ConnectionProtocol {
    func execute(sql script: SQLScript) throws(Connection.Error) {
        for query in script {
            let stmt = try prepare(sql: query, options: [])
            while try stmt.step() {}
        }
    }
}

// MARK: - PRAGMA Execution

public extension ConnectionProtocol {
    func get<T: SQLiteRawRepresentable>(pragma: Pragma) throws(Connection.Error) -> T? {
        let stmt = try prepare(sql: "PRAGMA \(pragma)", options: [])
        switch try stmt.step() {
        case true:  return stmt.columnValue(at: 0)
        case false: return nil
        }
    }
    
    @discardableResult
    func set<T: SQLiteRawRepresentable>(pragma: Pragma, value: T) throws(Connection.Error) -> T? {
        let query = "PRAGMA \(pragma) = \(value.sqliteLiteral)"
        let stmt = try prepare(sql: query, options: [])
        switch try stmt.step() {
        case true:  return stmt.columnValue(at: 0)
        case false: return nil
        }
    }
}

// MARK: - Transactions

public extension ConnectionProtocol {
    func beginTransaction(_ type: TransactionType = .deferred) throws(Connection.Error) {
        try prepare(sql: "BEGIN \(type) TRANSACTION", options: []).step()
    }
    
    func commitTransaction() throws(Connection.Error) {
        try prepare(sql: "COMMIT TRANSACTION", options: []).step()
    }
    
    func rollbackTransaction() throws(Connection.Error) {
        try prepare(sql: "ROLLBACK TRANSACTION", options: []).step()
    }
}
