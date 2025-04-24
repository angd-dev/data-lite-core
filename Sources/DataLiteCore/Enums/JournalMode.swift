import Foundation

/// Represents the journal modes available for an SQLite database.
///
/// The journal mode determines how the database handles transactions and how it
/// maintains the journal for rollback and recovery. For more details, refer to
/// [Journal Mode Pragma](https://www.sqlite.org/pragma.html#pragma_journal_mode).
public enum JournalMode: String, SQLiteRawRepresentable {
    /// DELETE journal mode.
    ///
    /// This is the default behavior. The rollback journal is deleted at the conclusion
    /// of each transaction. The delete operation itself causes the transaction to commit.
    /// For more details, refer to the
    /// [Atomic Commit In SQLite](https://www.sqlite.org/atomiccommit.html).
    case delete
    
    /// TRUNCATE journal mode.
    ///
    /// In this mode, the rollback journal is truncated to zero length at the end of each transaction
    /// instead of being deleted. On many systems, truncating a file is much faster than deleting it
    /// because truncating does not require modifying the containing directory.
    case truncate
    
    /// PERSIST journal mode.
    ///
    /// In this mode, the rollback journal is not deleted at the end of each transaction. Instead,
    /// the header of the journal is overwritten with zeros. This prevents other database connections
    /// from rolling the journal back. The PERSIST mode is useful as an optimization on platforms
    /// where deleting or truncating a file is more expensive than overwriting the first block of a file
    /// with zeros. For additional configuration, refer to
    /// [journal_size_limit](https://www.sqlite.org/pragma.html#pragma_journal_size_limit).
    case persist
    
    /// MEMORY journal mode.
    ///
    /// In this mode, the rollback journal is stored entirely in volatile RAM rather than on disk.
    /// This saves disk I/O but at the expense of database safety and integrity. If the application
    /// crashes during a transaction, the database file will likely become corrupt.
    case memory
    
    /// Write-Ahead Logging (WAL) journal mode.
    ///
    /// This mode uses a write-ahead log instead of a rollback journal to implement transactions.
    /// The WAL mode is persistent, meaning it stays in effect across multiple database connections
    /// and persists even after closing and reopening the database. For more details, refer to the
    /// [Write-Ahead Logging](https://www.sqlite.org/wal.html).
    case wal
    
    /// OFF journal mode.
    ///
    /// In this mode, the rollback journal is completely disabled, meaning no rollback journal is ever created.
    /// This disables SQLite's atomic commit and rollback capabilities. The `ROLLBACK` command will no longer work
    /// and behaves in an undefined way. Applications must avoid using the `ROLLBACK` command when the journal mode is OFF.
    /// If the application crashes in the middle of a transaction, the database file will likely become corrupt,
    /// as there is no way to unwind partially completed operations. For example, if a duplicate entry causes a
    /// `CREATE UNIQUE INDEX` statement to fail halfway through, it will leave behind a partially created index,
    /// resulting in a corrupted database state.
    case off
    
    public var rawValue: String {
        switch self {
        case .delete:       "DELETE"
        case .truncate:     "TRUNCATE"
        case .persist:      "PERSIST"
        case .memory:       "MEMORY"
        case .wal:          "WAL"
        case .off:          "OFF"
        }
    }
    
    public init?(rawValue: String) {
        switch rawValue.uppercased() {
        case "DELETE":      self = .delete
        case "TRUNCATE":    self = .truncate
        case "PERSIST":     self = .persist
        case "MEMORY":      self = .memory
        case "WAL":         self = .wal
        case "OFF":         self = .off
        default:            return nil
        }
    }
}
