import Foundation

/// Represents different synchronous modes available for an SQLite database.
///
/// The synchronous mode determines how SQLite handles data synchronization with the database.
/// For more details, refer to [Synchronous Pragma](https://www.sqlite.org/pragma.html#pragma_synchronous).
public enum Synchronous: UInt8, SQLiteRawRepresentable {
    /// Synchronous mode off. Disables synchronization for maximum performance.
    ///
    /// With synchronous OFF, SQLite continues without syncing as soon as it has handed data off
    /// to the operating system. If the application running SQLite crashes, the data will be safe,
    /// but the database might become corrupted if the operating system crashes or the computer loses
    /// power before the data is written to the disk surface. On the other hand, commits can be orders
    /// of magnitude faster with synchronous OFF.
    case off = 0
    
    /// Normal synchronous mode.
    ///
    /// The SQLite database engine syncs at the most critical moments, but less frequently
    /// than in FULL mode. While there is a very small chance of corruption in
    /// `journal_mode=DELETE` on older filesystems during a power failure, WAL
    /// mode is safe from corruption with synchronous=NORMAL. Modern filesystems
    /// likely make DELETE mode safe too. However, WAL mode in synchronous=NORMAL
    /// loses some durability, as a transaction committed in WAL mode might roll back
    /// after a power loss or system crash. Transactions are still durable across application
    /// crashes regardless of the synchronous setting or journal mode. This setting is a
    /// good choice for most applications running in WAL mode.
    case normal = 1
    
    /// Full synchronous mode.
    ///
    /// Uses the xSync method of the VFS to ensure that all content is safely written
    /// to the disk surface prior to continuing. This ensures that an operating system
    /// crash or power failure will not corrupt the database. FULL synchronous is very
    /// safe but also slower. It is the most commonly used synchronous setting when
    /// not in WAL mode.
    case full = 2
    
    /// Extra synchronous mode.
    ///
    /// Similar to FULL mode, but ensures the directory containing the rollback journal
    /// is synced after the journal is unlinked, providing additional durability in case of
    /// power loss shortly after a commit.
    case extra = 3
}
