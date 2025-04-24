import Foundation

/// A type that can be represented as literals in an SQL query.
///
/// This protocol ensures that types conforming to it provide a string representation
/// that can be used directly in SQL queries. Each conforming type must implement
/// a way to return its corresponding SQLite literal representation.
///
/// **Example implementation:**
///
/// ```swift
/// struct Device: SQLiteLiteralable {
///     var model: String
///
///     var sqliteLiteral: String {
///         return "'\(model)'"
///     }
/// }
/// ```
public protocol SQLiteLiteralable {
    /// Returns the string representation of the object, formatted as an SQLite literal.
    ///
    /// This property should return a string that adheres to SQL query syntax and is compatible
    /// with SQLite's rules for literals.
    ///
    /// For example:
    /// - **Integers:** `42` -> `"42"`
    /// - **Strings:** `"Hello"` -> `"'Hello'"` (with single quotes)
    /// - **Booleans:** `true` -> `"1"`, `false` -> `"0"`
    /// - **Data:** `Data([0x01, 0x02])` -> `"X'0102'"`
    /// - **Null:** `NSNull()` -> `"NULL"`
    var sqliteLiteral: String { get }
}
