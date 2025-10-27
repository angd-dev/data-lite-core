import Foundation

/// An enumeration that represents raw SQLite values.
///
/// `SQLiteValue` encapsulates all fundamental SQLite storage classes. It is used to
/// store values retrieved from or written to a SQLite database, providing a type-safe
/// Swift representation for each supported data type.
///
/// - SeeAlso: [Datatypes In SQLite](https://sqlite.org/datatype3.html)
///
/// ## Topics
///
/// ### Enumeration Cases
///
/// - ``int(_:)``
/// - ``real(_:)``
/// - ``text(_:)``
/// - ``blob(_:)``
/// - ``null``
public enum SQLiteValue: Equatable, Hashable, Sendable {
    /// A 64-bit integer value.
    case int(Int64)
    
    /// A double-precision floating-point value.
    case real(Double)
    
    /// A text string encoded in UTF-8.
    case text(String)
    
    /// Binary data (BLOB).
    case blob(Data)
    
    /// A `NULL` value.
    case null
}

public extension SQLiteValue {
    /// A SQL literal representation of the value.
    ///
    /// Converts the current value into a string suitable for embedding directly in an SQL
    /// statement. Strings are quoted and escaped, binary data is encoded in hexadecimal form, and
    /// `NULL` is represented by the literal `NULL`.
    var sqliteLiteral: String {
        switch self {
        case .int(let int):     "\(int)"
        case .real(let real):   "\(real)"
        case .text(let text):   "'\(text.replacingOccurrences(of: "'", with: "''"))'"
        case .blob(let data):   "X'\(data.hex)'"
        case .null:             "NULL"
        }
    }
}

extension SQLiteValue: CustomStringConvertible {
    /// A textual representation of the value, identical to `sqliteLiteral`.
    public var description: String {
        sqliteLiteral
    }
}

private extension Data {
    var hex: String {
        map { String(format: "%02hhX", $0) }.joined()
    }
}
