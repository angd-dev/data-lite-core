import Foundation

extension String: SQLiteRepresentable {
    /// Converts a `String` value to its SQLite representation.
    ///
    /// Strings are stored in SQLite as text (`TEXT` type). This property wraps the current value
    /// into an ``SQLiteValue/text(_:)`` case, suitable for parameter binding.
    ///
    /// - Returns: An ``SQLiteValue`` of type `.text` containing the string value.
    public var sqliteValue: SQLiteValue {
        .text(self)
    }
    
    /// Creates a `String` value from an SQLite representation.
    ///
    /// This initializer supports the ``SQLiteValue/text(_:)`` case and converts the text content
    /// to a `String` instance.
    ///
    /// - Parameter value: The SQLite value to convert from.
    /// - Returns: A `String` instance if the conversion succeeds, or `nil` otherwise.
    public init?(_ value: SQLiteValue) {
        switch value {
        case .text(let value):
            self = value
        default:
            return nil
        }
    }
}
