import Foundation

/// A delegate that observes connection-level database events.
///
/// Conforming types can monitor row-level updates and transaction lifecycle events. This protocol
/// is typically used for debugging, logging, or synchronizing application state with database
/// changes.
///
/// - Important: Delegate methods are invoked synchronously on SQLite’s internal execution thread.
///   Implementations must be lightweight and non-blocking to avoid slowing down SQL operations.
///
/// ## Topics
///
/// ### Instance Methods
///
/// - ``ConnectionDelegate/connection(_:didUpdate:)``
/// - ``ConnectionDelegate/connectionWillCommit(_:)``
/// - ``ConnectionDelegate/connectionDidRollback(_:)``
public protocol ConnectionDelegate: AnyObject {
    /// Called when a row is inserted, updated, or deleted.
    ///
    /// Enables reacting to data changes, for example to refresh caches or UI.
    ///
    /// - Parameters:
    ///   - connection: The connection where the update occurred.
    ///   - action: Describes the affected database, table, and row.
    func connection(_ connection: ConnectionProtocol, didUpdate action: SQLiteAction)
    
    /// Called right before a transaction is committed.
    ///
    /// Throwing an error aborts the commit and causes a rollback.
    ///
    /// - Parameter connection: The connection about to commit.
    /// - Throws: An error to cancel and roll back the transaction.
    func connectionWillCommit(_ connection: ConnectionProtocol) throws
    
    /// Called after a transaction is rolled back.
    ///
    /// Use to perform cleanup or maintain consistency after a failure.
    ///
    /// - Parameter connection: The connection that rolled back.
    func connectionDidRollback(_ connection: ConnectionProtocol)
}
