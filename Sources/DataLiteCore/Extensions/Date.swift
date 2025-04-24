import Foundation

extension Date: SQLiteRawRepresentable {
    /// Provides the `SQLiteRawValue` representation for `Date` types.
    ///
    /// This implementation converts the `Date` value to an `SQLiteRawValue` of type `.text`.
    /// The date is formatted as an ISO 8601 string.
    ///
    /// - Returns: An `SQLiteRawValue` of type `.text`, containing the ISO 8601 string representation of the date.
    public var sqliteRawValue: SQLiteRawValue {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: self)
        return .text(dateString)
    }
    
    /// Initializes an instance of `Date` from an `SQLiteRawValue`.
    ///
    /// This initializer handles `SQLiteRawValue` of type `.text`, converting it from an ISO 8601 string.
    /// It also supports `.int` and `.real` types representing time intervals since 1970.
    ///
    /// - Parameter sqliteRawValue: The raw SQLite value used to initialize the instance.
    public init?(_ sqliteRawValue: SQLiteRawValue) {
        switch sqliteRawValue {
        case .int(let value):
            self.init(timeIntervalSince1970: TimeInterval(value))
        case .real(let value):
            self.init(timeIntervalSince1970: value)
        case .text(let value):
            let formatter = ISO8601DateFormatter()
            if let date = formatter.date(from: value) {
                self = date
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
