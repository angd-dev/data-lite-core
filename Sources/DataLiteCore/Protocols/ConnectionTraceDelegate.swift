import Foundation

/// A delegate that receives SQL statement trace callbacks.
///
/// Conforming types can inspect SQL before and after parameter expansion for logging, diagnostics,
/// or profiling. Register a trace delegate with ``ConnectionProtocol/add(trace:)``.
///
/// - Important: Callbacks execute synchronously on SQLite’s internal thread. Keep implementations
///   lightweight to avoid slowing down query execution.
public protocol ConnectionTraceDelegate: AnyObject {
    /// Represents traced SQL text before and after parameter substitution.
    typealias Trace = (unexpandedSQL: String, expandedSQL: String)
    
    /// Called before a SQL statement is executed.
    ///
    /// Use to trace or log executed statements for debugging or profiling.
    ///
    /// - Parameters:
    ///   - connection: The active database connection.
    ///   - sql: A tuple with the original and expanded SQL text.
    func connection(_ connection: ConnectionProtocol, trace sql: Trace)
}
