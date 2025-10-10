# Database Encryption

Secure SQLite databases with SQLCipher encryption using DataLiteCore.

DataLiteCore provides a clean API for applying and rotating SQLCipher encryption keys through the
connection interface. You can use it to unlock existing encrypted databases or to initialize new
ones securely before executing SQL statements.

## Applying an Encryption Key

Use ``ConnectionProtocol/apply(_:name:)`` to unlock an encrypted database file or to initialize
encryption on a new one. Supported key formats include:

- ``Connection/Key/passphrase(_:)`` — a textual passphrase processed by SQLCipher’s key derivation.
- ``Connection/Key/rawKey(_:)`` — a 256-bit (`32`-byte) key supplied as `Data`.

```swift
let connection = try Connection(
    location: .file(path: "/path/to/sqlite.db"),
    options: [.readwrite, .create, .fullmutex]
)
try connection.apply(.passphrase("vault-password"), name: nil)
```

The first call on a new database establishes encryption. If the database already exists and is
encrypted, the same call unlocks it for the current session. Plaintext files cannot be encrypted in
place. Always call ``ConnectionProtocol/apply(_:name:)`` immediately after opening the connection
and before executing any statements to avoid `SQLITE_NOTADB` errors.

## Rotating Keys

Use ``ConnectionProtocol/rekey(_:name:)`` to rewrite the database with a new key. The connection
must already be unlocked with the current key via ``ConnectionProtocol/apply(_:name:)``.

```swift
let newKey = Data((0..<32).map { _ in UInt8.random(in: 0...UInt8.max) })
try connection.rekey(.rawKey(newKey), name: nil)
```

Rekeying touches every page in the database and can take noticeable time on large files. Schedule
it during maintenance windows and be prepared for `SQLITE_BUSY` if other connections keep the file
locked. Adjust ``ConnectionProtocol/busyTimeout`` or coordinate access with application-level
locking.

## Attached Databases

When attaching additional databases, pass the attachment alias through the `name` parameter.
Use `nil` or `"main"` for the primary database, `"temp"` for the temporary one, and the alias for
others.

```swift
try connection.execute(raw: "ATTACH DATABASE 'analytics.db' AS analytics")
try connection.apply(.passphrase("aux-password"), name: "analytics")
```

All databases attached to the same connection must follow a consistent encryption policy. If an
attached database must remain unencrypted, attach it using a separate connection instead.

- SeeAlso: ``ConnectionProtocol/apply(_:name:)``
- SeeAlso: ``ConnectionProtocol/rekey(_:name:)``
- SeeAlso: [SQLCipher Documentation](https://www.zetetic.net/sqlcipher/documentation/)
