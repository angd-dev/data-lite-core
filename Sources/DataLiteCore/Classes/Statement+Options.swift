import Foundation
import DataLiteC

extension Statement {
    /// A set of options that control how an SQLite statement is prepared.
    ///
    /// `Options` conforms to the `OptionSet` protocol, allowing multiple flags to be combined.
    /// Each option corresponds to a specific SQLite preparation flag.
    ///
    /// - SeeAlso: [Prepare Flags](https://sqlite.org/c3ref/c_prepare_normalize.html)
    ///
    /// ## Topics
    ///
    /// ### Initializers
    ///
    /// - ``init(rawValue:)-(UInt32)``
    /// - ``init(rawValue:)-(Int32)``
    ///
    /// ### Instance Properties
    ///
    /// - ``rawValue``
    ///
    /// ### Type Properties
    ///
    /// - ``persistent``
    /// - ``noVtab``
    public struct Options: OptionSet, Sendable {
        // MARK: - Properties
        
        /// The raw bitmask value that represents the combined options.
        ///
        /// Each bit in the mask corresponds to a specific SQLite preparation flag. ou can use this
        /// value for low-level bitwise operations or to construct an `Options` instance directly.
        public var rawValue: UInt32
        
        /// Indicates that the prepared statement is persistent and reusable.
        ///
        /// This flag hints to SQLite that the prepared statement will be kept and reused multiple
        /// times. Without this hint, SQLite assumes the statement will be used only a few times and
        /// then destroyed.
        ///
        /// Using `.persistent` can help avoid excessive lookaside memory usage and improve
        /// performance for frequently executed statements.
        public static let persistent = Self(rawValue: SQLITE_PREPARE_PERSISTENT)
        
        /// Disables the use of virtual tables in the prepared statement.
        ///
        /// When this flag is set, any attempt to reference a virtual table during statement
        /// preparation results in an error. Use this option when virtual tables are restricted or
        /// undesirable for security or policy reasons.
        public static let noVtab = Self(rawValue: SQLITE_PREPARE_NO_VTAB)
        
        // MARK: - Inits
        
        /// Creates a new set of options from a raw `UInt32` bitmask value.
        ///
        /// - Parameter rawValue: The bitmask value that represents the combined options.
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        /// Creates a new set of options from a raw `Int32` bitmask value.
        ///
        /// This initializer allows working directly with SQLite C constants that use
        /// 32-bit integers.
        ///
        /// - Parameter rawValue: The bitmask value that represents the combined options.
        public init(rawValue: Int32) {
            self.rawValue = UInt32(rawValue)
        }
    }
}
