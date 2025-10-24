import Foundation

public extension SQLiteBindable where Self: RawRepresentable, RawValue: SQLiteBindable {
    /// Converts a `RawRepresentable` value to its SQLite representation.
    ///
    /// The `rawValue` of the conforming type must itself conform to ``SQLiteBindable``. This
    /// property delegates the conversion to the underlying ``rawValue``.
    ///
    /// - Returns: The ``SQLiteValue`` representation of the underlying ``rawValue``.
    var sqliteValue: SQLiteValue {
        rawValue.sqliteValue
    }
}

public extension SQLiteRepresentable where Self: RawRepresentable, RawValue: SQLiteRepresentable {
    /// Creates a `RawRepresentable` value from an SQLite representation.
    ///
    /// This initializer first attempts to create the underlying ``RawValue`` from the provided
    /// ``SQLiteValue``. If successful, it uses that raw value to initialize the `RawRepresentable`
    /// type. If the conversion fails, the initializer returns `nil`.
    ///
    /// - Parameter value: The SQLite value to convert from.
    /// - Returns: A new instance if the conversion succeeds, or `nil` otherwise.
    init?(_ value: SQLiteValue) {
        if let value = RawValue(value) {
            self.init(rawValue: value)
        } else {
            return nil
        }
    }
}
