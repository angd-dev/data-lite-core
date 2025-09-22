import Foundation

/// A protocol defining methods that can be implemented by delegates of a `Connection` object.
///
/// The `ConnectionDelegate` protocol allows a delegate to receive notifications about various
/// events that occur within a ``Connection``, including SQL statement tracing, database update
/// actions, and transaction commits or rollbacks. Implementing this protocol provides a way
/// to monitor and respond to database interactions in a structured manner.
///
/// ### Default Implementations
///
/// The protocol provides default implementations for all methods, which do nothing. This allows
/// conforming types to only implement the methods they are interested in without the need to
/// provide an implementation for each method.
///
/// ## Topics
///
/// ### Instance Methods
///
/// - ``ConnectionDelegate/connection(_:trace:)``
/// - ``ConnectionDelegate/connection(_:didUpdate:)``
/// - ``ConnectionDelegate/connectionWillCommit(_:)``
/// - ``ConnectionDelegate/connectionDidRollback(_:)``
public protocol ConnectionDelegate: AnyObject {
    /// Informs the delegate that a SQL statement is being traced.
    ///
    /// This method is called right before a SQL statement is executed, allowing the delegate
    /// to monitor the queries being sent to SQLite. This can be particularly useful for debugging
    /// purposes or for performance analysis, as it provides insights into the exact SQL being
    /// executed against the database.
    ///
    /// - Parameters:
    ///   - connection: The ``Connection`` instance that is executing the SQL statement.
    ///   - sql: A tuple containing the unexpanded and expanded forms of the SQL statement being traced.
    ///     - `unexpandedSQL`: The original SQL statement as it was written by the developer.
    ///     - `expandedSQL`: The SQL statement with all parameters substituted in, which shows
    ///       exactly what is being sent to SQLite.
    ///
    /// ### Example
    ///
    /// You can implement this method to log or analyze SQL statements:
    ///
    /// ```swift
    /// func connection(
    ///     _ connection: Connection,
    ///     trace sql: (unexpandedSQL: String, expandedSQL: String)
    /// ) {
    ///     print("Tracing SQL: \(sql.unexpandedSQL)")
    /// }
    /// ```
    ///
    /// - Important: If the implementation of this method performs any heavy operations, it could
    /// potentially slow down the execution of the SQL statement. It is recommended to keep the
    /// implementation lightweight to avoid impacting performance.
    func connection(_ connection: Connection, trace sql: (unexpandedSQL: String, expandedSQL: String))
    
    /// Informs the delegate that an update action has occurred.
    ///
    /// This method is called whenever an update action, such as insertion, modification,
    /// or deletion, is performed on the database. It provides details about the action taken,
    /// allowing the delegate to respond appropriately to changes in the database.
    ///
    /// - Parameters:
    ///   - connection: The `Connection` instance where the update action occurred.
    ///   - action: The type of update action that occurred, represented by the ``SQLiteAction`` enum.
    ///
    /// ### Example
    ///
    /// You can implement this method to respond to specific update actions:
    ///
    /// ```swift
    /// func connection(_ connection: Connection, didUpdate action: SQLiteAction) {
    ///     switch action {
    ///     case .insert(let db, let table, let rowID):
    ///         print("Inserted row \(rowID) into \(table) in database \(db).")
    ///     case .update(let db, let table, let rowID):
    ///         print("Updated row \(rowID) in \(table) in database \(db).")
    ///     case .delete(let db, let table, let rowID):
    ///         print("Deleted row \(rowID) from \(table) in database \(db).")
    ///     }
    /// }
    /// ```
    ///
    /// - Note: Implementing this method can help you maintain consistency and perform any
    /// necessary actions (such as UI updates or logging) in response to database changes.
    func connection(_ connection: Connection, didUpdate action: SQLiteAction)
    
    /// Informs the delegate that a transaction has been successfully committed.
    ///
    /// This method is called when a transaction has been successfully committed. It provides an
    /// opportunity for the delegate to perform any necessary actions after the commit. If this
    /// method throws an error, the COMMIT operation will be converted into a ROLLBACK, ensuring
    /// data integrity in the database.
    ///
    /// - Parameter connection: The `Connection` instance where the transaction was committed.
    ///
    /// - Throws: May throw an error to abort the commit process, which will cause the transaction
    ///   to be rolled back.
    ///
    /// ### Example
    /// You can implement this method to perform actions after a successful commit:
    ///
    /// ```swift
    /// func connectionWillCommit(_ connection: Connection) throws {
    ///     print("Transaction committed successfully.")
    /// }
    /// ```
    ///
    /// - Important: Be cautious when implementing this method. If it performs heavy operations,
    ///   it could delay the commit process. It is advisable to keep the implementation lightweight
    ///   to maintain optimal performance and responsiveness.
    func connectionWillCommit(_ connection: Connection) throws
    
    /// Informs the delegate that a transaction has been rolled back.
    ///
    /// This method is called when a transaction is rolled back, allowing the delegate to handle
    /// any necessary cleanup or logging related to the rollback. This can be useful for maintaining
    /// consistency in the application state or for debugging purposes.
    ///
    /// - Parameter connection: The `Connection` instance where the rollback occurred.
    ///
    /// ### Example
    /// You can implement this method to respond to rollback events:
    ///
    /// ```swift
    /// func connectionDidRollback(_ connection: Connection) {
    ///     print("Transaction has been rolled back.")
    /// }
    /// ```
    ///
    /// - Note: It's a good practice to keep any logic within this method lightweight, as it may
    ///   be called frequently during database operations, especially in scenarios involving errors
    ///   that trigger rollbacks.
    func connectionDidRollback(_ connection: Connection)
}

public extension ConnectionDelegate {
    /// Default implementation of the `connection(_:trace:)` method.
    ///
    /// This default implementation does nothing.
    ///
    /// - Parameters:
    ///   - connection: The `Connection` instance that is executing the SQL statement.
    ///   - sql: A tuple containing the unexpanded and expanded forms of the SQL statement being traced.
    func connection(_ connection: Connection, trace sql: (unexpandedSQL: String, expandedSQL: String)) {}
    
    /// Default implementation of the `connection(_:didUpdate:)` method.
    ///
    /// This default implementation does nothing.
    ///
    /// - Parameters:
    ///   - connection: The `Connection` instance where the update action occurred.
    ///   - action: The type of update action that occurred.
    func connection(_ connection: Connection, didUpdate action: SQLiteAction) {}
    
    /// Default implementation of the `connectionWillCommit(_:)` method.
    ///
    /// This default implementation does nothing.
    ///
    /// - Parameter connection: The `Connection` instance where the transaction was committed.
    /// - Throws: May throw an error to abort the commit process.
    func connectionWillCommit(_ connection: Connection) throws {}
    
    /// Default implementation of the `connectionDidRollback(_:)` method.
    ///
    /// This default implementation does nothing.
    ///
    /// - Parameter connection: The `Connection` instance where the rollback occurred.
    func connectionDidRollback(_ connection: Connection) {}
}
