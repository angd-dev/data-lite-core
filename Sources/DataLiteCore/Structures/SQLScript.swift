import Foundation

/// A structure representing a collection of SQL queries.
///
/// ## Overview
///
/// `SQLScript` is a structure for loading and processing SQL scripts, representing a collection
/// where each element is an individual SQL query. It allows loading scripts from a file via URL,
/// from the app bundle, or from a string, and provides convenient access to individual SQL queries
/// and the ability to iterate over them.
///
/// ## Usage Examples
///
/// ### Loading from a File
///
/// To load a SQL script from a file in your project, use the following code. In this example,
/// we load a file named `sample_script.sql` from the main app bundle.
///
/// ```swift
/// do {
///     guard let sqlScript = try SQLScript(
///         byResource: "sample_script",
///         extension: "sql"
///     ) else {
///         throw NSError(
///             domain: "SomeDomain",
///             code: -1,
///             userInfo: [:]
///         )
///     }
///
///     for (index, statement) in sqlScript.enumerated() {
///         print("Query \(index + 1):")
///         print(statement)
///         print("--------------------")
///     }
/// } catch {
///     print("Error: \(error.localizedDescription)")
/// }
/// ```
///
/// ### Loading from a String
///
/// If the SQL queries are already contained in a string, you can create an instance of `SQLScript`
/// by passing the string to the initializer. Below is an example where we create a SQL script
/// with two queries: creating a table and inserting data.
///
/// ```swift
/// do {
///     let sqlString = """
///     CREATE TABLE users (
///         id INTEGER PRIMARY KEY,
///         username TEXT NOT NULL,
///         email TEXT NOT NULL
///     );
///     INSERT INTO users (id, username, email)
///     VALUES (1, 'john_doe', 'john@example.com');
///     """
///
///     let sqlScript = try SQLScript(string: sqlString)
///
///     for (index, statement) in sqlScript.enumerated() {
///         print("Query \(index + 1):")
///         print(statement)
///         print("--------------------")
///     }
/// } catch {
///     print("Error: \(error.localizedDescription)")
/// }
/// ```
///
/// ## SQL Format and Syntax
///
/// `SQLScript` is designed to handle SQL scripts that contain one or more SQL queries. Each query
/// must end with a semicolon (`;`), which indicates the end of the statement.
///
/// **Supported Features:**
///
/// - **Command Separation:** Each query ends with a semicolon (`;`), marking the end of the command.
/// - **Formatting:** SQLScript removes lines containing only whitespace or comments, keeping
///   only the valid SQL queries in the collection.
/// - **Comment Support:** Single-line (`--`) and multi-line (`/* */`) comments are supported.
///
/// **Example of a correctly formatted SQL script:**
///
/// ```sql
/// -- Create users table
/// CREATE TABLE users (
///     id INTEGER PRIMARY KEY,
///     username TEXT NOT NULL,
///     email TEXT NOT NULL
/// );
///
/// -- Insert data into users table
/// INSERT INTO users (id, username, email)
/// VALUES (1, 'john_doe', 'john@example.com');
///
/// /* Update user data */
/// UPDATE users
/// SET email = 'john.doe@example.com'
/// WHERE id = 1;
/// ```
///
/// - Important: Nested comments are not supported, so avoid placing multi-line comments inside
///   other multi-line comments.
///
/// - Important: `SQLScript` does not support SQL scripts containing transactions.
///   To execute an `SQLScript`, use the method ``Connection/execute(sql:)``, which executes
///   each statement individually in autocommit mode.
///
///   If you need to execute the entire `SQLScript` within a single transaction, use the methods
///   ``Connection/beginTransaction(_:)``, ``Connection/commitTransaction()``, and
///   ``Connection/rollbackTransaction()`` to manage the transaction explicitly.
///
///   If your SQL script includes transaction statements (e.g., BEGIN, COMMIT, ROLLBACK),
///   execute the entire script using ``Connection/execute(raw:)``.
///
/// - Important: This class is not designed to work with untrusted user data. Never insert
///   user-provided data directly into SQL queries without proper sanitization or parameterization.
///   Unfiltered data can lead to SQL injection attacks, which pose a security risk to your data and
///   database. For more information about SQL injection risks, see the OWASP documentation:
///   [SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection).
public struct SQLScript: Collection, ExpressibleByStringLiteral {
    /// The type representing the index in the collection of SQL queries.
    ///
    /// This type is used to access elements in the `SQLScript` collection. The index is an
    /// integer (`Int`) indicating the position of the SQL query in the collection.
    public typealias Index = Int
    
    /// The type representing an element in the collection of SQL queries.
    ///
    /// This type defines that each element in the `SQLScript` collection is a string (`String`).
    /// Each element represents a separate SQL query that can be loaded and processed.
    public typealias Element = String
    
    // MARK: - Properties
    
    /// An array containing SQL queries.
    private var elements: [Element]
    
    /// The starting index of the collection of SQL queries.
    ///
    /// This property returns the index of the first element in the collection. The starting
    /// index is used to initialize iterators and access the elements of the collection. If
    /// the collection is empty, this value will equal `endIndex`.
    public var startIndex: Index {
        elements.startIndex
    }
    
    /// The end index of the collection of SQL queries.
    ///
    /// This property returns the index that indicates the position following the last element
    /// of the collection. The end index is used for iterating over the collection and marks
    /// the point where the collection ends. If the collection is empty, this value will equal
    /// `startIndex`.
    public var endIndex: Index {
        elements.endIndex
    }
    
    /// The number of SQL queries in the collection.
    ///
    /// This property returns the total number of SQL queries stored in the collection. The
    /// value will be 0 if the collection is empty. Use this property to know how many queries
    /// can be processed or iterated over.
    public var count: Int {
        elements.count
    }
    
    /// A Boolean value indicating whether the collection is empty.
    ///
    /// This property returns `true` if there are no SQL queries in the collection, and `false`
    /// otherwise. Use this property to check for the presence of SQL queries before performing
    /// operations that require elements in the collection.
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    // MARK: - Inits
    
    /// Initializes an instance of `SQLScript`, loading SQL queries from a resource file.
    ///
    /// This initializer looks for a file with the specified name and extension in the given
    /// bundle and loads its contents as SQL queries.
    ///
    /// - If `name` is `nil`, the first found resource file with the specified extension will
    /// be loaded.
    /// - If `extension` is an empty string or `nil`, it is assumed that the extension does
    /// not exist, and the first found file that exactly matches the name will be loaded.
    /// - Returns `nil` if the specified file is not found.
    ///
    /// - Parameters:
    ///   - name: The name of the resource file containing SQL queries.
    ///   - extension: The extension of the resource file. Defaults to `nil`.
    ///   - bundle: The bundle from which to load the resource file. Defaults to `.main`.
    ///
    /// - Throws: An error if the file cannot be loaded or processed.
    public init?(
        byResource name: String?,
        extension: String? = nil,
        in bundle: Bundle = .main
    ) throws {
        guard let url = bundle.url(
            forResource: name,
            withExtension: `extension`
        ) else { return nil }
        try self.init(contentsOf: url)
    }
    
    /// Initializes an instance of `SQLScript`, loading SQL queries from the specified file.
    ///
    /// This initializer takes a URL to a file and loads its contents as SQL queries.
    ///
    /// - Parameter url: The URL of the file containing SQL queries.
    ///
    /// - Throws: An error if the file cannot be loaded or processed.
    public init(contentsOf url: URL) throws {
        try self.init(string: .init(contentsOf: url, encoding: .utf8))
    }
    
    /// Initializes an instance of `SQLScript` from a string literal.
    ///
    /// This initializer allows you to create a `SQLScript` instance directly from a string literal.
    /// The string is parsed into individual SQL queries, removing comments and empty lines.
    ///
    /// - Parameter value: The string literal containing SQL queries. Each query should be separated
    ///   by semicolons (`;`), and the string can include comments and empty lines, which will
    ///   be ignored during initialization.
    ///
    /// - Warning: The string literal should represent valid SQL queries. Invalid syntax or
    ///   improperly formatted SQL may lead to an error at runtime.
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)
    }
    
    /// Initializes an instance of `SQLScript` by parsing SQL queries from the specified string.
    ///
    /// This initializer takes a string containing SQL queries and extracts individual queries,
    /// removing comments and empty lines.
    ///
    /// - Parameter string: The string containing SQL queries.
    public init(string: String) {
        elements = string
            .removingComments()
            .trimmingLines()
            .splitStatements()
    }
    
    // MARK: - Collection Methods
    
    /// Accesses the element at the specified position in the collection.
    ///
    /// - Parameter index: The index of the SQL query in the collection. The index must be within the
    ///   bounds of the collection. If an out-of-bounds index is provided, a runtime error will occur.
    ///
    /// - Returns: The SQL query as a string at the specified index.
    public subscript(index: Index) -> Element {
        elements[index]
    }
    
    /// Returns the index after the given index.
    ///
    /// This method is used for iterating through the collection. It provides the next valid
    /// index following the specified index.
    ///
    /// - Parameter i: The index of the current element.
    ///
    /// - Returns: The index of the next element in the collection. If `i` is the last
    ///   index in the collection, this method returns `endIndex`, which is one past the
    ///   last valid index.
    public func index(after i: Index) -> Index {
        elements.index(after: i)
    }
}
