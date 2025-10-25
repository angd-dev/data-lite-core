# Working with Connections

Open, configure, monitor, and transact with SQLite connections using DataLiteCore.

Establishing and configuring a ``Connection`` is the first step before executing SQL statements
with **DataLiteCore**. A connection wraps the underlying SQLite handle, exposes ergonomic Swift
APIs, and provides hooks for observing database activity.

## Opening a Connection

Create a connection with ``Connection/init(location:options:)``. The initializer opens (or creates)
the target database file and registers lifecycle hooks that enable tracing, update notifications,
and transaction callbacks.

Call ``ConnectionProtocol/initialize()`` once during application start-up when you need to ensure
the SQLite core has been initialized manually—for example, when linking SQLite dynamically or when
the surrounding framework does not do it on your behalf. Pair it with
``ConnectionProtocol/shutdown()`` during application tear-down if you require full control of
SQLite's global state.

```swift
import DataLiteCore

do {
    try Connection.initialize()
    let connection = try Connection(
        location: .file(path: "/path/to/sqlite.db"),
        options: [.readwrite, .create]
    )
    // Execute SQL or configure PRAGMAs
} catch {
    print("Failed to open database: \(error)")
}
```

### Choosing a Location

Pick the database storage strategy from the ``Connection/Location`` enumeration:

- ``Connection/Location/file(path:)`` — a persistent on-disk file or URI backed database.
- ``Connection/Location/inMemory`` — a pure in-memory database that disappears once the connection
  closes.
- ``Connection/Location/temporary`` — a transient on-disk file that SQLite removes when the session
  ends.

### Selecting Options

Control how the connection is opened with ``Connection/Options``. Combine flags to describe the
required access mode, locking policy, and URI behavior.

```swift
let connection = try Connection(
    location: .inMemory,
    options: [.readwrite, .nomutex]
)
```

Common combinations include:

- ``Connection/Options/readwrite`` + ``Connection/Options/create`` — read/write access that creates
  the file if missing.
- ``Connection/Options/readonly`` — read-only access preventing accidental writes.
- ``Connection/Options/fullmutex`` — enables serialized mode for multi-threaded access.
- ``Connection/Options/uri`` — allows SQLite URI parameters, such as query string pragmas.

- SeeAlso: [Opening A New Database Connection](https://sqlite.org/c3ref/open.html)
- SeeAlso: [In-Memory Databases](https://sqlite.org/inmemorydb.html)

## Closing a Connection

``Connection`` automatically closes the underlying SQLite handle when the instance is deallocated.
This ensures resources are released even when the object leaves scope unexpectedly. For long-lived
applications, prefer explicit lifecycle management—store the connection in a dedicated component
and release it deterministically when you are done to avoid keeping file locks or WAL checkpoints
around unnecessarily.

If your application called ``ConnectionProtocol/shutdown()`` to clean up global state, make sure all
connections have been released before invoking it.

## Managing Transactions

Manage transactional work with ``ConnectionProtocol/beginTransaction(_:)``,
``ConnectionProtocol/commitTransaction()``, and ``ConnectionProtocol/rollbackTransaction()``. When
you do not start a transaction explicitly, SQLite runs in autocommit mode and executes each
statement in its own transaction.

```swift
do {
    try connection.beginTransaction(.immediate)
    try connection.execute(sql: "INSERT INTO users (name) VALUES ('Ada')")
    try connection.execute(sql: "INSERT INTO users (name) VALUES ('Grace')")
    try connection.commitTransaction()
} catch {
    try? connection.rollbackTransaction()
    throw error
}
```

``TransactionType`` controls when SQLite acquires locks:

- ``TransactionType/deferred`` — defers locking until the first read or write; this is the default.
- ``TransactionType/immediate`` — immediately takes a RESERVED lock to prevent other writers.
- ``TransactionType/exclusive`` — escalates to an EXCLUSIVE lock and, in `DELETE` journal mode,
  blocks readers.

``ConnectionProtocol/beginTransaction(_:)`` uses `.deferred` by default. When
``ConnectionProtocol/isAutocommit`` returns `false`, a transaction is already active. Calling
`beginTransaction` again raises an error, so guard composite operations accordingly.

- SeeAlso: [Transaction](https://sqlite.org/lang_transaction.html)

## PRAGMA Parameters

Most frequently used PRAGMA directives are modeled as direct properties on ``ConnectionProtocol``:
``ConnectionProtocol/busyTimeout``, ``ConnectionProtocol/applicationID``,
``ConnectionProtocol/foreignKeys``, ``ConnectionProtocol/journalMode``,
``ConnectionProtocol/synchronous``, and ``ConnectionProtocol/userVersion``. Update them directly on
an active connection:

```swift
connection.userVersion = 2024
connection.foreignKeys = true
connection.journalMode = .wal
```

### Custom PRAGMAs

Use ``ConnectionProtocol/get(pragma:)`` and ``ConnectionProtocol/set(pragma:value:)`` for PRAGMAs
that do not have a dedicated API. They accept ``Pragma`` values (string literal expressible) and
any type that conforms to ``SQLiteRepresentable``. `set` composes a `PRAGMA <name> = <value>`
statement, while `get` issues `PRAGMA <name>`.

```swift
// Read the current cache_size value
let cacheSize: Int32? = try connection.get(pragma: "cache_size")

// Enable WAL journaling and adjust the sync mode
try connection.set(pragma: .journalMode, value: JournalMode.wal)
try connection.set(pragma: .synchronous, value: Synchronous.normal)
```

The `value` parameter automatically converts to ``SQLiteValue`` through ``SQLiteRepresentable``,
so you can pass `Bool`, `Int`, `String`, `Synchronous`, `JournalMode`, or a custom type that
supports the protocol.

- SeeAlso: [PRAGMA Statements](https://sqlite.org/pragma.html)

## Observing Connection Events

``ConnectionDelegate`` lets you observe connection-level events such as row updates, commits, and
rollbacks. Register a delegate with ``ConnectionProtocol/add(delegate:)``. Delegates are stored
weakly, so you are responsible for managing their lifetime. Remove a delegate with
``ConnectionProtocol/remove(delegate:)`` when it is no longer required.

Use ``ConnectionTraceDelegate`` to receive SQL statement traces and register it with
``ConnectionProtocol/add(trace:)``. Trace delegates are also held weakly.

```swift
final class QueryLogger: ConnectionDelegate, ConnectionTraceDelegate {
    func connection(_ connection: ConnectionProtocol, trace sql: ConnectionTraceDelegate.Trace) {
        print("SQL:", sql.expandedSQL)
    }

    func connection(_ connection: ConnectionProtocol, didUpdate action: SQLiteAction) {
        print("Change:", action)
    }

    func connectionWillCommit(_ connection: ConnectionProtocol) throws {
        try validatePendingOperations()
    }

    func connectionDidRollback(_ connection: ConnectionProtocol) {
        resetInMemoryCache()
    }
}

let logger = QueryLogger()
connection.add(delegate: logger)
connection.add(trace: logger)

// ...

connection.remove(trace: logger)
connection.remove(delegate: logger)
```

All callbacks execute synchronously on SQLite's internal thread. Keep delegate logic lightweight,
avoid blocking I/O, and hand heavy work off to other queues when necessary to preserve responsiveness.
