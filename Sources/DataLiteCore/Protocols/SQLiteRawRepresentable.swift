import Foundation

/// A type that can be initialized from a raw SQLite value.
///
/// This protocol extends `SQLiteRawBindable` and requires conforming types to implement
/// an initializer that can convert a raw SQLite value into the corresponding type.
///
/// **Example implementation:**
///
/// ```swift
/// struct Device: SQLiteRawRepresentable {
///     var model: String
///
///     var sqliteRawValue: SQLiteRawValue {
///         return .text(model)
///     }
///
///     init?(_ sqliteRawValue: SQLiteRawValue) {
///         guard
///             case let .text(value) = sqliteRawValue
///         else { return nil }
///         self.model = value
///     }
/// }
/// ```
public protocol SQLiteRawRepresentable: SQLiteRawBindable {
    /// Initializes an instance from a raw SQLite value.
    ///
    /// This initializer should map the provided SQLite raw value to the appropriate type.
    /// If the conversion is not possible (e.g., if the raw value is of an incompatible type),
    /// the initializer should return `nil`.
    ///
    /// - Parameter sqliteRawValue: A raw SQLite value to be converted.
    init?(_ sqliteRawValue: SQLiteRawValue)
}
