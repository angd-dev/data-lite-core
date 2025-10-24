# Multithreading Strategies

Coordinate SQLite safely across queues, actors, and Swift concurrency using DataLiteCore.

SQLite remains fundamentally serialized, so deliberate connection ownership and scheduling are
essential for correctness and performance. DataLiteCore does not include a built-in connection
pool, but its deterministic behavior and configuration options allow you to design synchronization
strategies that match your workload.

## Core Guidelines

- **One connection per queue or actor**. Keep each ``Connection`` confined to a dedicated serial
  `DispatchQueue` or an `actor` to ensure ordered execution and predictable statement lifecycles.
- **Do not share statements across threads**. ``Statement`` instances are bound to their parent
  ``Connection`` and are not thread-safe.
- **Scale with multiple connections**. For concurrent workloads, use a dedicated writer connection
  alongside a pool of readers so long-running transactions don’t block unrelated operations.

```swift
actor Database {
    private let connection: Connection

    init(path: String) throws {
        connection = try Connection(
            path: path,
            options: [.readwrite, .create, .fullmutex]
        )
        connection.busyTimeout = 5_000   // wait up to 5 seconds for locks
    }

    func insertUser(name: String) throws {
        let statement = try connection.prepare(
            sql: "INSERT INTO users(name) VALUES (?)"
        )
        try statement.bind(name, at: 1)
        try statement.step()
    }
}
```

Encapsulating database work in an `actor` or serial queue aligns naturally with Swift Concurrency
while maintaining safe access to SQLite’s synchronous API.

## Synchronization Options

- ``Connection/Options/nomutex`` — disables SQLite’s internal mutexes (multi-thread mode). Each
  connection must be accessed by only one thread at a time.

  ```swift
  let connection = try Connection(
      location: .file(path: "/path/to/sqlite.db"),
      options: [.readwrite, .nomutex]
  )
  ```

- ``Connection/Options/fullmutex`` — enables serialized mode with full internal locking. A single
  ``Connection`` may be shared across threads, but global locks reduce throughput.

  ```swift
  let connection = try Connection(
      location: .file(path: "/path/to/sqlite.db"),
      options: [.readwrite, .fullmutex]
  )
  ```

SQLite defaults to serialized mode, but concurrent writers still contend for locks. Plan long
transactions carefully and adjust ``ConnectionProtocol/busyTimeout`` to handle `SQLITE_BUSY`
conditions gracefully.

- SeeAlso: [Using SQLite In Multi-Threaded Applications](https://sqlite.org/threadsafe.html)

## Delegates and Side Effects

``ConnectionDelegate`` and ``ConnectionTraceDelegate`` callbacks execute synchronously on SQLite’s
internal thread. Keep them lightweight and non-blocking. Offload work to another queue when
necessary to prevent deadlocks or extended lock holds.

```swift
final class Logger: ConnectionTraceDelegate {
    private let queue = DispatchQueue(label: "logging")

    func connection(
        _ connection: ConnectionProtocol,
        trace sql: ConnectionTraceDelegate.Trace
    ) {
        queue.async {
            print("SQL:", sql.expandedSQL)
        }
    }
}
```

This pattern keeps tracing responsive and prevents SQLite’s internal thread from being blocked by
slow I/O or external operations.
