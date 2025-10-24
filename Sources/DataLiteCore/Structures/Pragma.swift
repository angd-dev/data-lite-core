import Foundation

/// A type representing SQLite pragmas.
///
/// The `Pragma` structure provides a convenient way to work with SQLite pragmas, which are special
/// commands used to control various aspects of the SQLite database engine.
///
/// - SeeAlso: [SQLite Pragma Documentation](https://sqlite.org/pragma.html).
///
/// ## Topics
///
/// ### Initializers
///
/// - ``init(rawValue:)``
/// - ``init(stringLiteral:)``
///
/// ### Instances
///
/// - ``applicationID``
/// - ``foreignKeys``
/// - ``journalMode``
/// - ``synchronous``
/// - ``userVersion``
public struct Pragma: RawRepresentable, CustomStringConvertible, ExpressibleByStringLiteral, Sendable {
    // MARK: - Properties
    
    /// The raw string value of the pragma.
    ///
    /// This is the underlying string that represents the pragma, which can be used directly in SQL
    /// queries.
    public var rawValue: String
    
    /// A textual representation of the pragma.
    ///
    /// This provides a description of the pragma as a string.
    public var description: String {
        rawValue
    }
    
    // MARK: - Instances
    
    /// Represents the `application_id` pragma.
    ///
    /// This pragma allows you to query or set the application ID associated with the SQLite
    /// database file. The application ID is a 32-bit integer that can be used for versioning or
    /// identification purposes.
    ///
    /// - SeeAlso: [application_id](https://sqlite.org/pragma.html#pragma_application_id).
    public static let applicationID: Pragma = "application_id"
    
    /// Represents the `foreign_keys` pragma.
    ///
    /// This pragma controls the enforcement of foreign key constraints in SQLite. Foreign key
    /// constraints are disabled by default, but you can enable them by using this pragma.
    ///
    /// - SeeAlso: [foreign_keys](https://sqlite.org/pragma.html#pragma_foreign_keys).
    public static let foreignKeys: Pragma = "foreign_keys"
    
    /// Represents the `journal_mode` pragma.
    ///
    /// This pragma is used to query or configure the journal mode for the database connection. The
    /// journal mode determines how transactions are logged, influencing both the performance and
    /// recovery behavior of the database.
    ///
    /// - SeeAlso: [journal_mode](https://sqlite.org/pragma.html#pragma_journal_mode).
    public static let journalMode: Pragma = "journal_mode"
    
    /// Represents the `synchronous` pragma.
    ///
    /// This pragma is used to query or configure the synchronous mode for the database connection.
    /// The synchronous mode controls how the database synchronizes with the disk during write
    /// operations, affecting both performance and durability.
    ///
    /// - SeeAlso: [synchronous](https://sqlite.org/pragma.html#pragma_synchronous).
    public static let synchronous: Pragma = "synchronous"
    
    /// Represents the `user_version` pragma.
    ///
    /// This pragma is commonly used to query or set the user version number associated with the
    /// database file. It is useful for schema versioning or implementing custom database management
    /// strategies.
    ///
    /// - SeeAlso: [user_version](https://sqlite.org/pragma.html#pragma_user_version).
    public static let userVersion: Pragma = "user_version"
    
    /// Represents the `busy_timeout` pragma.
    ///
    /// This pragma defines the number of milliseconds that SQLite will wait for a locked database
    /// before returning a `SQLITE_BUSY` error. It helps prevent failures when multiple connections
    /// attempt to write simultaneously.
    ///
    /// - SeeAlso: [busy_timeout](https://sqlite.org/pragma.html#pragma_busy_timeout).
    public static let busyTimeout: Pragma = "busy_timeout"
    
    // MARK: - Inits
    
    /// Initializes a `Pragma` instance with the provided raw value.
    ///
    /// This initializer allows you to create a `Pragma` instance with any raw string that
    /// represents a valid SQLite pragma.
    ///
    /// - Parameter rawValue: The raw string value of the pragma.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Initializes a `Pragma` instance with the provided string literal.
    ///
    /// This initializer allows you to create a `Pragma` instance using a string literal, providing
    /// a convenient syntax for common pragmas.
    ///
    /// - Parameter value: The string literal representing the pragma.
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
