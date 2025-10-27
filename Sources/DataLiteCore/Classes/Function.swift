import Foundation
import DataLiteC

/// A base class representing a user-defined SQLite function.
///
/// The `Function` class defines the common interface and structure for implementing custom SQLite
/// functions. Subclasses are responsible for specifying the function name, argument count, and
/// behavior. This class should not be used directly — instead, use one of its specialized
/// subclasses, such as ``Scalar`` or ``Aggregate``.
///
/// To define a new SQLite function, subclass either ``Scalar`` or ``Aggregate`` depending on
/// whether the function computes a value from a single row or aggregates results across multiple
/// rows. Override the required properties and implement the necessary logic to define the
/// function’s behavior.
///
/// ## Topics
///
/// ### Base Function Classes
///
/// - ``Scalar``
/// - ``Aggregate``
///
/// ### Custom Function Classes
///
/// - ``Regexp``
///
/// ### Configuration
///
/// - ``argc``
/// - ``name``
/// - ``options``
/// - ``Options``
open class Function {
    // MARK: - Properties
    
    /// The number of arguments that the function accepts.
    ///
    /// Subclasses must override this property to specify the expected number of arguments. The
    /// value should be a positive integer, or zero if the function does not accept any arguments.
    open class var argc: Int32 {
        fatalError("Subclasses must override this property to specify the number of arguments.")
    }
    
    /// The name of the function.
    ///
    /// Subclasses must override this property to provide the name by which the SQLite engine
    /// identifies the function. The name must comply with SQLite function naming rules.
    open class var name: String {
        fatalError("Subclasses must override this property to provide the function name.")
    }
    
    /// The configuration options for the function.
    ///
    /// Subclasses must override this property to specify the function’s behavioral flags, such as
    /// whether it is deterministic, direct-only, or innocuous.
    open class var options: Options {
        fatalError("Subclasses must override this property to specify function options.")
    }
    
    class var encoding: Function.Options {
        Function.Options(rawValue: SQLITE_UTF8)
    }
    
    class var opts: Int32 {
        var options = options
        options.insert(encoding)
        return options.rawValue
    }
    
    // MARK: - Methods
    
    class func install(db connection: OpaquePointer) throws(SQLiteError) {
        fatalError("Subclasses must override this method to implement function installation.")
    }
    
    class func uninstall(db connection: OpaquePointer) throws(SQLiteError) {
        let status = sqlite3_create_function_v2(
            connection,
            name, argc, opts,
            nil, nil, nil, nil, nil
        )
        if status != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
}

// MARK: - Functions

func sqlite3_result_text(_ ctx: OpaquePointer!, _ string: String) {
    sqlite3_result_text(ctx, string, -1, SQLITE_TRANSIENT)
}

func sqlite3_result_blob(_ ctx: OpaquePointer!, _ data: Data) {
    data.withUnsafeBytes {
        sqlite3_result_blob(ctx, $0.baseAddress, Int32($0.count), SQLITE_TRANSIENT)
    }
}

func sqlite3_result_value(_ ctx: OpaquePointer!, _ value: SQLiteValue?) {
    switch value ?? .null {
    case .int(let value):   sqlite3_result_int64(ctx, value)
    case .real(let value):  sqlite3_result_double(ctx, value)
    case .text(let value):  sqlite3_result_text(ctx, value)
    case .blob(let value):  sqlite3_result_blob(ctx, value)
    case .null:             sqlite3_result_null(ctx)
    }
}
