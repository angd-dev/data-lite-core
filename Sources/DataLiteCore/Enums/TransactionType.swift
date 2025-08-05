import Foundation

/// An enumeration representing different types of SQLite transactions.
///
/// SQLite transactions determine how the database engine handles concurrency and locking
/// during a transaction. The default transaction behavior is DEFERRED. For more detailed information
/// about SQLite transactions, refer to the [SQLite documentation](https://www.sqlite.org/lang_transaction.html).
public enum TransactionType: String, CustomStringConvertible {
    /// A deferred transaction.
    ///
    /// A deferred transaction does not start until the database is first accessed. Internally,
    /// the `BEGIN DEFERRED` statement merely sets a flag on the database connection to prevent
    /// the automatic commit that normally occurs when the last statement finishes. If the first
    /// statement after `BEGIN DEFERRED` is a `SELECT`, a read transaction begins. If it is a write
    /// statement, a write transaction starts. Subsequent write operations may upgrade the transaction
    /// to a write transaction if possible, or return `SQLITE_BUSY`. The transaction persists until
    /// an explicit `COMMIT` or `ROLLBACK` or until a rollback is provoked by an error or an `ON CONFLICT ROLLBACK` clause.
    case deferred = "DEFERRED"
    
    /// An immediate transaction.
    ///
    /// An immediate transaction starts a new write immediately, without waiting for the first
    /// write statement. The `BEGIN IMMEDIATE` statement may fail with `SQLITE_BUSY` if another
    /// write transaction is active on a different database connection.
    case immediate = "IMMEDIATE"
    
    /// An exclusive transaction.
    ///
    /// Similar to `IMMEDIATE`, an exclusive transaction starts a write immediately. However,
    /// in non-WAL modes, `EXCLUSIVE` prevents other database connections from reading the database
    /// while the transaction is in progress. In WAL mode, `EXCLUSIVE` behaves the same as `IMMEDIATE`.
    case exclusive = "EXCLUSIVE"
    
    /// A textual representation of the transaction type.
    ///
    /// Returns the raw value of the transaction type (e.g., "DEFERRED", "IMMEDIATE", "EXCLUSIVE").
    public var description: String {
        rawValue
    }
}
