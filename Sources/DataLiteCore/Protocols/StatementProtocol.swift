import Foundation

/// A protocol that defines a prepared SQLite statement.
///
/// Conforming types manage the statement's lifetime, including initialization and finalization.
/// The protocol exposes facilities for parameter discovery and binding, stepping, resetting, and
/// reading result columns.
///
/// ## Topics
///
/// ### Binding Parameters
///
/// - ``parameterCount()``
/// - ``parameterIndexBy(_:)``
/// - ``parameterNameBy(_:)``
/// - ``bind(_:at:)-(SQLiteValue,_)``
/// - ``bind(_:by:)-(SQLiteValue,_)``
/// - ``bind(_:at:)-(T?,_)``
/// - ``bind(_:by:)-(T?,_)``
/// - ``bind(_:)``
/// - ``clearBindings()``
///
/// ### Statement Execution
///
/// - ``step()``
/// - ``reset()``
/// - ``execute(_:)``
///
/// ### Result Set
///
/// - ``columnCount()``
/// - ``columnName(at:)``
/// - ``columnValue(at:)->SQLiteValue``
/// - ``columnValue(at:)->T?``
/// - ``currentRow()``
public protocol StatementProtocol {
    // MARK: - Binding Parameters
    
    /// Returns the number of parameters in the prepared SQLite statement.
    ///
    /// This value corresponds to the highest parameter index in the compiled SQL statement.
    /// Parameters may be specified using anonymous placeholders (`?`), numbered placeholders
    /// (`?NNN`), or named placeholders (`:name`, `@name`, `$name`).
    ///
    /// For statements using only `?` or named parameters, this value equals the number of parameters.
    /// However, if numbered placeholders are used, the sequence may contain gaps — for example,
    /// a statement containing `?2` and `?5` will report a parameter count of `5`.
    ///
    /// - Returns: The index of the largest (rightmost) parameter in the prepared statement.
    ///
    /// - SeeAlso: [Number Of SQL Parameters](https://sqlite.org/c3ref/bind_parameter_count.html)
    func parameterCount() -> Int32
    
    /// Returns the index of a parameter identified by its name.
    ///
    /// The `name` must exactly match the placeholder used in the SQL statement, including its
    /// prefix character (`:`, `@`, or `$`). For example, if the SQL includes `WHERE id = :id`,
    /// you must call `parameterIndexBy(":id")`.
    ///
    /// If no parameter with the specified `name` exists in the prepared statement, this function
    /// returns `0`.
    ///
    /// - Parameter name: The parameter name as written in the SQL statement, including its prefix.
    /// - Returns: The 1-based parameter index corresponding to `name`, or `0` if not found.
    ///
    /// - SeeAlso: [Index Of A Parameter With A Given Name](https://sqlite.org/c3ref/bind_parameter_index.html)
    func parameterIndexBy(_ name: String) -> Int32
    
    /// Returns the name of the parameter at the specified index.
    ///
    /// The returned string matches the placeholder as written in the SQL statement, including its
    /// prefix (`:`, `@`, or `$`). For positional (unnamed) parameters, or if the `index` is out of
    /// range, this function returns `nil`.
    ///
    /// - Parameter index: A 1-based parameter index.
    /// - Returns: The parameter name as written in the SQL statement, or `nil` if unavailable.
    ///
    /// - SeeAlso: [Name Of A Host Parameter](https://sqlite.org/c3ref/bind_parameter_name.html)
    func parameterNameBy(_ index: Int32) -> String?
    
    /// Binds a raw SQLite value to a parameter at the specified index.
    ///
    /// Assigns the given `SQLiteValue` to the parameter at the provided 1-based index within the
    /// prepared statement. If the index is out of range, or if the statement is invalid or
    /// finalized, this function throws an error.
    ///
    /// - Parameters:
    ///   - value: The `SQLiteValue` to bind to the parameter.
    ///   - index: The 1-based index of the parameter to bind.
    /// - Throws: ``SQLiteError`` if the value cannot be bound (e.g., index out of range).
    ///
    /// - SeeAlso: [Binding Values To Prepared Statements](
    ///   https://sqlite.org/c3ref/bind_blob.html)
    func bind(_ value: SQLiteValue, at index: Int32) throws(SQLiteError)
    
    /// Binds a raw SQLite value to a parameter by its name.
    ///
    /// Resolves `name` to an index and binds `value` to that parameter. The `name` must include
    /// its prefix (e.g., `:AAA`, `@AAA`, `$AAA`). Binding a value to a parameter that does not
    /// exist results in an error.
    ///
    /// - Parameters:
    ///   - value: The ``SQLiteValue`` to bind.
    ///   - name: The parameter name as written in SQL, including its prefix.
    /// - Throws: ``SQLiteError`` if binding fails.
    ///
    /// - SeeAlso: [Binding Values To Prepared Statements](
    ///   https://sqlite.org/c3ref/bind_blob.html)
    func bind(_ value: SQLiteValue, by name: String) throws(SQLiteError)
    
    /// Binds a typed value conforming to `SQLiteBindable` by index.
    ///
    /// Converts `value` to its raw SQLite representation and binds it at `index`. If `value` is
    /// `nil`, binds `NULL`.
    ///
    /// - Parameters:
    ///   - value: The value to bind. If `nil`, `NULL` is bound.
    ///   - index: The 1-based parameter index.
    /// - Throws: ``SQLiteError`` if binding fails.
    ///
    /// - SeeAlso: [Binding Values To Prepared Statements](
    ///   https://sqlite.org/c3ref/bind_blob.html)
    func bind<T: SQLiteBindable>(_ value: T?, at index: Int32) throws(SQLiteError)
    
    /// Binds a typed value conforming to `SQLiteBindable` by name.
    ///
    /// Resolves `name` to a parameter index and binds the raw SQLite representation of `value`.
    /// If `value` is `nil`, binds `NULL`. The `name` must include its prefix (e.g., `:AAA`,
    /// `@AAA`, `$AAA`). Binding to a non-existent parameter results in an error.
    ///
    /// - Parameters:
    ///   - value: The value to bind. If `nil`, `NULL` is bound.
    ///   - name: The parameter name as written in SQL, including its prefix.
    /// - Throws: ``SQLiteError`` if binding fails.
    ///
    /// - SeeAlso: [Binding Values To Prepared Statements](
    ///   https://sqlite.org/c3ref/bind_blob.html)
    func bind<T: SQLiteBindable>(_ value: T?, by name: String) throws(SQLiteError)
    
    /// Binds the contents of a row to named statement parameters by column name.
    ///
    /// For each `(column, value)` pair in `row`, treats `column` as a named parameter `:column`
    /// and binds `value` to that parameter. Parameter names in the SQL must match the row's
    /// column names (including the leading colon). Binding to a non-existent parameter results
    /// in an error.
    ///
    /// - Parameter row: The row whose column values are to be bound.
    /// - Throws: ``SQLiteError`` if any value cannot be bound.
    ///
    /// - SeeAlso: [Binding Values To Prepared Statements](
    ///   https://sqlite.org/c3ref/bind_blob.html)
    func bind(_ row: SQLiteRow) throws(SQLiteError)
    
    /// Clears all parameter bindings of the prepared statement.
    ///
    /// After calling this function, all parameters are set to `NULL`. Call this when reusing the
    /// statement with a different set of parameter values.
    ///
    /// - Throws: ``SQLiteError`` if clearing bindings fails.
    ///
    /// - SeeAlso: [Reset All Bindings](https://sqlite.org/c3ref/clear_bindings.html)
    func clearBindings() throws(SQLiteError)
    
    // MARK: - Statement Execution
    
    /// Evaluates the prepared statement and advances to the next result row.
    ///
    /// Call repeatedly to iterate over all rows. It returns `true` while a new row is available.
    /// After the final row it returns `false`. Statements that produce no rows return `false`
    /// immediately. Reset the statement and clear bindings before re-executing.
    ///
    /// - Returns: `true` if a new row is available, or `false` when no more rows remain.
    /// - Throws: ``SQLiteError`` if evaluation fails.
    ///
    /// - SeeAlso: [Evaluate An SQL Statement](https://sqlite.org/c3ref/step.html)
    @discardableResult
    func step() throws(SQLiteError) -> Bool
    
    /// Resets the prepared SQLite statement to its initial state, ready for re-execution.
    ///
    /// Undoes the effects of previous calls to ``step()``. After reset, the statement may be
    /// executed again with the same or new inputs. This does not clear parameter bindings.
    /// Call ``clearBindings()`` to set all parameters to `NULL` if needed.
    ///
    /// - Throws: ``SQLiteError`` if the statement cannot be reset.
    ///
    /// - SeeAlso: [Reset A Prepared Statement](https://sqlite.org/c3ref/reset.html)
    func reset() throws(SQLiteError)
    
    /// Executes the statement once per provided parameter row.
    ///
    /// For each row, binds values, steps until completion (discarding any result rows), clears
    /// bindings, and resets the statement. Use this for efficient batch executions (e.g., inserts
    /// or updates) with different parameters per run.
    ///
    /// - Parameter rows: Parameter rows to bind for each execution.
    /// - Throws: ``SQLiteError`` if binding, stepping, clearing, or resetting fails.
    func execute(_ rows: [SQLiteRow]) throws(SQLiteError)
    
    // MARK: - Result Set
    
    /// Returns the number of columns in the current result set.
    ///
    /// If this value is `0`, the prepared statement does not produce rows. This is typically
    /// the case for statements that do not return data.
    ///
    /// - Returns: The number of columns in the result set, or `0` if there are no result columns.
    ///
    /// - SeeAlso: [Number Of Columns In A Result Set](
    ///   https://sqlite.org/c3ref/column_count.html)
    func columnCount() -> Int32
    
    /// Returns the name of the column at the specified index in the result set.
    ///
    /// The column name appears as defined in the SQL statement. If the index is out of bounds, this
    /// function returns `nil`.
    ///
    /// - Parameter index: The 0-based index of the column for which to retrieve the name.
    /// - Returns: The name of the column at the given index, or `nil` if the index is invalid.
    ///
    /// - SeeAlso: [Column Names In A Result Set](https://sqlite.org/c3ref/column_name.html)
    func columnName(at index: Int32) -> String?
    
    /// Returns the raw SQLite value at the given result column index.
    ///
    /// Retrieves the value for the specified column in the current result row of the prepared
    /// statement, represented as a ``SQLiteValue``. If the index is out of range, returns
    /// ``SQLiteValue/null``.
    ///
    /// - Parameter index: The 0-based index of the result column to access.
    /// - Returns: The raw ``SQLiteValue`` at the specified column.
    ///
    /// - SeeAlso: [Result Values From A Query](https://sqlite.org/c3ref/column_blob.html)
    func columnValue(at index: Int32) -> SQLiteValue
    
    /// Returns the value of the result column at `index`, converted to `T`.
    ///
    /// Attempts to initialize `T` from the raw ``SQLiteValue`` at `index` using
    /// ``SQLiteRepresentable``. Returns `nil` if the conversion is not possible.
    ///
    /// - Parameter index: The 0-based result column index.
    /// - Returns: A value of type `T` if conversion succeeds, otherwise `nil`.
    ///
    /// - SeeAlso: [Result Values From A Query](https://sqlite.org/c3ref/column_blob.html)
    func columnValue<T: SQLiteRepresentable>(at index: Int32) -> T?
    
    /// Returns the current result row.
    ///
    /// Builds a row by iterating over all result columns at the current cursor position, reading
    /// each column's name and value, and inserting them into the row.
    ///
    /// - Returns: A `SQLiteRow` mapping column names to values, or `nil` if there are no columns.
    ///
    /// - SeeAlso: [Result Values From A Query](https://sqlite.org/c3ref/column_blob.html)
    func currentRow() -> SQLiteRow?
}

// MARK: - Default Implementation

public extension StatementProtocol {
    func bind(_ value: SQLiteValue, by name: String) throws(SQLiteError) {
        try bind(value, at: parameterIndexBy(name))
    }
    
    func bind<T: SQLiteBindable>(_ value: T?, at index: Int32) throws(SQLiteError) {
        try bind(value?.sqliteValue ?? .null, at: index)
    }
    
    func bind<T: SQLiteBindable>(_ value: T?, by name: String) throws(SQLiteError) {
        try bind(value?.sqliteValue ?? .null, at: parameterIndexBy(name))
    }
    
    func bind(_ row: SQLiteRow) throws(SQLiteError) {
        for (column, value) in row {
            let index = parameterIndexBy(":\(column)")
            try bind(value, at: index)
        }
    }
    
    func execute(_ rows: [SQLiteRow]) throws(SQLiteError) {
        for row in rows {
            try bind(row)
            var hasStep: Bool
            repeat {
                hasStep = try step()
            } while hasStep
            try clearBindings()
            try reset()
        }
    }
    
    func columnValue<T: SQLiteRepresentable>(at index: Int32) -> T? {
        T(columnValue(at: index))
    }
    
    func currentRow() -> SQLiteRow? {
        let columnCount = columnCount()
        guard columnCount > 0 else { return nil }
        
        var row = SQLiteRow()
        row.reserveCapacity(columnCount)
        
        for index in 0..<columnCount {
            let name = columnName(at: index)!
            let value = columnValue(at: index)
            row[name] = value
        }
        
        return row
    }
}
