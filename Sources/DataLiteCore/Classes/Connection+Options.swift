import Foundation
import DataLiteC

extension Connection {
    /// Options that control how the SQLite database connection is opened.
    ///
    /// Each option corresponds to a flag from the SQLite C API. Multiple options can be combined
    /// using the `OptionSet` syntax.
    ///
    /// - SeeAlso: [Opening A New Database Connection](https://sqlite.org/c3ref/open.html)
    public struct Options: OptionSet, Sendable {
        // MARK: - Properties
        
        /// The raw integer value representing the option flags.
        public var rawValue: Int32
        
        // MARK: - Inits
        
        /// Creates a new set of options from a raw integer value.
        ///
        /// Combine multiple flags using bitwise OR (`|`).
        ///
        /// ```swift
        /// let opts = Connection.Options(
        ///     rawValue: SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
        /// )
        /// ```
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        // MARK: - Instances
        
        /// Opens the database in read-only mode.
        ///
        /// Fails if the database file does not exist.
        public static let readonly = Self(rawValue: SQLITE_OPEN_READONLY)
        
        /// Opens the database for reading and writing.
        ///
        /// Fails if the file does not exist or is write-protected.
        public static let readwrite = Self(rawValue: SQLITE_OPEN_READWRITE)
        
        /// Creates the database file if it does not exist.
        ///
        /// Commonly combined with `.readwrite`.
        public static let create = Self(rawValue: SQLITE_OPEN_CREATE)
        
        /// Interprets the filename as a URI.
        ///
        /// Enables SQLite’s URI parameters and schemes.
        /// - SeeAlso: [Uniform Resource Identifiers](https://sqlite.org/uri.html)
        public static let uri = Self(rawValue: SQLITE_OPEN_URI)
        
        /// Opens an in-memory database.
        ///
        /// Data is stored in RAM and discarded when closed.
        /// - SeeAlso: [In-Memory Databases](https://sqlite.org/inmemorydb.html)
        public static let memory = Self(rawValue: SQLITE_OPEN_MEMORY)
        
        /// Disables mutexes for higher concurrency.
        ///
        /// Each thread must use a separate connection.
        /// - SeeAlso: [Using SQLite In Multi-Threaded Applications](
        ///   https://sqlite.org/threadsafe.html)
        public static let nomutex = Self(rawValue: SQLITE_OPEN_NOMUTEX)
        
        /// Enables serialized access using full mutexes.
        ///
        /// Safe for concurrent access from multiple threads.
        /// - SeeAlso: [Using SQLite In Multi-Threaded Applications](
        ///   https://sqlite.org/threadsafe.html)
        public static let fullmutex = Self(rawValue: SQLITE_OPEN_FULLMUTEX)
        
        /// Enables shared cache mode.
        ///
        /// Allows multiple connections to share cached data.
        /// - SeeAlso: [SQLite Shared-Cache Mode](https://sqlite.org/sharedcache.html)
        /// - Warning: Shared cache mode is discouraged by SQLite.
        public static let sharedcache = Self(rawValue: SQLITE_OPEN_SHAREDCACHE)
        
        /// Disables shared cache mode.
        ///
        /// Each connection uses a private cache.
        /// - SeeAlso: [SQLite Shared-Cache Mode](https://sqlite.org/sharedcache.html)
        public static let privatecache = Self(rawValue: SQLITE_OPEN_PRIVATECACHE)
        
        /// Enables extended result codes.
        ///
        /// Provides more detailed SQLite error codes.
        /// - SeeAlso: [Result and Error Codes](https://sqlite.org/rescode.html)
        public static let exrescode = Self(rawValue: SQLITE_OPEN_EXRESCODE)
        
        /// Disallows following symbolic links.
        ///
        /// Improves security by preventing indirect file access.
        public static let nofollow = Self(rawValue: SQLITE_OPEN_NOFOLLOW)
    }
}
