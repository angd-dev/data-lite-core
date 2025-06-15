import Foundation
import OrderedCollections

/// A structure representing a single row in an SQLite database, providing ordered access to columns and their values.
///
/// The `SQLiteRow` structure allows for convenient access to the data stored in a row of an SQLite
/// database, using an ordered dictionary to maintain the insertion order of columns. This makes it
/// easy to retrieve, update, and manage the values associated with each column in the row.
///
/// ```swift
/// let row = SQLiteRow()
/// row["name"] = "John Doe"
/// row["age"] = 30
/// print(row.description)
/// // Outputs: ["name": 'John Doe', "age": 30]
/// ```
///
/// ## Topics
///
/// ### Type Aliases
///
/// - ``Elements``
/// - ``Column``
/// - ``Value``
/// - ``Index``
/// - ``Element``
public struct SQLiteRow: Collection, CustomStringConvertible, Equatable {
    // MARK: - Type Aliases
    
    /// A type for the internal storage of column names and their associated values in a database row.
    ///
    /// This ordered dictionary is used to store column data for a row, retaining the insertion order
    /// of columns as they appear in the SQLite database. Each key-value pair corresponds to a column name
    /// and its associated value, represented by `SQLiteRawValue`.
    ///
    /// - Key: `String` representing the name of the column.
    /// - Value: `SQLiteRawValue` representing the value of the column in the row.
    public typealias Elements = OrderedDictionary<String, SQLiteRawValue>
    
    /// A type representing the name of a column in a database row.
    ///
    /// This type alias provides a convenient way to refer to column names within a row.
    /// Each `Column` is a `String` key that corresponds to a specific column in the SQLite row,
    /// matching the key type of the `Elements` dictionary.
    public typealias Column = Elements.Key
    
    /// A type representing the value of a column in a database row.
    ///
    /// This type alias provides a convenient way to refer to the data stored in a column.
    /// Each `Value` is of type `SQLiteRawValue`, which corresponds to the value associated
    /// with a specific column in the SQLite row, matching the value type of the `Elements` dictionary.
    public typealias Value = Elements.Value
    
    /// A type representing the index of a column in a database row.
    ///
    /// This type alias provides a convenient way to refer to the position of a column
    /// within the ordered collection of columns. Each `Index` is an integer that corresponds
    /// to the index of a specific column in the SQLite row, matching the index type of the `Elements` dictionary.
    public typealias Index = Elements.Index
    
    /// A type representing a column-value pair in a database row.
    ///
    /// This type alias defines an element as a tuple consisting of a `Column` and its associated
    /// `Value`. Each `Element` encapsulates a single column name and its corresponding value,
    /// providing a clear structure for accessing and managing data within the SQLite row.
    public typealias Element = (column: Column, value: Value)
    
    // MARK: - Properties
    
    /// An ordered dictionary that stores the columns and their associated values in the row.
    ///
    /// This private property holds the internal representation of the row's data as an
    /// `OrderedDictionary`, maintaining the insertion order of columns. It is used to
    /// facilitate access to the row's columns and values, ensuring that the original
    /// order from the SQLite database is preserved.
    private var elements: Elements
    
    /// The starting index of the row, which is always zero.
    ///
    /// This property indicates the initial position of the row's elements. Since the
    /// elements in the row are indexed starting from zero, this property consistently
    /// returns zero, allowing for predictable iteration through the row's data.
    ///
    /// - Complexity: `O(1)`
    public var startIndex: Index {
        0
    }
    
    /// The ending index of the row, which is equal to the number of columns.
    ///
    /// This property indicates the position one past the last element in the row.
    /// It returns the count of columns in the row, allowing for proper iteration
    /// through the row's data in a collection context. The `endIndex` is useful
    /// for determining the bounds of the row's elements when traversing or accessing them.
    ///
    /// - Complexity: `O(1)`
    public var endIndex: Index {
        elements.count
    }
    
    /// A Boolean value indicating whether the row is empty.
    ///
    /// This property returns `true` if the row contains no columns; otherwise, it returns `false`.
    /// It provides a quick way to check if there are any data present in the row, which can be
    /// useful for validation or conditional logic when working with database rows.
    ///
    /// - Complexity: `O(1)`
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    /// The number of columns in the row.
    ///
    /// This property returns the total count of columns stored in the row. It reflects
    /// the number of column-value pairs in the `elements` dictionary, providing a convenient
    /// way to determine how much data is present in the row. This is useful for iteration
    /// and conditional checks when working with database rows.
    ///
    /// - Complexity: `O(1)`
    public var count: Int {
        elements.count
    }
    
    /// A textual description of the row, showing the columns and values.
    ///
    /// This property returns a string representation of the row, including all column names
    /// and their associated values. The description is generated from the `elements` dictionary,
    /// providing a clear and concise overview of the row's data, which can be helpful for debugging
    /// and logging purposes.
    public var description: String {
        elements.description
    }
    
    /// A list of column names in the row, preserving their insertion order.
    ///
    /// Useful for dynamically generating SQL queries (e.g. `INSERT INTO ... (columns)`).
    ///
    /// - Complexity: `O(1)`
    public var columns: [String] {
        elements.keys.elements
    }
    
    /// A list of SQL named parameters in the form `:column`, preserving column order.
    ///
    /// Useful for generating placeholders in SQL queries (e.g. `VALUES (:column1, :column2, ...)`)
    /// to match the row's structure.
    ///
    /// - Complexity: `O(n)`
    public var namedParameters: [String] {
        elements.keys.map { ":\($0)" }
    }
    
    // MARK: - Inits
    
    /// Initializes an empty row.
    ///
    /// This initializer creates a new instance of `SQLiteRow` with no columns or values.
    public init() {
        elements = [:]
    }
    
    // MARK: - Subscripts
    
    /// Accesses the element at the specified index.
    ///
    /// This subscript allows you to retrieve a column-value pair from the row by its index.
    /// It returns an `Element`, which is a tuple containing the column name and its associated
    /// value. The index must be valid; otherwise, it will trigger a runtime error.
    ///
    /// - Parameter index: The index of the element to access.
    /// - Returns: A tuple containing the column name and its associated value.
    ///
    /// - Complexity: `O(1)`
    public subscript(index: Index) -> Element {
        let element = elements.elements[index]
        return (element.key, element.value)
    }
    
    /// Accesses the value for the specified column.
    ///
    /// This subscript allows you to retrieve or set the value associated with a given column name.
    /// It returns an optional `Value`, which is the value stored in the row for the specified column.
    /// If the column does not exist, it returns `nil`. When setting a value, the column will be created
    /// if it does not already exist.
    ///
    /// - Parameter column: The name of the column to access.
    /// - Returns: The value associated with the specified column, or `nil` if the column does not exist.
    ///
    /// - Complexity: On average, the complexity is O(1) for lookups and amortized O(1) for updates.
    public subscript(column: Column) -> Value? {
        get { elements[column] }
        set { elements[column] = newValue }
    }
    
    // MARK: - Methods
    
    /// Returns the index immediately after the given index.
    ///
    /// This method provides the next valid index in the row's collection after the specified index.
    /// It increments the given index by one, allowing for iteration through the row's elements
    /// in a collection context. If the provided index is the last valid index, this method
    /// will return an index that may not be valid for the collection, so it should be used
    /// in conjunction with bounds checking.
    ///
    /// - Parameter i: A valid index of the row.
    /// - Returns: The index immediately after `i`.
    ///
    /// - Complexity: `O(1)`
    public func index(after i: Index) -> Index {
        i + 1
    }
    
    /// Checks if the row contains a value for the specified column.
    ///
    /// This method determines whether a column with the given name exists in the row. It is
    /// useful for validating the presence of data before attempting to access it.
    ///
    /// - Parameter column: The name of the column to check for.
    /// - Returns: `true` if the column exists; otherwise, `false`.
    ///
    /// - Complexity: On average, the complexity is `O(1)`.
    public func contains(_ column: Column) -> Bool {
        elements.keys.contains(column)
    }
}
