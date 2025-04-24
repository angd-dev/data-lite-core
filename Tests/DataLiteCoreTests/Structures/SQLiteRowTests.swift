import XCTest
import DataLiteCore

final class SQLiteRowTests: XCTestCase {
    func testInitEmptyRow() {
        let row = SQLiteRow()
        XCTAssertTrue(row.isEmpty)
        XCTAssertEqual(row.count, 0)
    }
    
    func testUpdateColumnPosition() {
        var row = SQLiteRow()
        row["name"] = .text("Alice")
        row["age"] = .int(30)
        
        row["name"] = .text("Bob")
        
        XCTAssertEqual(row[0].column, "name")
        XCTAssertEqual(row[0].value, .text("Bob"))
    }
    
    func testSubscriptByColumn() {
        var row = SQLiteRow()
        row["name"] = .text("Alice")
        
        XCTAssertEqual(row["name"], .text("Alice"))
        XCTAssertNil(row["age"])
        
        row["age"] = SQLiteRawValue.int(30)
        XCTAssertEqual(row["age"], .int(30))
    }
    
    func testSubscriptByIndex() {
        var row = SQLiteRow()
        row["name"] = .text("Alice")
        row["age"] = .int(30)
        
        let firstElement = row[row.startIndex]
        XCTAssertEqual(firstElement.column, "name")
        XCTAssertEqual(firstElement.value, .text("Alice"))
        
        let secondElement = row[row.index(after: row.startIndex)]
        XCTAssertEqual(secondElement.column, "age")
        XCTAssertEqual(secondElement.value, .int(30))
    }
    
    func testDescription() {
        var row = SQLiteRow()
        row["name"] = .text("Alice")
        row["age"] = .int(30)
        
        let expectedDescription = #"["name": 'Alice', "age": 30]"#
        XCTAssertEqual(row.description, expectedDescription)
    }
    
    func testCountAndIsEmpty() {
        var row = SQLiteRow()
        XCTAssertTrue(row.isEmpty)
        XCTAssertEqual(row.count, 0)
        
        row["name"] = .text("Alice")
        XCTAssertFalse(row.isEmpty)
        XCTAssertEqual(row.count, 1)
        
        row["age"] = .int(30)
        XCTAssertEqual(row.count, 2)
        
        row["name"] = nil
        XCTAssertEqual(row.count, 1)
    }
    
    func testIteration() {
        var row = SQLiteRow()
        row["name"] = .text("Alice")
        row["age"] = .int(30)
        row["city"] = .text("Wonderland")
        
        var elements: [SQLiteRow.Element] = []
        for (column, value) in row {
            elements.append((column, value))
        }
        
        XCTAssertEqual(elements.count, 3)
        XCTAssertEqual(elements[0].column, "name")
        XCTAssertEqual(elements[0].value, .text("Alice"))
        XCTAssertEqual(elements[1].column, "age")
        XCTAssertEqual(elements[1].value, .int(30))
        XCTAssertEqual(elements[2].column, "city")
        XCTAssertEqual(elements[2].value, .text("Wonderland"))
    }
}
