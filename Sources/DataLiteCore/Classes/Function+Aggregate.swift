import Foundation
import DataLiteC

extension Function {
    /// Base class for creating custom SQLite aggregate functions.
    ///
    /// This class provides a basic implementation for creating aggregate functions in SQLite.
    /// Aggregate functions process a set of input values and return a single value.
    /// To create a custom aggregate function, subclass `Function.Aggregate` and override the
    /// following properties and methods:
    ///
    /// - ``name``: The name of the function used in SQL queries.
    /// - ``argc``: The number of arguments the function accepts.
    /// - ``options``: Options for the function, such as `deterministic` and `innocuous`.
    /// - ``step(args:)``: Method called for each input value.
    /// - ``finalize()``: Method called after processing all input values.
    ///
    /// ### Example
    ///
    /// This example shows how to create a custom aggregate function to calculate the sum
    /// of integers.
    ///
    /// ```swift
    /// final class SumAggregate: Function.Aggregate {
    ///     enum Error: Swift.Error {
    ///         case argumentsWrong
    ///     }
    ///
    ///     override class var argc: Int32 { 1 }
    ///     override class var name: String { "sum_aggregate" }
    ///     override class var options: Function.Options {
    ///         [.deterministic, .innocuous]
    ///     }
    ///
    ///     private var sum: Int = 0
    ///
    ///     override func step(args: Arguments) throws {
    ///         guard let value = args[0] as Int? else {
    ///             throw Error.argumentsWrong
    ///         }
    ///         sum += value
    ///     }
    ///
    ///     override func finalize() throws -> SQLiteRawRepresentable? {
    ///         return sum
    ///     }
    /// }
    /// ```
    ///
    /// ### Usage
    ///
    /// To use a custom aggregate function, first establish a database connection and
    /// register the function.
    ///
    /// ```swift
    /// let connection = try Connection(
    ///     path: dbFileURL.path,
    ///     options: [.create, .readwrite]
    /// )
    /// try connection.add(function: SumAggregate.self)
    /// ```
    ///
    /// ### SQL Example
    ///
    /// Example SQL query using the custom aggregate function to calculate the sum of
    /// values in the `value` column of the `my_table`.
    ///
    /// ```sql
    /// SELECT sum_aggregate(value) FROM my_table
    /// ```
    ///
    /// ## Topics
    ///
    /// ### Initializers
    ///
    /// - ``init()``
    ///
    /// ### Instance Methods
    ///
    /// - ``step(args:)``
    /// - ``finalize()``
    open class Aggregate: Function {
        // MARK: - Context
        
        /// Helper class for storing and managing the context of a custom SQLite aggregate function.
        ///
        /// This class is used to hold a reference to the `Aggregate` function implementation.
        /// It is created and managed when the aggregate function is installed in the SQLite
        /// database connection. The context is passed to SQLite and is used to invoke the
        /// corresponding function implementation when called.
        fileprivate final class Context {
            // MARK: Properties
            
            /// The type of the aggregate function managed by this context.
            ///
            /// This property holds a reference to the subclass of `Aggregate` that implements
            /// the custom aggregate function. It is used to create instances of the function
            /// and manage its state during SQL query execution.
            private let function: Aggregate.Type
            
            // MARK: Inits
            
            /// Initializes a new `Context` with a reference to the aggregate function type.
            ///
            /// This initializer creates an instance of the `Context` class that will hold
            /// a reference to the aggregate function type. It is used to manage state and
            /// perform operations with the custom aggregate function in the SQLite context.
            ///
            /// - Parameter function: The subclass of `Aggregate` implementing the custom
            ///   aggregate function. This parameter specifies which function type will be
            ///   used in the context.
            ///
            /// - Note: The initializer establishes a link between the context and the function
            /// type, allowing extraction of function instances and management of their state
            /// during SQL query processing.
            init(function: Aggregate.Type) {
                self.function = function
            }
            
            // MARK: Methods
            
            /// Retrieves or creates an instance of the aggregate function.
            ///
            /// This method retrieves an existing instance of the aggregate function from the
            /// SQLite context or creates a new one if it has not yet been created. The returned
            /// instance allows management of the aggregate function's state during query execution.
            ///
            /// - Parameter ctx: Pointer to the SQLite context associated with the current
            ///   query. This parameter is used to access the aggregate context where the
            ///   function state is stored.
            ///
            /// - Returns: An unmanaged reference to the `Aggregate` instance.
            ///
            /// - Note: The method checks whether an instance of the function already exists in
            /// the context. If no instance is found, a new one is created and saved in the
            /// context for use in subsequent calls.
            func function(ctx: OpaquePointer?) -> Unmanaged<Aggregate> {
                let stride = MemoryLayout<Unmanaged<Aggregate>>.stride
                let functionBuffer = UnsafeMutableRawBufferPointer(
                    start: sqlite3_aggregate_context(ctx, Int32(stride)),
                    count: stride
                )
                
                if functionBuffer.contains(where: { $0 != 0 }) {
                    return functionBuffer.baseAddress!.assumingMemoryBound(
                        to: Unmanaged<Aggregate>.self
                    ).pointee
                } else {
                    let function = self.function.init()
                    let unmanagedFunction = Unmanaged.passRetained(function)
                    let functionPointer = unmanagedFunction.toOpaque()
                    withUnsafeBytes(of: functionPointer) {
                        functionBuffer.copyMemory(from: $0)
                    }
                    return unmanagedFunction
                }
            }
        }
        
        // MARK: - Properties
        
        /// Flag indicating whether an error occurred during execution.
        fileprivate var hasErrored = false
        
        // MARK: - Inits
        
        /// Initializes a new instance of the `Aggregate` class.
        ///
        /// This initializer is required for subclasses of ``Aggregate``.
        /// In the current implementation, it performs no additional actions but provides
        /// a basic structure for creating instances.
        ///
        /// Subclasses may override this initializer to implement their own initialization
        /// logic, including setting up additional properties or performing other necessary
        /// operations.
        ///
        /// ```swift
        /// public class MyCustomAggregate: Function.Aggregate {
        ///     required public init() {
        ///         super.init() // Call to superclass initializer
        ///         // Additional initialization if needed
        ///     }
        /// }
        /// ```
        ///
        /// - Note: Always call `super.init()` in the overridden initializer to ensure
        /// proper initialization of the parent class.
        required public override init() {}
        
        // MARK: - Methods
        
        /// Installs the custom SQLite aggregate function into the specified database connection.
        ///
        /// This method registers the custom aggregate function in the SQLite database,
        /// allowing it to be used in SQL queries. The method creates a context for the function
        /// and passes it to SQLite, as well as specifying callback functions to handle input
        /// values and finalize results.
        ///
        /// ```swift
        /// // Assuming the database connection is already open
        /// let db: OpaquePointer = ...
        /// // Register the function in the database
        /// try MyCustomAggregate.install(db: db)
        /// ```
        ///
        /// - Parameter connection: Pointer to the SQLite database connection where the function
        ///   will be installed.
        ///
        /// - Throws: ``Connection/Error`` if the function installation fails. The error is thrown if
        ///   the `sqlite3_create_function_v2` call does not return `SQLITE_OK`.
        ///
        /// - Note: This method must be called to register the custom function before using
        ///   it in SQL queries. Ensure that the database connection is open and available at
        ///   the time of this method call.
        override class func install(db connection: OpaquePointer) throws(Connection.Error) {
            let context = Context(function: self)
            let ctx = Unmanaged.passRetained(context).toOpaque()
            let status = sqlite3_create_function_v2(
                connection, name, argc, opts, ctx,
                nil, xStep(_:_:_:), xFinal(_:), xDestroy(_:)
            )
            if status != SQLITE_OK {
                throw Connection.Error(connection)
            }
        }
        
        /// Called for each input value during aggregate computation.
        ///
        /// This method should be overridden by subclasses to implement the specific logic
        /// for processing each input value. Your implementation should handle the input
        /// arguments and accumulate results for later finalization.
        ///
        /// ```swift
        /// class MyCustomAggregate: Function.Aggregate {
        ///     // ...
        ///
        ///     private var sum: Int = 0
        ///
        ///     override func step(args: Arguments) throws {
        ///         guard let value = args[0].intValue else {
        ///             throw MyCustomError.invalidInput
        ///         }
        ///         sum += value
        ///     }
        ///
        ///     // ...
        /// }
        /// ```
        ///
        /// - Parameter args: An ``Arguments`` object that contains the number of
        /// arguments and their values.
        ///
        /// - Throws: An error if the function execution fails. Subclasses may throw errors
        /// if the input values do not match the expected format or if other issues arise
        /// during processing.
        ///
        /// - Note: It is important to override this method in subclasses; otherwise, a
        /// runtime error will occur due to calling `fatalError()`.
        open func step(args: Arguments) throws {
            fatalError("The 'step' method should be overridden.")
        }
        
        /// Called when the aggregate computation is complete.
        ///
        /// This method should be overridden by subclasses to return the final result
        /// of the aggregate computation. Your implementation should return a value that will
        /// be used in SQL queries. If the aggregate should not return a value, you can
        /// return `nil`.
        ///
        /// ```swift
        /// class MyCustomAggregate: Function.Aggregate {
        ///     // ...
        ///
        ///     private var sum: Int = 0
        ///
        ///     override func finalize() throws -> SQLiteRawRepresentable? {
        ///         return sum
        ///     }
        /// }
        /// ```
        ///
        /// - Returns: An optional ``SQLiteRawRepresentable`` representing the result of the
        /// aggregate function. The return value may be `nil` if a result is not required.
        ///
        /// - Throws: An error if the function execution fails. Subclasses may throw errors
        /// if the aggregate cannot be computed correctly or if other issues arise.
        ///
        /// - Note: It is important to override this method in subclasses; otherwise, a
        /// runtime error will occur due to calling `fatalError()`.
        open func finalize() throws -> SQLiteRawRepresentable? {
            fatalError("The 'finalize' method should be overridden.")
        }
    }
}

// MARK: - Functions

/// C callback function to perform a step of the custom SQLite aggregate function.
///
/// This function is called by SQLite for each input value passed to the aggregate function.
/// It retrieves the function implementation from the context associated with the SQLite
/// request, calls the `step(args:)` method, and handles any errors that may occur during
/// execution.
///
/// - Parameters:
///   - ctx: Pointer to the SQLite context associated with the current query.
///   - argc: Number of arguments passed to the function.
///   - argv: Array of pointers to the argument values passed to the function.
private func xStep(
    _ ctx: OpaquePointer?,
    _ argc: Int32,
    _ argv: UnsafeMutablePointer<OpaquePointer?>?
) {
    let context = Unmanaged<Function.Aggregate.Context>
        .fromOpaque(sqlite3_user_data(ctx))
        .takeUnretainedValue()
    
    let function = context
        .function(ctx: ctx)
        .takeUnretainedValue()
    
    assert(!function.hasErrored)
    
    do {
        let args = Function.Arguments(argc: argc, argv: argv)
        try function.step(args: args)
    } catch {
        let name = type(of: function).name
        let description = error.localizedDescription
        let message = "Error executing function '\(name)': \(description)"
        function.hasErrored = true
        sqlite3_result_error(ctx, message, -1)
    }
}

/// C callback function to finalize the result of the custom SQLite aggregate function.
///
/// This function is called by SQLite when the aggregate computation is complete.
/// It retrieves the function implementation from the context, calls the `finalize()`
/// method, and sets the query result based on the returned value.
///
/// - Parameter ctx: Pointer to the SQLite context associated with the current query.
private func xFinal(_ ctx: OpaquePointer?) {
    let context = Unmanaged<Function.Aggregate.Context>
        .fromOpaque(sqlite3_user_data(ctx))
        .takeUnretainedValue()
    
    let unmanagedFunction = context.function(ctx: ctx)
    let function = unmanagedFunction.takeUnretainedValue()
    
    defer { unmanagedFunction.release() }
    
    guard !function.hasErrored else { return }
    
    do {
        let result = try function.finalize()
        sqlite3_result_value(ctx, result?.sqliteRawValue)
    } catch {
        let name = type(of: function).name
        let description = error.localizedDescription
        let message = "Error executing function '\(name)': \(description)"
        sqlite3_result_error(ctx, message, -1)
    }
}

/// C callback function to destroy the context associated with the custom SQLite aggregate function.
///
/// This function is called by SQLite when the function is uninstalled. It frees the memory
/// allocated for the `Context` object associated with the function to avoid memory leaks.
///
/// - Parameter ctx: Pointer to the SQLite query context.
private func xDestroy(_ ctx: UnsafeMutableRawPointer?) {
    guard let ctx else { return }
    Unmanaged<AnyObject>.fromOpaque(ctx).release()
}
