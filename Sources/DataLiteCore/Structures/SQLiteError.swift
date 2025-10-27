import Foundation
import DataLiteC

/// A structure that represents an error produced by SQLite operations.
///
/// `SQLiteError` encapsulates both the numeric SQLite error code and its associated human-readable
/// message. It provides a unified way to report and inspect failures that occur during database
/// interactions.
///
/// - SeeAlso: [Result and Error Codes](https://sqlite.org/rescode.html)
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
public struct SQLiteError: Error, Equatable, CustomStringConvertible, Sendable {
    /// The extended SQLite result code associated with the error.
    ///
    /// This numeric value identifies the specific type of error that occurred. Extended result
    /// codes offer more precise information than primary codes, enabling finer-grained error
    /// handling and diagnostics.
    ///
    /// - SeeAlso: [Result and Error Codes](https://sqlite.org/rescode.html)
    public let code: Int32
    
    /// The human-readable message returned by SQLite.
    ///
    /// This string describes the error condition reported by SQLite. It is typically retrieved
    /// directly from the database engine and may include details about constraint violations,
    /// syntax errors, I/O issues, or resource limitations.
    ///
    /// - Note: The content of this message is determined by SQLite and may vary between error
    ///   occurrences. Always refer to this property for detailed diagnostic information.
    public let message: String
    
    /// A textual representation of the error including its code and message.
    ///
    /// The value of this property is a concise string describing the error. It includes the type
    /// name (`SQLiteError`), the numeric code, and the corresponding message, making it useful for
    /// debugging, logging, or diagnostic displays.
    public var description: String {
        "\(Self.self)(\(code)): \(message)"
    }
    
    /// Creates a new error instance with the specified result code and message.
    ///
    /// Use this initializer to represent an SQLite error explicitly by providing both the numeric
    /// result code and the associated descriptive message.
    ///
    /// - Parameters:
    ///   - code: The extended SQLite result code associated with the error.
    ///   - message: A human-readable description of the error, as reported by SQLite.
    public init(code: Int32, message: String) {
        self.code = code
        self.message = message
    }
    
    init(_ connection: OpaquePointer) {
        self.code = sqlite3_extended_errcode(connection)
        self.message = String(cString: sqlite3_errmsg(connection))
    }
}
