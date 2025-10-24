# Extending SQLite with Custom Functions

Build custom scalar and aggregate SQL functions that run inside SQLite.

DataLiteCore lets you register custom SQL functions that participate in expressions, queries, and
aggregations just like built-in ones. Each function is registered on a specific connection and
becomes available to all statements executed through that connection.

## Registering Functions

Use ``ConnectionProtocol/add(function:)`` to register a function type on a connection. Pass the
function’s type, not an instance. DataLiteCore automatically manages function creation and
lifecycle — scalar functions are executed via their type, while aggregate functions are instantiated
per SQL invocation.

```swift
try connection.add(function: Function.Regexp.self)  // Built-in helper
try connection.add(function: Slugify.self)          // Custom scalar function
```

To remove a registered function, call ``ConnectionProtocol/remove(function:)``. This is useful for
dynamic plug-ins or test environments that require a clean registration state.

```swift
try connection.remove(function: Slugify.self)
```

## Implementing Scalar Functions

Subclass ``Function/Scalar`` to define a function that returns a single value for each call.
Override the static metadata properties — ``Function/name``, ``Function/argc``, and
``Function/options`` — to declare the function’s signature, and implement its logic in
``Function/Scalar/invoke(args:)``. Return any type conforming to ``SQLiteRepresentable``.

```swift
final class Slugify: Function.Scalar {
    override class var name: String { "slugify" }
    override class var argc: Int32 { 1 }
    override class var options: Function.Options { [.deterministic, .innocuous] }

    override class func invoke(args: any ArgumentsProtocol) throws -> SQLiteRepresentable? {
        guard let value = args[0] as String?, !value.isEmpty else { return nil }
        return value.lowercased()
            .replacingOccurrences(of: "\\W+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: .init(charactersIn: "-"))
    }
}

try connection.add(function: Slugify.self)
let rows = try connection.prepare(sql: "SELECT slugify(title) FROM articles")
```

## Implementing Aggregate Functions

Aggregate functions maintain internal state across multiple rows. Subclass ``Function/Aggregate``
and override ``Function/Aggregate/step(args:)`` to process each row and
``Function/Aggregate/finalize()`` to produce the final result.

```swift
final class Median: Function.Aggregate {
    private var values: [Double] = []

    override class var name: String { "median" }
    override class var argc: Int32 { 1 }
    override class var options: Function.Options { [.deterministic] }

    override func step(args: any ArgumentsProtocol) throws {
        if let value = args[0] as Double? {
            values.append(value)
        }
    }

    override func finalize() throws -> SQLiteRepresentable? {
        guard !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let mid = sorted.count / 2
        return sorted.count.isMultiple(of: 2)
            ? (sorted[mid - 1] + sorted[mid]) / 2
            : sorted[mid]
    }
}

try connection.add(function: Median.self)
```

SQLite creates a new instance of an aggregate function for each aggregate expression in a query and
reuses it for all rows contributing to that result. It’s safe to store mutable state in instance
properties.

## Handling Arguments and Results

Custom functions receive input through an ``ArgumentsProtocol`` instance. Use subscripts to access
arguments by index and automatically convert them to Swift types.

Two access forms are available:

- `subscript(index: Index) -> SQLiteValue` — returns the raw SQLite value without conversion.
- `subscript<T: SQLiteRepresentable>(index: Index) -> T?`— converts the value to a Swift type
  conforming to ``SQLiteRepresentable``. Returns `nil` if the argument is `NULL` or cannot be
  converted.

Use ``Function/Arguments/count`` to verify argument count before accessing elements. For
fine-grained decoding control, prefer the raw ``SQLiteValue`` form and handle conversion manually.

```swift
override class func invoke(args: any ArgumentsProtocol) throws -> SQLiteRepresentable? {
    guard args.count == 2 else {
        throw SQLiteError(code: SQLITE_MISUSE, message: "expected two arguments")
    }
    guard let lhs = args[0] as Double?, let rhs = args[1] as Double? else {
        return nil  // returns SQL NULL if either argument is NULL
    }
    return lhs * rhs
}
```

Any type conforming to ``SQLiteRepresentable`` can be used both to read arguments and to return
results. Returning `nil` produces an SQL `NULL`.

## Choosing Function Options

Customize function characteristics via the ``Function/Options`` bitset:

- ``Function/Options/deterministic`` — identical arguments always yield the same result, enabling
  SQLite to cache calls and optimize query plans.
- ``Function/Options/directonly`` — restricts usage to trusted contexts (for example, disallows
  calls from triggers or CHECK constraints).
- ``Function/Options/innocuous`` — marks the function as side-effect-free and safe for untrusted
  SQL.

Each scalar or aggregate subclass may return a different option set, depending on its behavior.

## Error Handling

Throwing from ``Function/Scalar/invoke(args:)``, ``Function/Aggregate/step(args:)``, or
``Function/Aggregate/finalize()`` propagates an error back to SQLite. DataLiteCore converts the
thrown error into a generic `SQLITE_ERROR` result code and uses its `localizedDescription` as the
message text.

You can use this mechanism to signal both validation failures and runtime exceptions during function
execution. Throwing an error stops evaluation immediately and returns control to SQLite.

- SeeAlso: ``Function``
- SeeAlso: [Application-Defined SQL Functions](https://sqlite.org/appfunc.html)
