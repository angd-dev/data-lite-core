import Foundation
import DataLiteC

extension Function {
    /// An option set representing the configuration flags for an SQLite function.
    ///
    /// The `Options` structure defines a set of flags that control the behavior of a user-defined
    /// SQLite function. Multiple options can be combined using bitwise OR operations.
    ///
    /// - SeeAlso: [Function Flags](https://sqlite.org/c3ref/c_deterministic.html)
    public struct Options: OptionSet, Hashable, Sendable {
        // MARK: - Properties
        
        /// The raw integer value representing the combined SQLite function options.
        public var rawValue: Int32
        
        // MARK: - Options
        
        /// Marks the function as deterministic.
        ///
        /// A deterministic function always produces the same output for the same input parameters.
        /// For example, mathematical functions like `sqrt()` or `abs()` are deterministic.
        public static let deterministic = Self(rawValue: SQLITE_DETERMINISTIC)
        
        /// Restricts the function to be invoked only from top-level SQL.
        ///
        /// A function with the `directonly` flag cannot be used in views, triggers, or schema
        /// definitions such as `CHECK` constraints, `DEFAULT` clauses, expression indexes, partial
        /// indexes, or generated columns.
        ///
        /// This option is recommended for functions that may have side effects or expose sensitive
        /// information. It helps prevent attacks involving maliciously crafted database schemas
        /// that attempt to invoke such functions implicitly.
        public static let directonly = Self(rawValue: SQLITE_DIRECTONLY)
        
        /// Marks the function as innocuous.
        ///
        /// The `innocuous` flag indicates that the function is safe even if misused. Such a
        /// function should have no side effects and depend only on its input parameters. For
        /// instance, `abs()` is innocuous, while `load_extension()` is not due to its side effects.
        ///
        /// This option is similar to ``deterministic`` but not identical. For example, `random()`
        /// is innocuous but not deterministic.
        public static let innocuous = Self(rawValue: SQLITE_INNOCUOUS)
        
        // MARK: - Inits
        
        /// Creates a new set of SQLite function options from the specified raw value.
        ///
        /// - Parameter rawValue: The raw value representing the SQLite function options.
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
