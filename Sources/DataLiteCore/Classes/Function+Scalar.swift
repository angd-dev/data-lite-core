import Foundation
import DataLiteC

extension Function {
    /// A base class for creating custom scalar SQLite functions.
    ///
    /// This class provides a base implementation for creating scalar functions in SQLite.
    /// Scalar functions take one or more input arguments and return a single value. To
    /// create a custom scalar function, subclass `Function.Scalar` and override the
    /// ``name``, ``argc``, ``options``, and ``invoke(args:)`` methods.
    ///
    /// ### Example
    ///
    /// To create a custom scalar function, subclass `Function.Scalar` and implement the
    /// required methods. Here's an example of creating a custom `REGEXP` function that
    /// checks if a string matches a regular expression.
    ///
    /// ```swift
    /// @available(macOS 13.0, *)
    /// final class Regexp: Function.Scalar {
    ///     enum Error: Swift.Error {
    ///         case argumentsWrong
    ///         case regexError(Swift.Error)
    ///     }
    ///
    ///     // MARK: - Properties
    ///
    ///     override class var argc: Int32 { 2 }
    ///     override class var name: String { "REGEXP" }
    ///     override class var options: Function.Options {
    ///         [.deterministic, .innocuous]
    ///     }
    ///
    ///     // MARK: - Methods
    ///
    ///     override class func invoke(
    ///         args: Function.Arguments
    ///     ) throws -> SQLiteRawRepresentable? {
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
    /// Once you've created your custom function, you need to install it into the SQLite database
    /// connection. Here's how you can add the `Regexp` function to a ``Connection`` instance:
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
    /// With the `Regexp` function installed, you can use it in your SQL queries. For
    /// example, to find rows where the `name` column matches the regular expression
    /// `John.*`, you would write:
    ///
    /// ```sql
    /// -- Find rows where 'name' column matches the regular expression 'John.*'
    /// SELECT * FROM users WHERE REGEXP('John.*', name);
    /// ```
    open class Scalar: Function {
        // MARK: - Context
        
        /// A helper class to store and manage context for a custom scalar SQLite function.
        ///
        /// This class is used internally to hold a reference to the `Scalar` function
        /// implementation. It is created and managed during the installation of the scalar
        /// function into the SQLite database connection. The context is passed to SQLite
        /// and used to call the appropriate function implementation when the function is
        /// invoked.
        fileprivate final class Context {
            // MARK: Properties
            
            /// The type of the `Scalar` function being managed.
            ///
            /// This property holds a reference to the `Scalar` subclass that implements the
            /// custom scalar function logic. It is used to invoke the function with the
            /// provided arguments.
            let function: Scalar.Type
            
            // MARK: Inits
            
            /// Initializes a new `Context` with a reference to the `Scalar` function type.
            ///
            /// - Parameter function: The `Scalar` subclass that implements the custom scalar
            ///   function.
            init(function: Scalar.Type) {
                self.function = function
            }
        }
        
        // MARK: - Methods
        
        /// Installs a custom scalar SQLite function into the specified database connection.
        ///
        /// This method registers the scalar function with the SQLite database. It creates
        /// a `Context` object to hold a reference to the function implementation and sets up
        /// the function using `sqlite3_create_function_v2`. The context is passed to SQLite,
        /// allowing the implementation to be called later.
        ///
        /// ```swift
        /// // Assume the database connection is already open
        /// let db: OpaquePointer = ...
        /// // Registering the function in the database
        /// try MyCustomScalar.install(db: db)
        /// ```
        ///
        /// - Parameter connection: A pointer to the SQLite database connection where the
        ///   function will be installed.
        ///
        /// - Throws: ``Connection/Error`` if the function installation fails. This error occurs if
        ///   the call to `sqlite3_create_function_v2` does not return `SQLITE_OK`.
        ///
        /// - Note: This method should be called to register the custom function before using
        ///   it in SQL queries. Ensure the database connection is open and available at the
        ///   time of this method call.
        override class func install(db connection: OpaquePointer) throws(Connection.Error) {
            let context = Context(function: self)
            let ctx = Unmanaged.passRetained(context).toOpaque()
            let status = sqlite3_create_function_v2(
                connection, name, argc, opts, ctx,
                xFunc(_:_:_:), nil, nil, xDestroy(_:)
            )
            if status != SQLITE_OK {
                throw Connection.Error(connection)
            }
        }
        
        /// Implementation of the custom scalar function.
        ///
        /// This method must be overridden by subclasses to implement the specific logic
        /// of the function. Your implementation should handle the input arguments and return
        /// the result as ``SQLiteRawRepresentable``.
        ///
        /// - Parameter args: An ``Arguments`` object containing the input arguments of the
        ///   function.
        ///
        /// - Returns: The result of the function execution, represented as
        ///   ``SQLiteRawRepresentable``.
        ///
        /// - Throws: An error if the function execution fails. Subclasses can throw
        ///   errors for invalid input values or other issues during processing.
        ///
        /// - Note: It is important to override this method in subclasses; otherwise,
        ///   a runtime error will occur due to calling `fatalError()`.
        open class func invoke(args: Arguments) throws -> SQLiteRawRepresentable? {
            fatalError("Subclasses must override this method to implement function logic.")
        }
    }
}

// MARK: - Functions

/// The C function callback for executing a custom SQLite scalar function.
///
/// This function is called by SQLite when the scalar function is invoked. It retrieves the
/// function implementation from the context associated with the SQLite query, invokes the
/// function with the provided arguments, and sets the result of the query based on the
/// returned value. If an error occurs during the function invocation, it sets an error
/// message.
///
/// - Parameters:
///   - ctx: A pointer to the SQLite context associated with the current query. This context
///     contains information about the query execution and is used to set the result or error.
///   - argc: The number of arguments passed to the function. This is used to determine how
///     many arguments are available in the `argv` array.
///   - argv: An array of pointers to the values of the arguments passed to the function. Each
///     pointer corresponds to a value that the function will process.
///
/// - Note: The `xFunc` function should handle the function invocation logic, including
///   argument extraction and result setting. It should also handle errors by setting
///   appropriate error messages using `sqlite3_result_error`.
private func xFunc(
    _ ctx: OpaquePointer?,
    _ argc: Int32,
    _ argv: UnsafeMutablePointer<OpaquePointer?>?
) {
    let context = Unmanaged<Function.Scalar.Context>
        .fromOpaque(sqlite3_user_data(ctx))
        .takeUnretainedValue()
    
    do {
        let args = Function.Arguments(argc: argc, argv: argv)
        let result = try context.function.invoke(args: args)
        sqlite3_result_value(ctx, result?.sqliteRawValue)
    } catch {
        let name = context.function.name
        let description = error.localizedDescription
        let message = "Error executing function '\(name)': \(description)"
        sqlite3_result_error(ctx, message, -1)
    }
}

/// The C function callback for destroying the context associated with a custom SQLite scalar function.
///
/// This function is called by SQLite when the function is uninstalled. It releases the memory
/// allocated for the `Context` object associated with the function to avoid memory leaks.
///
/// - Parameter ctx: A pointer to the context of the SQLite query. This context contains the
///   `Context` object that should be released.
///
/// - Note: The `xDestroy` function should only release the memory allocated for the `Context`
///   object. It should not perform any other operations or access the context beyond freeing
///   the memory.
private func xDestroy(_ ctx: UnsafeMutableRawPointer?) {
    guard let ctx else { return }
    Unmanaged<AnyObject>.fromOpaque(ctx).release()
}
