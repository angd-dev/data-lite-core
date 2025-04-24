import Foundation

public extension SQLiteRawBindable where Self: BinaryInteger {
    /// Provides the `SQLiteRawValue` representation for integer types.
    ///
    /// This implementation converts the integer value to an `SQLiteRawValue` of type `.int`.
    ///
    /// - Returns: An `SQLiteRawValue` of type `.int`, containing the integer value.
    var sqliteRawValue: SQLiteRawValue {
        .int(Int64(self))
    }
}

public extension SQLiteRawRepresentable where Self: BinaryInteger {
    /// Initializes an instance of the conforming type from an `SQLiteRawValue`.
    ///
    /// This initializer handles `SQLiteRawValue` of type `.int`, converting it to the integer value.
    /// It uses the `init(exactly:)` initializer to ensure that the value fits within the range of the
    /// integer type. If the value cannot be exactly represented by the integer type, the initializer
    /// will return `nil`.
    ///
    /// - Parameter sqliteRawValue: The raw SQLite value used to initialize the instance.
    init?(_ sqliteRawValue: SQLiteRawValue) {
        switch sqliteRawValue {
        case .int(let value):
            self.init(exactly: value)
        default:
            return nil
        }
    }
}

extension Int: SQLiteRawRepresentable {}
extension Int8: SQLiteRawRepresentable {}
extension Int16: SQLiteRawRepresentable {}
extension Int32: SQLiteRawRepresentable {}
extension Int64: SQLiteRawRepresentable {}

extension UInt: SQLiteRawRepresentable {}
extension UInt8: SQLiteRawRepresentable {}
extension UInt16: SQLiteRawRepresentable {}
extension UInt32: SQLiteRawRepresentable {}
extension UInt64: SQLiteRawRepresentable {}
