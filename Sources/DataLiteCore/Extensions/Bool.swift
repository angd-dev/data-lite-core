import Foundation

extension Bool: SQLiteRawRepresentable {
    /// Provides the `SQLiteRawValue` representation for boolean types.
    ///
    /// This implementation converts the boolean value to an `SQLiteRawValue` of type `.int`.
    /// - `true` is represented as `1`.
    /// - `false` is represented as `0`.
    ///
    /// - Returns: An `SQLiteRawValue` of type `.int`, containing `1` for `true` and `0` for `false`.
    public var sqliteRawValue: SQLiteRawValue {
        .int(self ? 1 : 0)
    }
    
    /// Initializes an instance of the conforming type from an `SQLiteRawValue`.
    ///
    /// This initializer handles `SQLiteRawValue` of type `.int`, converting it to a boolean value.
    /// - `1` is converted to `true`.
    /// - `0` is converted to `false`.
    ///
    /// If the integer value is not `0` or `1`, the initializer returns `nil`.
    ///
    /// - Parameter sqliteRawValue: The raw SQLite value used to initialize the instance.
    public init?(_ sqliteRawValue: SQLiteRawValue) {
        switch sqliteRawValue {
        case .int(let value) where value == 0 || value == 1:
            self = value == 1
        default:
            return nil
        }
    }
}
