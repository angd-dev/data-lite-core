import Foundation

extension Data: SQLiteRepresentable {
    /// Converts a `Data` value to its SQLite representation.
    ///
    /// Binary data is stored in SQLite as a BLOB (`BLOB` type). This property wraps the current
    /// value into an ``SQLiteValue/blob(_:)`` case, suitable for parameter binding.
    ///
    /// - Returns: An ``SQLiteValue`` of type `.blob` containing the binary data.
    public var sqliteValue: SQLiteValue {
        .blob(self)
    }
    
    /// Creates a `Data` value from an SQLite representation.
    ///
    /// This initializer supports the ``SQLiteValue/blob(_:)`` case and converts the binary content
    /// to a `Data` instance.
    ///
    /// - Parameter value: The SQLite value to convert from.
    /// - Returns: A `Data` instance if the conversion succeeds, or `nil` otherwise.
    public init?(_ value: SQLiteValue) {
        switch value {
        case .blob(let data):
            self = data
        default:
            return nil
        }
    }
}
