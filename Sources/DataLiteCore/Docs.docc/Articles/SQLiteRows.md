# Working with SQLiteRow

Represent SQL rows and parameters with SQLiteRow.

``SQLiteRow`` is an ordered container for column/value pairs. It preserves insertion order—matching
the schema when representing result sets—and provides helpers for column names, named parameters,
and literal rendering.

## Creating Rows

Initialize a row with a dictionary literal or assign values incrementally through subscripting.
Values can be ``SQLiteValue`` instances or any type convertible via ``SQLiteRepresentable``.

```swift
var payload: SQLiteRow = [
    "username": .text("ada"),
    "email": "ada@example.com".sqliteValue,
    "is_admin": false.sqliteValue
]

payload["last_login_at"] = Int64(Date().timeIntervalSince1970).sqliteValue
```

``SQLiteRow/columns`` returns the ordered column names, and ``SQLiteRow/namedParameters`` provides
matching tokens (prefixed with `:`) suitable for parameterized SQL.

```swift
print(payload.columns)         // ["username", "email", "is_admin", "last_login_at"]
print(payload.namedParameters) // [":username", ":email", ":is_admin", ":last_login_at"]
```

## Generating SQL Fragments

Use row metadata to build SQL snippets without manual string concatenation:

```swift
let columns = payload.columns.joined(separator: ", ")
let placeholders = payload.namedParameters.joined(separator: ", ")
let assignments = zip(payload.columns, payload.namedParameters)
    .map { "\($0) = \($1)" }
    .joined(separator: ", ")

// columns -> "username, email, is_admin, last_login_at"
// placeholders -> ":username, :email, :is_admin, :last_login_at"
// assignments -> "username = :username, ..."
```

When generating migrations or inserting literal values, ``SQLiteValue/sqliteLiteral`` renders safe
SQL fragments for numeric and text values. Always escape identifiers manually if column names come
from untrusted input.

## Inserting Rows

Bind an entire row to a statement using ``StatementProtocol/bind(_:)``. The method matches column
names to identically named placeholders.

```swift
var user: SQLiteRow = [
    "username": .text("ada"),
    "email": .text("ada@example.com"),
    "created_at": Int64(Date().timeIntervalSince1970).sqliteValue
]

let insertSQL = """
INSERT INTO users (\(user.columns.joined(separator: ", ")))
VALUES (\(user.namedParameters.joined(separator: ", ")))
"""

let insert = try connection.prepare(sql: insertSQL)
try insert.bind(user)
try insert.step()
try insert.reset()
```

To insert multiple rows, prepare an array of ``SQLiteRow`` values and call
``StatementProtocol/execute(_:)``. The helper performs binding, stepping, and clearing for each row:

```swift
let batch: [SQLiteRow] = [
    ["username": .text("ada"), "email": .text("ada@example.com")],
    ["username": .text("grace"), "email": .text("grace@example.com")]
]

try insert.execute(batch)
```

## Updating Rows

Because ``SQLiteRow`` is a value type, you can duplicate and extend it for related operations such
as building `SET` clauses or constructing `WHERE` conditions.

```swift
var changes: SQLiteRow = [
    "email": .text("ada@new.example"),
    "last_login_at": Int64(Date().timeIntervalSince1970).sqliteValue
]

let setClause = zip(changes.columns, changes.namedParameters)
    .map { "\($0) = \($1)" }
    .joined(separator: ", ")

var parameters = changes
parameters["id"] = .int(1)

let update = try connection.prepare(sql: """
    UPDATE users
    SET \(setClause)
    WHERE id = :id
""")

try update.bind(parameters)
try update.step()
```

## Reading Rows

``StatementProtocol/currentRow()`` returns an ``SQLiteRow`` snapshot of the current result. Use it
to pass data through mapping layers or transform results lazily without immediate conversion:

```swift
let statement = try connection.prepare(sql: "SELECT id, email FROM users LIMIT 10")

var rows: [SQLiteRow] = []
while try statement.step() {
    if let row = statement.currentRow() {
        rows.append(row)
    }
}
```

You can iterate over a row’s columns via `columns`, and subscript by name to retrieve stored values.
For typed access, cast through ``SQLiteValue`` or adopt ``SQLiteRepresentable`` in your custom
types.

## Diagnostics

Use ``SQLiteRow/description`` to log payloads during development. For security-sensitive logs,
redact or whitelist keys before printing. Because rows preserve order, logs mirror the schema
defined in your SQL, making comparisons straightforward.

- SeeAlso: ``SQLiteRow``
- SeeAlso: ``StatementProtocol``
