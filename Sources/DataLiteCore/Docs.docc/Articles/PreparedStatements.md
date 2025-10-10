# Mastering Prepared Statements

Execute SQL efficiently and safely with reusable prepared statements in DataLiteCore.

Prepared statements allow you to compile SQL once, bind parameters efficiently, and execute it
multiple times without re-parsing or re-planning. The ``Statement`` type in DataLiteCore is a thin,
type-safe wrapper around SQLite’s C API that manages the entire lifecycle of a compiled SQL
statement — from preparation and parameter binding to execution and result retrieval. Statements are
automatically finalized when no longer referenced, ensuring predictable resource cleanup.

## Preparing Statements

Use ``ConnectionProtocol/prepare(sql:)`` or ``ConnectionProtocol/prepare(sql:options:)`` to create
a compiled ``StatementProtocol`` instance ready for parameter binding and execution.

The optional ``Statement/Options`` control how the database engine optimizes the compilation and
reuse of a prepared statement. For example, ``Statement/Options/persistent`` marks the statement as
suitable for long-term reuse, allowing the engine to optimize memory allocation for statements
expected to remain active across multiple executions. ``Statement/Options/noVtab`` restricts the use
of virtual tables during preparation, preventing them from being referenced at compile time.

```swift
let statement = try connection.prepare(
    sql: """
        SELECT id, email
        FROM users
        WHERE status = :status
          AND updated_at >= ?
    """,
    options: [.persistent]
)
```

Implementations of ``StatementProtocol`` are responsible for managing the lifetime of their
underlying database resources. The default ``Statement`` type provided by DataLiteCore automatically
finalizes statements when their last strong reference is released, ensuring deterministic cleanup
through Swift’s memory management.

## Managing the Lifecycle

Use ``StatementProtocol/reset()`` to return a statement to its initial state so that it can be
executed again. Call ``StatementProtocol/clearBindings()`` to remove all previously bound parameter
values, allowing the same prepared statement to be reused with completely new input data. Always
use these methods before reusing a prepared statement.

```swift
try statement.reset()
try statement.clearBindings()
```

## Binding Parameters

You can bind either raw ``SQLiteValue`` values or any Swift type that conforms to ``SQLiteBindable``
or ``SQLiteRepresentable``. Parameter placeholders in the SQL statement are assigned numeric indexes
in the order they appear, starting from `1`.

To inspect or debug parameter mappings, use ``StatementProtocol/parameterCount()`` to check the
total number of parameters, or ``StatementProtocol/parameterNameBy(_:)`` to retrieve the name of a
specific placeholder by its index.

### Binding by Index

Use positional placeholders to bind parameters by numeric index. A simple `?` placeholder is
automatically assigned the next available index in the order it appears, starting from `1`.
A numbered placeholder (`?NNN`) explicitly defines its own index within the statement, letting you
bind parameters out of order if needed.

```swift
let insertLog = try connection.prepare(sql: """
    INSERT INTO logs(level, message, created_at)
    VALUES (?, ?, ?)
""")

try insertLog.bind("info", at: 1)
try insertLog.bind("Cache warmed", at: 2)
try insertLog.bind(Date(), at: 3)
try insertLog.step()    // executes the INSERT
try insertLog.reset()
```

### Binding by Name

Named placeholders (`:name`, `@name`, `$name`) improve readability and allow the same parameter to
appear multiple times within a statement. When binding, pass the full placeholder token — including
its prefix — to the ``StatementProtocol/bind(_:by:)-(SQLiteValue,_)`` method.

```swift
let usersByStatus = try connection.prepare(sql: """
    SELECT id, email
    FROM users
    WHERE status = :status
      AND email LIKE :pattern
""")

try usersByStatus.bind("active", by: ":status")
try usersByStatus.bind("%@example.com", by: ":pattern")
```

If you need to inspect the numeric index associated with a named parameter, use
``StatementProtocol/parameterIndexBy(_:)``. This can be useful for diagnostics, logging, or
integrating with utility layers that operate by index.

### Reusing Parameters

When the same named placeholder appears multiple times in a statement, SQLite internally assigns all
of them to a single binding slot. This means you only need to set the value once, and it will be
applied everywhere that placeholder occurs.

```swift
let sales = try connection.prepare(sql: """
    SELECT id
    FROM orders
    WHERE customer_id = :client
       OR created_by = :client
    LIMIT :limit
""")

try sales.bind(42, by: ":client") // used for both conditions
try sales.bind(50, by: ":limit")
```

### Mixing Placeholders

You can freely combine named and positional placeholders within the same statement. SQLite assigns
numeric indexes to all placeholders in the order they appear, regardless of whether they are named
or positional. To keep bindings predictable, it’s best to follow a consistent style within each
statement.

```swift
let search = try connection.prepare(sql: """
    SELECT id, title
    FROM articles
    WHERE category_id IN (?, ?, ?)
      AND published_at >= :since
""")

try search.bind(3, at: 1)
try search.bind(5, at: 2)
try search.bind(8, at: 3)
try search.bind(Date(timeIntervalSinceNow: -7 * 24 * 60 * 60), by: ":since")
```

## Executing Statements

Advance execution with ``StatementProtocol/step()``. This method returns `true` while rows are
available, and `false` when the statement is fully consumed — or immediately, for statements that
do not produce results.

Always reset a statement before re-executing it; otherwise, the database engine will report a misuse
error.

```swift
var rows: [SQLiteRow] = []
while try usersByStatus.step() {
    if let row = usersByStatus.currentRow() {
        rows.append(row)
    }
}

try usersByStatus.reset()
try usersByStatus.clearBindings()
```

For bulk operations, use ``StatementProtocol/execute(_:)``. It accepts an array of ``SQLiteRow``
values and automatically performs binding, stepping, clearing, and resetting in a loop — making it
convenient for batch inserts or updates.

## Fetching Result Data

Use ``StatementProtocol/columnCount()`` and ``StatementProtocol/columnName(at:)`` to inspect the
structure of the result set. Retrieve individual column values with
``StatementProtocol/columnValue(at:)->SQLiteValue`` — either as a raw ``SQLiteValue`` or as a typed
value conforming to ``SQLiteRepresentable``. Alternatively, use ``StatementProtocol/currentRow()``
to obtain the full set of column values for the current result row.

```swift
while try statement.step() {
    guard let identifier: Int64 = statement.columnValue(at: 0),
          let email: String = statement.columnValue(at: 1)
    else { continue }
    print("User \(identifier): \(email)")
}
try statement.reset()
```

Each row returned by `currentRow()` is an independent copy of the current result data. You can
safely store it, transform it into a domain model, or reuse its values as parameters in subsequent
statements through ``StatementProtocol/bind(_:)``.

- SeeAlso: ``StatementProtocol``
- SeeAlso: ``Statement``
- SeeAlso: [SQLite Prepared Statements](https://sqlite.org/c3ref/stmt.html)
