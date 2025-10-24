import Foundation

/// A protocol representing a collection of SQLite argument values.
///
/// Conforming types provide indexed access to a sequence of ``SQLiteValue`` elements. This protocol
/// extends `Collection` to allow convenient typed subscripting using types conforming to
/// ``SQLiteRepresentable``.
public protocol ArgumentsProtocol: Collection where Element == SQLiteValue, Index == Int {
    /// Returns the element at the specified index, converted to the specified type.
    ///
    /// This subscript retrieves the argument value at the given index and attempts to convert it to
    /// a type conforming to ``SQLiteRepresentable``. If the conversion succeeds, the resulting
    /// value of type `T` is returned. Otherwise, `nil` is returned.
    ///
    /// - Parameter index: The index of the value to retrieve and convert.
    /// - Returns: A value of type `T` if conversion succeeds, or `nil` if it fails.
    subscript<T: SQLiteRepresentable>(index: Index) -> T? { get }
}

public extension ArgumentsProtocol {
    subscript<T: SQLiteRepresentable>(index: Index) -> T? {
        T.init(self[index])
    }
}
