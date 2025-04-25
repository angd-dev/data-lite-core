import Foundation
import DataLiteC

/// Represents different types of columns in an SQLite database.
///
/// The `SQLiteRawType` enum encapsulates the various data types that SQLite supports for columns.
/// Each case in the enum corresponds to a specific SQLite data type, providing a way to work with these
/// types in a type-safe manner. This enum allows for easier handling of SQLite column types by abstracting
/// their raw representations and offering more readable code.
/// For more details, refer to [Datatypes In SQLite](https://www.sqlite.org/datatype3.html).
///
/// ## Topics
///
/// ### Enumeration Cases
///
/// - ``int``
/// - ``real``
/// - ``text``
/// - ``blob``
/// - ``null``
///
/// ### Instance Properties
///
/// - ``rawValue``
///
/// ### Initializers
///
/// - ``init(rawValue:)``
public enum SQLiteRawType: Int32 {
    /// The data type of an integer column.
    case int
    
    /// The data type of a real (floating point) column.
    case real
    
    /// The data type of a text (string) column.
    case text
    
    /// The data type of a blob (binary large object) column.
    case blob
    
    /// The data type of a NULL column.
    case null
    
    /// Returns the raw SQLite data type value corresponding to the column type.
    ///
    /// This computed property provides the raw integer value used by SQLite to represent each column type.
    ///
    /// - Returns: An `Int32` representing the SQLite data type constant.
    public var rawValue: Int32 {
        switch self {
        case .int:  return SQLITE_INTEGER
        case .real: return SQLITE_FLOAT
        case .text: return SQLITE_TEXT
        case .blob: return SQLITE_BLOB
        case .null: return SQLITE_NULL
        }
    }
    
    /// Initializes a `SQLiteRawType` enum case from its raw value.
    ///
    /// This initializer maps a raw `Int32` value (SQLite constant) to the corresponding enum case.
    ///
    /// - Parameter rawValue: The raw value representing the column type as defined by SQLite.
    public init?(rawValue: Int32) {
        switch rawValue {
        case SQLITE_INTEGER:    self = .int
        case SQLITE_FLOAT:      self = .real
        case SQLITE_TEXT:       self = .text
        case SQLITE_BLOB:       self = .blob
        case SQLITE_NULL:       self = .null
        default:                return nil
        }
    }
}
