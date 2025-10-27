import Foundation

extension Function {
    /// A scalar SQL function that performs regular expression matching.
    ///
    /// This function checks whether a given string matches a specified regular expression pattern
    /// and returns `true` if it matches, or `false` otherwise.
    ///
    /// ```swift
    /// let connection = try Connection(
    ///     location: .inMemory,
    ///     options: [.create, .readwrite]
    /// )
    /// try connection.add(function: Function.Regexp.self)
    ///
    /// try connection.execute(sql: """
    ///     SELECT * FROM users WHERE name REGEXP 'John.*';
    /// """)
    /// ```
    @available(iOS 16.0, *)
    @available(macOS 13.0, *)
    public final class Regexp: Scalar {
        /// Errors that can occur during the evaluation of the `REGEXP` function.
        public enum Error: Swift.Error {
            /// Thrown when the arguments provided to the function are invalid.
            case invalidArguments
            
            /// Thrown when an error occurs while processing the regular expression.
            /// - Parameter error: The underlying error from the regex operation.
            case regexError(Swift.Error)
        }
        
        // MARK: - Properties
        
        /// The number of arguments required by the function.
        ///
        /// The `REGEXP` function expects exactly two arguments:
        /// 1. A string containing the regular expression pattern.
        /// 2. A string value to be evaluated against the pattern.
        public override class var argc: Int32 { 2 }
        
        /// The name of the SQL function.
        ///
        /// The SQL function can be invoked in queries using the name `REGEXP`.
        public override class var name: String { "REGEXP" }
        
        /// Options that define the behavior of the SQL function.
        ///
        /// - `deterministic`: Ensures the same result is returned for identical inputs.
        /// - `innocuous`: Indicates the function does not have any side effects.
        public override class var options: Options {
            [.deterministic, .innocuous]
        }
        
        // MARK: - Methods
        
        /// Invokes the `REGEXP` function to evaluate whether a string matches a regular expression.
        ///
        /// - Parameters:
        ///   - args: The arguments provided to the SQL function.
        ///     - `args[0]`: The regular expression pattern as a `String`.
        ///     - `args[1]`: The value to match against the pattern as a `String`.
        /// - Returns: `true` if the value matches the pattern, `false` otherwise.
        /// - Throws: ``Error/invalidArguments`` if the arguments are invalid or missing.
        /// - Throws: ``Error/regexError(_:)`` if an error occurs during regex evaluation.
        public override class func invoke(
            args: any ArgumentsProtocol
        ) throws -> SQLiteRepresentable? {
            guard let regex = args[0] as String?,
                  let value = args[1] as String?
            else { throw Error.invalidArguments }
            
            do {
                return try Regex(regex).wholeMatch(in: value) != nil
            } catch {
                throw Error.regexError(error)
            }
        }
    }
}
