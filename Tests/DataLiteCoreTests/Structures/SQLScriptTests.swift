import XCTest
import DataLiteCore

class SQLScriptTests: XCTestCase {
    func testInitWithValidFile() throws {
        let sqlScript = try SQLScript(
            byResource: "valid_script",
            extension: "sql",
            in: .module
        )
        XCTAssertNotNil(sqlScript)
        XCTAssertEqual(sqlScript?.count, 2)
    }
    
    func testInitWithEmptyFile() throws {
        let sqlScript = try SQLScript(
            byResource: "empty_script",
            extension: "sql",
            in: .module
        )
        XCTAssertNotNil(sqlScript)
        XCTAssertEqual(sqlScript?.count, 0)
    }
    
    func testInitWithInvalidFile() throws {
        XCTAssertThrowsError(
            try SQLScript(
                byResource: "invalid_script",
                extension: "sql",
                in: .module
            )
        ) { error in
            let error = error as NSError
            XCTAssertEqual(error.domain, NSCocoaErrorDomain)
            XCTAssertEqual(error.code, 259)
        }
    }
    
    func testAccessingStatements() throws {
        let sqlScript = try SQLScript(
            byResource: "valid_script",
            extension: "sql",
            in: .module
        )
        
        let oneStatement = """
        CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            username TEXT NOT NULL,
            email TEXT NOT NULL
        )
        """
        
        let twoStatement = """
        INSERT INTO users (id, username, email)
        VALUES
            (1, 'john_doe', 'john@example.com'),
            (2, 'jane_doe', 'jane@example.com')
        """
        
        XCTAssertEqual(sqlScript?[0], oneStatement)
        XCTAssertEqual(sqlScript?[1], twoStatement)
    }
}
