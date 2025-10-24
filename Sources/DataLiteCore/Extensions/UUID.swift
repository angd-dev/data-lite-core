import Foundation

extension UUID: SQLiteRepresentable {
    /// Converts a `UUID` value to its SQLite representation.
    ///
    /// UUIDs are stored in SQLite as text (`TEXT` type) using their canonical string form
    /// (e.g. `"550E8400-E29B-41D4-A716-446655440000"`). This property wraps the current value into
    /// an ``SQLiteValue/text(_:)`` case.
    ///
    /// - Returns: An ``SQLiteValue`` of type `.text` containing the UUID string.
    public var sqliteValue: SQLiteValue {
        .text(self.uuidString)
    }
    
    /// Creates a `UUID` value from an SQLite representation.
    ///
    /// This initializer supports the ``SQLiteValue/text(_:)`` case and attempts to parse the stored
    /// text as a valid UUID string.
    ///
    /// - Parameter value: The SQLite value to convert from.
    /// - Returns: A `UUID` instance if the string is valid, or `nil` otherwise.
    public init?(_ value: SQLiteValue) {
        switch value {
        case .text(let value):
            self.init(uuidString: value)
        default:
            return nil
        }
    }
}
