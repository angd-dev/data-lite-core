import Foundation
import DataLiteC

/// A class representing a connection to an SQLite database.
///
/// ## Overview
///
/// The `Connection` class manages the connection to an SQLite database. It provides an interface
/// for preparing SQL queries, managing transactions, and handling errors. This class serves as the
/// main object for interacting with the database.
///
/// ## Opening a New Connection
///
/// Use the ``init(location:options:)`` initializer to open a database connection. Specify the
/// database's location using the ``Location`` parameter and configure connection settings with the
/// ``Options`` parameter.
///
/// ```swift
/// do {
///     let connection = try Connection(
///         location: .file(path: "~/example.db"),
///         options: [.readwrite, .create]
///     )
///     print("Connection established")
/// } catch {
///     print("Failed to connect: \(error)")
/// }
/// ```
///
/// ## Closing the Connection
///
/// The `Connection` class automatically closes the database connection when the object is
/// deallocated (`deinit`). This ensures proper cleanup even if the object goes out of scope.
///
/// ## Delegate
///
/// The `Connection` class can optionally use a delegate to handle specific events during the
/// connection lifecycle, such as tracing SQL statements or responding to transaction actions. The
/// delegate must conform to the ``ConnectionDelegate`` protocol, which provides methods for
/// handling these events.
///
/// ## Custom SQL Functions
///
/// The `Connection` class allows you to add custom SQL functions using subclasses of ``Function``.
/// You can create either **scalar** functions (which return a single value) or **aggregate**
/// functions (which perform operations across multiple rows). Both types can be used directly in
/// SQL queries.
///
/// To add or remove custom functions, use the ``add(function:)`` and ``remove(function:)`` methods
/// of the `Connection` class.
///
/// ## Preparing SQL Statements
///
/// The  `Connection`  class provides functionality for preparing SQL statements that can be
/// executed multiple times with different parameter values. The  ``prepare(sql:options:)``  method
/// takes a SQL query as a string and an optional  ``Statement/Options``  parameter to configure
/// the behavior of the statement. It returns a  ``Statement``  object that can be executed.
///
/// ```swift
/// do {
///     let statement = try connection.prepare(
///         sql: "SELECT * FROM users WHERE age > ?",
///         options: [.persistent]
///     )
///     // Bind parameters and execute the statement
/// } catch {
///     print("Error preparing statement: \(error)")
/// }
/// ```
///
/// ## Executing SQL Scripts
///
/// The `Connection` class allows you to execute a series of SQL statements using the ``SQLScript``
/// structure. The ``SQLScript`` structure is designed to load and process multiple SQL queries
/// from a file, URL, or string.
///
/// You can create an instance of ``SQLScript`` with the SQL script content and then pass it to the
/// ``execute(sql:)`` method of the `Connection` class to execute the script.
///
/// ```swift
/// let script: SQLScript = """
/// CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);
/// INSERT INTO users (name) VALUES ('Alice');
/// INSERT INTO users (name) VALUES ('Bob');
/// """
///
/// do {
///     try connection.execute(sql: script)
///     print("Script executed successfully")
/// } catch {
///     print("Error executing script: \(error)")
/// }
/// ```
///
/// ## Transaction Handling
///
/// By default, the `Connection` class operates in **autocommit mode**, where each SQL statement is
/// automatically committed after execution. In this mode, each statement is treated as a separate
/// transaction, eliminating the need for explicit transaction management. To determine whether the
/// connection is in autocommit mode, use the ``isAutocommit`` property.
///
/// For manual transaction management, use ``beginTransaction(_:)`` to start a transaction, and
/// ``commitTransaction()`` or ``rollbackTransaction()`` to either commit or roll back the
/// transaction.
///
/// ```swift
/// do {
///     try connection.beginTransaction()
///     try connection.execute(sql: "INSERT INTO users (name) VALUES ('Alice')")
///     try connection.execute(sql: "INSERT INTO users (name) VALUES ('Bob')")
///     try connection.commitTransaction()
///     print("Transaction committed successfully")
/// } catch {
///     try? connection.rollbackTransaction()
///     print("Error during transaction: \(error)")
/// }
/// ```
///
/// Learn more in the [SQLite Transaction Documentation](https://www.sqlite.org/lang_transaction.html).
///
/// ## Error Handling
///
/// The `Connection` class uses Swift's throwing mechanism to handle errors. Errors in database
/// operations are propagated using `throws`, allowing you to catch and handle specific issues in
/// your application.
///
/// SQLite-related errors, such as invalid SQL queries, connection failures, or issues with
/// transaction management, throw an ``SQLiteError`` struct. These errors conform to the `Error`
/// protocol, and you can handle them using Swift's `do-catch` syntax to manage exceptions in your
/// code.
///
/// ```swift
/// do {
///     let statement = try connection.prepare(
///         sql: "SELECT * FROM users WHERE age > ?",
///         options: []
///     )
/// } catch let error as SQLiteError {
///     print("SQLite error: \(error.mesg), Code: \(error.code)")
/// } catch {
///     print("Unexpected error: \(error)")
/// }
/// ```
///
/// ## Multithreading
///
/// The `Connection` class supports multithreading, but its behavior depends on the selected
/// thread-safety mode. You can configure the desired mode using the ``Options`` parameter in the
/// ``init(location:options:)`` method.
///
/// **Multi-thread** (``Options/nomutex``): This mode allows SQLite to be used across multiple
/// threads. However, it requires that no `Connection` instance or its derived objects (e.g.,
/// prepared statements) are accessed simultaneously by multiple threads.
///
/// ```swift
/// let connection = try Connection(
///     location: .file(path: "~/example.db"),
///     options: [.readwrite, .nomutex]
/// )
/// ```
///
/// **Serialized** (``Options/fullmutex``): In this mode, SQLite uses internal mutexes to ensure
/// thread safety. This allows multiple threads to safely share `Connection` instances and their
/// derived objects.
///
/// ```swift
/// let connection = try Connection(
///     location: .file(path: "~/example.db"),
///     options: [.readwrite, .fullmutex]
/// )
/// ```
///
/// - Important: The `Connection` class does not include built-in synchronization for shared
///   resources. Developers must implement custom synchronization mechanisms, such as using
///   `DispatchQueue`, when sharing resources across threads.
///
/// For more details, see the [Using SQLite in Multi-Threaded Applications](https://www.sqlite.org/threadsafe.html).
///
/// ## Encryption
///
/// The `Connection` class supports transparent encryption and re-encryption of databases using the
/// ``apply(_:name:)`` and ``rekey(_:name:)`` methods. This allows sensitive data to be securely
/// stored on disk.
///
/// ### Applying an Encryption Key
///
/// To open an encrypted database or encrypt a new one, call ``apply(_:name:)`` immediately after
/// initializing the connection, and before executing any SQL statements.
///
/// ```swift
/// let connection = try Connection(
///     path: "~/secure.db",
///     options: [.readwrite, .create]
/// )
/// try connection.apply(Key.passphrase("secret-password"))
/// ```
///
/// - If the database is already encrypted, the key must match the one previously used.
/// - If the database is unencrypted, applying a key will encrypt it on first write.
///
/// You can use either a **passphrase**, which is internally transformed into a key, or a **raw key**:
///
/// ```swift
/// try connection.apply(Key.raw(data: rawKeyData))
/// ```
///
/// - Important: The encryption key must be applied *before* any SQL queries are executed.
///   Otherwise, the database may remain unencrypted or unreadable.
///
/// ### Rekeying the Database
///
/// To change the encryption key of an existing database, you must first apply the current key using
/// ``apply(_:name:)``, then call ``rekey(_:name:)`` with the new key.
///
/// ```swift
/// let connection = try Connection(
///     path: "~/secure.db",
///     options: [.readwrite]
/// )
/// try connection.apply(Key.passphrase("old-password"))
/// try connection.rekey(Key.passphrase("new-password"))
/// ```
///
/// - Important: ``rekey(_:name:)`` requires that the correct current key has already been applied
///   via ``apply(_:name:)``. If the wrong key is used, the operation will fail with an error.
///
/// ### Attached Databases
///
/// Both ``apply(_:name:)`` and ``rekey(_:name:)`` accept an optional `name` parameter to operate
/// on an attached database. If omitted, they apply to the main database.
///
/// ## Topics
///
/// ### Initializers
///
/// - ``init(location:options:)``
/// - ``init(path:options:)``
///
/// - ``Options``
/// - ``Location``
///
/// ### Delegates
///
/// - ``delegate``
/// - ``ConnectionDelegate``
///
/// ### Instance Properties
///
/// - ``isAutocommit``
/// - ``isReadonly``
/// - ``busyTimeout``
///
/// ### PRAGMA Properties
///
/// - ``applicationID``
/// - ``foreignKeys``
/// - ``journalMode``
/// - ``synchronous``
/// - ``userVersion``
///
/// ### Initialize SQLite Library
///
/// - ``initialize()``
/// - ``shutdown()``
///
/// ### Manage Custom SQL Functions
///
/// - ``add(function:)``
/// - ``remove(function:)``
///
/// ### Preparing SQL Statement
///
/// - ``prepare(sql:options:)``
///
/// ### Executing SQL Script
///
/// - ``execute(sql:)``
///
/// ### Executing PRAGMA Queries
///
/// - ``get(pragma:)``
/// - ``set(pragma:value:)``
///
/// ### Transaction Methods
///
/// - ``beginTransaction(_:)``
/// - ``commitTransaction()``
/// - ``rollbackTransaction()``
///
/// ### Encryption
///
/// - ``apply(_:name:)``
/// - ``rekey(_:name:)``
///
/// - ``Key``
public final class Connection {
    // MARK: - Private Properties
    
    /// The low-level SQLite connection pointer.
    ///
    /// This property holds a reference to the underlying SQLite connection (`OpaquePointer`) used for
    /// executing SQL queries and managing the database. It serves as a direct link between the high-level
    /// ``Connection`` class and the SQLite C API.
    ///
    /// - Note: This pointer should only be accessed internally by the ``Connection`` class and its methods,
    /// as it represents the raw connection handle to the SQLite database.
    private let connection: OpaquePointer
    
    /// The location of the database file or in-memory database.
    ///
    /// This property holds the ``Location`` where the database is stored. The ``Location`` can represent
    /// either a path to a file-based database or an in-memory database. This allows the `Connection`
    /// to manage different types of databases seamlessly.
    ///
    /// - SeeAlso: The ``Location`` type, which defines the possible locations for an SQLite database.
    private let location: Location
    
    /// A collection of custom SQLite functions.
    ///
    /// This property holds an array of custom SQLite functions that are associated with the connection.
    /// Each function conforms to the `Function.Type` and is registered with SQLite to extend its capabilities.
    ///
    /// - Note: Functions in SQLite can be used to perform custom computations, and they are registered
    /// using the SQLite C API. The `functions` array allows the `Connection` to keep track of all custom
    /// functions that are active within the connection.
    private var functions = [Function.Type]()
    
    // MARK: - Delegates
    
    /// The delegate that receives notifications about various database events.
    ///
    /// The `delegate` can be any object that conforms to the ``ConnectionDelegate`` protocol. By
    /// attaching a delegate, you can monitor and respond to database actions such as SQL statement
    /// tracing, updates (inserts, deletes, and modifications), and transaction events (commits and rollbacks).
    ///
    /// - Note: The delegate is marked as `weak` to avoid retain cycles and memory leaks. This ensures that
    /// the `Connection` does not strongly hold onto the delegate, allowing for proper memory management
    /// and the release of both the ``Connection`` and its delegate when needed.
    public weak var delegate: ConnectionDelegate?
    
    // MARK: - Instance Properties
    
    /// A Boolean value indicating whether the database connection is in autocommit mode.
    ///
    /// This property returns `true` if the SQLite database connection is currently in autocommit mode,
    /// meaning that every individual SQL statement is automatically committed without the need for an explicit
    /// `COMMIT` command. If autocommit mode is disabled (typically within a transaction), this property returns `false`.
    ///
    /// ### Usage Example
    ///
    /// ```swift
    /// let connection = try Connection(
    ///     path: "~/example.db",
    ///     options: .readwrite
    /// )
    /// // Output: true or false, depending on the transaction state
    /// print(connection.isAutocommit)
    /// ```
    ///
    /// - Returns: `true` if the connection is in autocommit mode, otherwise `false`.
    public var isAutocommit: Bool {
        sqlite3_get_autocommit(connection) != 0
    }
    
    /// A Boolean value indicating whether the database connection is read-only.
    ///
    /// This property returns `true` if the SQLite database connection to the specified database
    /// file is in read-only mode. If the database is opened with read-write permissions, this property
    /// returns `false`.
    ///
    /// ### Usage Example
    ///
    /// ```swift
    /// let connection = try Connection(
    ///     path: "~/example.db",
    ///     options: .readwrite
    /// )
    /// // Output: false if opened with read-write permissions
    /// print(connection.isReadonly)
    /// ```
    ///
    /// - Returns: `true` if the database is in read-only mode, otherwise `false`.
    public var isReadonly: Bool {
        sqlite3_db_readonly(connection, location.path) == 1
    }
    
    /// The busy timeout duration in milliseconds for the database connection.
    ///
    /// This property sets the amount of time (in milliseconds) the SQLite library will wait when a table
    /// is locked before returning an error. If the value is greater than 0, SQLite will sleep for the
    /// specified time when a table is locked. If the table remains locked, SQLite will retry the operation
    /// until the total wait time reaches the specified value. Setting the value to 0 disables the busy timeout,
    /// meaning SQLite will return immediately if it encounters a locked database.
    ///
    /// The default value is 0, indicating no busy timeout is set.
    ///
    /// - Note: There can only be one busy handler for a database connection at a time. Setting this property
    /// clears any previously set busy handler.
    ///
    /// ### Example Usage
    ///
    /// ```swift
    /// let connection = try Connection(
    ///     path: "~/example.db",
    ///     options: .readwrite
    /// )
    /// // Set busy timeout to 5 seconds
    /// connection.busyTimeout = 5000
    /// ```
    ///
    /// If a table is locked for over 5 seconds, SQLite will return `SQLITE_BUSY`.
    public var busyTimeout: Int32 = 0 {
        didSet { sqlite3_busy_timeout(connection, busyTimeout) }
    }
    
    // MARK: - PRAGMA Properties
    
    /// Represents the application identifier stored in the database header.
    ///
    /// This property allows reading and setting a 32-bit signed integer that uniquely identifies
    /// the application using the database. It is often used by applications to ensure compatibility
    /// and to provide additional context about the file type.
    public var applicationID: Int32 {
        get { try! get(pragma: .applicationID) ?? 0 }
        set { try! set(pragma: .applicationID, value: newValue) }
    }
    
    /// A Boolean value indicating whether foreign key constraints are enabled.
    ///
    /// This property gets or sets the state of foreign key constraints in the database.
    /// Enabling foreign keys ensures referential integrity between tables.
    public var foreignKeys: Bool {
        get { try! get(pragma: .foreignKeys) ?? false }
        set { try! set(pragma: .foreignKeys, value: newValue) }
    }
    
    /// The journal mode of the database.
    ///
    /// This property gets or sets the journal mode for the database.
    /// The journal mode determines how changes are recorded in the database.
    public var journalMode: SQLiteJournalMode {
        get { try! get(pragma: .journalMode) ?? .off }
        set { try! set(pragma: .journalMode, value: newValue) }
    }
    
    /// The synchronous setting of the database.
    ///
    /// This property gets or sets the synchronous setting for the database.
    /// The synchronous mode determines how transactions are synchronized to disk.
    public var synchronous: SQLiteSynchronous {
        get { try! get(pragma: .synchronous) ?? .off }
        set { try! set(pragma: .synchronous, value: newValue) }
    }
    
    /// The user version number of the database.
    ///
    /// This property gets or sets the user version number for the database.
    /// The user version number can be used to track and manage database schema versions.
    public var userVersion: Int32 {
        get { try! get(pragma: .userVersion) ?? 0 }
        set { try! set(pragma: .userVersion, value: newValue) }
    }
    
    // MARK: - Inits
    
    /// Initializes a new connection to an SQLite database.
    ///
    /// This initializer sets up a connection to the SQLite database at the specified `location`
    /// with the provided `options`. It ensures the necessary directory is created for file-based
    /// databases, and registers several hooks with SQLite for tracing SQL statements, monitoring
    /// database updates, and tracking transaction commits and rollbacks.
    ///
    /// ### Usage Example
    ///
    /// ```swift
    /// do {
    ///     let connection = try Connection(
    ///         location: .file(path: "~/example.db"),
    ///         options: .readwrite
    ///     )
    ///     // Use the connection to execute queries
    /// } catch {
    ///     print("Error establishing connection: \(error)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - location: The ``Location`` where the SQLite database is located. This can either be
    ///     a file path, temporary database or an in-memory database.
    ///   - options: The ``Options`` used to configure the connection, such as whether it is
    ///     read-only, read-write, or supports shared cache mode. Pass the appropriate options
    ///     for how you want to interact with the database.
    ///
    /// - Throws: ``SQLiteError`` if the connection to the database cannot be opened or if an
    ///   error occurs during the setup process. This includes cases such as invalid file paths,
    ///   read/write permission errors, or other SQLite-specific failures.
    ///
    /// - Throws: `Error` if subdirectories for the database file cannot be created. This is
    ///   relevant when the ``Location/file(path:)`` option is used, and the directory path
    ///   cannot be created.
    ///
    /// - Note: If the ``Location/file(path:)`` option is used, and the directory containing
    ///   the database file doesn't exist, it will be created automatically.
    ///
    /// - Note: The initializer sets up SQLite hooks to enable monitoring of SQL execution,
    ///   database changes, and transaction lifecycle events.
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
            self.location = location
            
            let ctx = Unmanaged.passUnretained(self).toOpaque()
            sqlite3_trace_v2(connection, UInt32(SQLITE_TRACE_STMT), traceCallback(_:_:_:_:), ctx)
            sqlite3_update_hook(connection, updateHookCallback(_:_:_:_:_:), ctx)
            sqlite3_commit_hook(connection, commitHookCallback(_:), ctx)
            sqlite3_rollback_hook(connection, rollbackHookCallback(_:), ctx)
        } else {
            let error = SQLiteError(connection)
            sqlite3_close_v2(connection)
            throw error
        }
    }
    
    /// Initializes a new connection to an SQLite database using a file path.
    ///
    /// This convenience initializer sets up a connection to the SQLite database located at the
    /// specified `path` with the provided `options`. It internally calls the main initializer
    /// to manage the connection setup.
    ///
    /// ### Usage Example
    ///
    /// ```swift
    /// do {
    ///     let connection = try Connection(
    ///         path: "~/example.db",
    ///         options: .readwrite
    ///     )
    ///     // Use the connection to execute queries
    /// } catch {
    ///     print("Error establishing connection: \(error)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - path: A `String` representing the file path to the SQLite database.
    ///   - options: The ``Options`` used to configure the connection, such as whether it is
    ///     read-only, read-write, or supports shared cache mode.
    ///
    /// - Throws: ``SQLiteError`` if the connection cannot be opened or if any error
    ///   occurs during setup, including invalid file paths or permission issues.
    ///
    /// - Throws: `Error` if subdirectories for the database file cannot be created.
    ///
    /// - Note: The directory containing the database file will be created automatically if it
    ///   does not exist.
    ///
    /// - Note: The initializer sets up SQLite hooks to enable monitoring of SQL execution,
    ///   database changes, and transaction lifecycle events.
    public convenience init(path: String, options: Options) throws {
        try self.init(location: .file(path: path), options: options)
    }
    
    deinit {
        sqlite3_close_v2(connection)
    }
    
    // MARK: - Initialize SQLite Library
    
    /// Initializes the SQLite library.
    ///
    /// This method initializes the SQLite library, making it ready for use. Although SQLite
    /// automatically initializes itself the first time it is used, you may call this method
    /// explicitly to ensure that it is properly initialized, especially in embedded systems.
    ///
    /// An effective call to `initialize()` is the first invocation during the process's
    /// lifetime, or after a call to ``shutdown()``. Subsequent calls are no-ops and do
    /// not perform any additional initialization.
    ///
    /// ### Usage Example
    ///
    /// ```swift
    /// do {
    ///     try Connection.initialize()
    ///     print("SQLite library initialized successfully.")
    /// } catch {
    ///     print("Failed to initialize SQLite: \(error)")
    /// }
    /// ```
    ///
    /// - Throws: ``SQLiteError``: If the library fails to initialize, an error is thrown with a
    ///   corresponding error code. Common reasons for failure include inability to allocate
    ///   required resources, such as mutexes.
    ///
    /// - Important: This method is thread-safe, meaning it can be called from multiple threads.
    ///
    /// - Note: SQLite automatically initializes itself the first time it is used, so calling this
    ///   function explicitly may not be necessary in many cases. It is recommended to call this
    ///   method only once in your application, ideally during the application startup phase.
    public static func initialize() throws {
        let status = sqlite3_initialize()
        if status != SQLITE_OK {
            throw SQLiteError(code: status, mesg: "")
        }
    }
    
    /// Shuts down the SQLite library.
    ///
    /// This method deallocates all resources that were allocated by ``initialize()``.
    /// It should only be called from a single thread, and you must ensure that all open database
    /// connections are closed and all other SQLite resources are deallocated prior to invoking this
    /// method.
    ///
    /// An effective call to `shutdown()` occurs when it is the first call to this function
    /// since the last successful call to ``initialize()``. Subsequent calls are harmless no-ops
    /// and will not perform any deinitialization.
    ///
    /// ### Usage Example
    ///
    /// ```swift
    /// do {
    ///     try Connection.shutdown()
    ///     print("SQLite library shut down successfully.")
    /// } catch {
    ///     print("Failed to shut down SQLite: \(error)")
    /// }
    /// ```
    ///
    /// - Throws: ``SQLiteError``: If shutting down the SQLite library fails, an error is thrown with a
    ///   corresponding error code. This may occur if resources could not be released properly.
    ///
    /// - Important: This method is not thread-safe. It must only be invoked from a single thread
    /// to avoid undefined behavior.
    ///
    /// - Important: Attempting to call this method while there are still open database connections
    ///   or allocated resources will lead to undefined behavior. Ensure that all database connections
    ///   are closed before calling `shutdown()`.
    ///
    /// - Note: This method is typically unnecessary for workstation applications using SQLite, as
    ///   the library is automatically managed. However, for embedded systems or applications that
    ///   require explicit resource management, calling `shutdown()` ensures that all resources are
    ///   properly released.
    public static func shutdown() throws {
        let status = sqlite3_shutdown()
        if status != SQLITE_OK {
            throw SQLiteError(code: status, mesg: "")
        }
    }
    
    // MARK: - Manage Custom SQL Functions
    
    /// Adds a custom SQLite function to the current database connection.
    ///
    /// This method registers the specified custom function in the SQLite database.
    /// If the function has already been added, no action is taken.
    ///
    /// ### Usage Example
    ///
    /// ```swift
    /// let connection = try Connection(
    ///     path: "~/example.db",
    ///     options: .readwrite
    /// )
    /// try connection.add(
    ///     function: MyCustomFunction.self
    /// )
    /// ```
    ///
    /// - Parameter function: The type of the custom function to be added, which
    ///   must be a subclass of ``Function``.
    ///
    /// - Throws: ``SQLiteError`` if the function installation fails. This may occur if
    ///   the underlying SQLite call to create the function does not succeed.
    public func add(function: Function.Type) throws {
        guard !functions.contains(
            where: { $0 == function }
        ) else { return }
        try function.install(db: connection)
        functions.append(function)
    }
    
    /// Removes a custom SQLite function from the current database connection.
    ///
    /// This method unregisters the specified custom function from the SQLite database.
    /// If the function is not currently registered, no action is taken.
    ///
    /// ### Usage Example
    ///
    /// ```swift
    /// let connection = try Connection(
    ///     path: "~/example.db",
    ///     options: .readwrite
    /// )
    /// try connection.remove(
    ///     function: MyCustomFunction.self
    /// )
    /// ```
    ///
    /// - Parameter function: The type of the custom function to be removed, which
    ///   must be a subclass of ``Function``.
    ///
    /// - Throws: ``SQLiteError`` if the function uninstallation fails. This may occur if
    ///   the underlying SQLite call to remove the function does not succeed.
    public func remove(function: Function.Type) throws {
        guard let function = functions.first(
            where: { $0 == function }
        ) else { return }
        try function.uninstall(db: connection)
        functions.removeAll { $0 == function }
    }
    
    // MARK: - Preparing SQL Statement
    
    /// Prepares an SQL statement with the specified options.
    ///
    /// This method prepares an SQL query string for execution, applying the provided options to control
    /// how the statement is prepared. The options allow specifying flags such as persistent statements
    /// or the exclusion of virtual tables.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let connection = try Connection(
    ///     path: "~/example.db",
    ///     options: .readwrite
    /// )
    /// let statement = try connection.prepare(
    ///     sql: "SELECT * FROM users",
    ///     options: [.persistent]
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - query: The SQL query string to be prepared.
    ///   - options: The set of options to apply when preparing the statement. These options control
    ///     how SQLite handles the statement, such as making it persistent or avoiding virtual tables.
    ///
    /// - Returns: A prepared ``Statement`` object ready for execution.
    ///
    /// - Throws: ``SQLiteError`` if the SQL statement fails to prepare, or if any options are invalid.
    public func prepare(sql query: String, options: Statement.Options = []) throws -> Statement {
        try Statement(db: connection, sql: query, options: options)
    }
    
    // MARK: - Executing SQL Script
    
    /// Executes SQL statements provided in a `SQLScript` instance.
    ///
    /// This function iterates over each SQL statement in the provided ``SQLScript`` instance
    /// and executes them sequentially. Each statement is executed in autocommit mode.
    ///
    /// - Parameter script: The ``SQLScript`` instance containing SQL statements to execute.
    /// - Throws: An ``SQLiteError`` if the SQL preparation or execution fails.
    public func execute(sql script: SQLScript) throws {
        try script.forEach { query in
            let stmt = try prepare(sql: query)
            while try stmt.step() {}
        }
    }
    
    // MARK: - Executing PRAGMA Queries
    
    /// Retrieves a value from the database using a specified PRAGMA statement.
    ///
    /// This function prepares and executes a PRAGMA statement, returning the result as an optional
    /// value of a type that conforms to ``SQLiteRawRepresentable``. If the query returns no result,
    /// `nil` is returned.
    ///
    /// - Parameter pragma: The ``SQLitePragma`` to be executed.
    /// - Returns: An optional value of type `T` containing the result of the PRAGMA statement.
    /// - Throws: An ``SQLiteError`` if the SQL preparation or execution fails.
    public func get<T: SQLiteRawRepresentable>(pragma: SQLitePragma) throws -> T? {
        let query = "PRAGMA \(pragma)"
        let stmt = try prepare(sql: query)
        if try stmt.step() {
            return stmt.columnValue(at: 0)
        } else {
            return nil
        }
    }
    
    /// Sets a value in the database using a specified PRAGMA statement.
    ///
    /// This function prepares and executes a PRAGMA statement to set a specified value.
    /// The function returns an optional value of a type that conforms to
    /// ``SQLiteRawRepresentable``. If the query returns no result, `nil` is returned.
    ///
    /// - Parameter pragma: The ``SQLitePragma`` to be executed.
    /// - Parameter value: The value to be set for the specified PRAGMA,
    ///   conforming to ``SQLiteRawRepresentable``.
    /// - Returns: An optional value of type `T` containing the result of the PRAGMA statement.
    /// - Throws: An ``SQLiteError`` if the SQL preparation or execution fails.
    @discardableResult
    public func set<T: SQLiteRawRepresentable>(pragma: SQLitePragma, value: T) throws -> T? {
        let query = "PRAGMA \(pragma) = \(value.sqliteLiteral)"
        let stmt = try prepare(sql: query)
        if try stmt.step() {
            return stmt.columnValue(at: 0)
        } else {
            return nil
        }
    }
    
    // MARK: - Transaction Methods
    
    /// Begins a transaction with the specified transaction type.
    ///
    /// - Parameter type: The type of transaction to begin. Defaults to `.deferred`.
    /// - Throws: An ``SQLiteError`` if the transaction cannot be initiated.
    public func beginTransaction(_ type: SQLiteTransactionType = .deferred) throws {
        let query = "BEGIN \(type) TRANSACTION"
        try prepare(sql: query).step()
    }
    
    /// Commits the current transaction.
    ///
    /// - Throws: An ``SQLiteError`` if the transaction cannot be committed.
    public func commitTransaction() throws {
        let query = "COMMIT TRANSACTION"
        try prepare(sql: query).step()
    }
    
    /// Rolls back the current transaction.
    ///
    /// - Throws: An ``SQLiteError`` if the transaction cannot be rolled back.
    public func rollbackTransaction() throws {
        let query = "ROLLBACK TRANSACTION"
        try prepare(sql: query).step()
    }
    
    // MARK: - Encryption
    
    /// Applies an encryption key to the opened database connection.
    ///
    /// This method must be called immediately after opening the database and **before** any SQL
    /// statements are executed. If the database is already encrypted, the key must match the one used
    /// during encryption. If the database is unencrypted, the behavior depends on whether the database
    /// contains any data:
    ///
    /// - If the database is empty (e.g. just created), the key will be accepted and encryption will
    ///   be initialized upon first write.
    /// - If the database already contains data, applying a key will cause errors when executing SQL
    ///   statements, because SQLite will attempt to decrypt unencrypted content.
    ///
    /// - Important: This method does **not** encrypt an existing unencrypted database. To encrypt a
    ///   populated unencrypted database, you must perform a manual export (copy) into a new encrypted one.
    ///
    /// - Parameters:
    ///   - key: The encryption key to apply. This can be a passphrase or raw key, depending on how
    ///     the ``Key`` instance is constructed.
    ///   - name: The name of the target database (used for attached databases). Defaults to `nil`
    ///     for the main database.
    /// - Throws: ``SQLiteError`` if the key application fails.
    public func apply(_ key: Key, name: String? = nil) throws {
        let status = if let name {
            sqlite3_key_v2(connection, name, key.keyValue, key.length)
        } else {
            sqlite3_key(connection, key.keyValue, key.length)
        }
        if status != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    /// Changes the encryption key of the connected database.
    ///
    /// This method re-encrypts the database using a new key. You must first apply the current
    /// encryption key using ``apply(_:name:)``. If the current key was not applied or is incorrect,
    /// rekeying will fail.
    ///
    /// - Parameters:
    ///   - key: The new encryption key to use. This can be a passphrase or raw key, depending on how
    ///     the ``Key`` instance is constructed.
    ///   - name: The name of the target database (used for attached databases). Defaults to `nil`
    ///     for the main database.
    /// - Throws: ``SQLiteError`` if rekeying fails.
    public func rekey(_ key: Key, name: String? = nil) throws {
        let status = if let name {
            sqlite3_rekey_v2(connection, name, key.keyValue, key.length)
        } else {
            sqlite3_rekey(connection, key.keyValue, key.length)
        }
        if status != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
}

// MARK: - Functions

/// Callback function for tracing SQL statements executed by SQLite.
///
/// This function serves as a tracing mechanism for SQL statements executed within a SQLite database.
/// It is invoked during SQL execution to extract both the unexpanded and expanded forms of the SQL
/// statement, notifying the `Connection`'s delegate if one exists. The delegate is expected to
/// implement the `connection(_:trace:)` method to handle tracing events.
///
/// This callback is registered with SQLite to trace queries, especially during debugging or logging.
/// It extracts the unexpanded SQL (as written by the developer) and the expanded SQL (with parameters
/// filled in) and passes these to the delegate through the `connection(_:trace:)` method.
///
/// The unexpanded SQL comes from the `x` parameter, while the expanded SQL is obtained by calling
/// `sqlite3_expanded_sql()` on the statement. Both are passed to the delegate as a tuple in the order
/// `(expandedSQL, unexpandedSQL)`.
///
/// - Parameters:
///   - flag: A tracing flag that indicates the tracing operation type. This value is not directly
///     used in this function but can be used to further customize tracing behavior if needed.
///   - ctx: A context pointer that references the `Connection` instance, allowing access to the
///     delegate and associated tracing logic.
///   - p: A pointer to the SQLite statement being executed (`sqlite3_stmt*`), used to retrieve
///     the expanded SQL query.
///   - x: A pointer to additional information (`CChar*`), which contains the unexpanded SQL string.
///
/// - Returns: An SQLite result code indicating success or failure. The function always returns `SQLITE_OK`
///   to indicate that tracing completed successfully, even if no tracing logic is implemented.
///
/// - Important: The `ConnectionDelegate` must implement `connection(_:trace:)` to receive the
///   traced SQL. If no delegate is assigned, tracing is effectively ignored.
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

/// Callback function for update notifications triggered by SQLite.
///
/// This function is registered as an update hook with SQLite and is called whenever an
/// insert, update, or delete operation occurs in the database. It provides information about
/// the affected database, table, and the row that was modified. If the `Connection` has a
/// delegate, this callback informs the delegate about the specific type of update action that
/// took place, using the ``SQLiteAction`` enum.
///
/// This function extracts the database and table names, along with the row ID, from the
/// provided C-style strings and integer values. It then determines the type of update action
/// (insert, update, or delete) based on the `action` parameter and creates a corresponding
/// ``SQLiteAction`` enum case. The update information is passed to the ``ConnectionDelegate`` via
/// the `connection(_:didUpdate:)` method.
///
/// The function is used internally by the `Connection` class to monitor database changes
/// and notify any registered delegate about these changes.
///
/// - Parameters:
///   - ctx: A context pointer that refers to the `Connection` instance. This is used to
///     access the delegate and notify it about the update event.
///   - action: The type of update action that occurred, represented as an `Int32`. This value
///     corresponds to the constants `SQLITE_INSERT`, `SQLITE_UPDATE`, or `SQLITE_DELETE`.
///   - dName: A pointer to the name of the affected database (as a C-style string).
///   - tName: A pointer to the name of the affected table (as a C-style string).
///   - rowID: The row ID of the affected row, which is a 64-bit integer (`sqlite3_int64`).
///
/// - Important: This function expects the `Connection`'s delegate to implement
/// `connection(_:didUpdate:)` to handle the notification of updates. If no delegate is assigned,
/// the update information is ignored.
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

/// Callback function for committing transactions.
///
/// This function is registered as a commit hook in SQLite and is called when a transaction
/// is about to be committed. It provides a way to notify the connection's delegate that the
/// transaction has been successfully committed. If the delegate throws an error during the commit
/// process, the COMMIT operation is converted into a ROLLBACK, which ensures data integrity.
///
/// This function is used internally by the `Connection` class to handle commit events from SQLite.
/// If a delegate is attached to the `Connection`, it calls the `connectionDidCommit(_:)` method
/// on the delegate. If the delegate throws an error during this process, the commit operation
/// is aborted, and SQLite will roll back the transaction.
///
/// The purpose of this callback is to give the delegate an opportunity to validate or log the
/// transaction before it is permanently committed. This can be useful for enforcing business rules,
/// auditing, or other validation tasks.
///
/// - Parameter ctx: A context pointer that refers to the `Connection` instance. This is used
///   to access the delegate and notify it about the commit event.
///
/// - Returns: An SQLite result code. If the commit is successful, `SQLITE_OK` is returned. If the
///   delegate throws an error, `SQLITE_ERROR` is returned, which causes the transaction to be rolled back.
///
/// - Throws: If the delegate throws an error, the commit process is aborted, and SQLite
///   will perform a rollback instead of a commit.
///
/// - Note: Returning `SQLITE_ERROR` will cause SQLite to roll back the transaction.
///   Ensure that any errors thrown within the `connectionDidCommit(_:)` method
///   are handled properly, as this will affect the commit process.
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

/// Callback function for rolling back transactions.
///
/// This function is registered as a rollback hook in SQLite and is called when a transaction
/// is rolled back. It provides a way to notify the connection's delegate that the transaction
/// was not completed and has been reverted.
///
/// This function is used internally by the `Connection` class to handle rollback events from SQLite.
/// If a delegate is attached to the `Connection`, it calls the `connectionDidRollback(_:)` method
/// on the delegate. This can be used to handle rollback scenarios such as logging, reverting application state,
/// or taking corrective action in response to the failed transaction.
///
/// The purpose of this callback is to give the delegate an opportunity to react when a transaction is
/// rolled back. This could be due to an explicit rollback command or as a result of an error that caused
/// SQLite to undo the changes made in the current transaction.
///
/// - Parameter ctx: A context pointer that refers to the `Connection` instance.
///   This is used to access the delegate and notify it about the rollback event.
///
/// - Note: A rollback means the changes made in the current transaction are undone, and the database
///   is restored to the state before the transaction started. It is crucial for the delegate
///   to handle this event if the application maintains any in-memory state related to the transaction.
private func rollbackHookCallback(_ ctx: UnsafeMutableRawPointer?) {
    guard let ctx = ctx else { return }
    let connection = Unmanaged<Connection>
        .fromOpaque(ctx)
        .takeUnretainedValue()
    if let delegate = connection.delegate {
        delegate.connectionDidRollback(connection)
    }
}
