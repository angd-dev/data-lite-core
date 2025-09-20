import Foundation
import DataLiteC

extension Connection {
    /// Represents an error encountered when interacting with the underlying database engine.
    ///
    /// This type encapsulates SQLite-specific error codes and messages returned
    /// from a `Connection` instance. It is used throughout the system to report
    /// failures related to database operations.
    ///
    /// ## Topics
    ///
    /// ### Instance Properties
    ///
    /// - ``code``
    /// - ``message``
    /// - ``description``
    ///
    /// ### Initializers
    ///
    /// - ``init(code:message:)``
    public struct Error: Swift.Error, Equatable, CustomStringConvertible {
        // MARK: - Properties
        
        /// The database engine error code.
        ///
        /// This code indicates the specific error returned by SQLite during an operation.
        /// For a full list of possible error codes, see:
        /// [SQLite Result and Error Codes](https://www.sqlite.org/rescode.html).
        public let code: Int32
        
        /// A human-readable error message describing the failure.
        public let message: String
        
        /// A textual representation of the error.
        ///
        /// Combines the error code and message into a single descriptive string.
        public var description: String {
            "Connection.Error code: \(code) message: \(message)"
        }
        
        // MARK: - Initialization
        
        /// Creates an error with the given code and message.
        ///
        /// - Parameters:
        ///   - code: The SQLite error code.
        ///   - message: A description of the error.
        public init(code: Int32, message: String) {
            self.code = code
            self.message = message
        }
        
        /// Creates an error by extracting details from a SQLite connection.
        ///
        /// - Parameter connection: A pointer to the SQLite connection.
        ///
        /// This initializer reads the extended error code and error message
        /// from the provided SQLite connection pointer.
        init(_ connection: OpaquePointer) {
            self.code = sqlite3_extended_errcode(connection)
            self.message = String(cString: sqlite3_errmsg(connection))
        }
    }
}
