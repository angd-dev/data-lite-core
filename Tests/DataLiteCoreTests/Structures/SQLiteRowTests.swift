import Testing

@testable import DataLiteCore

struct SQLiteRowTests {
    @Test func subscriptByColumn() {
        var row = SQLiteRow()
        #expect(row["name"] == nil)
        
        row["name"] = .text("Alice")
        #expect(row["name"] == .text("Alice"))
        
        row["name"] = .text("Bob")
        #expect(row["name"] == .text("Bob"))
        
        row["name"] = nil
        #expect(row["name"] == nil)
    }
    
    @Test func subscriptByIndex() {
        let row: SQLiteRow = [
            "name": .text("Alice"),
            "age": .int(30),
            "city": .text("Wonderland")
        ]
        #expect(row[0] == ("name", .text("Alice")))
        #expect(row[1] == ("age", .int(30)))
        #expect(row[2] == ("city", .text("Wonderland")))
    }
    
    @Test func columns() {
        let row: SQLiteRow = [
            "name": .text("Alice"),
            "age": .int(30),
            "city": .text("Wonderland")
        ]
        #expect(row.columns == ["name", "age", "city"])
    }
    
    @Test func namedParameters() {
        let row: SQLiteRow = [
            "name": .text("Alice"),
            "age": .int(30),
            "city": .text("Wonderland")
        ]
        #expect(row.namedParameters == [":name", ":age", ":city"])
    }
    
    @Test func containsColumn() {
        let row: SQLiteRow = ["one": .null]
        #expect(row.contains("one"))
        #expect(row.contains("two") == false)
    }
    
    @Test func description() {
        let row: SQLiteRow = [
            "name": .text("Alice"),
            "age": .int(30)
        ]
        #expect(row.description == #"["name": 'Alice', "age": 30]"#)
    }
    
    @Test func startIndex() {
        let row: SQLiteRow = [
            "name": .text("Alice"),
            "age": .int(30)
        ]
        #expect(row.startIndex == 0)
    }
    
    @Test func endIndex() {
        let row: SQLiteRow = [
            "name": .text("Alice"),
            "age": .int(30)
        ]
        #expect(row.endIndex == 2)
    }
    
    @Test func endIndexEmptyRow() {
        let row = SQLiteRow()
        #expect(row.endIndex == 0)
    }
    
    @Test func isEmpty() {
        var row = SQLiteRow()
        #expect(row.isEmpty)
        
        row["one"] = .int(1)
        #expect(row.isEmpty == false)
    }
    
    @Test func count() {
        var row = SQLiteRow()
        #expect(row.count == 0)
        
        row["one"] = .int(1)
        #expect(row.count == 1)
    }
    
    @Test func indexAfter() {
        let row = SQLiteRow()
        #expect(row.index(after: 0) == 1)
        #expect(row.index(after: 1) == 2)
        #expect(row.index(after: 2) == 3)
    }
}
