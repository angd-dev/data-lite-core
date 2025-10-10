import Foundation

public extension SQLiteBindable where Self: BinaryFloatingPoint {
    /// Converts a floating-point value to its SQLite representation.
    ///
    /// Floating-point numbers are stored in SQLite as `REAL` values. This property wraps the
    /// current value into an ``SQLiteValue/real(_:)`` case, suitable for parameter binding.
    ///
    /// - Returns: An ``SQLiteValue`` of type `.real` containing the numeric value.
    var sqliteValue: SQLiteValue {
        .real(.init(self))
    }
}

public extension SQLiteRepresentable where Self: BinaryFloatingPoint {
    /// Creates a floating-point value from an SQLite representation.
    ///
    /// This initializer supports both ``SQLiteValue/real(_:)`` and ``SQLiteValue/int(_:)`` cases,
    /// converting the stored number to the corresponding floating-point type.
    ///
    /// - Parameter value: The SQLite value to convert from.
    /// - Returns: A new instance if the conversion succeeds, or `nil` if the value is incompatible.
    init?(_ value: SQLiteValue) {
        switch value {
        case .int(let value):
            self.init(Double(value))
        case .real(let value):
            self.init(value)
        default:
            return nil
        }
    }
}

extension Float: SQLiteRepresentable {}
extension Double: SQLiteRepresentable {}
