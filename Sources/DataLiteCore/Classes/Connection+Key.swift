import Foundation

extension Connection {
    /// An encryption key for accessing an encrypted SQLite database.
    ///
    /// Used after the connection is opened to unlock the contents of the database.
    /// Two formats are supported: a passphrase with subsequent derivation, and
    /// a raw 256-bit key (32 bytes) without transformation.
    public enum Key {
        /// A passphrase used to derive an encryption key.
        ///
        /// Intended for human-readable strings such as passwords or PIN codes.
        /// The string is passed directly without escaping or quoting.
        case passphrase(String)
        
        /// A raw 256-bit encryption key (32 bytes).
        ///
        /// No key derivation is performed. The key is passed as-is and must be
        /// securely generated and stored.
        case rawKey(Data)
        
        /// The string value to be passed to the database engine.
        ///
        /// For `.passphrase`, this is the raw string exactly as provided.
        /// For `.rawKey`, this is a hexadecimal literal in the format `X'...'`.
        public var keyValue: String {
            switch self {
            case .passphrase(let string):
                return string
            case .rawKey(let data):
                return data.sqliteLiteral
            }
        }
        
        /// The length of the key value in bytes.
        ///
        /// Returns the number of bytes in the UTF-8 encoding of `keyValue`,
        /// not the length of the original key or string.
        public var length: Int32 {
            Int32(keyValue.utf8.count)
        }
    }
}
