import Foundation

public extension SQLiteRawBindable where Self: RawRepresentable, RawValue: SQLiteRawBindable {
    /// Provides the `SQLiteRawValue` representation for `RawRepresentable` types.
    ///
    /// This implementation converts the `RawRepresentable` type's `rawValue` to its corresponding
    /// `SQLiteRawValue` representation. The `rawValue` itself must conform to `SQLiteRawBindable`.
    ///
    /// - Returns: An `SQLiteRawValue` representation of the `RawRepresentable` type.
    var sqliteRawValue: SQLiteRawValue {
        rawValue.sqliteRawValue
    }
}

public extension SQLiteRawRepresentable where Self: RawRepresentable, RawValue: SQLiteRawRepresentable {
    /// Initializes an instance of the conforming type from an `SQLiteRawValue`.
    ///
    /// This initializer converts the `SQLiteRawValue` to the `RawRepresentable` type's `rawValue`.
    /// It first attempts to create a `RawValue` from the `SQLiteRawValue`, then uses that to initialize
    /// the `RawRepresentable` instance. If the `SQLiteRawValue` cannot be converted to the `RawValue`, the
    /// initializer returns `nil`.
    ///
    /// - Parameter sqliteRawValue: The raw SQLite value used to initialize the instance.
    init?(_ sqliteRawValue: SQLiteRawValue) {
        if let value = RawValue(sqliteRawValue) {
            self.init(rawValue: value)
        } else {
            return nil
        }
    }
}
