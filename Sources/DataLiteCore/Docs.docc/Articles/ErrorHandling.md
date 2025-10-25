# Handling SQLite Errors

Handle SQLite errors predictably with DataLiteCore.

DataLiteCore converts all SQLite failures into an ``SQLiteError`` structure that contains both the
extended result code and a descriptive message. This unified error model lets you accurately
distinguish between constraint violations, locking issues, and other failure categories — while
preserving full diagnostic information for recovery and logging.

## SQLiteError Breakdown

``SQLiteError`` exposes fields that help with diagnostics and recovery:

- ``SQLiteError/code`` — the extended SQLite result code (for example,
  `SQLITE_CONSTRAINT_FOREIGNKEY` or `SQLITE_BUSY_TIMEOUT`). Use it for programmatic
  branching — e.g., retry logic, rollbacks, or user-facing messages.
- ``SQLiteError/message`` — a textual description of the underlying SQLite failure.

Since ``SQLiteError`` conforms to `CustomStringConvertible`, you can log it directly. For
user-facing alerts, derive your own localized messages from the error code instead of exposing
SQLite messages verbatim.

## Typed Throws

Most DataLiteCore APIs are annotated as `throws(SQLiteError)`, meaning they only throw SQLiteError
instances.

Only APIs that execute arbitrary user code or integrate with external systems may surface other
error types. Consult the documentation on each API for specific details.

```swift
do {
    try connection.execute(raw: """
        INSERT INTO users(email) VALUES ('ada@example.com')
    """)
} catch {
    switch error.code {
    case SQLITE_CONSTRAINT:
        showAlert("A user with this email already exists.")
    case SQLITE_BUSY, SQLITE_LOCKED:
        retryLater()
    default:
        print("Unexpected error: \(error.message)")
    }
}
```

## Multi-Statement Scenarios

- ``ConnectionProtocol/execute(sql:)`` and ``ConnectionProtocol/execute(raw:)`` stop at the first
  failing statement and propagate its ``SQLiteError``.
- ``StatementProtocol/execute(_:)`` reuses prepared statements; inside `catch` blocks, remember to
  call ``StatementProtocol/reset()`` and (if needed) ``StatementProtocol/clearBindings()`` before
  retrying.
- When executing multiple statements, add your own logging if you need to know which one
  failed — the propagated ``SQLiteError`` reflects SQLite’s diagnostics only.

## Custom Functions

Errors thrown from ``Function/Scalar`` or ``Function/Aggregate`` implementations are reported back
to SQLite as `SQLITE_ERROR`, with the error’s `localizedDescription` as the message text.
Define clear, domain-specific error types to make SQL traces and logs more meaningful.

- SeeAlso: ``SQLiteError``
- SeeAlso: [SQLite Result Codes](https://sqlite.org/rescode.html)
