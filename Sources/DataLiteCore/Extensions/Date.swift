import Foundation

extension Date: SQLiteRepresentable {
    /// Converts a `Date` value to its SQLite representation.
    ///
    /// Dates are stored in SQLite as text using the ISO 8601 format. This property converts the
    /// current date into an ISO 8601 string and wraps it in an ``SQLiteValue/text(_:)`` case,
    /// suitable for parameter binding.
    ///
    /// - Returns: An ``SQLiteValue`` of type `.text`, containing the ISO 8601 string.
    public var sqliteValue: SQLiteValue {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: self)
        return .text(dateString)
    }
    
    /// Creates a `Date` value from an SQLite representation.
    ///
    /// This initializer supports the following ``SQLiteValue`` cases:
    /// - ``SQLiteValue/text(_:)`` — parses an ISO 8601 date string.
    /// - ``SQLiteValue/int(_:)`` or ``SQLiteValue/real(_:)`` — interprets the number as a time
    ///   interval since 1970 (UNIX timestamp).
    ///
    /// - Parameter value: The SQLite value to convert from.
    /// - Returns: A `Date` instance if the conversion succeeds, or `nil` otherwise.
    public init?(_ value: SQLiteValue) {
        switch value {
        case .int(let value):
            self.init(timeIntervalSince1970: TimeInterval(value))
        case .real(let value):
            self.init(timeIntervalSince1970: value)
        case .text(let value):
            let formatter = ISO8601DateFormatter()
            guard let date = formatter.date(from: value) else { return nil }
            self = date
        default:
            return nil
        }
    }
}
