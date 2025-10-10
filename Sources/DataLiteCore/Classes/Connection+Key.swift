import Foundation

extension Connection {
    /// An encryption key for opening an encrypted SQLite database.
    ///
    /// The key is applied after the connection is established to unlock the database contents.
    /// Two formats are supported:
    /// - a passphrase, which undergoes key derivation;
    /// - a raw 256-bit key (32 bytes) passed without transformation.
    public enum Key {
        /// A human-readable passphrase used for key derivation.
        ///
        /// The passphrase is supplied as-is and processed by the underlying key derivation
        /// mechanism configured in the database engine.
        case passphrase(String)
        
        /// A raw 256-bit encryption key (32 bytes).
        ///
        /// The key is passed directly to the database without derivation. It must be securely
        /// generated and stored.
        case rawKey(Data)
        
        /// The string value passed to the database engine.
        ///
        /// For `.passphrase`, returns the passphrase exactly as provided.
        /// For `.rawKey`, returns a hexadecimal literal in the format `X'...'`.
        public var keyValue: String {
            switch self {
            case .passphrase(let string):
                string
            case .rawKey(let data):
                data.sqliteLiteral
            }
        }
        
        /// The number of bytes in the string representation of the key.
        public var length: Int32 {
            Int32(keyValue.utf8.count)
        }
    }
}
