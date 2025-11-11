import Foundation

/// Represents a type of database change operation.
///
/// The `SQLiteAction` enumeration describes an action that modifies a database table. It
/// distinguishes between row insertions, updates, and deletions, providing context such
/// as the database name, table, and affected row ID.
///
/// - SeeAlso: [Data Change Notification Callbacks](https://sqlite.org/c3ref/update_hook.html)
public enum SQLiteAction: Hashable, Sendable {
    /// A new row was inserted into a table.
    ///
    /// - Parameters:
    ///   - db: The name of the database where the insertion occurred.
    ///   - table: The name of the table into which the row was inserted.
    ///   - rowID: The row ID of the newly inserted row.
    case insert(db: String, table: String, rowID: Int64)
    
    /// An existing row was modified in a table.
    ///
    /// - Parameters:
    ///   - db: The name of the database where the update occurred.
    ///   - table: The name of the table containing the updated row.
    ///   - rowID: The row ID of the modified row.
    case update(db: String, table: String, rowID: Int64)
    
    /// A row was deleted from a table.
    ///
    /// - Parameters:
    ///   - db: The name of the database where the deletion occurred.
    ///   - table: The name of the table from which the row was deleted.
    ///   - rowID: The row ID of the deleted row.
    case delete(db: String, table: String, rowID: Int64)
}
