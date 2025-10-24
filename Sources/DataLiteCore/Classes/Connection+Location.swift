import Foundation

extension Connection {
    /// A location specifying where the SQLite database is stored or created.
    ///
    /// Three locations are supported:
    /// - ``file(path:)``: A database at a specific file path or URI (persistent).
    /// - ``inMemory``: An in-memory database that exists only in RAM.
    /// - ``temporary``: A temporary on-disk database deleted when the connection closes.
    public enum Location {
        /// A database stored at a given file path or URI.
        ///
        /// Use this for persistent databases located on disk or referenced via SQLite URI.
        /// The file is created if it does not exist (subject to open options).
        ///
        /// - Parameter path: Absolute/relative file path or URI.
        /// - SeeAlso: [Uniform Resource Identifiers](https://sqlite.org/uri.html)
        case file(path: String)
        
        /// A transient in-memory database.
        ///
        /// The database exists only in RAM and is discarded once the connection closes.
        /// Suitable for testing, caching, or temporary data processing.
        ///
        /// - SeeAlso: [In-Memory Databases](https://sqlite.org/inmemorydb.html)
        case inMemory
        
        /// A temporary on-disk database.
        ///
        /// Created on disk and removed automatically when the connection closes or the
        /// process terminates. Useful for ephemeral data that should not persist.
        ///
        /// - SeeAlso: [Temporary Databases](https://sqlite.org/inmemorydb.html)
        case temporary
        
        var path: String {
            switch self {
            case .file(let path): path
            case .inMemory: ":memory:"
            case .temporary: ""
            }
        }
    }
}
