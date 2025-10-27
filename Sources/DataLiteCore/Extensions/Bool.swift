import Foundation

extension Bool: SQLiteRepresentable {
    /// Converts a Boolean value to its SQLite representation.
    ///
    /// Boolean values are stored in SQLite as integers (`INTEGER` type). The value `true` is
    /// represented as `1`, and `false` as `0`.
    ///
    /// - Returns: An ``SQLiteValue`` of type `.int`, containing `1` for `true`
    ///   and `0` for `false`.
    public var sqliteValue: SQLiteValue {
        .int(self ? 1 : 0)
    }
    
    /// Creates a Boolean value from an SQLite representation.
    ///
    /// This initializer supports the ``SQLiteValue/int(_:)`` case and converts the integer value to
    ///  a Boolean. `1` is interpreted as `true`, `0` as `false`. If the integer is not `0` or `1`,
    /// the initializer returns `nil`.
    ///
    /// - Parameter value: The SQLite value to convert from.
    /// - Returns: A Boolean value if the conversion succeeds, or `nil` otherwise.
    public init?(_ value: SQLiteValue) {
        switch value {
        case .int(let value) where value == 0 || value == 1:
            self = value == 1
        default:
            return nil
        }
    }
}
