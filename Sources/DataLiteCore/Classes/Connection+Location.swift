import Foundation

extension Connection {
    /// The `Location` enum represents different locations for a SQLite database.
    ///
    /// This enum allows you to specify how and where a SQLite database will be stored or accessed.
    /// You can choose from three options:
    ///
    /// - **File**: A database located at a specified file path or URI. This option is suitable
    ///   for persistent storage and can reference any valid file location in the filesystem or
    ///   a URI.
    ///
    /// - **In-Memory**: An in-memory database that exists only in RAM. This option is useful
    ///   for temporary data processing, testing, or scenarios where persistence is not required.
    ///
    /// - **Temporary**: A temporary database on disk that is created for the duration of the
    ///   connection and is automatically deleted when the connection is closed or when the
    ///   process ends.
    ///
    /// ### Usage
    ///
    /// You can create instances of the `Location` enum to specify the desired database location:
    ///
    /// ```swift
    /// let fileLocation = Connection.Location.file(path: "/path/to/database.db")
    /// let inMemoryLocation = Connection.Location.inMemory
    /// let temporaryLocation = Connection.Location.temporary
    /// ```
    public enum Location {
        /// A database located at a given file path or URI.
        ///
        /// This case allows you to specify the exact location of a SQLite database using a file
        /// path or a URI. The provided path should point to a valid SQLite database file. If the
        /// database file does not exist, the behavior will depend on the connection options
        /// specified when opening the database.
        ///
        /// - Parameter path: The path or URI to the database file. This can be an absolute or
        ///   relative path, or a URI scheme supported by SQLite.
        ///
        /// ### Example
        ///
        /// You can create a `Location.file` case as follows:
        ///
        /// ```swift
        /// let databaseLocation = Connection.Location.file(path: "/path/to/database.db")
        /// ```
        ///
        /// - Important: Ensure that the specified path is correct and that your application has
        ///   the necessary permissions to access the file.
        ///
        /// For more details, refer to [Uniform Resource Identifiers](https://www.sqlite.org/uri.html).
        case file(path: String)
        
        /// An in-memory database.
        ///
        /// In-memory databases are temporary and exist only in RAM. They are not persisted to disk,
        /// which makes them suitable for scenarios where you need fast access to data without the
        /// overhead of disk I/O.
        ///
        /// When you create an in-memory database, it is stored entirely in memory, meaning that
        /// all data will be lost when the connection is closed or the application exits.
        ///
        /// ### Usage
        ///
        /// You can specify an in-memory database as follows:
        ///
        /// ```swift
        /// let databaseLocation = Connection.Location.inMemory
        /// ```
        ///
        /// - Important: In-memory databases should only be used for scenarios where persistence is
        ///   not required, such as temporary data processing or testing.
        ///
        /// - Note: In-memory databases can provide significantly faster performance compared to
        ///   disk-based databases due to the absence of disk I/O operations.
        ///
        /// For more details, refer to [In-Memory Databases](https://www.sqlite.org/inmemorydb.html).
        case inMemory
        
        /// A temporary database on disk.
        ///
        /// Temporary databases are created on disk but are not intended for persistent storage. They
        /// are automatically deleted when the connection is closed or when the process ends. This
        /// allows you to use a database for temporary operations without worrying about the overhead
        /// of file management.
        ///
        /// Temporary databases can be useful for scenarios such as:
        /// - Testing database operations without affecting permanent data.
        /// - Storing transient data that only needs to be accessible during a session.
        ///
        /// ### Usage
        ///
        /// You can specify a temporary database as follows:
        ///
        /// ```swift
        /// let databaseLocation = Connection.Location.temporary
        /// ```
        ///
        /// - Important: Since temporary databases are deleted when the connection is closed, make
        ///   sure to use this option only for non-persistent data requirements.
        ///
        /// For more details, refer to [Temporary Databases](https://www.sqlite.org/inmemorydb.html).
        case temporary
        
        /// Returns the path to the database.
        ///
        /// This computed property provides the appropriate path representation for the selected
        /// `Location` case. Depending on the case, it returns:
        /// - The specified file path for `.file`.
        /// - The string `":memory:"` for in-memory databases, indicating that the database exists
        ///   only in RAM.
        /// - An empty string for temporary databases, as these are created on disk but do not
        ///   require a specific file path.
        ///
        /// ### Usage
        ///
        /// You can access the `path` property as follows:
        ///
        /// ```swift
        /// let location = Connection.Location.file(path: "/path/to/database.db")
        /// let databasePath = location.path  // "/path/to/database.db"
        ///
        /// let inMemoryLocation = Connection.Location.inMemory
        /// let inMemoryPath = inMemoryLocation.path  // ":memory:"
        ///
        /// let temporaryLocation = Connection.Location.temporary
        /// let temporaryPath = temporaryLocation.path  // ""
        /// ```
        ///
        /// - Note: When using the `.temporary` case, the returned value is an empty string
        ///   because the database is created as a temporary file that does not have a
        ///   persistent path.
        var path: String {
            switch self {
            case .file(let path): return path
            case .inMemory: return ":memory:"
            case .temporary: return ""
            }
        }
    }
}
