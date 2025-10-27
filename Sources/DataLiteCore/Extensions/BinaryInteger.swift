import Foundation

public extension SQLiteBindable where Self: BinaryInteger {
    /// Converts an integer value to its SQLite representation.
    ///
    /// Integer values are stored in SQLite as `INTEGER` values. This property wraps the current
    /// value into an ``SQLiteValue/int(_:)`` case, suitable for use in parameter binding.
    ///
    /// - Returns: An ``SQLiteValue`` of type `.int` containing the integer value.
    var sqliteValue: SQLiteValue {
        .int(Int64(self))
    }
}

public extension SQLiteRepresentable where Self: BinaryInteger {
    /// Creates an integer value from an SQLite representation.
    ///
    /// This initializer supports the ``SQLiteValue/int(_:)`` case and uses `init(exactly:)` to
    /// ensure that the value fits within the bounds of the integer type. If the value cannot be
    /// exactly represented, the initializer returns `nil`.
    ///
    /// - Parameter value: The SQLite value to convert from.
    /// - Returns: A new instance if the conversion succeeds, or `nil` otherwise.
    init?(_ value: SQLiteValue) {
        switch value {
        case .int(let value):
            self.init(exactly: value)
        default:
            return nil
        }
    }
}

extension Int: SQLiteRepresentable {}
extension Int8: SQLiteRepresentable {}
extension Int16: SQLiteRepresentable {}
extension Int32: SQLiteRepresentable {}
extension Int64: SQLiteRepresentable {}

extension UInt: SQLiteRepresentable {}
extension UInt8: SQLiteRepresentable {}
extension UInt16: SQLiteRepresentable {}
extension UInt32: SQLiteRepresentable {}
extension UInt64: SQLiteRepresentable {}
