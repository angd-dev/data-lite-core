import Foundation

extension UUID: SQLiteRawRepresentable {
    /// Provides the `SQLiteRawValue` representation for `UUID`.
    ///
    /// This implementation converts the `UUID` value to an `SQLiteRawValue` of type `.text`.
    ///
    /// - Returns: An `SQLiteRawValue` of type `.text`, containing the UUID string.
    public var sqliteRawValue: SQLiteRawValue {
        .text(self.uuidString)
    }
    
    /// Initializes an instance of `UUID` from an `SQLiteRawValue`.
    ///
    /// This initializer handles `SQLiteRawValue` of type `.text`, converting it to a `UUID`.
    ///
    /// - Parameter sqliteRawValue: The raw SQLite value used to initialize the instance.
    public init?(_ sqliteRawValue: SQLiteRawValue) {
        switch sqliteRawValue {
        case .text(let value):
            self.init(uuidString: value)
        default:
            return nil
        }
    }
}
