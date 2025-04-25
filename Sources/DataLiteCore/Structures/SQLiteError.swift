import Foundation
import DataLiteC

/// Represents an error encountered when interacting with SQLite.
///
/// ## Topics
///
/// ### Instance Properties
///
/// - ``code``
/// - ``mesg``
/// - ``description``
public struct SQLiteError: Error, CustomStringConvertible {
    // MARK: - Properties
    
    /// The SQLite error code.
    ///
    /// This code represents the specific error that occurred during SQLite operations.
    /// For a list of possible SQLite error codes, see
    /// [Result and Error Codes](https://www.sqlite.org/rescode.html).
    public let code: Int32
    
    /// The SQLite error message.
    ///
    /// This message provides a description of the error encountered.
    public let mesg: String
    
    /// A textual representation of the error.
    ///
    /// This computed property returns a string describing the error, including
    /// the error code and message.
    public var description: String {
        return "SQLiteError code: \(code) message: \(mesg)"
    }
    
    // MARK: - Inits
    
    /// Initializes an `SQLiteError` from an SQLite connection.
    ///
    /// - Parameter connection: The SQLite connection pointer.
    ///
    /// This initializer creates an `SQLiteError` by retrieving the error code
    /// and message from the provided SQLite connection.
    init(_ connection: OpaquePointer) {
        self.code = sqlite3_extended_errcode(connection)
        self.mesg = String(cString: sqlite3_errmsg(connection))
    }
    
    /// Initializes an `SQLiteError` with a specific code and message.
    ///
    /// - Parameters:
    ///   - code: The SQLite error code.
    ///   - mesg: The SQLite error message.
    ///
    /// This initializer allows creating an `SQLiteError` by manually providing
    /// the error code and message.
    init(code: Int32, mesg: String) {
        self.code = code
        self.mesg = mesg
    }
}
