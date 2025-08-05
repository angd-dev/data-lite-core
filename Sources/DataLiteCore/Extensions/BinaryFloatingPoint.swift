import Foundation

public extension SQLiteRawBindable where Self: BinaryFloatingPoint {
    /// Provides the `SQLiteRawValue` representation for floating-point types.
    ///
    /// This implementation converts the floating-point value to a `real` SQLite raw value.
    ///
    /// - Returns: An `SQLiteRawValue` of type `.real`, containing the floating-point value.
    var sqliteRawValue: SQLiteRawValue {
        .real(.init(self))
    }
}

public extension SQLiteRawRepresentable where Self: BinaryFloatingPoint {
    /// Initializes an instance of the conforming type from an `SQLiteRawValue`.
    ///
    /// This initializer handles `SQLiteRawValue` of type `.real`, converting it to the floating-point value.
    /// It also handles `SQLiteRawValue` of type `.int`, converting it to the floating-point value.
    ///
    /// - Parameter sqliteRawValue: The raw SQLite value used to initialize the instance.
    init?(_ sqliteRawValue: SQLiteRawValue) {
        switch sqliteRawValue {
        case .int(let value):
            self.init(Double(value))
        case .real(let value):
            self.init(value)
        default:
            return nil
        }
    }
}

extension Float: SQLiteRawRepresentable {}
extension Double: SQLiteRawRepresentable {}
