import Foundation
import DataLiteC

extension Connection {
    /// Options for controlling the connection to a SQLite database.
    ///
    /// This type represents a set of options that can be used when opening a connection to a
    /// SQLite database. Each option corresponds to one of the flags defined in the SQLite
    /// library. For more details, read [Opening A New Database Connection](https://www.sqlite.org/c3ref/open.html).
    ///
    /// ### Usage
    ///
    /// ```swift
    /// do {
    ///     let dbFilePath = "path/to/your/database.db"
    ///     let options: Connection.Options = [.readwrite, .create]
    ///     let connection = try Connection(path: dbFilePath, options: options)
    ///     print("Database connection established successfully!")
    /// } catch {
    ///     print("Error opening database: \(error)")
    /// }
    /// ```
    ///
    /// ## Topics
    ///
    /// ### Initializers
    ///
    /// - ``init(rawValue:)``
    ///
    /// ### Instance Properties
    ///
    /// - ``rawValue``
    ///
    /// ### Type Properties
    ///
    /// - ``readonly``
    /// - ``readwrite``
    /// - ``create``
    /// - ``uri``
    /// - ``memory``
    /// - ``nomutex``
    /// - ``fullmutex``
    /// - ``sharedcache``
    /// - ``privatecache``
    /// - ``exrescode``
    /// - ``nofollow``
    public struct Options: OptionSet, Sendable {
        // MARK: - Properties
        
        /// An integer value representing a combination of option flags.
        ///
        /// This property holds the raw integer representation of the selected options for the
        /// SQLite database connection. Each option corresponds to a specific flag defined in the
        /// SQLite library, allowing for a flexible and efficient way to specify multiple options
        /// using bitwise operations. The value can be combined using the bitwise OR operator (`|`).
        ///
        /// ```swift
        /// let options = [
        ///     Connection.Options.readonly,
        ///     Connection.Options.create
        /// ]
        /// ```
        ///
        /// In this example, the `rawValue` will represent a combination of the ``readonly`` and ``create`` options.
        ///
        /// - Important: When combining options, ensure that the selected flags are compatible and do not conflict,
        ///   as certain combinations may lead to unexpected behavior. For example, setting both ``readonly`` and
        ///   ``readwrite`` is not allowed.
        public var rawValue: Int32
        
        // MARK: - Instances
        
        /// Option: open the database for read-only access.
        ///
        /// This option configures the SQLite database connection to be opened in read-only mode. When this
        /// option is specified, the database can be accessed for querying, but any attempts to modify the
        /// data (such as inserting, updating, or deleting records) will result in an error. If the specified
        /// database file does not already exist, an error will also be returned.
        ///
        /// This is particularly useful when you want to ensure that your application does not accidentally
        /// modify the database, or when you need to work with a database that is being shared among multiple
        /// processes or applications that require read-only access.
        ///
        /// ### Usage
        ///
        /// You can specify the `readonly` option when opening a database connection, as shown in the example:
        ///
        /// ```swift
        /// let options: Connection.Options = [.readonly]
        /// let connection = try Connection(path: dbFilePath, options: options)
        /// ```
        ///
        /// ### Important Notes
        ///
        /// - Note: If you attempt to write to a read-only database, an error will be thrown.
        ///
        /// - Note: Ensure that the database file exists before opening it in read-only mode, as the connection
        ///   will fail if the file does not exist.
        ///
        /// For more details, refer to the SQLite documentation on
        /// [opening a new database connection](https://www.sqlite.org/c3ref/open.html).
        public static let readonly = Self(rawValue: SQLITE_OPEN_READONLY)
        
        /// Option: open the database for reading and writing.
        ///
        /// This option configures the SQLite database connection to be opened in read-write mode. When this
        /// option is specified, the database can be accessed for both querying and modifying data. This means
        /// you can perform operations such as inserting, updating, or deleting records in addition to reading.
        ///
        /// If the database file does not exist, an error will be returned. If the file is write-protected by
        /// the operating system, the connection will be opened in read-only mode instead, as a fallback.
        ///
        /// ### Usage
        ///
        /// You can specify the `readwrite` option when opening a database connection, as shown below:
        ///
        /// ```swift
        /// let options: Connection.Options = [.readwrite]
        /// let connection = try Connection(path: dbFilePath, options: options)
        /// ```
        ///
        /// ### Important Notes
        ///
        /// - Note: If the database file does not exist, an error will be thrown.
        /// - Note: If you are unable to open the database in read-write mode due to permissions, it will
        ///   attempt to open it in read-only mode.
        ///
        /// For more details, refer to the SQLite documentation on
        /// [opening a new database connection](https://www.sqlite.org/c3ref/open.html).
        public static let readwrite = Self(rawValue: SQLITE_OPEN_READWRITE)
        
        /// Option: create the database if it does not exist.
        ///
        /// This option instructs SQLite to create a new database file if it does not already exist. If the
        /// specified database file already exists, the connection will open that existing database instead.
        ///
        /// ### Usage
        ///
        /// You can specify the `create` option when opening a database connection, as shown below:
        ///
        /// ```swift
        /// let options: Connection.Options = [.create]
        /// let connection = try Connection(path: dbFilePath, options: options)
        /// ```
        ///
        /// ### Important Notes
        ///
        /// - Note: If the database file exists, it will be opened normally, and no new file will be created.
        /// - Note: If the database file does not exist, a new file will be created at the specified path.
        ///
        /// This option is often used in conjunction with other options, such as `readwrite`, to ensure that a
        /// new database can be created and written to right away.
        ///
        /// For more details, refer to the SQLite documentation on
        /// [opening a new database connection](https://www.sqlite.org/c3ref/open.html).
        public static let create = Self(rawValue: SQLITE_OPEN_CREATE)
        
        /// Option: specify a URI for opening the database.
        ///
        /// This option allows the filename provided to be interpreted as a Uniform Resource Identifier (URI).
        /// When this flag is set, SQLite will parse the filename as a URI, enabling the use of URI features
        /// such as special encoding and various URI schemes.
        ///
        /// ### Usage
        ///
        /// You can specify the `uri` option when opening a database connection. Here’s an example:
        ///
        /// ```swift
        /// let options: Connection.Options = [.uri]
        /// let connection = try Connection(path: "file:///path/to/database.db", options: options)
        /// ```
        ///
        /// ### Important Notes
        ///
        /// - Note: Using this option allows you to take advantage of SQLite's URI capabilities, such as
        ///   specifying various parameters in the URI (e.g., caching, locking, etc.).
        /// - Note: If this option is not set, the filename will be treated as a simple path without URI
        ///   interpretation.
        ///
        /// For more details, refer to the SQLite documentation on
        /// [opening a new database connection](https://www.sqlite.org/c3ref/open.html).
        public static let uri = Self(rawValue: SQLITE_OPEN_URI)
        
        /// Option: open the database in memory.
        ///
        /// This option opens the database as an in-memory database, meaning that all data is stored in RAM
        /// rather than on disk. This can be useful for temporary databases or for testing purposes where
        /// persistence is not required.
        ///
        /// When using this option, the "filename" argument is ignored, but it is still used for cache-sharing
        /// if shared cache mode is enabled.
        ///
        /// ### Usage
        ///
        /// You can specify the `memory` option when opening a database connection. Here’s an example:
        ///
        /// ```swift
        /// let options: Connection.Options = [.memory]
        /// let connection = try Connection(path: ":memory:", options: options)
        /// ```
        ///
        /// ### Important Notes
        ///
        /// - Note: Since the database is stored in memory, all data will be lost when the connection is
        ///   closed or the program exits. Therefore, this option is best suited for scenarios where data
        ///   persistence is not necessary.
        /// - Note: In-memory databases can be significantly faster than disk-based databases due to the
        ///   absence of disk I/O operations.
        ///
        /// For more details, refer to the SQLite documentation on
        /// [opening a new database connection](https://www.sqlite.org/c3ref/open.html).
        public static let memory = Self(rawValue: SQLITE_OPEN_MEMORY)
        
        /// Option: do not use mutexes.
        ///
        /// This option configures the new database connection to use the "multi-thread"
        /// [threading mode](https://www.sqlite.org/threadsafe.html). In this mode, separate threads can
        /// concurrently access SQLite, provided that each thread is utilizing a different
        /// [database connection](https://www.sqlite.org/c3ref/sqlite3.html).
        ///
        /// ### Usage
        ///
        /// You can specify the `nomutex` option when opening a database connection. Here’s an example:
        ///
        /// ```swift
        /// let options: Connection.Options = [.nomutex]
        /// let connection = try Connection(path: "myDatabase.sqlite", options: options)
        /// ```
        ///
        /// ### Important Notes
        ///
        /// - Note: When using this option, ensure that each thread has its own database connection, as
        ///   concurrent access to the same connection is not safe.
        /// - Note: This option can improve performance in multi-threaded applications by reducing the
        ///   overhead of mutex locking, but it may lead to undefined behavior if not used carefully.
        /// - Note: If your application requires safe concurrent access to a single database connection
        ///   from multiple threads, consider using the ``fullmutex`` option instead.
        ///
        /// For more details, refer to the SQLite documentation on
        /// [thread safety](https://www.sqlite.org/threadsafe.html).
        public static let nomutex = Self(rawValue: SQLITE_OPEN_NOMUTEX)
        
        /// Option: use full mutexing.
        ///
        /// This option configures the new database connection to utilize the "serialized"
        /// [threading mode](https://www.sqlite.org/threadsafe.html). In this mode, multiple threads can safely
        /// attempt to access the same database connection simultaneously. Although mutexes will block any
        /// actual concurrency, this mode allows for multiple threads to operate without causing data corruption
        /// or undefined behavior.
        ///
        /// ### Usage
        ///
        /// You can specify the `fullmutex` option when opening a database connection. Here’s an example:
        ///
        /// ```swift
        /// let options: Connection.Options = [.fullmutex]
        /// let connection = try Connection(path: "myDatabase.sqlite", options: options)
        /// ```
        ///
        /// ### Important Notes
        ///
        /// - Note: Using the `fullmutex` option is recommended when you need to ensure thread safety when
        ///   multiple threads access the same database connection.
        /// - Note: This option may introduce some performance overhead due to the locking mechanisms in place.
        ///   If your application is designed for high concurrency and can manage separate connections per thread,
        ///   consider using the ``nomutex`` option for better performance.
        /// - Note: It's essential to be aware of potential deadlocks if multiple threads are competing for the
        ///   same resources. Proper design can help mitigate these risks.
        ///
        /// For more details, refer to the SQLite documentation on
        /// [thread safety](https://www.sqlite.org/threadsafe.html).
        public static let fullmutex = Self(rawValue: SQLITE_OPEN_FULLMUTEX)
        
        /// Option: use a shared cache.
        ///
        /// This option enables the database to be opened in [shared cache](https://www.sqlite.org/sharedcache.html)
        /// mode. In this mode, multiple database connections can share cached data, potentially improving
        /// performance when accessing the same database from different connections.
        ///
        /// ### Usage
        ///
        /// You can specify the `sharedcache` option when opening a database connection. Here’s an example:
        ///
        /// ```swift
        /// let options: Connection.Options = [.sharedcache]
        /// let connection = try Connection(path: "myDatabase.sqlite", options: options)
        /// ```
        ///
        /// ### Important Notes
        ///
        /// - Note: **Discouraged Usage**: The use of shared cache mode is
        ///   [discouraged](https://www.sqlite.org/sharedcache.html#dontuse). It may lead to unpredictable behavior,
        ///   especially in applications with complex threading models or multiple database connections.
        ///
        /// - Note: **Build Variability**: Shared cache capabilities may be omitted from many builds of SQLite.
        ///   If your SQLite build does not support shared cache, this option will be a no-op, meaning it will
        ///   have no effect on the behavior of your database connection.
        ///
        /// - Note: **Performance Considerations**: While shared cache can improve performance by reducing memory
        ///   usage, it may introduce complexity in managing concurrent access. Consider your application's design
        ///   and the potential for contention among connections when using this option.
        ///
        /// For more information, consult the SQLite documentation on
        /// [shared cache mode](https://www.sqlite.org/sharedcache.html).
        public static let sharedcache = Self(rawValue: SQLITE_OPEN_SHAREDCACHE)
        
        /// Option: use a private cache.
        ///
        /// This option disables the use of [shared cache](https://www.sqlite.org/sharedcache.html) mode.
        /// When a database is opened with this option, it uses a private cache for its connections, meaning
        /// that the cached data will not be shared with other database connections.
        ///
        /// ### Usage
        ///
        /// You can specify the `privatecache` option when opening a database connection. Here’s an example:
        ///
        /// ```swift
        /// let options: Connection.Options = [.privatecache]
        /// let connection = try Connection(path: "myDatabase.sqlite", options: options)
        /// ```
        ///
        /// ### Important Notes
        ///
        /// - Note: **Isolation**: Using a private cache ensures that the database connection operates in
        ///   isolation, preventing any caching interference from other connections. This can be beneficial
        ///   in multi-threaded applications where shared cache might lead to unpredictable behavior.
        ///
        /// - Note: **Performance Impact**: While a private cache avoids the complexities associated with
        ///   shared caching, it may increase memory usage since each connection maintains its own cache.
        ///   Consider your application’s performance requirements when choosing between shared and private
        ///   cache options.
        ///
        /// - Note: **Build Compatibility**: Ensure that your SQLite build supports the private cache option.
        ///   While most builds do, it’s always a good idea to verify if you encounter any issues.
        ///
        /// For more information, refer to the SQLite documentation on
        /// [shared cache mode](https://www.sqlite.org/sharedcache.html).
        public static let privatecache = Self(rawValue: SQLITE_OPEN_PRIVATECACHE)
        
        /// Option: use extended result code mode.
        ///
        /// This option enables "extended result code mode" for the database connection. When this mode is
        /// enabled, SQLite provides additional error codes that can help in diagnosing issues that may
        /// arise during database operations.
        ///
        /// ### Usage
        ///
        /// You can specify the `exrescode` option when opening a database connection. Here’s an example:
        ///
        /// ```swift
        /// let options: Connection.Options = [.exrescode]
        /// let connection = try Connection(path: "myDatabase.sqlite", options: options)
        /// ```
        ///
        /// ### Benefits
        ///
        /// - **Improved Error Handling**: By using extended result codes, you can get more granular
        ///   information about errors, which can be particularly useful for debugging and error handling
        ///   in your application.
        ///
        /// - **Detailed Diagnostics**: Extended result codes may provide context about the failure,
        ///   allowing for more targeted troubleshooting and resolution of issues.
        ///
        /// ### Considerations
        ///
        /// - **Compatibility**: Make sure your version of SQLite supports extended result codes. This
        ///   option should be available in most modern builds of SQLite.
        ///
        /// For more information, refer to the SQLite documentation on
        /// [extended result codes](https://www.sqlite.org/rescode.html).
        public static let exrescode = Self(rawValue: SQLITE_OPEN_EXRESCODE)
        
        /// Option: do not follow symbolic links when opening a file.
        ///
        /// When this option is enabled, the database filename must not contain a symbolic link. If the
        /// filename refers to a symbolic link, an error will be returned when attempting to open the
        /// database.
        ///
        /// ### Usage
        ///
        /// You can specify the `nofollow` option when opening a database connection. Here’s an example:
        ///
        /// ```swift
        /// let options: Connection.Options = [.nofollow]
        /// let connection = try Connection(path: "myDatabase.sqlite", options: options)
        /// ```
        ///
        /// ### Benefits
        ///
        /// - **Increased Security**: By disallowing symbolic links, you reduce the risk of unintended
        ///   file access or manipulation through links that may point to unexpected locations.
        ///
        /// - **File Integrity**: Ensures that the database connection directly references the intended
        ///   file without any indirection that symbolic links could introduce.
        ///
        /// ### Considerations
        ///
        /// - **Filesystem Limitations**: This option may limit your ability to use symbolic links in
        ///   your application. Make sure this behavior is acceptable for your use case.
        ///
        /// For more information, refer to the SQLite documentation on [file opening](https://www.sqlite.org/c3ref/open.html).
        public static let nofollow = Self(rawValue: SQLITE_OPEN_NOFOLLOW)
        
        // MARK: - Inits
        
        /// Initializes a set of options for connecting to a SQLite database.
        ///
        /// This initializer allows you to create a combination of option flags that dictate how the
        /// database connection will behave. The `rawValue` parameter should be an integer that
        /// represents one or more options, combined using a bitwise OR operation.
        ///
        /// - Parameter rawValue: An integer value representing a combination of option flags. This
        ///   value can be constructed using the predefined options, e.g., `SQLITE_OPEN_READWRITE |
        ///   SQLITE_OPEN_CREATE`.
        ///
        /// ### Example
        ///
        /// You can create a set of options as follows:
        ///
        /// ```swift
        /// let options = Connection.Options(
        ///     rawValue: SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
        /// )
        /// ```
        ///
        /// In this example, the `options` variable will have both the ``readwrite`` and
        /// ``create`` options enabled, allowing for read/write access and creating the database if
        /// it does not exist.
        ///
        /// ### Important Notes
        ///
        /// - Note: Be cautious when combining options, as some combinations may lead to conflicts or
        ///   unintended behavior (e.g., ``readonly`` and ``readwrite`` cannot be set together).
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
