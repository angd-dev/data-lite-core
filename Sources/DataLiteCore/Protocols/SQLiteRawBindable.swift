import Foundation

/// A type that can be used as a parameter in an SQL statement.
///
/// Conforming types provide a raw SQLite-compatible representation of their values,
/// enabling them to be directly bound to SQL statements.
///
/// **Example implementation:**
///
/// ```swift
/// struct Device: SQLiteRawBindable {
///     var model: String
///
///     var sqliteRawValue: SQLiteRawValue {
///         return .text(model)
///     }
/// }
/// ```
public protocol SQLiteRawBindable: SQLiteLiteralable {
    /// The raw SQLite representation of the value.
    ///
    /// This property provides a value that is compatible with SQLite's internal representation,
    /// such as text, integer, real, blob, or null. It is used when binding the conforming
    /// type to SQL statements.
    var sqliteRawValue: SQLiteRawValue { get }
}

public extension SQLiteRawBindable {
    /// The string representation of the value as an SQLite literal.
    ///
    /// This property leverages the `sqliteRawValue` to produce a valid SQLite-compatible literal,
    /// formatted appropriately for use in SQL queries.
    var sqliteLiteral: String {
        sqliteRawValue.sqliteLiteral
    }
}
