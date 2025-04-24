import Foundation
import OrderedCollections

extension Statement {
    /// A structure representing a set of arguments used in database statements.
    ///
    /// `Arguments` provides a convenient way to manage and pass parameters to database queries.
    /// It supports both indexed and named tokens, allowing flexibility in specifying parameters.
    ///
    /// ## Argument Tokens
    ///
    /// A "token" in this context refers to a placeholder in the SQL statement for a value that is provided at runtime.
    /// There are two types of tokens:
    ///
    /// - Indexed Tokens: Represented by numerical indices (`?NNNN`, `?`).
    ///   These placeholders correspond to specific parameter positions.
    /// - Named Tokens: Represented by string names (`:AAAA`, `@AAAA`, `$AAAA`).
    ///   These placeholders are identified by unique names.
    ///
    /// More information on SQLite parameters can be found [here](https://www.sqlite.org/lang_expr.html#varparam).
    /// The `Arguments` structure supports indexed (?) and named (:AAAA) forms of tokens.
    ///
    /// ## Creating Arguments
    ///
    /// You can initialize `Arguments` using arrays or dictionaries:
    ///
    /// - **Indexed Arguments**: Initialize with an array of values or use an array literal.
    /// ```swift
    /// let args: Statement.Arguments = ["John", 30]
    /// ```
    /// - **Named Arguments**: Initialize with a dictionary of named values or use a dictionary literal.
    /// ```swift
    /// let args: Statement.Arguments = ["name": "John", "age": 30]
    /// ```
    ///
    /// ## Combining Arguments
    ///
    /// You can combine two sets of `Arguments` using the ``merge(with:using:)-23pzs``or
    /// ``merged(with:using:)-23p3q``methods. These methods allow you to define how to resolve
    /// conflicts when the same parameter token exists in both argument sets.
    ///
    /// ```swift
    /// var base: Statement.Arguments = ["name": "Alice"]
    /// let update: Statement.Arguments = ["name": "Bob", "age": 30]
    ///
    /// base.merge(with: update) { token, current, new in
    ///     return .replace
    /// }
    /// ```
    ///
    /// Alternatively, you can create a new merged instance without modifying the original:
    ///
    /// ```swift
    /// let merged = base.merged(with: update) { token, current, new in
    ///     return .ignore
    /// }
    /// ```
    ///
    /// Conflict resolution is controlled by the closure you provide, which receives the token, the current value,
    /// and the new value. It returns a value of type ``ConflictResolution``, specifying how to handle the
    /// conflict.. This ensures that merging is performed explicitly and predictably, avoiding accidental overwrites.
    ///
    /// - Important: Although mixing parameter styles is technically allowed, it is generally not recommended.
    ///   For clarity and maintainability, you should consistently use either indexed or named parameters
    ///   throughout a query. Mixing styles may lead to confusion or hard-to-diagnose bugs in more complex queries.
    ///
    /// ## Topics
    ///
    /// ### Subtypes
    ///
    /// - ``Token``
    /// - ``ConflictResolution``
    ///
    /// ### Type Aliases
    ///
    /// - ``Resolver``
    /// - ``Elements``
    /// - ``RawValue``
    /// - ``Index``
    /// - ``Element``
    ///
    /// ### Initializers
    ///
    /// - ``init()``
    /// - ``init(_:)-1v7s``
    /// - ``init(_:)-bfj9``
    /// - ``init(arrayLiteral:)``
    /// - ``init(dictionaryLiteral:)``
    ///
    /// ### Instance Properties
    ///
    /// - ``tokens``
    /// - ``count``
    /// - ``isEmpty``
    /// - ``startIndex``
    /// - ``endIndex``
    /// - ``description``
    ///
    /// ### Instance Methods
    ///
    /// - ``index(after:)``
    /// - ``contains(_:)``
    /// - ``merged(with:using:)-23p3q``
    /// - ``merged(with:using:)-89krm``
    /// - ``merge(with:using:)-23pzs``
    /// - ``merge(with:using:)-4r21o``
    ///
    /// ### Subscripts
    ///
    /// - ``subscript(_:)``
    public struct Arguments: Collection, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, CustomStringConvertible {
        /// Represents a token used in database statements, either indexed or named.
        ///
        /// Tokens are used to identify placeholders for values in SQL statements.
        /// They can either be indexed, represented by an integer index, or named, represented by a string name.
        public enum Token: Hashable {
            /// Represents an indexed token with a numerical index.
            case indexed(index: Int)
            /// Represents a named token with a string name.
            case named(name: String)
        }
        
        /// A strategy for resolving conflicts when merging two sets of arguments.
        ///
        /// When two `Arguments` instances contain the same token, a `ConflictResolution` value
        /// determines how the conflict should be handled.
        public enum ConflictResolution {
            /// Keeps the current value and ignores the new one.
            case ignore
            /// Replaces the current value with the new one.
            case replace
        }
        
        /// A closure used to resolve conflicts when merging two sets of arguments.
        ///
        /// This closure is invoked when both argument sets contain the same token.
        /// It determines whether to keep the existing value or replace it with the new one.
        ///
        /// - Parameters:
        ///   - token: The conflicting parameter token.
        ///   - current: The value currently associated with the token.
        ///   - new: The new value from the other argument set.
        /// - Returns: A strategy indicating how to resolve the conflict.
        public typealias Resolver = (
            _ token: Token,
            _ current: SQLiteRawValue,
            _ new: SQLiteRawValue
        ) -> ConflictResolution
        
        /// The underlying storage for `Arguments`, mapping tokens to their raw values while preserving order.
        ///
        /// Keys are tokens (either indexed or named), and values are the corresponding SQLite-compatible values.
        public typealias Elements = OrderedDictionary<Token, SQLiteRawValue>
        
        /// The value type used in the underlying elements dictionary.
        ///
        /// This represents a SQLite-compatible raw value, such as a string, number, or null.
        public typealias RawValue = Elements.Value
        
        /// The index type used to traverse the arguments collection.
        public typealias Index = Elements.Index
        
        /// A key–value pair representing an argument token and its associated value.
        public typealias Element = (token: Token, value: RawValue)
        
        // MARK: - Private Properties
        
        private var elements: Elements
        
        // MARK: - Public Properties
        
        /// The starting index of the arguments collection, which is always zero.
        ///
        /// This property represents the initial position in the arguments collection.
        /// Since the elements are indexed starting from zero, it consistently returns zero,
        /// allowing predictable forward iteration.
        ///
        /// - Complexity: `O(1)`
        public var startIndex: Index {
            0
        }
        
        /// The ending index of the arguments collection, equal to the number of elements.
        ///
        /// This property marks the position one past the last element in the collection.
        /// It returns the total number of arguments and defines the upper bound for iteration
        /// over tokens and their associated values.
        ///
        /// - Complexity: `O(1)`
        public var endIndex: Index {
            elements.count
        }
        
        /// A Boolean value indicating whether the arguments collection is empty.
        ///
        /// Returns `true` if the collection contains no arguments; otherwise, returns `false`.
        ///
        /// - Complexity: `O(1)`
        public var isEmpty: Bool {
            elements.isEmpty
        }
        
        /// The number of arguments in the collection.
        ///
        /// This property reflects the total number of token–value pairs
        /// currently stored in the arguments set.
        ///
        /// - Complexity: `O(1)`
        public var count: Int {
            elements.count
        }
        
        /// A textual representation of the arguments collection.
        ///
        /// The description includes all tokens and their associated values
        /// in the order they appear in the collection. This is useful for debugging.
        ///
        /// - Complexity: `O(n)`
        public var description: String {
            elements.description
        }
        
        /// An array of all tokens present in the arguments collection.
        ///
        /// The tokens are returned in insertion order and include both
        /// indexed and named forms, depending on how the arguments were constructed.
        ///
        /// - Complexity: `O(1)`
        public var tokens: [Token] {
            elements.keys.elements
        }
        
        // MARK: - Inits
        
        /// Initializes an empty `Arguments`.
        ///
        /// - Complexity: `O(1)`
        public init() {
            self.elements = [:]
        }
        
        /// Initializes `Arguments` with an array of values.
        ///
        /// - Parameter elements: An array of `SQLiteRawBindable` values.
        ///
        /// - Complexity: `O(n)`, where `n` is the number of elements in the input array.
        public init(_ elements: [SQLiteRawBindable?]) {
            self.elements = .init(
                uniqueKeysWithValues: elements.enumerated().map { offset, value in
                    (.indexed(index: offset + 1), value?.sqliteRawValue ?? .null)
                }
            )
        }
        
        /// Initializes `Arguments` with a dictionary of named values.
        ///
        /// - Parameter elements: A dictionary mapping names to `SQLiteRawBindable` values.
        ///
        /// - Complexity: `O(n)`, where `n` is the number of elements in the input dictionary.
        public init(_ elements: [String: SQLiteRawBindable?]) {
            self.elements = .init(
                uniqueKeysWithValues: elements.map { name, value in
                    (.named(name: name), value?.sqliteRawValue ?? .null)
                }
            )
        }
        
        /// Initializes `Arguments` from an array literal.
        ///
        /// This initializer enables array literal syntax for positional (indexed) arguments.
        ///
        /// ```swift
        /// let args: Statement.Arguments = ["Alice", 42]
        /// ```
        ///
        /// Each value is bound to a token of the form `?1`, `?2`, etc., based on its position.
        ///
        /// - Complexity: `O(n)`, where `n` is the number of elements.
        public init(arrayLiteral elements: SQLiteRawBindable?...) {
            self.elements = .init(
                uniqueKeysWithValues: elements.enumerated().map { offset, value in
                    (.indexed(index: offset + 1), value?.sqliteRawValue ?? .null)
                }
            )
        }
        
        /// Initializes `Arguments` from a dictionary literal.
        ///
        /// This initializer enables dictionary literal syntax for named arguments.
        ///
        /// ```swift
        /// let args: Statement.Arguments = ["name": "Alice", "age": 42]
        /// ```
        ///
        /// Each key becomes a named token (`:name`, `:age`, etc.).
        ///
        /// - Complexity: `O(n)`, where `n` is the number of elements.
        public init(dictionaryLiteral elements: (String, SQLiteRawBindable?)...) {
            self.elements = .init(
                uniqueKeysWithValues: elements.map { name, value in
                    (.named(name: name), value?.sqliteRawValue ?? .null)
                }
            )
        }
        
        // MARK: - Subscripts
        
        /// Accesses the element at the specified position.
        ///
        /// This subscript returns the `(token, value)` pair located at the given index
        /// in the arguments collection. The order of elements reflects their insertion order.
        ///
        /// - Parameter index: The position of the element to access.
        /// - Returns: A tuple containing the token and its associated value.
        ///
        /// - Complexity: `O(1)`
        public subscript(index: Index) -> Element {
            let element = elements.elements[index]
            return (element.key, element.value)
        }
        
        // MARK: - Methods
        
        /// Returns the position immediately after the given index.
        ///
        /// Use this method to advance an index when iterating over the arguments collection.
        ///
        /// - Parameter i: A valid index of the collection.
        /// - Returns: The index value immediately following `i`.
        ///
        /// - Complexity: `O(1)`
        public func index(after i: Index) -> Index {
            i + 1
        }
        
        /// Returns a Boolean value indicating whether the specified token exists in the arguments.
        ///
        /// Use this method to check whether a token—either indexed or named—is present in the collection.
        ///
        /// - Parameter token: The token to search for in the arguments.
        /// - Returns: `true` if the token exists in the collection; otherwise, `false`.
        ///
        /// - Complexity: On average, the complexity is `O(1)`.
        public func contains(_ token: Token) -> Bool {
            elements.keys.contains(token)
        }
        
        /// Merges the contents of another `Arguments` instance into this one using a custom resolver.
        ///
        /// For each token present in `other`, the method either inserts the new value
        /// or resolves conflicts when the token already exists in the current collection.
        ///
        /// - Parameters:
        ///   - other: Another `Arguments` instance whose contents will be merged into this one.
        ///   - resolve: A closure that determines how to resolve conflicts between existing and new values.
        /// - Complexity: `O(n)`, where `n` is the number of elements in `other`.
        public mutating func merge(with other: Self, using resolve: Resolver) {
            for (token, newValue) in other.elements {
                if let index = elements.index(forKey: token) {
                    let currentValue = elements.values[index]
                    switch resolve(token, currentValue, newValue) {
                    case .ignore: continue
                    case .replace: elements[token] = newValue
                    }
                } else {
                    elements[token] = newValue
                }
            }
        }
        
        /// Merges the contents of another `Arguments` instance into this one using a fixed conflict resolution strategy.
        ///
        /// This variant applies the same resolution strategy to all conflicts without requiring a custom closure.
        ///
        /// - Parameters:
        ///   - other: Another `Arguments` instance whose contents will be merged into this one.
        ///   - resolution: A fixed strategy to apply when a token conflict occurs.
        /// - Complexity: `O(n)`, where `n` is the number of elements in `other`.
        public mutating func merge(with other: Self, using resolution: ConflictResolution) {
            merge(with: other) { _, _, _ in resolution }
        }
        
        /// Returns a new `Arguments` instance by merging the contents of another one using a custom resolver.
        ///
        /// This method creates a copy of the current arguments and merges `other` into it.
        /// For each conflicting token, the provided resolver determines whether to keep the existing value
        /// or replace it with the new one.
        ///
        /// - Parameters:
        ///   - other: Another `Arguments` instance whose contents will be merged into the copy.
        ///   - resolve: A closure that determines how to resolve conflicts between existing and new values.
        /// - Returns: A new `Arguments` instance containing the merged values.
        /// - Complexity: `O(n)`, where `n` is the number of elements in `other`.
        public func merged(with other: Self, using resolve: Resolver) -> Self {
            var copy = self
            copy.merge(with: other, using: resolve)
            return copy
        }
        
        /// Returns a new `Arguments` instance by merging the contents of another one using a fixed strategy.
        ///
        /// This variant uses the same resolution strategy for all conflicts without requiring a custom closure.
        ///
        /// - Parameters:
        ///   - other: Another `Arguments` instance whose contents will be merged into the copy.
        ///   - resolution: A fixed strategy to apply when a token conflict occurs.
        /// - Returns: A new `Arguments` instance containing the merged values.
        /// - Complexity: `O(n)`, where `n` is the number of elements in `other`.
        public func merged(with other: Self, using resolution: ConflictResolution) -> Self {
            merged(with: other) { _, _, _ in resolution }
        }
    }
}
