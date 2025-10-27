import Foundation
import DataLiteC

extension Function {
    /// Base class for defining custom SQLite aggregate functions.
    ///
    /// The `Aggregate` class provides a foundation for creating aggregate
    /// functions in SQLite. Aggregate functions operate on multiple rows of
    /// input and return a single result value.
    ///
    /// To define a custom aggregate function, subclass `Function.Aggregate` and
    /// override the following:
    ///
    /// - ``name`` – The SQL name of the function.
    /// - ``argc`` – The number of arguments accepted by the function.
    /// - ``options`` – Function options, such as `.deterministic` or `.innocuous`.
    /// - ``step(args:)`` – Called for each row's argument values.
    /// - ``finalize()`` – Called once to compute and return the final result.
    ///
    /// ### Example
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
    ///     override func step(args: ArgumentsProtocol) throws {
    ///         guard let value = args[0] as Int? else {
    ///             throw Error.argumentsWrong
    ///         }
    ///         sum += value
    ///     }
    ///
    ///     override func finalize() throws -> SQLiteRepresentable? {
    ///         return sum
    ///     }
    /// }
    /// ```
    ///
    /// ### Registration
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
    /// ```sql
    /// SELECT sum_aggregate(value) FROM my_table
    /// ```
    ///
    /// ## Topics
    ///
    /// ### Initialization
    ///
    /// - ``init()``
    ///
    /// ### Instance Methods
    ///
    /// - ``step(args:)``
    /// - ``finalize()``
    open class Aggregate: Function {
        // MARK: - Properties
        
        fileprivate var hasErrored = false
        
        // MARK: - Inits
        
        /// Initializes a new aggregate function instance.
        ///
        /// Subclasses may override this initializer to perform custom setup.
        /// The base implementation performs no additional actions.
        ///
        /// - Important: Always call `super.init()` when overriding.
        required public override init() {}
        
        // MARK: - Methods
        
        override class func install(db connection: OpaquePointer) throws(SQLiteError) {
            let context = Context(function: self)
            let ctx = Unmanaged.passRetained(context).toOpaque()
            let status = sqlite3_create_function_v2(
                connection, name, argc, opts, ctx,
                nil, xStep(_:_:_:), xFinal(_:), xDestroy(_:)
            )
            if status != SQLITE_OK {
                throw SQLiteError(connection)
            }
        }
        
        /// Processes one step of the aggregate computation.
        ///
        /// This method is called once for each row of input data. Subclasses must override it to
        /// accumulate intermediate results.
        ///
        /// - Parameter args: The set of arguments passed to the function.
        /// - Throws: An error if the input arguments are invalid or the computation fails.
        ///
        /// - Note: The default implementation triggers a runtime error.
        open func step(args: any ArgumentsProtocol) throws {
            fatalError("Subclasses must override `step(args:)`.")
        }
        
        /// Finalizes the aggregate computation and returns the result.
        ///
        /// SQLite calls this method once after all input rows have been processed.
        /// Subclasses must override it to produce the final result of the aggregate.
        ///
        /// - Returns: The final computed value, or `nil` if the function produces no result.
        /// - Throws: An error if the computation cannot be finalized.
        /// - Note: The default implementation triggers a runtime error.
        open func finalize() throws -> SQLiteRepresentable? {
            fatalError("Subclasses must override `finalize()`.")
        }
    }
}

extension Function.Aggregate {
    fileprivate final class Context {
        // MARK: - Properties
        
        private let function: Aggregate.Type
        
        // MARK: - Inits
        
        init(function: Aggregate.Type) {
            self.function = function
        }
        
        // MARK: - Methods
        
        func function(
            for ctx: OpaquePointer?, isFinal: Bool = false
        ) -> Unmanaged<Aggregate>? {
            typealias U = Unmanaged<Aggregate>
            
            let bytes = isFinal ? 0 : MemoryLayout<U>.stride
            let raw = sqlite3_aggregate_context(ctx, Int32(bytes))
            guard let raw else { return nil }
            
            let pointer = raw.assumingMemoryBound(to: U?.self)
            
            if let pointer = pointer.pointee {
                return pointer
            } else {
                let function = self.function.init()
                pointer.pointee = Unmanaged.passRetained(function)
                return pointer.pointee
            }
        }
    }
}

// MARK: - Functions

private func xStep(
    _ ctx: OpaquePointer?,
    _ argc: Int32,
    _ argv: UnsafeMutablePointer<OpaquePointer?>?
) {
    let function = Unmanaged<Function.Aggregate.Context>
        .fromOpaque(sqlite3_user_data(ctx))
        .takeUnretainedValue()
        .function(for: ctx)?
        .takeUnretainedValue()
    
    guard let function else {
        sqlite3_result_error_nomem(ctx)
        return
    }
    
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
        sqlite3_result_error_code(ctx, SQLITE_ERROR)
    }
}

private func xFinal(_ ctx: OpaquePointer?) {
    let pointer = Unmanaged<Function.Aggregate.Context>
        .fromOpaque(sqlite3_user_data(ctx))
        .takeUnretainedValue()
        .function(for: ctx, isFinal: true)
    
    defer { pointer?.release() }
    
    guard let function = pointer?.takeUnretainedValue() else {
        sqlite3_result_null(ctx)
        return
    }
    
    guard !function.hasErrored else { return }
    
    do {
        let result = try function.finalize()
        sqlite3_result_value(ctx, result?.sqliteValue)
    } catch {
        let name = type(of: function).name
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
