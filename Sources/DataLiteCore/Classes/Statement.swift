import Foundation
import DataLiteC

/// A value representing a static destructor for SQLite.
///
/// `SQLITE_STATIC` is used to indicate that the SQLite library should not free the associated
/// memory when the statement is finalized.
let SQLITE_STATIC = unsafeBitCast(
    OpaquePointer(bitPattern: 0),
    to: sqlite3_destructor_type.self
)

/// A value representing a transient destructor for SQLite.
///
/// `SQLITE_TRANSIENT` is used to indicate that the SQLite library should make a copy of the
/// associated memory and free the original memory when the statement is finalized.
let SQLITE_TRANSIENT = unsafeBitCast(
    OpaquePointer(bitPattern: -1),
    to: sqlite3_destructor_type.self
)

/// A class representing a prepared SQL statement in SQLite.
///
/// ## Overview
///
/// This class provides functionality for preparing, binding parameters, and executing SQL
/// statements using SQLite. It also supports retrieving results and resource management, ensuring
/// the statement is finalized when no longer needed.
///
/// ## Preparing an SQL Statement
///
/// To create a prepared SQL statement, use the ``Connection/prepare(sql:options:)`` method of the
/// ``Connection`` object.
///
/// ```swift
/// do {
///     let statement = try connection.prepare(
///         sql: "SELECT id, name FROM users WHERE age > ?",
///         options: [.persistent, .normalize]
///     )
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
///
/// ## Binding Parameters
///
/// SQL queries can contain parameters whose values can be bound after the statement is prepared.
/// This prevents SQL injection and makes the code more secure.
///
/// ### Binding Parameters by Index
///
/// When preparing an SQL query, you can use the question mark (`?`) as a placeholder for parameter
/// values. Parameter indexing starts from one (1). It is important to keep this in mind for
/// correctly binding values to parameters in the SQL query. The method ``bind(_:at:)-(T?,_)``
/// is used to bind values to parameters.
///
/// ```swift
/// do {
///     let query = "INSERT INTO users (name, age) VALUES (?, ?)"
///     let statement = try connection.prepare(sql: query)
///     try statement.bind("John Doe", at: 1)
///     try statement.bind(30, at: 2)
/// } catch {
///     print("Error binding parameters: \(error)")
/// }
/// ```
///
/// ### Binding Parameters by Explicit Index
///
/// Parameters can be explicitly bound by indices `?1`, `?2`, and so on. This improves readability
/// and simplifies working with queries containing many parameters. Explicit indices do not need to
/// start from one, be sequential, or contiguous.
///
/// ```swift
/// do {
///     let query = "INSERT INTO users (name, age) VALUES (?1, ?2)"
///     let statement = try connection.prepare(sql: query)
///     try statement.bind("Jane Doe", at: 1)
///     try statement.bind(25, at: 2)
/// } catch {
///     print("Error binding parameters: \(error)")
/// }
/// ```
///
/// ### Binding Parameters by Name
///
/// Parameters can also be bound by names. This increases code readability and simplifies managing
/// complex queries. Use ``bind(parameterIndexBy:)`` to retrieve the index of a named parameter.
///
/// ```swift
/// do {
///     let query = "INSERT INTO users (name, age) VALUES (:userName, :userAge)"
///     let statement = try connection.prepare(sql: query)
///
///     let indexName = statement.bind(parameterIndexBy: "userName")
///     let indexAge = statement.bind(parameterIndexBy: "userAge")
///
///     try statement.bind("Jane Doe", at: indexName)
///     try statement.bind(25, at: indexAge)
/// } catch {
///     print("Error binding parameters: \(error)")
/// }
/// ```
///
/// ### Duplicating Parameters
///
/// Parameters with explicit indices or names can be duplicated. This allows the same value to be
/// bound to multiple places in the query.
///
/// ```swift
/// do {
///     let query = """
///     INSERT INTO users (name, age)
///     VALUES
///         (:userName, :userAge),
///         (:userName, :userAge)
///     """
///     let statement = try connection.prepare(sql: query)
///
///     let indexName = statement.bind(parameterIndexBy: "userName")
///     let indexAge = statement.bind(parameterIndexBy: "userAge")
///
///     try statement.bind("Jane Doe", at: indexName)
///     try statement.bind(25, at: indexAge)
/// } catch {
///     print("Error binding parameters: \(error)")
/// }
/// ```
///
/// ## Executing an SQL Statement
///
/// The SQL statement is executed using the ``step()`` method. It returns `true` if there is a
/// result to process, and `false` when execution is complete. To retrieve the results of an SQL
/// statement, use ``columnCount()``, ``columnType(at:)``, ``columnName(at:)``,
/// ``columnValue(at:)->SQLiteRawValue``, and ``rowValue()``.
///
/// ```swift
/// do {
///     let query = "SELECT id, name FROM users WHERE age > ?"
///     let statement = try connection.prepare(sql: query)
///     try statement.bind(18, at: 1)
///     while try statement.step() {
///         for index in 0..<statement.columnCount() {
///             let columnName = statement.columnName(at: index)
///             let columnValue = statement.columnValue(at: index)
///             print("\(columnName): \(columnValue)")
///         }
///     }
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
///
/// ## Preparing for Reuse
///
/// Before reusing a prepared SQL statement, you should call the ``clearBindings()`` method to
/// remove the values bound to the parameters and then call the ``reset()`` method to restore it to
/// its original state.
///
/// ```swift
/// do {
///     let query = "INSERT INTO users (name, age) VALUES (?, ?)"
///     let statement = try connection.prepare(sql: query)
///
///     try statement.bind("John Doe", at: 1)
///     try statement.bind(30, at: 2)
///     try statement.step()
///
///     try statement.clearBindings()
///     try statement.reset()
///
///     try statement.bind("Jane Doe", at: 1)
///     try statement.bind(25, at: 2)
///     try statement.step()
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
///
/// ## Topics
///
/// ### Subtypes
///
/// - ``Options``
///
/// ### Binding Parameters
///
/// - ``bindParameterCount()``
/// - ``bind(parameterIndexBy:)``
/// - ``bind(parameterNameBy:)``
/// - ``bind(_:at:)-(SQLiteRawValue,_)``
/// - ``bind(_:at:)-(T?,_)``
/// - ``clearBindings()``
///
/// ### Getting Results
///
/// - ``columnCount()``
/// - ``columnType(at:)``
/// - ``columnName(at:)``
/// - ``columnValue(at:)->SQLiteRawValue``
/// - ``columnValue(at:)->T?``
/// - ``rowValue()``
///
/// ### Evaluating
///
/// - ``step()``
/// - ``reset()``
///
/// ### Hashing
///
/// - ``hash(into:)``
public final class Statement: Equatable, Hashable {
    // MARK: - Private Properties
    
    /// The SQLite statement pointer associated with this `Statement` instance.
    private let statement: OpaquePointer
    
    /// The SQLite database connection pointer used to create this statement.
    private let connection: OpaquePointer
    
    // MARK: - Inits
    
    /// Initializes a new `Statement` instance with a given SQL query and options.
    ///
    /// This initializer prepares the SQL statement for execution and sets up any necessary
    /// options. It throws an ``SQLiteError`` if the SQL preparation fails.
    ///
    /// - Parameters:
    ///   - connection: A pointer to the SQLite database connection to use.
    ///   - query: The SQL query string to prepare.
    ///   - options: The options to use when preparing the SQL statement.
    /// - Throws: ``SQLiteError`` if the SQL statement preparation fails.
    init(db connection: OpaquePointer, sql query: String, options: Options) throws {
        var statement: OpaquePointer! = nil
        let status = sqlite3_prepare_v3(connection, query, -1, options.rawValue, &statement, nil)
        
        if status == SQLITE_OK, let statement {
            self.statement = statement
            self.connection = connection
        } else {
            sqlite3_finalize(statement)
            throw SQLiteError(connection)
        }
    }
    
    /// Finalizes the SQL statement, releasing any associated resources.
    deinit {
        sqlite3_finalize(statement)
    }
    
    // MARK: - Binding Parameters
    
    /// Returns the count of parameters that can be bound to this statement.
    ///
    /// This method provides the number of parameters that can be bound in the SQL statement,
    /// allowing you to determine how many parameters need to be set.
    ///
    /// - Returns: The number of bindable parameters in the statement.
    public func bindParameterCount() -> Int32 {
        sqlite3_bind_parameter_count(statement)
    }
    
    /// Returns the index of a parameter by its name.
    ///
    /// This method is used to find the index of a parameter in the SQL statement given its name.
    /// This is useful for binding values to named parameters.
    ///
    /// - Parameters:
    ///   - name: The name of the parameter.
    /// - Returns: The index of the parameter, or 0 if the parameter does not exist.
    public func bind(parameterIndexBy name: String) -> Int32 {
        sqlite3_bind_parameter_index(statement, name)
    }
    
    /// Returns the name of a parameter by its index.
    ///
    /// This method retrieves the name of a parameter based on its index in the SQL statement. This
    /// is useful for debugging or when parameter names are needed.
    ///
    /// - Parameters:
    ///   - index: The index of the parameter (1-based).
    /// - Returns: The name of the parameter, or `nil` if the name could not be retrieved.
    public func bind(parameterNameBy index: Int32) -> String? {
        guard let cString = sqlite3_bind_parameter_name(statement, index) else {
            return nil
        }
        return String(cString: cString)
    }
    
    /// Binds a value to a parameter at a specified index.
    ///
    /// This method allows you to bind various types of values (integer, real, text, or blob) to a
    /// parameter in the SQL statement. The appropriate SQLite function is called based on the type
    /// of value being bound.
    ///
    /// - Parameters:
    ///   - value: The value to bind to the parameter.
    ///   - index: The index of the parameter to bind (1-based).
    /// - Throws: ``SQLiteError`` if the binding operation fails.
    public func bind(_ value: SQLiteRawValue, at index: Int32) throws {
        let status: Int32
        switch value {
        case .int(let value):   status = sqlite3_bind_int64(statement, index, value)
        case .real(let value):  status = sqlite3_bind_double(statement, index, value)
        case .text(let value):  status = sqlite3_bind_text(statement, index, value)
        case .blob(let value):  status = sqlite3_bind_blob(statement, index, value)
        case .null:             status = sqlite3_bind_null(statement, index)
        }
        if status != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    /// Binds a value conforming to `SQLiteRawBindable` to a parameter at a specified index.
    ///
    /// This method provides a generic way to bind values that conform to `SQLiteRawBindable`,
    /// allowing for flexibility in the types of values that can be bound to SQL statements.
    ///
    /// - Parameters:
    ///   - value: The value to bind to the parameter.
    ///   - index: The index of the parameter to bind (1-based).
    /// - Throws: ``SQLiteError`` if the binding operation fails.
    public func bind<T: SQLiteRawBindable>(_ value: T?, at index: Int32) throws {
        try bind(value?.sqliteRawValue ?? .null, at: index)
    }
    
    /// Clears all parameter bindings from the statement.
    ///
    /// This method resets any parameter bindings, allowing you to reuse the same SQL statement
    /// with different parameter values. This is useful for executing the same statement multiple
    /// times with different parameters.
    ///
    /// - Throws: ``SQLiteError`` if the operation to clear bindings fails.
    public func clearBindings() throws {
        if sqlite3_clear_bindings(statement) != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    // MARK: - Retrieving Results
    
    /// Returns the number of columns in the result set.
    ///
    /// This method provides the count of columns returned by the SQL statement result, which is
    /// useful for iterating over query results and processing data.
    ///
    /// - Returns: The number of columns in the result set.
    public func columnCount() -> Int32 {
        sqlite3_column_count(statement)
    }
    
    /// Returns the type of data stored in a column at a specified index.
    ///
    /// This method retrieves the type of data stored in a particular column of the result set,
    /// allowing you to handle different data types appropriately.
    ///
    /// - Parameters:
    ///   - index: The index of the column (0-based).
    /// - Returns: The type of data in the column as `SQLiteRawType`.
    public func columnType(at index: Int32) -> SQLiteRawType {
        .init(rawValue: sqlite3_column_type(statement, index)) ?? .null
    }
    
    /// Returns the name of a column at a specified index.
    ///
    /// This method retrieves the name of a column, which is useful for debugging or when you need
    /// to work with column names directly.
    ///
    /// - Parameters:
    ///   - index: The index of the column (0-based).
    /// - Returns: The name of the column as a `String`.
    public func columnName(at index: Int32) -> String {
        String(cString: sqlite3_column_name(statement, index))
    }
    
    /// Retrieves the value from a column at a specified index.
    ///
    /// This method extracts the value from a column and returns it as an `SQLiteRawValue`, which
    /// can represent different data types like integer, real, text, or blob.
    ///
    /// - Parameters:
    ///   - index: The index of the column (0-based).
    /// - Returns: The value from the column as `SQLiteRawValue`.
    public func columnValue(at index: Int32) -> SQLiteRawValue {
        switch columnType(at: index) {
        case .int:  return .int(sqlite3_column_int64(statement, index))
        case .real: return .real(sqlite3_column_double(statement, index))
        case .text: return .text(sqlite3_column_text(statement, index))
        case .blob: return .blob(sqlite3_column_blob(statement, index))
        case .null: return .null
        }
    }
    
    /// Retrieves the value from a column at a specified index and converts it to a value
    /// conforming to `SQLiteRawRepresentable`.
    ///
    /// This method provides a way to convert column values into types that conform to
    /// ``SQLiteRawRepresentable``, allowing for easier integration with custom data models.
    ///
    /// - Parameters:
    ///   - index: The index of the column (0-based).
    /// - Returns: The value from the column converted to `T`, or `nil` if conversion fails.
    public func columnValue<T: SQLiteRawRepresentable>(at index: Int32) -> T? {
        T(columnValue(at: index))
    }
    
    /// Retrieves the current row of the result set as a `SQLiteRow` instance.
    ///
    /// This method iterates over the columns of the current row in the result set.
    /// For each column, it retrieves the column name and the corresponding value using the
    /// ``columnName(at:)`` and ``columnValue(at:)->SQLiteRawValue`` methods.
    /// It then populates a ``SQLiteRow`` instance with these column-value pairs.
    ///
    /// - Returns: A `SQLiteRow` instance representing the current row of the result set.
    public func rowValue() -> SQLiteRow {
        var row = SQLiteRow()
        for index in 0..<columnCount() {
            let name = columnName(at: index)
            let value = columnValue(at: index)
            row[name] = value
        }
        return row
    }
    
    // MARK: - Evaluating
    
    /// Advances to the next row in the result set.
    ///
    /// This method steps through the result set row by row, returning `true` if there is a row
    /// available and `false` if the end of the result set is reached.
    ///
    /// - Returns: `true` if there is a row available, `false` if the end of the result set is
    ///   reached.
    /// - Throws: ``SQLiteError`` if an error occurs during execution.
    @discardableResult
    public func step() throws -> Bool {
        switch sqlite3_step(statement) {
        case SQLITE_ROW:  return true
        case SQLITE_DONE: return false
        default: throw SQLiteError(connection)
        }
    }
    
    /// Resets the prepared SQL statement to its initial state.
    ///
    /// Use this method before re-executing the statement. It does not clear the bound parameters,
    /// allowing their values to persist between executions. To clear the parameters, use the
    /// `clearBindings()` method.
    ///
    /// - Throws: `SQLiteError` if the statement reset fails.
    public func reset() throws {
        if sqlite3_reset(statement) != SQLITE_OK {
            throw SQLiteError(connection)
        }
    }
    
    // MARK: - Equatable
    
    /// Compares two `Statement` instances for equality.
    ///
    /// This method checks whether two `Statement` instances are equal by comparing their
    /// underlying SQLite statement pointers and connection pointers.
    ///
    /// - Parameters:
    ///   - lhs: The first `Statement` instance.
    ///   - rhs: The second `Statement` instance.
    /// - Returns: `true` if the two instances are equal, `false` otherwise.
    public static func == (lhs: Statement, rhs: Statement) -> Bool {
        lhs.statement == rhs.statement && lhs.connection == rhs.connection
    }
    
    // MARK: - Hashable
    
    /// Computes a hash value for the `Statement` instance.
    ///
    /// This method computes a hash value based on the SQLite statement pointer and connection
    /// pointer. It is used to support hash-based collections like sets and dictionaries.
    ///
    /// - Parameter hasher: The hasher to use for computing the hash value.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(statement)
        hasher.combine(connection)
    }
}

// MARK: - Functions

/// Binds a string to a parameter in an SQL statement.
///
/// - Parameters:
///   - stmt: A pointer to the prepared SQL statement.
///   - index: The index of the parameter (1-based).
///   - string: The string to be bound to the parameter.
/// - Returns: SQLite error code if binding fails.
private func sqlite3_bind_text(_ stmt: OpaquePointer!, _ index: Int32, _ string: String) -> Int32 {
    sqlite3_bind_text(stmt, index, string, -1, SQLITE_TRANSIENT)
}

/// Binds binary data to a parameter in an SQL statement.
///
/// - Parameters:
///   - stmt: A pointer to the prepared SQL statement.
///   - index: The index of the parameter (1-based).
///   - data: The `Data` to be bound to the parameter.
/// - Returns: SQLite error code if binding fails.
private func sqlite3_bind_blob(_ stmt: OpaquePointer!, _ index: Int32, _ data: Data) -> Int32 {
    data.withUnsafeBytes {
        sqlite3_bind_blob(stmt, index, $0.baseAddress, Int32($0.count), SQLITE_TRANSIENT)
    }
}

/// Retrieves text data from a result column of an SQL statement.
///
/// - Parameters:
///   - stmt: A pointer to the prepared SQL statement.
///   - iCol: The column index.
/// - Returns: A `String` containing the text data from the specified column.
private func sqlite3_column_text(_ stmt: OpaquePointer!, _ iCol: Int32) -> String {
    String(cString: DataLiteC.sqlite3_column_text(stmt, iCol))
}

/// Retrieves binary data from a result column of an SQL statement.
///
/// - Parameters:
///   - stmt: A pointer to the prepared SQL statement.
///   - iCol: The column index.
/// - Returns: A `Data` object containing the binary data from the specified column.
private func sqlite3_column_blob(_ stmt: OpaquePointer!, _ iCol: Int32) -> Data {
    Data(
        bytes: sqlite3_column_blob(stmt, iCol),
        count: Int(sqlite3_column_bytes(stmt, iCol))
    )
}
