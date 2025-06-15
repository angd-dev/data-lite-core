import XCTest
import DataLiteC
@testable import DataLiteCore

final class StatementTests: XCTestCase {
    private let databasePath = FileManager.default.temporaryDirectory.appendingPathComponent("test.db").path
    private var connection: OpaquePointer!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        XCTAssertEqual(
            sqlite3_open(databasePath, &connection),
            SQLITE_OK,
            "Failed to open database"
        )
        
        XCTAssertEqual(
            sqlite3_exec(
                connection,
                """
                CREATE TABLE users (
                    id INTEGER PRIMARY KEY,
                    name TEXT,
                    age INTEGER
                );
                """,
                nil, nil, nil
            ),
            SQLITE_OK,
            "Failed to create table"
        )
    }
    
    override func tearDownWithError() throws {
        sqlite3_close(connection)
        try FileManager.default.removeItem(atPath: databasePath)
        try super.tearDownWithError()
    }
    
    func testMixBindings() throws {
        do {
            let sql = "INSERT INTO users (name, age) VALUES (?, ?)"
            let stmt = try Statement(db: connection, sql: sql, options: [])
            try stmt.bind("Alice", at: 1)
            try stmt.bind(88, at: 2)
            XCTAssertFalse(try stmt.step())
        }
        
        do {
            let sql = "SELECT * FROM users WHERE age = ? AND name = $name"
            let stmt = try Statement(db: connection, sql: sql, options: [])
            try stmt.bind(88, at: 1)
            try stmt.bind("Alice", at: stmt.bind(parameterIndexBy: "$name"))
            XCTAssertTrue(try stmt.step())
            XCTAssertEqual(stmt.columnValue(at: 1), "Alice")
            XCTAssertEqual(stmt.columnValue(at: 2), 88)
        }
    }
    
    func testStatementInitialization() throws {
        let sql = "INSERT INTO users (name, age) VALUES (?, ?)"
        let statement = try Statement(db: connection, sql: sql, options: [.persistent])
        XCTAssertNotNil(statement, "Statement should not be nil")
    }
    
    func testBindAndExecute() throws {
        let sql = "INSERT INTO users (name, age) VALUES (?, ?)"
        let statement = try Statement(db: connection, sql: sql, options: [.persistent])
        try statement.bind("Alice", at: 1)
        try statement.bind(30, at: 2)
        XCTAssertEqual(statement.bindParameterCount(), 2)
        XCTAssertFalse(try statement.step())
        
        let query = "SELECT * FROM users WHERE name = ?"
        let queryStatement = try Statement(db: connection, sql: query, options: [.persistent])
        try queryStatement.bind("Alice", at: 1)
        
        XCTAssertTrue(try queryStatement.step(), "Failed to execute SELECT query")
        XCTAssertEqual(queryStatement.columnValue(at: 1), "Alice")
        XCTAssertEqual(queryStatement.columnValue(at: 2), 30)
    }
    
    func testClearBindings() throws {
        let sql = "INSERT INTO users (name, age) VALUES (?, ?)"
        let statement = try Statement(db: connection, sql: sql, options: [.persistent])
        try statement.bind("Bob", at: 1)
        try statement.bind(25, at: 2)
        try statement.clearBindings()
        XCTAssertFalse(try statement.step())
    }
    
    func testResetStatement() throws {
        let sql = "INSERT INTO users (name, age) VALUES (?, ?)"
        let statement = try Statement(db: connection, sql: sql, options: [.persistent])
        try statement.bind("Charlie", at: 1)
        try statement.bind(40, at: 2)
        try statement.step()
        
        // Reset the statement and try executing it again with new values
        try statement.reset()
        try statement.bind("Dave", at: 1)
        try statement.bind(45, at: 2)
        XCTAssertEqual(statement.bindParameterCount(), 2)
        XCTAssertFalse(try statement.step())
        
        // Check if the record was actually inserted
        let query = "SELECT * FROM users WHERE name = ?"
        let queryStatement = try Statement(db: connection, sql: query, options: [.persistent])
        try queryStatement.bind("Dave", at: 1)
        
        XCTAssertTrue(try queryStatement.step(), "Failed to execute SELECT query")
        XCTAssertEqual(queryStatement.columnValue(at: 1), "Dave")
        XCTAssertEqual(queryStatement.columnValue(at: 2), 45)
    }
    
    func testColumnValues() throws {
        let sql = "INSERT INTO users (name, age) VALUES (?, ?)"
        let statement = try Statement(db: connection, sql: sql, options: [.persistent])
        try statement.bind("Eve", at: 1)
        try statement.bind(28, at: 2)
        try statement.step()
        
        // Perform a SELECT query and check column data types
        let query = "SELECT * FROM users WHERE name = ?"
        let queryStatement = try Statement(db: connection, sql: query, options: [.persistent])
        try queryStatement.bind("Eve", at: 1)
        
        XCTAssertTrue(try queryStatement.step(), "Failed to execute SELECT query")
        XCTAssertEqual(queryStatement.columnType(at: 1), .text)
        XCTAssertEqual(queryStatement.columnType(at: 2), .int)
        XCTAssertEqual(queryStatement.columnValue(at: 1), "Eve")
        XCTAssertEqual(queryStatement.columnValue(at: 2), 28)
    }
}
