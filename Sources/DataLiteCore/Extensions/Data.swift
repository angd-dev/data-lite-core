import Foundation

extension Data: SQLiteRawRepresentable {
    /// Provides the `SQLiteRawValue` representation for `Data` types.
    ///
    /// This implementation converts the `Data` value to an `SQLiteRawValue` of type `.blob`.
    ///
    /// - Returns: An `SQLiteRawValue` of type `.blob`, containing the data.
    public var sqliteRawValue: SQLiteRawValue {
        .blob(self)
    }
    
    /// Initializes an instance of the conforming type from an `SQLiteRawValue`.
    ///
    /// This initializer handles `SQLiteRawValue` of type `.blob`, converting it to `Data`.
    ///
    /// - Parameter sqliteRawValue: The raw SQLite value used to initialize the instance.
    public init?(_ sqliteRawValue: SQLiteRawValue) {
        switch sqliteRawValue {
        case .blob(let data):
            self = data
        default:
            return nil
        }
    }
}
