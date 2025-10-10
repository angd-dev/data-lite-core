import Foundation
import OrderedCollections

/// An ordered collection that stores the column-value pairs of a single SQLite result row.
///
/// `SQLiteRow` preserves the order of columns as provided by the underlying data source. Each key
/// is the column name exposed by the executed statement, and every value is represented as a
/// ``SQLiteValue``.
///
/// You can use dictionary-style lookup to access values by column name or iterate over ordered
/// pairs using standard collection APIs. Column names are unique, and insertion order is maintained
/// deterministically, making `SQLiteRow` safe to pass into APIs that rely on stable row layouts.
public struct SQLiteRow {
    /// The type that identifies a column within a row.
    ///
    /// In SQLite, a column name corresponds to the alias or identifier returned by the executing
    /// statement. Each column name is unique within a single row.
    public typealias Column = String
    
    /// The type that represents a value stored in a column.
    public typealias Value = SQLiteValue
    
    // MARK: - Properties
    
    private var elements: OrderedDictionary<Column, Value>
    
    /// The column names in the order they appear in the result set.
    ///
    /// The order of column names corresponds to the sequence defined in the executed SQL statement.
    /// This order is preserved exactly as provided by SQLite, ensuring deterministic column
    /// indexing across rows.
    public var columns: [Column] {
        elements.keys.elements
    }
    
    /// The named parameter tokens corresponding to each column, in result order.
    ///
    /// Each element is formed by prefixing the column name with a colon (`:`), matching the syntax
    /// of SQLite named parameters (e.g., `:username`, `:id`). The order of tokens matches the order
    /// of columns in the result set.
    public var namedParameters: [String] {
        elements.keys.map { ":\($0)" }
    }
    
    // MARK: - Inits
    
    /// Creates an empty row with no columns.
    public init() {
        elements = [:]
    }
    
    // MARK: - Subscripts
    
    /// Accesses the value associated with the specified column.
    ///
    /// Use this subscript to read or modify the value of a particular column by name. If the column
    /// does not exist, the getter returns `nil` and assigning a value to a new column name adds it
    /// to the row.
    ///
    /// - Parameter column: The name of the column.
    /// - Returns: The value for the specified column, or `nil` if the column is not present.
    /// - Complexity: Average O(1) lookup and amortized O(1) mutation.
    public subscript(column: Column) -> Value? {
        get { elements[column] }
        set { elements[column] = newValue }
    }
    
    // MARK: - Methods
    
    /// Checks whether the row contains a column with the specified name.
    ///
    /// Use this method to check if a column exists without retrieving its value or iterating
    /// through all columns.
    ///
    /// - Parameter column: The name of the column to look for.
    /// - Returns: `true` if the column exists, otherwise `false`.
    /// - Complexity: Average O(1).
    public func contains(_ column: Column) -> Bool {
        elements.keys.contains(column)
    }
    
    /// Reserves enough storage to hold the specified number of columns.
    ///
    /// Calling this method can minimize reallocations when adding multiple columns to the row.
    ///
    /// - Parameter minimumCapacity: The requested number of column-value pairs to store.
    /// - Complexity: O(max(count, minimumCapacity))
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }
    
    /// Reserves enough storage to hold the specified number of columns.
    ///
    /// This overload provides a convenient interface for values originating from SQLite APIs, which
    /// commonly use 32-bit integer sizes.
    ///
    /// - Parameter minimumCapacity: The requested number of column-value pairs to store.
    /// - Complexity: O(max(count, minimumCapacity))
    public mutating func reserveCapacity(_ minimumCapacity: Int32) {
        elements.reserveCapacity(Int(minimumCapacity))
    }
}

// MARK: - CustomStringConvertible

extension SQLiteRow: CustomStringConvertible {
    /// A textual representation of the row as an ordered dictionary of column-value pairs.
    public var description: String {
        elements.description
    }
}

// MARK: - Collection

extension SQLiteRow: Collection {
    /// The element type of the row collection.
    public typealias Element = (column: Column, value: Value)
    
    /// The index type used to access elements in the row.
    public typealias Index = OrderedDictionary<Column, Value>.Index
    
    /// The position of the first element in the row.
    ///
    /// If the row is empty, `startIndex` equals `endIndex`. Use this property as the starting
    /// position when iterating over columns.
    ///
    /// - Complexity: O(1)
    public var startIndex: Index {
        elements.elements.startIndex
    }
    
    /// The position one past the last valid element in the row.
    ///
    /// Use this property to detect the end of iteration when traversing columns.
    ///
    /// - Complexity: O(1)
    public var endIndex: Index {
        elements.elements.endIndex
    }
    
    /// A Boolean value that indicates whether the row contains no columns.
    ///
    /// - Complexity: O(1)
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    /// The number of column-value pairs in the row.
    ///
    /// - Complexity: O(1)
    public var count: Int {
        elements.count
    }
    
    /// Accesses the element at the specified position in the row.
    ///
    /// - Parameter index: A valid index of the row.
    /// - Returns: The (column, value) pair at the specified position.
    /// - Complexity: O(1)
    public subscript(index: Index) -> Element {
        let element = elements.elements[index]
        return (element.key, element.value)
    }
    
    /// Returns the position immediately after the specified index.
    ///
    /// - Parameter i: A valid index of the row.
    /// - Returns: The index immediately after `i`.
    /// - Complexity: O(1)
    public func index(after i: Index) -> Index {
        elements.elements.index(after: i)
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension SQLiteRow: ExpressibleByDictionaryLiteral {
    /// Creates a `SQLiteRow` from a sequence of (column, value) pairs.
    ///
    /// - Parameter elements: The column-value pairs to include in the row.
    /// - Note: Preserves the argument order and requires unique column names.
    /// - Complexity: O(n), where n is the number of pairs.
    public init(dictionaryLiteral elements: (Column, Value)...) {
        self.elements = .init(uniqueKeysWithValues: elements)
    }
}

// MARK: - Equatable

extension SQLiteRow: Equatable {}

// MARK: - Hashable

extension SQLiteRow: Hashable {}

// MARK: - Sendable

extension SQLiteRow: Sendable {}
