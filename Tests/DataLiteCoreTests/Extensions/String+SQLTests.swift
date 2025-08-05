import Foundation
import Testing

@testable import DataLiteCore

struct StringSQLTests {
    // MARK: - Test Remove Single Line Comments
    
    @Test func testSingleLineCommentAtStart() {
        let input = """
            -- This is a comment
            SELECT * FROM users;
            """
        let expected = """
            
            SELECT * FROM users;
            """
        #expect(input.removingComments() == expected)
    }
    
    @Test func testSingleLineCommentAfterStatement() {
        let input = """
            SELECT * FROM users; -- This is a comment
            """
        let expected = """
            SELECT * FROM users;\u{0020}
            """
        #expect(input.removingComments() == expected)
    }
    
    @Test func testSingleLineCommentBetweenStatementLines() {
        let input = """
            INSERT INTO users (
                id, name
                -- comment between statement
            ) VALUES (1, 'Alice');
            """
        let expected = """
            INSERT INTO users (
                id, name
                
            ) VALUES (1, 'Alice');
            """
        #expect(input.removingComments() == expected)
    }
    
    @Test func testSingleLineCommentAtEnd() {
        let input = """
            SELECT * FROM users;
            -- final comment
            """
        let expected = """
            SELECT * FROM users;
            
            """
        #expect(input.removingComments() == expected)
    }
    
    @Test func testSingleLineCommentWithTabsAndSpaces() {
        let input = "SELECT 1;\t -- comment with tab\nSELECT 2;"
        let expected = "SELECT 1;\t \nSELECT 2;"
        #expect(input.removingComments() == expected)
    }
    
    @Test func testSingleLineCommentWithLiterals() {
        let input = """
        INSERT INTO logs (text) VALUES ('This isn''t -- a comment'); -- trailing comment
        """
        let expected = """
        INSERT INTO logs (text) VALUES ('This isn''t -- a comment'); 
        """
        #expect(input.removingComments() == expected)
    }
    
    // MARK: - Test Remove Multiline Comments
    
    @Test func testMultilineCommentAtStart() {
        let input = """
            /* This is a
               comment at the top */
            SELECT * FROM users;
            """
        let expected = """
            
            SELECT * FROM users;
            """
        #expect(input.removingComments() == expected)
    }
    
    @Test func testMultilineCommentAtLineStart() {
        let input = """
            /* comment */ SELECT * FROM users;
            """
        let expected = """
            \u{0020}SELECT * FROM users;
            """
        #expect(input.removingComments() == expected)
    }
    
    @Test func testMultilineCommentInMiddleOfLine() {
        let input = """
            SELECT /* inline comment */ * FROM users;
            """
        let expected = """
            SELECT  * FROM users;
            """
        #expect(input.removingComments() == expected)
    }
    
    @Test func testMultilineCommentAtEndOfLine() {
        let input = """
            SELECT * FROM users; /* trailing comment */
            """
        let expected = """
            SELECT * FROM users;\u{0020}
            """
        #expect(input.removingComments() == expected)
    }
    
    @Test func testMultilineCommentBetweenLines() {
        let input = """
            INSERT INTO users (
                id,
                /* this field stores username */
                username,
                email
            ) VALUES (1, 'alice', 'alice@example.com');
            """
        let expected = """
            INSERT INTO users (
                id,
                
                username,
                email
            ) VALUES (1, 'alice', 'alice@example.com');
            """
        #expect(input.removingComments() == expected)
    }
    
    @Test func testMultilineCommentAtEndOfFile() {
        let input = """
            SELECT * FROM users;
            /* final block comment */
            """
        let expected = """
            SELECT * FROM users;
            
            """
        #expect(input.removingComments() == expected)
    }
    
    @Test func testMultilineCommentWithLiterals() {
        let input = """
        INSERT INTO notes (text) VALUES ('This isn''t /* a comment */ either'); /* trailing comment */
        """
        let expected = """
        INSERT INTO notes (text) VALUES ('This isn''t /* a comment */ either');\u{0020}
        """
        #expect(input.removingComments() == expected)
    }
    
    // MARK: - Test Trimming Lines
    
    @Test func testTrimmingEmptyFirstLine() {
        let input = "\nSELECT * FROM users;"
        let expected = "SELECT * FROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingEmptyFirstLineWithSpace() {
        let input = " \nSELECT * FROM users;"
        let expected = "SELECT * FROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingEmptyFirstLineWithTab() {
        let input = "\t\nSELECT * FROM users;"
        let expected = "SELECT * FROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingEmptyMiddleLine() {
        let input = "SELECT *\n\nFROM users;"
        let expected = "SELECT *\nFROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingEmptyMiddleLineWithSpace() {
        let input = "SELECT *\n\u{0020}\nFROM users;"
        let expected = "SELECT *\nFROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingEmptyMiddleLineWithTab() {
        let input = "SELECT *\n\t\nFROM users;"
        let expected = "SELECT *\nFROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingEmptyLastLine() {
        let input = "SELECT * FROM users;\n"
        let expected = "SELECT * FROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingEmptyLastLineWithSpace() {
        let input = "SELECT * FROM users; \n"
        let expected = "SELECT * FROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingEmptyLastLineWithTab() {
        let input = "SELECT * FROM users;\t\n"
        let expected = "SELECT * FROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingTrailingSpacesOnly() {
        let input = "SELECT * FROM users;    "
        let expected = "SELECT * FROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingTrailingSpacesAndNewline() {
        let input = "SELECT * FROM users;   \n"
        let expected = "SELECT * FROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingTrailingTabsOnly() {
        let input = "SELECT * FROM users;\t\t"
        let expected = "SELECT * FROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingTrailingTabsAndNewline() {
        let input = "SELECT * FROM users;\t\t\n"
        let expected = "SELECT * FROM users;"
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingMultipleEmptyLinesAndSpaces() {
        let input = "\n\n\t\u{0020}\nSELECT * FROM users;\n\n\u{0020}\n\n"
        let expected = "SELECT * FROM users;"
        print("zzzz\n\(input.trimmingLines())")
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingLiteralPreservesWhitespace() {
        let input = "INSERT INTO logs VALUES ('line with\n\nspaces \t \n\n and tabs');"
        let expected = input
        #expect(input.trimmingLines() == expected)
    }
    
    @Test func testTrimmingPreserveLineBreaksInMultilineInsert() {
        let input = """
            INSERT INTO users (id, username, email)
            VALUES \t
                (1, 'john_doe', 'john@example.com'),
                (2, 'jane_doe', 'jane@example.com');
            """
        let expected = """
            INSERT INTO users (id, username, email)
            VALUES
                (1, 'john_doe', 'john@example.com'),
                (2, 'jane_doe', 'jane@example.com');
            """
        #expect(input.trimmingLines() == expected)
    }
    
    // MARK: - Test Split Statements
    
    @Test func testSplitSingleStatement() {
        let input = "SELECT * FROM users;"
        let expected = ["SELECT * FROM users"]
        #expect(input.splitStatements() == expected)
    }
    
    @Test func testSplitSingleStatementWithoutSemicolon() {
        let input = "SELECT * FROM users"
        let expected = ["SELECT * FROM users"]
        #expect(input.splitStatements() == expected)
    }
    
    @Test func testSplitMultipleStatements() {
        let input = """
            SELECT * FROM users;
            DELETE FROM users WHERE id=123;
            DELETE FROM users WHERE id=987;
            """
        let expected = [
            "SELECT * FROM users",
            "DELETE FROM users WHERE id=123",
            "DELETE FROM users WHERE id=987"
        ]
        #expect(input.splitStatements() == expected)
    }
    
    @Test func testSplitMultipleStatementsLastWithoutSemicolon() {
        let input = """
            SELECT * FROM users;
            DELETE FROM users WHERE id=1;
            UPDATE users SET name='Bob' WHERE id=2
            """
        let expected = [
            "SELECT * FROM users",
            "DELETE FROM users WHERE id=1",
            "UPDATE users SET name='Bob' WHERE id=2"
        ]
        #expect(input.splitStatements() == expected)
    }
    
    @Test func testSplitTextLiteralSemicolon() {
        let input = "INSERT INTO logs (msg) VALUES ('Hello; world');"
        let expected = ["INSERT INTO logs (msg) VALUES ('Hello; world')"]
        #expect(input.splitStatements() == expected)
    }
    
    @Test func testSplitTextLiteralEscapingQuotes() {
        let input = "INSERT INTO test VALUES ('It''s a test');"
        let expected = ["INSERT INTO test VALUES ('It''s a test')"]
        #expect(input.splitStatements() == expected)
    }
    
    @Test func testSplitMultipleSemicolon() {
        let input = "SELECT * FROM users;;SELECT * FROM users;"
        let expected = [
            "SELECT * FROM users",
            "SELECT * FROM users"
        ]
        #expect(input.splitStatements() == expected)
    }
    
    @Test(arguments: [
        ("BEGIN", "END"),
        ("Begin", "End"),
        ("begin", "end"),
        ("bEgIn", "eNd"),
        ("BeGiN", "EnD")
    ])
    func testSplitWithBeginEnd(begin: String, end: String) {
        let input = """
            CREATE TABLE KDFMetadata (
                id      INTEGER     PRIMARY KEY,
                value   TEXT        NOT NULL
            );
            CREATE TRIGGER KDFMetadataLimit
            BEFORE INSERT ON KDFMetadata
            WHEN (SELECT COUNT(*) FROM KDFMetadata) >= 1
            \(begin)
                SELECT RAISE(FAIL, 'Only one row allowed in KDFMetadata');
            \(end);
            """
        let expected = [
            """
            CREATE TABLE KDFMetadata (
                id      INTEGER     PRIMARY KEY,
                value   TEXT        NOT NULL
            )
            """,
            """
            CREATE TRIGGER KDFMetadataLimit
            BEFORE INSERT ON KDFMetadata
            WHEN (SELECT COUNT(*) FROM KDFMetadata) >= 1
            \(begin)
                SELECT RAISE(FAIL, 'Only one row allowed in KDFMetadata');
            \(end)
            """
        ]
        #expect(input.splitStatements() == expected)
    }
    
    @Test func testSplitWithSavepoints() {
        let input = """
            SAVEPOINT sp1;
            INSERT INTO users (id, name) VALUES (1, 'Alice');
            RELEASE SAVEPOINT sp1;
            SAVEPOINT sp2;
            UPDATE users SET name = 'Bob' WHERE id = 1;
            ROLLBACK TO SAVEPOINT sp2;
            RELEASE SAVEPOINT sp2;
            """
        let expected = [
            "SAVEPOINT sp1",
            "INSERT INTO users (id, name) VALUES (1, 'Alice')",
            "RELEASE SAVEPOINT sp1",
            "SAVEPOINT sp2",
            "UPDATE users SET name = 'Bob' WHERE id = 1",
            "ROLLBACK TO SAVEPOINT sp2",
            "RELEASE SAVEPOINT sp2"
        ]
        #expect(input.splitStatements() == expected)
    }
}
