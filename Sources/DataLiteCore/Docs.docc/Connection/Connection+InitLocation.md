# ``DataLiteCore/Connection/init(location:options:)``

Initializes a new connection to an SQLite database.

This initializer opens a connection to the SQLite database at the specified `location`
with the provided `options`. If the location is a file path, it ensures the necessary
directory exists, creating intermediate directories if needed.

```swift
do {
    let connection = try Connection(
        location: .file(path: "~/example.db"),
        options: .readwrite
    )
    // Use the connection to execute queries
} catch {
    print("Error establishing connection: \(error)")
}
```

- Parameters:
  - location: Specifies where the database is located. 
    Can be a file path, an in-memory database, or a temporary database.
  - options: Configures connection behavior,
    such as read-only or read-write access and cache mode.

- Throws: ``Connection/Error`` if the connection fails to open due to SQLite errors,
  invalid path, permission issues, or other underlying failures.

- Throws: An error if directory creation fails for file-based database locations.
