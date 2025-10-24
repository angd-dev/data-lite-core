import Foundation

/// A protocol whose conforming types can be used in SQLite statements and queries.
///
/// Conforming types provide a raw SQLite value for binding to prepared-statement parameters
/// and an SQL literal that can be inserted directly into SQL text.
///
/// ```swift
/// struct Device: SQLiteBindable {
///     var model: String
///
///     var sqliteValue: SQLiteValue {
///         return .text(model)
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Instance Properties
///
/// - ``sqliteValue``
/// - ``sqliteLiteral``
public protocol SQLiteBindable {
    /// The raw SQLite value representation.
    ///
    /// Supplies a value compatible with SQLite's internal representation. Used when binding
    /// conforming types to parameters of a prepared SQLite statement.
    var sqliteValue: SQLiteValue { get }
    
    /// The SQL literal representation.
    ///
    /// Provides a string that conforms to SQL syntax and is compatible with SQLite's rules
    /// for literals. Defaults to ``SQLiteValue/sqliteLiteral``.
    var sqliteLiteral: String { get }
}

public extension SQLiteBindable {
    var sqliteLiteral: String {
        sqliteValue.sqliteLiteral
    }
}
