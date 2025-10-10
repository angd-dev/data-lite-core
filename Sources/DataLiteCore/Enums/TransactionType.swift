import Foundation

/// Represents the transaction modes supported by SQLite.
///
/// A transaction defines how the database manages concurrency and locking. The transaction type
/// determines when a write lock is acquired and how other connections can access the database
/// during the transaction.
///
/// - SeeAlso: [Transaction](https://sqlite.org/lang_transaction.html)
public enum TransactionType: String, CustomStringConvertible {
    /// Defers the start of the transaction until the first database access.
    ///
    /// With `BEGIN DEFERRED`, no locks are acquired immediately. If the first statement is a read
    /// (`SELECT`), a read transaction begins. If it is a write statement, a write transaction
    /// begins instead. Deferred transactions allow greater concurrency and are the default mode.
    case deferred = "DEFERRED"
    
    /// Starts a write transaction immediately.
    ///
    /// With `BEGIN IMMEDIATE`, a reserved lock is acquired right away to ensure that no other
    /// connection can start a conflicting write. The statement may fail with `SQLITE_BUSY` if
    /// another write transaction is already active.
    case immediate = "IMMEDIATE"
    
    /// Starts an exclusive write transaction.
    ///
    /// With `BEGIN EXCLUSIVE`, a write lock is acquired immediately. In rollback journal mode, it
    /// also prevents other connections from reading the database while the transaction is active.
    /// In WAL mode, it behaves the same as `.immediate`.
    case exclusive = "EXCLUSIVE"
    
    /// A textual representation of the transaction type.
    public var description: String {
        rawValue
    }
}
