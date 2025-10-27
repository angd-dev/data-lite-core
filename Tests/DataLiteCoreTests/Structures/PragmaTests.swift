import Testing

@testable import DataLiteCore

struct PragmaTests {
    @Test(arguments: [
        (Pragma.applicationID, "application_id"),
        (Pragma.foreignKeys, "foreign_keys"),
        (Pragma.journalMode, "journal_mode"),
        (Pragma.synchronous, "synchronous"),
        (Pragma.userVersion, "user_version"),
        (Pragma.busyTimeout, "busy_timeout")
    ])
    func predefinedPragmas(_ pragma: Pragma, _ expected: String) {
        #expect(pragma.rawValue == expected)
        #expect(pragma.description == expected)
    }
    
    @Test func initRawValue() {
        let pragma = Pragma(rawValue: "custom_pragma")
        #expect(pragma.rawValue == "custom_pragma")
        #expect(pragma.description == "custom_pragma")
    }
    
    @Test func initStringLiteral() {
        let pragma: Pragma = "another_pragma"
        #expect(pragma.rawValue == "another_pragma")
        #expect(pragma.description == "another_pragma")
    }
}
