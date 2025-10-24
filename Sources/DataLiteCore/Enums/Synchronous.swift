import Foundation

/// Represents the available synchronous modes for an SQLite database.
///
/// The synchronous mode controls how thoroughly SQLite ensures that data is physically written to
/// disk. It defines the balance between durability, consistency, and performance during commits.
///
/// - SeeAlso: [PRAGMA synchronous](https://sqlite.org/pragma.html#pragma_synchronous)
public enum Synchronous: UInt8, SQLiteRepresentable {
    /// Disables synchronization for maximum performance.
    ///
    /// With `synchronous=OFF`, SQLite does not wait for data to reach non-volatile storage before
    /// continuing. The database may become inconsistent if the operating system crashes or power is
    /// lost, although application-level crashes do not cause corruption.
    /// Best suited for temporary databases or rebuildable data.
    case off = 0
    
    /// Enables normal synchronization.
    ///
    /// SQLite performs syncs only at critical points. In WAL mode, this guarantees consistency but
    /// not full durability: the most recent transactions might be lost after a power failure. In
    /// rollback journal mode, there is a very small chance of corruption on older filesystems.
    /// Recommended for most use cases where performance is preferred over strict durability.
    case normal = 1
    
    /// Enables full synchronization.
    ///
    /// SQLite calls the VFS `xSync` method to ensure that all data is written to disk before
    /// continuing. Prevents corruption even after a system crash or power loss. Default mode for
    /// rollback journals and fully ACID-compliant in WAL mode. Provides strong consistency and
    /// isolation; durability may depend on filesystem behavior.
    case full = 2
    
    /// Enables extra synchronization for maximum durability.
    ///
    /// Extends `FULL` by also syncing the directory that contained the rollback journal after it
    /// is removed, ensuring durability even if power is lost immediately after a commit. Guarantees
    /// full ACID compliance in both rollback and WAL modes. Recommended for systems where
    /// durability is more important than performance.
    case extra = 3
}
