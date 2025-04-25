import XCTest
import DataLiteCore

class SQLiteActionTests: XCTestCase {
    func testInsertAction() {
        let action = SQLiteAction.insert(db: "testDB", table: "users", rowID: 1)
        
        switch action {
        case .insert(let db, let table, let rowID):
            XCTAssertEqual(db, "testDB", "Database name should be 'testDB'")
            XCTAssertEqual(table, "users", "Table name should be 'users'")
            XCTAssertEqual(rowID, 1, "Row ID should be 1")
        default:
            XCTFail("Expected insert action")
        }
    }
    
    func testUpdateAction() {
        let action = SQLiteAction.update(db: "testDB", table: "users", rowID: 1)
        
        switch action {
        case .update(let db, let table, let rowID):
            XCTAssertEqual(db, "testDB", "Database name should be 'testDB'")
            XCTAssertEqual(table, "users", "Table name should be 'users'")
            XCTAssertEqual(rowID, 1, "Row ID should be 1")
        default:
            XCTFail("Expected update action")
        }
    }
    
    func testDeleteAction() {
        let action = SQLiteAction.delete(db: "testDB", table: "users", rowID: 1)
        
        switch action {
        case .delete(let db, let table, let rowID):
            XCTAssertEqual(db, "testDB", "Database name should be 'testDB'")
            XCTAssertEqual(table, "users", "Table name should be 'users'")
            XCTAssertEqual(rowID, 1, "Row ID should be 1")
        default:
            XCTFail("Expected delete action")
        }
    }
}
