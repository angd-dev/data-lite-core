import Foundation

/// Represents different types of database update actions.
///
/// The `SQLiteAction` enum is used to identify the type of action
/// performed on a database, such as insertion, updating, or deletion.
public enum SQLiteAction {
    /// Indicates the insertion of a new row into a table.
    ///
    /// This case is used to represent the action of adding a new
    /// row to a specific table in a database.
    ///
    /// - Parameters:
    ///     - db: The name of the database where the insertion occurred.
    ///     - table: The name of the table where the insertion occurred.
    ///     - rowID: The row ID of the newly inserted row.
    case insert(db: String, table: String, rowID: Int64)
    
    /// Indicates the modification of an existing row in a table.
    ///
    /// This case is used to represent the action of updating an
    /// existing row within a specific table in a database.
    ///
    /// - Parameters:
    ///     - db: The name of the database where the update occurred.
    ///     - table: The name of the table where the update occurred.
    ///     - rowID: The row ID of the updated row.
    case update(db: String, table: String, rowID: Int64)
    
    /// Indicates the removal of a row from a table.
    ///
    /// This case is used to represent the action of deleting a
    /// row from a specific table in a database.
    ///
    /// - Parameters:
    ///     - db: The name of the database from which the row was deleted.
    ///     - table: The name of the table from which the row was deleted.
    ///     - rowID: The row ID of the deleted row.
    case delete(db: String, table: String, rowID: Int64)
}
