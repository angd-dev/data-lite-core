import Foundation
import Testing
import DataLiteC

@testable import DataLiteCore

final class StatementTests {
    let connection: OpaquePointer
    
    init() {
        var connection: OpaquePointer! = nil
        let opts = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        sqlite3_open_v2(":memory:", &connection, opts, nil)
        sqlite3_exec(
            connection,
            """
            CREATE TABLE t(
                id INTEGER PRIMARY KEY,
                n  INTEGER,
                r  REAL,
                s  TEXT,
                b  BLOB
            );
            """, nil, nil, nil
        )
        self.connection = connection
    }
    
    deinit {
        sqlite3_close_v2(connection)
    }
    
    @Test func testInitWithError() throws {
        #expect(
            throws: SQLiteError(
                code: SQLITE_ERROR,
                message: "no such table: invalid"
            ),
            performing: {
                try Statement(
                    db: connection,
                    sql: "SELECT * FROM invalid",
                    options: []
                )
            }
        )
    }
    
    @Test func testParameterCount() throws {
        let sql = "SELECT * FROM t WHERE id = ? AND s = ?"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.parameterCount() == 2)
    }
    
    @Test func testZeroParameterCount() throws {
        let sql = "SELECT * FROM t"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.parameterCount() == 0)
    }
    
    @Test func testParameterIndexByName() throws {
        let sql = "SELECT * FROM t WHERE id = :id AND s = :s"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.parameterIndexBy(":id") == 1)
        #expect(stmt.parameterIndexBy(":s") == 2)
        #expect(stmt.parameterIndexBy(":invalid") == 0)
    }
    
    @Test func testParameterNameByIndex() throws {
        let sql = "SELECT * FROM t WHERE id = :id AND s = :s"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.parameterNameBy(1) == ":id")
        #expect(stmt.parameterNameBy(2) == ":s")
        #expect(stmt.parameterNameBy(3) == nil)
    }
    
    @Test func testBindValueAtIndex() throws {
        let sql = "SELECT * FROM t where id = ?"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        try stmt.bind(.int(42), at: 1)
        try stmt.bind(.real(42), at: 1)
        try stmt.bind(.text("42"), at: 1)
        try stmt.bind(.blob(Data([0x42])), at: 1)
        try stmt.bind(.null, at: 1)
        try stmt.bind(TestValue(value: 42), at: 1)
        try stmt.bind(TestValue?.none, at: 1)
    }
    
    @Test func testErrorBindValueAtIndex() throws {
        let sql = "SELECT * FROM t where id = ?"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(
            throws: SQLiteError(
                code: SQLITE_RANGE,
                message: "column index out of range"
            ),
            performing: {
                try stmt.bind(.null, at: 0)
            }
        )
    }
    
    @Test func testBindValueByName() throws {
        let sql = "SELECT * FROM t where id = :id"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        try stmt.bind(.int(42), by: ":id")
        try stmt.bind(.real(42), by: ":id")
        try stmt.bind(.text("42"), by: ":id")
        try stmt.bind(.blob(Data([0x42])), by: ":id")
        try stmt.bind(.null, by: ":id")
        try stmt.bind(TestValue(value: 42), by: ":id")
        try stmt.bind(TestValue?.none, by: ":id")
    }
    
    @Test func testErrorBindValueByName() throws {
        let sql = "SELECT * FROM t where id = :id"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(
            throws: SQLiteError(
                code: SQLITE_RANGE,
                message: "column index out of range"
            ),
            performing: {
                try stmt.bind(.null, by: ":invalid")
            }
        )
    }
    
    @Test func testStepOneRow() throws {
        let sql = "SELECT 1 where 1"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(try stmt.step())
        #expect(try stmt.step() == false)
    }
    
    @Test func testStepMultipleRows() throws {
        sqlite3_exec(connection, "INSERT INTO t(n) VALUES (1),(2),(3)", nil, nil, nil)
        let sql = "SELECT id FROM t ORDER BY id"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(try stmt.step())
        #expect(try stmt.step())
        #expect(try stmt.step())
        #expect(try stmt.step() == false)
    }
    
    @Test func testStepNoRows() throws {
        let sql = "SELECT 1 WHERE 0"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(try stmt.step() == false)
    }
    
    @Test func testStepWithError() throws {
        sqlite3_exec(connection, "INSERT INTO t(id, n) VALUES (1, 10)", nil, nil, nil)
        let sql = "INSERT INTO t(id, n) VALUES (?, ?)"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        try stmt.bind(.int(1), at: 1)
        try stmt.bind(.int(20), at: 2)
        #expect(
            throws: SQLiteError(
                code: 1555,
                message: "UNIQUE constraint failed: t.id"
            ),
            performing: {
                try stmt.step()
            }
        )
    }
    
    @Test func testColumnCount() throws {
        let sql = "SELECT * FROM t"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.columnCount() == 5)
    }
    
    @Test func testColumnName() throws {
        let sql = "SELECT * FROM t"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.columnName(at: 0) == "id")
        #expect(stmt.columnName(at: 1) == "n")
        #expect(stmt.columnName(at: 2) == "r")
        #expect(stmt.columnName(at: 3) == "s")
        #expect(stmt.columnName(at: 4) == "b")
    }
    
    @Test func testColumnValueAtIndex() throws {
        sqlite3_exec(connection, """
            INSERT INTO t (id, n, r, s, b)
            VALUES (10, 42, 3.5, 'hello', x'DEADBEEF')
            """, nil, nil, nil
        )
        
        let sql = "SELECT * FROM t WHERE id = 10"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        
        #expect(try stmt.step())
        #expect(stmt.columnValue(at: 0) == .int(10))
        #expect(stmt.columnValue(at: 1) == .int(42))
        #expect(stmt.columnValue(at: 1) == TestValue(value: 42))
        #expect(stmt.columnValue(at: 2) == .real(3.5))
        #expect(stmt.columnValue(at: 3) == .text("hello"))
        #expect(stmt.columnValue(at: 4) == .blob(Data([0xDE, 0xAD, 0xBE, 0xEF])))
    }
    
    @Test func testColumnNullValueAtIndex() throws {
        sqlite3_exec(connection, """
            INSERT INTO t (id) VALUES (10)
            """, nil, nil, nil
        )
        
        let sql = "SELECT * FROM t WHERE id = 10"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        
        #expect(try stmt.step())
        #expect(stmt.columnValue(at: 0) == .int(10))
        #expect(stmt.columnValue(at: 1) == .null)
        #expect(stmt.columnValue(at: 1) == TestValue?.none)
    }
}

private extension StatementTests {
    struct TestValue: SQLiteRepresentable, Equatable {
        let value: Int
        
        var sqliteValue: SQLiteValue {
            .int(Int64(value))
        }
        
        init(value: Int) {
            self.value = value
        }
        
        init?(_ value: SQLiteValue) {
            if case .int(let intValue) = value {
                self.value = Int(intValue)
            } else {
                return nil
            }
        }
    }
}
