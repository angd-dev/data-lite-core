# Running SQL Scripts

Execute and automate SQL migrations, seed data, and test fixtures with DataLiteCore.

``SQLScript`` and ``ConnectionProtocol/execute(sql:)`` let you run sequences of prepared statements
as a single script. The loader splits content by semicolons, removes comments and whitespace, and
compiles each statement individually. Scripts run in autocommit mode by default — execution stops at
the first failure and throws the corresponding ``SQLiteError``.

## Building Scripts

Create a script inline or load it from a bundled resource. ``SQLScript`` automatically strips
comments and normalizes whitespace.

```swift
let script = SQLScript(string: """
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL UNIQUE
    );
    INSERT INTO users (username) VALUES ('ada'), ('grace');
""")
```

Load a script from your module or app bundle using ``SQLScript/init(byResource:extension:in:)``:

```swift
let bootstrap = try? SQLScript(
    byResource: "bootstrap",
    extension: "sql",
    in: .module
)
```

## Executing Scripts

Run the script through ``ConnectionProtocol/execute(sql:)``. Statements execute sequentially in the
order they appear.

```swift
let connection = try Connection(
    location: .file(path: dbPath),
    options: [.readwrite, .create]
)
try connection.execute(sql: script)
```

In autocommit mode, each statement commits as soon as it succeeds. If any statement fails, execution
stops and previously executed statements remain committed. To ensure all-or-nothing execution, wrap
the script in an explicit transaction:

```swift
try connection.beginTransaction(.immediate)
do {
    try connection.execute(sql: script)
    try connection.commitTransaction()
} catch {
    try? connection.rollbackTransaction()
    throw error
}
```

- Important: SQLScript must not include BEGIN, COMMIT, or ROLLBACK. Always manage transactions at
  the connection level.

## Executing Raw SQL

Use ``ConnectionProtocol/execute(raw:)`` to run multi-statement SQL directly, without parsing or
preprocessing. This method executes the script exactly as provided, allowing you to manage
transactions explicitly within the SQL itself.

```swift
let migrations = """
    BEGIN;
    CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
    );
    INSERT INTO categories (name) VALUES ('Swift'), ('SQLite');
    COMMIT;
"""

try connection.execute(raw: migrations)
```

Each statement runs in sequence until completion or until the first error occurs. If a statement
fails, execution stops and remaining statements are skipped. Open transactions are not rolled back
automatically — they must be handled explicitly inside the script or by the caller.

## Handling Errors

Inspect the thrown ``SQLiteError`` to identify the failing statement’s result code and message. For
longer scripts, wrap execution in logging to trace progress and isolate the exact statement that
triggered the exception.

- SeeAlso: ``SQLScript``
- SeeAlso: ``ConnectionProtocol/execute(sql:)``
- SeeAlso: ``ConnectionProtocol/execute(raw:)``
