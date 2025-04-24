# ``DataLiteCore/Connection``

A class representing a connection to an SQLite database.

## Overview

The `Connection` class manages the connection to an SQLite database. It provides an interface
for preparing SQL queries, managing transactions, and handling errors. This class serves as the
main object for interacting with the database.

## Opening a New Connection

Use the ``init(location:options:)`` initializer to open a database connection. Specify the
database's location using the ``Location`` parameter and configure connection settings with the
``Options`` parameter.

```swift
do {
    let connection = try Connection(
        location: .file(path: "~/example.db"),
        options: [.readwrite, .create]
    )
    print("Connection established")
} catch {
    print("Failed to connect: \(error)")
}
```

## Closing the Connection

The `Connection` class automatically closes the database connection when the object is
deallocated (`deinit`). This ensures proper cleanup even if the object goes out of scope.

## Delegate

The `Connection` class can optionally use a delegate to handle specific events during the
connection lifecycle, such as tracing SQL statements or responding to transaction actions.
The delegate must conform to the ``ConnectionDelegate`` protocol, which provides methods for
handling these events.

## Custom SQL Functions

The `Connection` class allows you to add custom SQL functions using subclasses of ``Function``.
You can create either **scalar** functions (which return a single value) or **aggregate**
functions (which perform operations across multiple rows). Both types can be used directly in
SQL queries.

To add or remove custom functions, use the ``add(function:)`` and ``remove(function:)`` methods
of the `Connection` class.

## Preparing SQL Statements

The  `Connection`  class provides functionality for preparing SQL statements that can be
executed multiple times with different parameter values. The  ``prepare(sql:options:)``  method
takes a SQL query as a string and an optional  ``Statement/Options``  parameter to configure
the behavior of the statement. It returns a  ``Statement``  object that can be executed.

```swift
do {
    let statement = try connection.prepare(
        sql: "SELECT * FROM users WHERE age > ?",
        options: [.persistent]
    )
    // Bind parameters and execute the statement
} catch {
    print("Error preparing statement: \(error)")
}
```

## Executing SQL Scripts

The `Connection` class allows you to execute a series of SQL statements using the ``SQLScript``
structure. The ``SQLScript`` structure is designed to load and process multiple SQL queries
from a file, URL, or string.

You can create an instance of ``SQLScript`` with the SQL script content and then pass it to the
``execute(sql:)`` method of the `Connection` class to execute the script.

```swift
let script: SQLScript = """
CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);
INSERT INTO users (name) VALUES ('Alice');
INSERT INTO users (name) VALUES ('Bob');
"""

do {
    try connection.execute(sql: script)
    print("Script executed successfully")
} catch {
    print("Error executing script: \(error)")
}
```

## Transaction Handling

By default, the `Connection` class operates in **autocommit mode**, where each SQL statement is
automatically committed after execution. In this mode, each statement is treated as a separate
transaction, eliminating the need for explicit transaction management. To determine whether the
connection is in autocommit mode, use the ``isAutocommit`` property.

For manual transaction management, use ``beginTransaction(_:)`` to start a transaction, and
``commitTransaction()`` or ``rollbackTransaction()`` to either commit or roll back the
transaction.

```swift
do {
    try connection.beginTransaction()
    try connection.execute(sql: "INSERT INTO users (name) VALUES ('Alice')")
    try connection.execute(sql: "INSERT INTO users (name) VALUES ('Bob')")
    try connection.commitTransaction()
    print("Transaction committed successfully")
} catch {
    try? connection.rollbackTransaction()
    print("Error during transaction: \(error)")
}
```

Learn more in the [SQLite Transaction Documentation](https://www.sqlite.org/lang_transaction.html).

## Error Handling

The `Connection` class uses Swift's throwing mechanism to handle errors. Errors in database
operations are propagated using `throws`, allowing you to catch and handle specific issues in
your application.

SQLite-related errors, such as invalid SQL queries, connection failures, or issues with
transaction management, throw an ``Connection/Error`` struct. These errors conform to the
`Error` protocol, and you can handle them using Swift's `do-catch` syntax to manage exceptions
in your code.

```swift
do {
    let statement = try connection.prepare(
        sql: "SELECT * FROM users WHERE age > ?",
        options: []
    )
} catch let error as Error {
    print("SQLite error: \(error.mesg), Code: \(error.code)")
} catch {
    print("Unexpected error: \(error)")
}
```

## Multithreading

The `Connection` class supports multithreading, but its behavior depends on the selected
thread-safety mode. You can configure the desired mode using the ``Options`` parameter in the
``init(location:options:)`` method.

**Multi-thread** (``Options/nomutex``): This mode allows SQLite to be used across multiple
threads. However, it requires that no `Connection` instance or its derived objects (e.g.,
prepared statements) are accessed simultaneously by multiple threads.

```swift
let connection = try Connection(
    location: .file(path: "~/example.db"),
    options: [.readwrite, .nomutex]
)
```

**Serialized** (``Options/fullmutex``): In this mode, SQLite uses internal mutexes to ensure
thread safety. This allows multiple threads to safely share `Connection` instances and their
derived objects.

```swift
let connection = try Connection(
    location: .file(path: "~/example.db"),
    options: [.readwrite, .fullmutex]
)
```

- Important: The `Connection` class does not include built-in synchronization for shared
  resources. Developers must implement custom synchronization mechanisms, such as using
  `DispatchQueue`, when sharing resources across threads.

For more details, see the [Using SQLite in Multi-Threaded Applications](https://www.sqlite.org/threadsafe.html).

## Encryption

The `Connection` class supports transparent encryption and re-encryption of databases using the
``apply(_:name:)`` and ``rekey(_:name:)`` methods. This allows sensitive data to be securely
stored on disk.

### Applying an Encryption Key

To open an encrypted database or encrypt a new one, call ``apply(_:name:)`` immediately after
initializing the connection, and before executing any SQL statements.

```swift
let connection = try Connection(
    path: "~/secure.db",
    options: [.readwrite, .create]
)
try connection.apply(Key.passphrase("secret-password"))
```

- If the database is already encrypted, the key must match the one previously used.
- If the database is unencrypted, applying a key will encrypt it on first write.

You can use either a **passphrase**, which is internally transformed into a key,
or a **raw key**:

```swift
try connection.apply(Key.raw(data: rawKeyData))
```

- Important: The encryption key must be applied *before* any SQL queries are executed.
  Otherwise, the database may remain unencrypted or unreadable.

### Rekeying the Database

To change the encryption key of an existing database, you must first apply the current key
using ``apply(_:name:)``, then call ``rekey(_:name:)`` with the new key.

```swift
let connection = try Connection(
    path: "~/secure.db",
    options: [.readwrite]
)
try connection.apply(Key.passphrase("old-password"))
try connection.rekey(Key.passphrase("new-password"))
```

- Important: ``rekey(_:name:)`` requires that the correct current key has already been applied
  via ``apply(_:name:)``. If the wrong key is used, the operation will fail with an error.

### Attached Databases

Both ``apply(_:name:)`` and ``rekey(_:name:)`` accept an optional `name` parameter to operate
on an attached database. If omitted, they apply to the main database.

## Topics

### Errors

- ``Error``

### Initializers

- ``Location``
- ``Options``
- ``init(location:options:)``
- ``init(path:options:)``

### Delegation

- ``ConnectionDelegate``
- ``delegate``

### Connection State

- ``isAutocommit``
- ``isReadonly``
- ``busyTimeout``

### PRAGMA Accessors

- ``applicationID``
- ``foreignKeys``
- ``journalMode``
- ``synchronous``
- ``userVersion``

### SQLite Lifecycle

- ``initialize()``
- ``shutdown()``

### Custom SQL Functions

- ``add(function:)``
- ``remove(function:)``

### Statement Preparation

- ``prepare(sql:options:)``

### Script Execution

- ``execute(sql:)``
- ``execute(raw:)``

### PRAGMA Execution

- ``get(pragma:)``
- ``set(pragma:value:)``

### Transactions

- ``beginTransaction(_:)``
- ``commitTransaction()``
- ``rollbackTransaction()``

### Encryption Keys

- ``Connection/Key``
- ``apply(_:name:)``
- ``rekey(_:name:)`` 
