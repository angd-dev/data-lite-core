import Foundation
import DataLiteC

extension Function {
    /// A collection representing the arguments passed to an SQLite function.
    ///
    /// The `Arguments` structure provides a type-safe interface for accessing the arguments
    /// received by a user-defined SQLite function. Each element of the collection is represented
    /// by a ``SQLiteValue`` instance that can store integers, floating-point numbers, text, blobs,
    /// or nulls.
    public struct Arguments: ArgumentsProtocol {
        // MARK: - Properties
        
        private let argc: Int32
        private let argv: UnsafeMutablePointer<OpaquePointer?>?
        
        /// The number of arguments passed to the SQLite function.
        public var count: Int {
            Int(argc)
        }
        
        /// A Boolean value indicating whether there are no arguments.
        public var isEmpty: Bool {
            count == 0
        }
        
        /// The index of the first argument.
        public var startIndex: Index {
            0
        }
        
        /// The index immediately after the last valid argument.
        public var endIndex: Index {
            count
        }
        
        // MARK: - Inits
        
        init(argc: Int32, argv: UnsafeMutablePointer<OpaquePointer?>?) {
            self.argc = argc
            self.argv = argv
        }
        
        // MARK: - Subscripts
        
        /// Returns the SQLite value at the specified index.
        ///
        /// Retrieves the raw value from the SQLite function arguments and returns it as an
        /// instance of ``SQLiteValue``.
        ///
        /// - Parameter index: The index of the argument to retrieve.
        /// - Returns: The SQLite value at the specified index.
        /// - Complexity: O(1)
        public subscript(index: Index) -> Element {
            guard index < count else {
                fatalError("Index \(index) out of bounds")
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
        
        // MARK: - Methods
        
        /// Returns the index that follows the specified index.
        ///
        /// - Parameter i: The current index.
        /// - Returns: The index immediately after the specified one.
        /// - Complexity: O(1)
        public func index(after i: Index) -> Index {
            i + 1
        }
    }
}

// MARK: - Functions

private func sqlite3_value_text(_ value: OpaquePointer!) -> String {
    String(cString: DataLiteC.sqlite3_value_text(value))
}

private func sqlite3_value_blob(_ value: OpaquePointer!) -> Data {
    Data(
        bytes: sqlite3_value_blob(value),
        count: Int(sqlite3_value_bytes(value))
    )
}
