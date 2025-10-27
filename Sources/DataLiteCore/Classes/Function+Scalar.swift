import Foundation
import DataLiteC

extension Function {
    /// A base class for defining custom scalar SQLite functions.
    ///
    /// The `Scalar` class provides a foundation for defining scalar functions in SQLite. Scalar
    /// functions take one or more input arguments and return a single value for each function call.
    ///
    /// To define a custom scalar function, subclass `Function.Scalar` and override the following
    /// members:
    ///
    /// - ``name`` – The SQL name of the function.
    /// - ``argc`` – The number of arguments the function accepts.
    /// - ``options`` – Function options, such as `.deterministic` or `.innocuous`.
    /// - ``invoke(args:)`` – The method implementing the function’s logic.
    ///
    /// ### Example
    ///
    /// ```swift
    /// @available(macOS 13.0, *)
    /// final class Regexp: Function.Scalar {
    ///     enum Error: Swift.Error {
    ///         case argumentsWrong
    ///         case regexError(Swift.Error)
    ///     }
    ///
    ///     override class var argc: Int32 { 2 }
    ///     override class var name: String { "REGEXP" }
    ///     override class var options: Function.Options {
    ///         [.deterministic, .innocuous]
    ///     }
    ///
    ///     override class func invoke(
    ///         args: ArgumentsProtocol
    ///     ) throws -> SQLiteRepresentable? {
    ///         guard let regex = args[0] as String?,
    ///               let value = args[1] as String?
    ///         else { throw Error.argumentsWrong }
    ///         do {
    ///             return try Regex(regex).wholeMatch(in: value) != nil
    ///         } catch {
    ///             throw Error.regexError(error)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ### Usage
    ///
    /// To use a custom function, register it with an SQLite connection:
    ///
    /// ```swift
    /// let connection = try Connection(
    ///     path: dbFileURL.path,
    ///     options: [.create, .readwrite]
    /// )
    /// try connection.add(function: Regexp.self)
    /// ```
    ///
    /// ### SQL Example
    ///
    /// After registration, the function becomes available in SQL expressions:
    ///
    /// ```sql
    /// SELECT * FROM users WHERE REGEXP('John.*', name);
    /// ```
    open class Scalar: Function {
        // MARK: - Methods
        
        override class func install(db connection: OpaquePointer) throws(SQLiteError) {
            let context = Context(function: self)
            let ctx = Unmanaged.passRetained(context).toOpaque()
            let status = sqlite3_create_function_v2(
                connection, name, argc, opts, ctx,
                xFunc(_:_:_:), nil, nil, xDestroy(_:)
            )
            if status != SQLITE_OK {
                throw SQLiteError(connection)
            }
        }
        
        /// Implements the logic of the custom scalar function.
        ///
        /// Subclasses must override this method to process the provided arguments and return a
        /// result value for the scalar function call.
        ///
        /// - Parameter args: The set of arguments passed to the function.
        /// - Returns: The result of the function call, represented as ``SQLiteRepresentable``.
        /// - Throws: An error if the arguments are invalid or the computation fails.
        ///
        /// - Note: The default implementation triggers a runtime error.
        open class func invoke(args: any ArgumentsProtocol) throws -> SQLiteRepresentable? {
            fatalError("Subclasses must override this method to implement function logic.")
        }
    }
}

extension Function.Scalar {
    fileprivate final class Context {
        // MARK: - Properties
        
        let function: Scalar.Type
        
        // MARK: - Inits
        
        init(function: Scalar.Type) {
            self.function = function
        }
    }
}

// MARK: - Functions

private func xFunc(
    _ ctx: OpaquePointer?,
    _ argc: Int32,
    _ argv: UnsafeMutablePointer<OpaquePointer?>?
) {
    let function = Unmanaged<Function.Scalar.Context>
        .fromOpaque(sqlite3_user_data(ctx))
        .takeUnretainedValue()
        .function
    
    do {
        let args = Function.Arguments(argc: argc, argv: argv)
        let result = try function.invoke(args: args)
        sqlite3_result_value(ctx, result?.sqliteValue)
    } catch {
        let name = function.name
        let description = error.localizedDescription
        let message = "Error executing function '\(name)': \(description)"
        sqlite3_result_error(ctx, message, -1)
        sqlite3_result_error_code(ctx, SQLITE_ERROR)
    }
}

private func xDestroy(_ ctx: UnsafeMutableRawPointer?) {
    guard let ctx else { return }
    Unmanaged<AnyObject>.fromOpaque(ctx).release()
}
