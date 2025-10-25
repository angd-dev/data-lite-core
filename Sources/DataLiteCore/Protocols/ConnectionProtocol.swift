import Foundation

/// A protocol that defines an SQLite database connection.
///
/// The `ConnectionProtocol` defines the essential API for managing a database connection,
/// including configuration, statement preparation, transactions, encryption, and delegation.
/// Conforming types are responsible for maintaining the connection’s lifecycle and settings.
///
/// ## Topics
///
/// ### Managing Connection State
///
/// - ``isAutocommit``
/// - ``isReadonly``
/// - ``busyTimeout``
///
/// ### Accessing PRAGMA Values
///
/// - ``applicationID``
/// - ``foreignKeys``
/// - ``journalMode``
/// - ``synchronous``
/// - ``userVersion``
///
/// ### Managing SQLite Lifecycle
///
/// - ``initialize()``
/// - ``shutdown()``
///
/// ### Handling Encryption
///
/// - ``apply(_:name:)``
/// - ``rekey(_:name:)``
///
/// ### Managing Delegates
///
/// - ``add(delegate:)``
/// - ``remove(delegate:)``
/// - ``add(trace:)``
/// - ``remove(trace:)``
///
/// ### Registering Custom SQL Functions
///
/// - ``add(function:)``
/// - ``remove(function:)``
///
/// ### Preparing SQL Statements
///
/// - ``prepare(sql:)``
/// - ``prepare(sql:options:)``
///
/// ### Executing SQL Commands
///
/// - ``execute(sql:)``
///
/// ### Controlling PRAGMA Settings
///
/// - ``get(pragma:)``
/// - ``set(pragma:value:)``
///
/// ### Managing Transactions
///
/// - ``beginTransaction(_:)``
/// - ``commitTransaction()``
/// - ``rollbackTransaction()``
public protocol ConnectionProtocol: AnyObject {
    // MARK: - Connection State
    
    /// The autocommit state of the connection.
    ///
    /// Autocommit is enabled by default and remains active when no explicit transaction is open.
    /// Executing `BEGIN` disables autocommit, while `COMMIT` or `ROLLBACK` re-enables it.
    ///
    /// - Returns: `true` if autocommit mode is active; otherwise, `false`.
    /// - SeeAlso: [Test For Auto-Commit Mode](https://sqlite.org/c3ref/get_autocommit.html)
    var isAutocommit: Bool { get }
    
    /// The read-only state of the connection.
    ///
    /// Returns `true` if the main database allows only read operations, or `false` if it permits
    /// both reading and writing.
    ///
    /// - Returns: `true` if the connection is read-only; otherwise, `false`.
    /// - SeeAlso: [Determine if a database is read-only](https://sqlite.org/c3ref/db_readonly.html)
    var isReadonly: Bool { get }
    
    /// The busy timeout of the connection, in milliseconds.
    ///
    /// Defines how long SQLite waits for a locked database to become available before returning
    /// a `SQLITE_BUSY` error. A value of zero disables the timeout, causing operations to fail
    /// immediately if the database is locked.
    ///
    /// - SeeAlso: [Set A Busy Timeout](https://sqlite.org/c3ref/busy_timeout.html)
    var busyTimeout: Int32 { get set }
    
    // MARK: - PRAGMA Accessors
    
    /// The application identifier stored in the database header.
    ///
    /// Used to distinguish database files created by different applications or file formats. This
    /// value is a 32-bit integer written to the database header and can be queried or modified
    /// through the `PRAGMA application_id` command.
    ///
    /// - SeeAlso: [Application ID](https://sqlite.org/pragma.html#pragma_application_id)
    var applicationID: Int32 { get set }
    
    /// The foreign key enforcement state of the connection.
    ///
    /// When enabled, SQLite enforces foreign key constraints on all tables. This behavior can be
    /// controlled with `PRAGMA foreign_keys`.
    ///
    /// - SeeAlso: [Foreign Keys](https://sqlite.org/pragma.html#pragma_foreign_keys)
    var foreignKeys: Bool { get set }
    
    /// The journal mode used by the database connection.
    ///
    /// Determines how SQLite maintains the rollback journal for transactions.
    ///
    /// - SeeAlso: [Journal Mode](https://sqlite.org/pragma.html#pragma_journal_mode)
    var journalMode: JournalMode { get set }
    
    /// The synchronization mode for database writes.
    ///
    /// Controls how aggressively SQLite syncs data to disk for durability versus performance.
    ///
    /// - SeeAlso: [Synchronous](https://sqlite.org/pragma.html#pragma_synchronous)
    var synchronous: Synchronous { get set }
    
    /// The user-defined schema version number.
    ///
    /// This value is stored in the database header and can be used by applications to track schema
    /// migrations or format changes.
    ///
    /// - SeeAlso: [User Version](https://sqlite.org/pragma.html#pragma_user_version)
    var userVersion: Int32 { get set }
    
    // MARK: - SQLite Lifecycle
    
    /// Initializes the SQLite library.
    ///
    /// Sets up the global state required by SQLite, including operating-system–specific
    /// initialization. This function must be called before using any other SQLite API,
    /// unless the library is initialized automatically.
    ///
    /// Only the first invocation during the process lifetime, or the first after
    /// ``shutdown()``, performs real initialization. All subsequent calls are no-ops.
    ///
    /// - Note: Workstation applications normally do not need to call this function explicitly,
    ///   as it is invoked automatically by interfaces such as `sqlite3_open()`. It is mainly
    ///   intended for embedded systems and controlled initialization scenarios.
    ///
    /// - Throws: ``SQLiteError`` if initialization fails.
    /// - SeeAlso: [Initialize The SQLite Library](https://sqlite.org/c3ref/initialize.html)
    static func initialize() throws(SQLiteError)
    
    /// Shuts down the SQLite library.
    ///
    /// Releases all global resources allocated by SQLite and undoes the effects of a
    /// successful call to ``initialize()``. This function should be called exactly once
    /// for each effective initialization and only after all database connections are closed.
    ///
    /// Only the first invocation since the last call to ``initialize()`` performs
    /// deinitialization. All other calls are harmless no-ops.
    ///
    /// - Note: Workstation applications normally do not need to call this function explicitly,
    ///   as cleanup happens automatically at process termination. It is mainly used in
    ///   embedded systems where precise resource control is required.
    ///
    /// - Important: This function is **not** threadsafe and must be called from a single thread.
    /// - Throws: ``SQLiteError`` if the shutdown process fails.
    /// - SeeAlso: [Initialize The SQLite Library](https://sqlite.org/c3ref/initialize.html)
    static func shutdown() throws(SQLiteError)
    
    // MARK: - Encryption
    
    /// Applies an encryption key to a database connection.
    ///
    /// If the database is newly created, this call initializes encryption and makes it encrypted.
    /// If the database already exists, this call decrypts its contents for access using the
    /// provided key. An existing unencrypted database cannot be encrypted using this method.
    ///
    /// This function must be called immediately after the connection is opened and before invoking
    /// any other operation on the same connection.
    ///
    /// - Parameters:
    ///   - key: The encryption key to apply.
    ///   - name: The database name, or `nil` for the main database.
    /// - Throws: ``SQLiteError`` if the key is invalid or the decryption process fails.
    /// - SeeAlso: [Setting The Key](https://www.zetetic.net/sqlcipher/sqlcipher-api/#key)
    func apply(_ key: Connection.Key, name: String?) throws(SQLiteError)
    
    /// Changes the encryption key for an open database.
    ///
    /// Re-encrypts the database file with a new key while preserving its existing data. The
    /// connection must already be open and unlocked with a valid key applied through
    /// ``apply(_:name:)``. This operation replaces the current encryption key but does not modify
    /// the database contents.
    ///
    /// This function can only be used with an encrypted database. It has no effect on unencrypted
    /// databases.
    ///
    /// - Parameters:
    ///   - key: The new encryption key to apply.
    ///   - name: The database name, or `nil` for the main database.
    /// - Throws: ``SQLiteError`` if rekeying fails or encryption is not supported.
    /// - SeeAlso: [Changing The Key](https://www.zetetic.net/sqlcipher/sqlcipher-api/#Changing_Key)
    func rekey(_ key: Connection.Key, name: String?) throws(SQLiteError)
    
    // MARK: - Delegation
    
    /// Adds a delegate to receive connection-level events.
    ///
    /// Registers an object conforming to ``ConnectionDelegate`` to receive notifications such as
    /// update actions and transaction events.
    ///
    /// - Parameter delegate: The delegate to add.
    func add(delegate: ConnectionDelegate)
    
    /// Removes a previously added delegate.
    ///
    /// Unregisters an object that was previously added with ``add(delegate:)`` so it no longer
    /// receives update and transaction events.
    ///
    /// - Parameter delegate: The delegate to remove.
    func remove(delegate: ConnectionDelegate)
    
    /// Adds a delegate to receive SQL trace callbacks.
    ///
    /// Registers an object conforming to ``ConnectionTraceDelegate`` to observe SQL statements as
    /// they are executed by the connection.
    ///
    /// - Parameter delegate: The trace delegate to add.
    func add(trace delegate: ConnectionTraceDelegate)
    
    /// Removes a previously added trace delegate.
    ///
    /// Unregisters an object that was previously added with ``add(trace:)`` so it no longer
    /// receives SQL trace callbacks.
    ///
    /// - Parameter delegate: The trace delegate to remove.
    func remove(trace delegate: ConnectionTraceDelegate)
    
    // MARK: - Custom SQL Functions
    
    /// Registers a custom SQLite function with the current connection.
    ///
    /// The specified function type must be a subclass of ``Function/Scalar`` or
    /// ``Function/Aggregate``. Once registered, the function becomes available in SQL queries
    /// executed through this connection.
    ///
    /// - Parameter function: The custom function type to register.
    /// - Throws: ``SQLiteError`` if registration fails.
    func add(function: Function.Type) throws(SQLiteError)
    
    /// Unregisters a previously registered custom SQLite function.
    ///
    /// The specified function type must match the one used during registration. After removal,
    /// the function will no longer be available for use in SQL statements.
    ///
    /// - Parameter function: The custom function type to unregister.
    /// - Throws: ``SQLiteError`` if the function could not be unregistered.
    func remove(function: Function.Type) throws(SQLiteError)
    
    // MARK: - Statement Preparation
    
    /// Prepares an SQL statement for execution.
    ///
    /// Compiles the provided SQL query into a prepared statement associated with this connection.
    /// Use the returned statement to bind parameters and execute queries safely and efficiently.
    ///
    /// - Parameter query: The SQL query to prepare.
    /// - Returns: A compiled statement ready for execution.
    /// - Throws: ``SQLiteError`` if the statement could not be prepared.
    ///
    /// - SeeAlso: [Compiling An SQL Statement](https://sqlite.org/c3ref/prepare.html)
    func prepare(sql query: String) throws(SQLiteError) -> StatementProtocol
    
    /// Prepares an SQL statement with custom compilation options.
    ///
    /// Similar to ``prepare(sql:)`` but allows specifying additional compilation flags through
    /// ``Statement/Options`` to control statement creation behavior.
    ///
    /// - Parameters:
    ///   - query: The SQL query to prepare.
    ///   - options: Additional compilation options.
    /// - Returns: A compiled statement ready for execution.
    /// - Throws: ``SQLiteError`` if the statement could not be prepared.
    ///
    /// - SeeAlso: [Compiling An SQL Statement](https://sqlite.org/c3ref/prepare.html)
    func prepare(
        sql query: String, options: Statement.Options
    ) throws(SQLiteError) -> StatementProtocol
    
    // MARK: - SQL Execution
    
    /// Executes one or more SQL statements in a single step.
    ///
    /// The provided SQL string may contain one or more statements separated by semicolons.
    /// Each statement is compiled and executed sequentially within the current connection.
    /// This method is suitable for operations that do not produce result sets, such as
    /// `CREATE TABLE`, `INSERT`, `UPDATE`, or `PRAGMA`.
    ///
    /// Execution stops at the first error, and the corresponding ``SQLiteError`` is thrown.
    ///
    /// - Parameter script: The SQL text containing one or more statements to execute.
    /// - Throws: ``SQLiteError`` if any statement fails to execute.
    ///
    /// - SeeAlso: [One-Step Query Execution Interface](https://sqlite.org/c3ref/exec.html)
    func execute(sql script: String) throws(SQLiteError)
    
    // MARK: - PRAGMA Control
    
    /// Reads the current value of a database PRAGMA.
    ///
    /// Retrieves the value of the specified PRAGMA and attempts to convert it to the provided
    /// generic type `T`. This method is typically used for reading configuration or status values
    /// such as `journal_mode`, `foreign_keys`, or `user_version`.
    ///
    /// If the PRAGMA query succeeds but the value cannot be converted to the requested type,
    /// the method returns `nil` instead of throwing an error.
    ///
    /// - Parameter pragma: The PRAGMA to query.
    /// - Returns: The current PRAGMA value, or `nil` if the result is empty or conversion fails.
    /// - Throws: ``SQLiteError`` if the PRAGMA query itself fails.
    ///
    /// - SeeAlso: [PRAGMA Statements](https://sqlite.org/pragma.html)
    func get<T: SQLiteRepresentable>(pragma: Pragma) throws(SQLiteError) -> T?
    
    /// Sets a database PRAGMA value.
    ///
    /// Assigns the specified value to the given PRAGMA. This can be used to change runtime
    /// configuration parameters, such as `foreign_keys`, `journal_mode`, or `synchronous`.
    ///
    /// - Parameters:
    ///   - pragma: The PRAGMA to set.
    ///   - value: The value to assign to the PRAGMA.
    /// - Throws: ``SQLiteError`` if the assignment fails.
    ///
    /// - SeeAlso: [PRAGMA Statements](https://sqlite.org/pragma.html)
    func set<T: SQLiteRepresentable>(pragma: Pragma, value: T) throws(SQLiteError)
    
    // MARK: - Transactions
    
    /// Begins a new transaction of the specified type.
    ///
    /// Starts an explicit transaction using the given ``TransactionType``. If a transaction is
    /// already active, this method throws an error.
    ///
    /// - Parameter type: The transaction type to begin.
    /// - Throws: ``SQLiteError`` if the transaction could not be started.
    ///
    /// - SeeAlso: [Transaction](https://sqlite.org/lang_transaction.html)
    func beginTransaction(_ type: TransactionType) throws(SQLiteError)
    
    /// Commits the current transaction.
    ///
    /// Makes all changes made during the transaction permanent. If no transaction is active, this
    /// method has no effect.
    ///
    /// - Throws: ``SQLiteError`` if the commit operation fails.
    ///
    /// - SeeAlso: [Transaction](https://sqlite.org/lang_transaction.html)
    func commitTransaction() throws(SQLiteError)
    
    /// Rolls back the current transaction.
    ///
    /// Reverts all changes made during the transaction. If no transaction is active, this method
    /// has no effect.
    ///
    /// - Throws: ``SQLiteError`` if the rollback operation fails.
    ///
    /// - SeeAlso: [Transaction](https://sqlite.org/lang_transaction.html)
    func rollbackTransaction() throws(SQLiteError)
}

// MARK: - Default Implementation

public extension ConnectionProtocol {
    var busyTimeout: Int32 {
        get { try! get(pragma: .busyTimeout) ?? 0 }
        set { try! set(pragma: .busyTimeout, value: newValue) }
    }
    
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
    
    func prepare(sql query: String) throws(SQLiteError) -> StatementProtocol {
        try prepare(sql: query, options: [])
    }
    
    func get<T: SQLiteRepresentable>(pragma: Pragma) throws(SQLiteError) -> T? {
        let stmt = try prepare(sql: "PRAGMA \(pragma)")
        switch try stmt.step() {
        case true: return stmt.columnValue(at: 0)
        case false: return nil
        }
    }
    
    func set<T: SQLiteRepresentable>(pragma: Pragma, value: T) throws(SQLiteError) {
        let query = "PRAGMA \(pragma) = \(value.sqliteLiteral)"
        try prepare(sql: query).step()
    }
    
    func beginTransaction(_ type: TransactionType = .deferred) throws(SQLiteError) {
        try prepare(sql: "BEGIN \(type) TRANSACTION", options: []).step()
    }
    
    func commitTransaction() throws(SQLiteError) {
        try prepare(sql: "COMMIT TRANSACTION", options: []).step()
    }
    
    func rollbackTransaction() throws(SQLiteError) {
        try prepare(sql: "ROLLBACK TRANSACTION", options: []).step()
    }
}
