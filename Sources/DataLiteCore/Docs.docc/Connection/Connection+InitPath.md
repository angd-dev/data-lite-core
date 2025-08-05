# ``DataLiteCore/Connection/init(path:options:)``

Initializes a new connection to an SQLite database using a file path.

This convenience initializer sets up a connection to the SQLite database located at the
specified `path` with the provided `options`. It internally calls the main initializer
to manage the connection setup.

### Usage Example

```swift
do {
    let connection = try Connection(
        path: "~/example.db",
        options: .readwrite
    )
    // Use the connection to execute queries
} catch {
    print("Error establishing connection: \(error)")
}
```

- Parameters:
  - path: A string representing the file path to the SQLite database.
  - options: Configures the connection behavior,
    such as read-only or read-write access and cache mode.

- Throws: ``Connection/Error`` if the connection fails to open due to SQLite errors,
  invalid path, permission issues, or other underlying failures.

- Throws: An error if subdirectories for the database file cannot be created.
