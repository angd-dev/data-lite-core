import Foundation

/// An enumeration that represents the different types of raw values in an SQLite database.
///
/// This type is used to store values retrieved from or stored in an SQLite database. It supports
/// various data types such as integers, floating-point numbers, text, binary data, and null values.
/// For more details, refer to [Datatypes In SQLite](https://www.sqlite.org/datatype3.html).
///
/// ## Example
///
/// ```swift
/// let integerValue: SQLiteRawValue = .int(42)
/// let realValue: SQLiteRawValue = .real(3.14)
/// let textValue: SQLiteRawValue = .text("Hello, SQLite")
/// let blobValue: SQLiteRawValue = .blob(Data([0x01, 0x02, 0x03]))
/// let nullValue: SQLiteRawValue = .null
/// ```
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
public enum SQLiteRawValue: Equatable {
    /// Represents a 64-bit integer value.
    case int(Int64)
    
    /// Represents a floating-point number.
    case real(Double)
    
    /// Represents a text string.
    case text(String)
    
    /// Represents binary large objects (BLOBs).
    case blob(Data)
    
    /// Represents a SQL `NULL` value.
    case null
}

extension SQLiteRawValue: SQLiteLiteralable {
    /// Returns a string representation of the value suitable for use in SQL queries.
    ///
    /// This method converts the `SQLiteRawValue` into a format that is directly usable in SQL statements:
    /// - For `.int`: Converts the integer to its string representation.
    /// - For `.real`: Converts the floating-point number to its string representation.
    /// - For `.text`: Escapes single quotes within the string and wraps the result in single quotes.
    /// - For `.blob`: Converts the binary data to a hexadecimal string representation, formatted as `X'...'`.
    /// - For `.null`: Returns the SQL literal `"NULL"`.
    ///
    /// The resulting string is formatted for inclusion in SQL queries, ensuring proper handling of the value
    /// according to SQL syntax.
    ///
    /// - Returns: A string representation of the value, formatted for use in SQL queries.
    public var sqliteLiteral: String {
        switch self {
        case .int(let int):     return "\(int)"
        case .real(let real):   return "\(real)"
        case .text(let text):   return "'\(text.replacingOccurrences(of: "'", with: "''"))'"
        case .blob(let data):   return "X'\(data.hex)'"
        case .null:             return "NULL"
        }
    }
}

extension SQLiteRawValue: CustomStringConvertible {
    /// A textual representation of the `SQLiteRawValue`.
    ///
    /// This property returns the string representation of the `SQLiteRawValue` as defined by the `sqliteLiteral` method.
    /// It provides a clear and readable format of the value, useful for debugging and logging purposes.
    ///
    /// - Returns: A string that represents the `SQLiteRawValue` in a format suitable for display.
    public var description: String {
        return sqliteLiteral
    }
}

extension Data {
    /// Converts the data to a hexadecimal string representation.
    ///
    /// This method converts each byte of the `Data` instance into its two-digit hexadecimal representation.
    /// The hexadecimal values are concatenated into a single string. This is useful for representing binary data
    /// in a human-readable format, particularly for SQL BLOB literals.
    ///
    /// ## Example
    /// ```swift
    /// let data = Data([0x01, 0x02, 0x03])
    /// print(data.hex)  // Output: "010203"
    /// ```
    ///
    /// - Returns: A hexadecimal string representation of the data.
    var hex: String {
        return map { String(format: "%02hhX", $0) }.joined()
    }
}
