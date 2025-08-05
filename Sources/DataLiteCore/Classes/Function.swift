import Foundation
import DataLiteC

/// A base class representing a custom SQLite function.
///
/// This class provides a framework for defining custom functions in SQLite. Subclasses must
/// override specific properties and methods to define the function's behavior, including
/// its name, argument count, and options.
///
/// To create a custom SQLite function, you should subclass either ``Scalar`` or
/// ``Aggregate`` depending on whether your function is a scalar function (returns
/// a single result) or an aggregate function (returns a result accumulated from multiple
/// rows). The subclass will then override the necessary properties and methods to implement
/// the function's behavior.
///
/// ## Topics
///
/// ### Base Function Classes
///
/// - ``Aggregate``
/// - ``Scalar``
///
/// ### Custom Function Classes
///
/// - ``Regexp``
open class Function {
    // MARK: - Properties
    
    /// The number of arguments that the custom SQLite function accepts.
    ///
    /// This property must be overridden by subclasses to specify how many arguments
    /// the function expects. The value should be a positive integer representing the
    /// number of arguments, or zero if the function does not accept arguments.
    open class var argc: Int32 {
        fatalError("Subclasses must override this property to specify the number of arguments.")
    }
    
    /// The name of the custom SQLite function.
    ///
    /// This property must be overridden by subclasses to provide the name that the SQLite
    /// engine will use to identify the function. The name should be a valid SQLite function
    /// name according to SQLite naming conventions.
    open class var name: String {
        fatalError("Subclasses must override this property to provide the function name.")
    }
    
    /// The options for the custom SQLite function.
    ///
    /// This property must be overridden by subclasses to specify options such as whether the
    /// function is deterministic or not. Options are represented as a bitmask of `Function.Options`.
    open class var options: Options {
        fatalError("Subclasses must override this property to specify function options.")
    }
    
    /// The encoding used by the function, which defaults to UTF-8.
    ///
    /// This is used to set the encoding for text data in the custom SQLite function. The default
    /// encoding is UTF-8, but this can be modified if necessary. This encoding is combined with
    /// the function's options to configure the function.
    class var encoding: Function.Options {
        Function.Options(rawValue: SQLITE_UTF8)
    }
    
    /// The combined options for the custom SQLite function.
    ///
    /// This property combines the function's options with the encoding. The result is used when
    /// registering the function with SQLite. This property is derived from `options` and `encoding`.
    class var opts: Int32 {
        var options = options
        options.insert(encoding)
        return options.rawValue
    }
    
    // MARK: - Methods
    
    /// Installs the custom SQLite function into the specified database connection.
    ///
    /// Subclasses must override this method to provide the implementation for installing
    /// the function into the SQLite database. This typically involves registering the function
    /// with SQLite using `sqlite3_create_function_v2` or similar APIs.
    ///
    /// - Parameter connection: A pointer to the SQLite database connection where the function
    ///   will be installed.
    /// - Throws: An error if the function installation fails. The method will throw an exception
    ///   if the installation cannot be completed successfully.
    class func install(db connection: OpaquePointer) throws(Connection.Error) {
        fatalError("Subclasses must override this method to implement function installation.")
    }
    
    /// Uninstalls the custom SQLite function from the specified database connection.
    ///
    /// This method unregisters the function from the SQLite database using `sqlite3_create_function_v2`
    /// with `NULL` for the function implementations. This effectively removes the function from the
    /// database.
    ///
    /// - Parameter connection: A pointer to the SQLite database connection from which the function
    ///   will be uninstalled.
    /// - Throws: An error if the function uninstallation fails. An exception is thrown if the function
    ///   cannot be removed successfully.
    class func uninstall(db connection: OpaquePointer) throws(Connection.Error) {
        let status = sqlite3_create_function_v2(
            connection,
            name, argc, opts,
            nil, nil, nil, nil, nil
        )
        if status != SQLITE_OK {
            throw Connection.Error(connection)
        }
    }
}

// MARK: - Functions

/// Sets the result of an SQLite query as a text string.
///
/// This function sets the result of the query to the specified text string. SQLite will store
/// this string inside the database as the result of the custom function.
///
/// - Parameters:
///   - ctx: A pointer to the SQLite context that provides information about the current query.
///   - string: A `String` that will be returned as the result of the query.
///
/// - Note: The `SQLITE_TRANSIENT` flag is used, meaning that SQLite makes a copy of the passed
///   data. This ensures that the string remains valid after the function execution is completed.
func sqlite3_result_text(_ ctx: OpaquePointer!, _ string: String) {
    sqlite3_result_text(ctx, string, -1, SQLITE_TRANSIENT)
}

/// Sets the result of an SQLite query as binary data (BLOB).
///
/// This function sets the result of the query to the specified binary data. This is useful for
/// returning non-textual data such as images or other binary content from a custom function.
///
/// - Parameters:
///   - ctx: A pointer to the SQLite context that provides information about the current query.
///   - data: A `Data` object representing the binary data to be returned as the result.
///
/// - Note: The `SQLITE_TRANSIENT` flag is used, ensuring that SQLite makes a copy of the binary
///   data. This prevents issues related to memory management if the original data is modified
///   or deallocated after the function completes.
func sqlite3_result_blob(_ ctx: OpaquePointer!, _ data: Data) {
    data.withUnsafeBytes {
        sqlite3_result_blob(ctx, $0.baseAddress, Int32($0.count), SQLITE_TRANSIENT)
    }
}

/// Sets the result of an SQLite query based on the `SQLiteRawValue` type.
///
/// This function sets the result of the query according to the type of the provided value. It can
/// handle integers, floating-point numbers, strings, binary data, or `NULL` values.
///
/// - Parameters:
///   - ctx: A pointer to the SQLite context that provides information about the current query.
///   - value: A `SQLiteRawValue` that represents the result to be returned. If the value is `nil`,
///     the result will be set to `NULL`.
///
/// - Note: The function uses a `switch` statement to determine the type of the value and then
///   calls the appropriate SQLite function to set the result. This ensures that the correct SQLite
///   result type is used based on the provided value.
func sqlite3_result_value(_ ctx: OpaquePointer!, _ value: SQLiteRawValue?) {
    switch value ?? .null {
    case .int(let value):   sqlite3_result_int64(ctx, value)
    case .real(let value):  sqlite3_result_double(ctx, value)
    case .text(let value):  sqlite3_result_text(ctx, value)
    case .blob(let value):  sqlite3_result_blob(ctx, value)
    case .null:             sqlite3_result_null(ctx)
    }
}
