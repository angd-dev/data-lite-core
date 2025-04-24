import Foundation
import DataLiteC

extension Statement {
    /// Provides a set of options for preparing SQLite statements.
    ///
    /// This struct conforms to the `OptionSet` protocol, allowing multiple options to be combined using
    /// bitwise operations. Each option corresponds to a specific SQLite preparation flag.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let options: Statement.Options = [.persistent, .noVtab]
    ///
    /// if options.contains(.persistent) {
    ///     print("Persistent option is set")
    /// }
    ///
    /// if options.contains(.noVtab) {
    ///     print("noVtab option is set")
    /// }
    /// ```
    ///
    /// The example demonstrates how to create an `Options` instance with `persistent` and `noVtab`
    /// options set, and then check each option using the `contains` method.
    ///
    /// ## Topics
    ///
    /// ### Initializers
    ///
    /// - ``init(rawValue:)-(Int32)``
    /// - ``init(rawValue:)-(UInt32)``
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
        
        /// The underlying raw value representing the set of options as a bitmask.
        ///
        /// Each bit in the raw value corresponds to a specific option in the `Statement.Options` set. You can
        /// use this value to perform low-level bitmask operations or to directly initialize an `Options`
        /// instance.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let options = Statement.Options(
        ///     rawValue: SQLITE_PREPARE_PERSISTENT | SQLITE_PREPARE_NO_VTAB
        /// )
        /// print(options.rawValue)  // Output: bitmask representing the combined options
        /// ```
        ///
        /// The example shows how to access the raw bitmask value from an `Options` instance.
        public var rawValue: UInt32
        
        /// Specifies that the prepared statement should be persistent and reusable.
        ///
        /// The `persistent` flag hints to SQLite that the prepared statement will be retained and reused
        /// multiple times. Without this flag, SQLite assumes the statement will be used only once or a few
        /// times and then destroyed.
        ///
        /// The current implementation uses this hint to avoid depleting the limited store of lookaside
        /// memory, potentially improving performance for frequently executed statements. Future versions
        /// of SQLite may handle this flag differently.
        public static let persistent = Self(rawValue: UInt32(SQLITE_PREPARE_PERSISTENT))
        
        /// Specifies that virtual tables should not be used in the prepared statement.
        ///
        /// The `noVtab` flag instructs SQLite to prevent the use of virtual tables when preparing the SQL
        /// statement. This can be useful in cases where the use of virtual tables is undesirable or
        /// restricted by the application logic. If this flag is set, any attempt to access a virtual table
        /// during the execution of the prepared statement will result in an error.
        ///
        /// This option ensures that the prepared statement will only work with standard database tables.
        public static let noVtab = Self(rawValue: UInt32(SQLITE_PREPARE_NO_VTAB))
        
        // MARK: - Inits
        
        /// Initializes an `Options` instance with the given `UInt32` raw value.
        ///
        /// Use this initializer to create a set of options using the raw bitmask value, where each bit
        /// corresponds to a specific option.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let options = Statement.Options(
        ///     rawValue: UInt32(SQLITE_PREPARE_PERSISTENT | SQLITE_PREPARE_NO_VTAB)
        /// )
        /// print(options.contains(.persistent))  // Output: true
        /// print(options.contains(.noVtab))      // Output: true
        /// ```
        ///
        /// - Parameter rawValue: The `UInt32` raw bitmask value representing the set of options.
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        /// Initializes an `Options` instance with the given `Int32` raw value.
        ///
        /// This initializer allows the use of `Int32` values directly, converting them to the `UInt32` type
        /// required for bitmask operations.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let options = Statement.Options(
        ///     rawValue: SQLITE_PREPARE_PERSISTENT | SQLITE_PREPARE_NO_VTAB
        /// )
        /// print(options.contains(.persistent))  // Output: true
        /// print(options.contains(.noVtab))      // Output: true
        /// ```
        ///
        /// - Parameter rawValue: The `Int32` raw bitmask value representing the set of options.
        public init(rawValue: Int32) {
            self.rawValue = UInt32(rawValue)
        }
    }
}
