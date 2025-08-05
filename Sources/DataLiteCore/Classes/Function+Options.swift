import Foundation
import DataLiteC

extension Function {
    /// An option set representing the options for an SQLite function.
    ///
    /// This structure defines an option set to configure various options for an SQLite function.
    /// Options can be combined using bitwise OR operations.
    ///
    /// Example usage:
    /// ```swift
    /// let options: Function.Options = [.deterministic, .directonly]
    /// ```
    ///
    /// - SeeAlso: [SQLite Function Flags](https://www.sqlite.org/c3ref/c_deterministic.html)
    public struct Options: OptionSet, Hashable, Sendable {
        // MARK: - Properties
        
        /// The raw value type used to store the SQLite function options.
        public var rawValue: Int32
        
        // MARK: - Options
        
        /// Indicates that the function is deterministic.
        ///
        /// A deterministic function always gives the same output when it has the same input parameters.
        /// For example, a mathematical function like sqrt() is deterministic.
        public static let deterministic = Self(rawValue: SQLITE_DETERMINISTIC)
        
        /// Indicates that the function may only be invoked from top-level SQL.
        ///
        /// A function with the `directonly` option cannot be used in a VIEWs or TRIGGERs, or in schema structures
        /// such as CHECK constraints, DEFAULT clauses, expression indexes, partial indexes, or generated columns.
        ///
        /// The `directonly` option is recommended for any application-defined SQL function that has side-effects
        /// or that could potentially leak sensitive information. This will prevent attacks in which an application
        /// is tricked into using a database file that has had its schema surreptitiously modified to invoke the
        /// application-defined function in ways that are harmful.
        public static let directonly = Self(rawValue: SQLITE_DIRECTONLY)
        
        /// Indicates that the function is innocuous.
        ///
        /// The `innocuous` option means that the function is unlikely to cause problems even if misused.
        /// An innocuous function should have no side effects and should not depend on any values other
        /// than its input parameters.
        /// The `abs()` function is an example of an innocuous function.
        /// The `load_extension()` SQL function is not innocuous because of its side effects.
        ///
        /// `innocuous` is similar to `deterministic`, but is not exactly the same.
        /// The `random()` function is an example of a function that is innocuous but not deterministic.
        public static let innocuous = Self(rawValue: SQLITE_INNOCUOUS)
        
        // MARK: - Inits
        
        /// Creates an SQLite function option set from a raw value.
        ///
        /// - Parameter rawValue: The raw value representing the SQLite function options.
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
