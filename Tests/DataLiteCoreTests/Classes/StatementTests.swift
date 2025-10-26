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
    
    @Test func initWithError() throws {
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
    
    @Test func sqlString() throws {
        let sql = "SELECT * FROM t WHERE id = ?"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.sql == sql)
    }
    
    @Test(arguments: [
        ("SELECT * FROM t WHERE id = ? AND s = ?", 2),
        ("SELECT * FROM t WHERE id = 1 AND s = ''", 0)
    ])
    func parameterCount(_ sql: String, _ expanded: Int32) throws {
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.parameterCount() == expanded)
    }
    
    @Test func parameterIndexByName() throws {
        let sql = "SELECT * FROM t WHERE id = :id AND s = :s"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.parameterIndexBy(":id") == 1)
        #expect(stmt.parameterIndexBy(":s") == 2)
        #expect(stmt.parameterIndexBy(":invalid") == 0)
    }
    
    @Test func parameterNameByIndex() throws {
        let sql = "SELECT * FROM t WHERE id = :id AND s = :s"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.parameterNameBy(1) == ":id")
        #expect(stmt.parameterNameBy(2) == ":s")
        #expect(stmt.parameterNameBy(3) == nil)
    }
    
    @Test func bindValueAtIndex() throws {
        let sql = "SELECT * FROM t WHERE id = ?"
        
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = NULL")
        
        try stmt.bind(.int(42), at: 1)
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = 42")
        
        try stmt.bind(.real(42), at: 1)
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = 42.0")
        
        try stmt.bind(.text("42"), at: 1)
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = '42'")
        
        try stmt.bind(.blob(Data([0x42])), at: 1)
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = x'42'")
        
        try stmt.bind(.null, at: 1)
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = NULL")
        
        try stmt.bind(TestValue(value: 42), at: 1)
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = 42")
        
        try stmt.bind(TestValue?.none, at: 1)
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = NULL")
    }
    
    @Test func errorBindValueAtIndex() throws {
        let sql = "SELECT * FROM t WHERE id = ?"
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
    
    @Test func bindValueByName() throws {
        let sql = "SELECT * FROM t WHERE id = :id"
        
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = NULL")
        
        try stmt.bind(.int(42), by: ":id")
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = 42")
        
        try stmt.bind(.real(42), by: ":id")
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = 42.0")
        
        try stmt.bind(.text("42"), by: ":id")
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = '42'")
        
        try stmt.bind(.blob(Data([0x42])), by: ":id")
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = x'42'")
        
        try stmt.bind(.null, by: ":id")
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = NULL")
        
        try stmt.bind(TestValue(value: 42), by: ":id")
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = 42")
        
        try stmt.bind(TestValue?.none, by: ":id")
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = NULL")
    }
    
    @Test func errorBindValueByName() throws {
        let sql = "SELECT * FROM t WHERE id = :id"
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
    
    @Test func bindRow() throws {
        let row: SQLiteRow = ["id": .int(42), "name": .text("Alice")]
        let sql = "SELECT * FROM t WHERE id = :id AND s = :name"
        
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = NULL AND s = NULL")
        
        try stmt.bind(row)
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = 42 AND s = 'Alice'")
    }
    
    @Test func errorBindRow() throws {
        let row: SQLiteRow = ["name": .text("Alice")]
        let stmt = try Statement(
            db: connection, sql: "SELECT * FROM t", options: []
        )
        #expect(
            throws: SQLiteError(
                code: SQLITE_RANGE,
                message: "column index out of range"
            ),
            performing: {
                try stmt.bind(row)
            }
        )
    }
    
    @Test func clearBindings() throws {
        let sql = "SELECT * FROM t WHERE id = :id"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        
        try stmt.bind(.int(42), at: 1)
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = 42")
        
        try stmt.clearBindings()
        #expect(stmt.expandedSQL == "SELECT * FROM t WHERE id = NULL")
    }
    
    @Test func stepOneRow() throws {
        let sql = "SELECT 1 WHERE 1"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(try stmt.step())
        #expect(try stmt.step() == false)
    }
    
    @Test func stepMultipleRows() throws {
        sqlite3_exec(connection, "INSERT INTO t(n) VALUES (1),(2),(3)", nil, nil, nil)
        let sql = "SELECT id FROM t ORDER BY id"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(try stmt.step())
        #expect(try stmt.step())
        #expect(try stmt.step())
        #expect(try stmt.step() == false)
    }
    
    @Test func stepNoRows() throws {
        let sql = "SELECT 1 WHERE 0"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(try stmt.step() == false)
    }
    
    @Test func stepWithError() throws {
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
    
    @Test func executeRows() throws {
        let rows: [SQLiteRow] = [
            [
                "id": .int(1),
                "n": .int(42),
                "r": .real(3.14),
                "s": .text("Test"),
                "b": .blob(Data([0x42]))
            ],
            [
                "id": .int(2),
                "n": .null,
                "r": .null,
                "s": .null,
                "b": .null
            ]
        ]
        let sql = "INSERT INTO t(id, n, r, s, b) VALUES (:id, :n, :r, :s, :b)"
        try Statement(db: connection, sql: sql, options: []).execute(rows)
        
        let stmt = try Statement(db: connection, sql: "SELECT * FROM t", options: [])
        
        #expect(try stmt.step())
        #expect(stmt.currentRow() == rows[0])
        
        #expect(try stmt.step())
        #expect(stmt.currentRow() == rows[1])
        
        #expect(try stmt.step() == false)
    }
    
    @Test func executeEmptyRows() throws {
        let sql = "INSERT INTO t(id, n, r, s, b) VALUES (:id, :n, :r, :s, :b)"
        try Statement(db: connection, sql: sql, options: []).execute([])
        
        let stmt = try Statement(db: connection, sql: "SELECT * FROM t", options: [])
        #expect(try stmt.step() == false)
    }
    
    @Test func columnCount() throws {
        let sql = "SELECT * FROM t"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.columnCount() == 5)
    }
    
    @Test func columnName() throws {
        let sql = "SELECT * FROM t"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        #expect(stmt.columnName(at: 0) == "id")
        #expect(stmt.columnName(at: 1) == "n")
        #expect(stmt.columnName(at: 2) == "r")
        #expect(stmt.columnName(at: 3) == "s")
        #expect(stmt.columnName(at: 4) == "b")
        #expect(stmt.columnName(at: 5) == nil)
    }
    
    @Test func columnValueAtIndex() throws {
        sqlite3_exec(
            connection,
            """
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
    
    @Test func columnNullValueAtIndex() throws {
        sqlite3_exec(
            connection,
            """
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
    
    @Test func currentRow() throws {
        sqlite3_exec(
            connection,
            """
            INSERT INTO t (id, n, r, s, b)
            VALUES (10, 42, 3.5, 'hello', x'DEADBEEF')
            """, nil, nil, nil
        )
        
        let row: SQLiteRow = [
            "id": .int(10),
            "n": .int(42),
            "r": .real(3.5),
            "s": .text("hello"),
            "b": .blob(Data([0xDE, 0xAD, 0xBE, 0xEF]))
        ]

        let sql = "SELECT * FROM t WHERE id = 10"
        let stmt = try Statement(db: connection, sql: sql, options: [])
        
        #expect(try stmt.step())
        #expect(stmt.currentRow() == row)
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
