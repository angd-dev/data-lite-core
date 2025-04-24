import Foundation
import DataLiteC

extension Function {
    /// A collection representing the arguments passed to an SQLite function.
    ///
    /// This structure provides a collection interface to access the arguments passed to an SQLite
    /// function. Each argument is represented by an instance of `SQLiteValue`, which can hold
    /// various types of SQLite values such as integers, floats, text, blobs, or nulls.
    ///
    /// - Important: This collection does not perform bounds checking when accessing arguments via
    /// subscripts. It is the responsibility of the caller to ensure that the provided index is within the bounds
    /// of the argument list.
    ///
    /// - Important: The indices of this collection start from 0 and go up to, but not including, the
    /// count of arguments.
    public struct Arguments: Collection {
        /// Alias for the type representing an element in `Arguments`, which is a `SQLiteValue`.
        public typealias Element = SQLiteRawValue
        
        /// Alias for the index type used in `Arguments`.
        public typealias Index = Int
        
        // MARK: - Properties
        
        /// The number of arguments passed to the SQLite function.
        private let argc: Int32
        
        /// A pointer to an array of `OpaquePointer?` representing SQLite values.
        private let argv: UnsafeMutablePointer<OpaquePointer?>?
        
        /// The number of arguments passed to the SQLite function.
        public var count: Int {
            Int(argc)
        }
        
        /// A Boolean value indicating whether there are no arguments passed to the SQLite function.
        public var isEmpty: Bool {
            count == 0
        }
        
        /// The starting index of the arguments passed to the SQLite function.
        public var startIndex: Index {
            0
        }
        
        /// The ending index of the arguments passed to the SQLite function.
        public var endIndex: Index {
            count
        }
        
        // MARK: - Inits
        
        /// Initializes the argument list with the provided count and pointer to SQLite values.
        ///
        /// - Parameters:
        ///   - argc: The number of arguments.
        ///   - argv: A pointer to an array of `OpaquePointer?` representing SQLite values.
        init(argc: Int32, argv: UnsafeMutablePointer<OpaquePointer?>?) {
            self.argc = argc
            self.argv = argv
        }
        
        // MARK: - Subscripts
        
        /// Accesses the SQLite value at the specified index.
        ///
        /// - Parameter index: The index of the SQLite value to access.
        /// - Returns: The SQLite value at the specified index.
        ///
        /// This subscript allows accessing the SQLite value at a specific index within the argument list.
        /// If the index is out of bounds, a fatal error is triggered.
        ///
        /// - Complexity: O(1)
        public subscript(index: Index) -> Element {
            guard count > index else {
                fatalError("\(index) out of bounds")
            }
            let arg = argv.unsafelyUnwrapped[index]
            switch sqlite3_value_type(arg) {
            case SQLITE_INTEGER:    return .int(sqlite3_value_int64(arg))
            case SQLITE_FLOAT:      return .real(sqlite3_value_double(arg))
            case SQLITE_TEXT:       return .text(sqlite3_value_text(arg))
            case SQLITE_BLOB:       return .blob(sqlite3_value_blob(arg))
            default:                return .null
            }
        }
        
        /// Accesses the SQLite value at the specified index and converts it to a type conforming to
        /// `SQLiteConvertible`.
        ///
        /// - Parameter index: The index of the SQLite value to access.
        /// - Returns: The SQLite value at the specified index, converted to the specified type,
        /// or `nil` if conversion fails.
        ///
        /// This subscript allows accessing the SQLite value at a specific index within the argument
        /// list and converting it to a type conforming to `SQLiteConvertible`.
        ///
        /// - Complexity: O(1)
        public subscript<T: SQLiteRawRepresentable>(index: Index) -> T? {
            T(self[index])
        }
        
        // MARK: - Methods
        
        /// Returns the index after the specified index.
        ///
        /// - Parameter i: The index.
        /// - Returns: The index immediately after the specified index.
        ///
        /// This method is used to advance to the next index in the argument list when iterating over
        /// its elements.
        ///
        /// - Complexity: O(1)
        public func index(after i: Index) -> Index {
            i + 1
        }
    }
}

// MARK: - Functions

/// Retrieves the textual data from an SQLite value.
///
/// - Parameter value: An opaque pointer to an SQLite value.
/// - Returns: A `String` representing the text value extracted from the SQLite value.
///
/// This function retrieves the textual data from an SQLite value and converts it into a Swift `String`.
///
/// - Note: The returned string may contain UTF-8 encoded text.
/// - Note: Ensure the provided `OpaquePointer` is valid and points to a valid SQLite value.
/// Passing a null pointer will result in undefined behavior.
///
/// - Important: This function does not perform error checking for null pointers or invalid SQLite values.
/// It is the responsibility of the caller to ensure the validity of the provided pointer.
///
/// - SeeAlso: [SQLite Documentation](https://www.sqlite.org/index.html)
private func sqlite3_value_text(_ value: OpaquePointer!) -> String {
    String(cString: DataLiteC.sqlite3_value_text(value))
}

/// Retrieves binary data from an SQLite value.
///
/// - Parameter value: An opaque pointer to an SQLite value.
/// - Returns: A `Data` object representing the binary data extracted from the SQLite value.
///
/// This function retrieves binary data from an SQLite value and converts it into a Swift `Data` object.
///
/// - Note: Ensure the provided `OpaquePointer` is valid and points to a valid SQLite value.
/// Passing a null pointer will result in undefined behavior.
///
/// - Important: This function does not perform error checking for null pointers or invalid SQLite values.
/// It is the responsibility of the caller to ensure the validity of the provided pointer.
///
/// - SeeAlso: [SQLite Documentation](https://www.sqlite.org/index.html)
private func sqlite3_value_blob(_ value: OpaquePointer!) -> Data {
    Data(
        bytes: sqlite3_value_blob(value),
        count: Int(sqlite3_value_bytes(value))
    )
}
