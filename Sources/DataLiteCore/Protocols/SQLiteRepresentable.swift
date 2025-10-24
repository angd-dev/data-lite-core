import Foundation

/// A protocol whose conforming types can be initialized from raw SQLite values.
///
/// This protocol extends ``SQLiteBindable`` and adds an initializer for converting a raw SQLite
/// value into the corresponding type.
///
/// ```swift
/// struct Device: SQLiteRepresentable {
///     var model: String
///
///     var sqliteValue: SQLiteValue {
///         return .text(model)
///     }
///
///     init?(_ value: SQLiteValue) {
///         switch value {
///         case .text(let value):
///             self.model = value
///         default:
///             return nil
///         }
///     }
/// }
/// ```
public protocol SQLiteRepresentable: SQLiteBindable {
    /// Initializes an instance from a raw SQLite value.
    ///
    /// The initializer should map the provided raw SQLite value to the corresponding type.
    /// If the conversion is not possible (for example, the value has an incompatible type),
    /// the initializer should return `nil`.
    ///
    /// - Parameter value: The raw SQLite value to convert.
    init?(_ value: SQLiteValue)
}
