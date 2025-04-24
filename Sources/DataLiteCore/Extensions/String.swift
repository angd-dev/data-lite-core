import Foundation

extension String: SQLiteRawRepresentable {
    /// Provides the `SQLiteRawValue` representation for `String` type.
    ///
    /// This implementation converts the `String` value to an `SQLiteRawValue` of type `.text`.
    ///
    /// - Returns: An `SQLiteRawValue` of type `.text`, containing the string value.
    public var sqliteRawValue: SQLiteRawValue {
        .text(self)
    }
    
    /// Initializes an instance of `String` from an `SQLiteRawValue`.
    ///
    /// This initializer handles `SQLiteRawValue` of type `.text`, converting it to a `String` value.
    ///
    /// - Parameter sqliteRawValue: The raw SQLite value used to initialize the instance.
    public init?(_ sqliteRawValue: SQLiteRawValue) {
        switch sqliteRawValue {
        case .text(let value):
            self = value
        default:
            return nil
        }
    }
}
