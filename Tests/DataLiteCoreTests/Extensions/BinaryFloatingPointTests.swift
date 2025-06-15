import Testing
import DataLiteCore

struct BinaryFloatingPointTests {
    @Test func testFloatToSQLiteRawValue() {
        let floatValue: Float = 3.14
        let rawValue = floatValue.sqliteRawValue
        #expect(rawValue == .real(Double(floatValue)))
    }
    
    @Test func testDoubleToSQLiteRawValue() {
        let doubleValue: Double = 3.14
        let rawValue = doubleValue.sqliteRawValue
        #expect(rawValue == .real(doubleValue))
    }
    
    @Test func testFloatInitializationFromSQLiteRawValue() {
        let realValue: SQLiteRawValue = .real(3.14)
        let floatValue = Float(realValue)
        #expect(floatValue != nil)
        #expect(floatValue == 3.14)
        
        let intValue: SQLiteRawValue = .int(42)
        let floatFromInt = Float(intValue)
        #expect(floatFromInt != nil)
        #expect(floatFromInt == 42.0)
    }
    
    @Test func testDoubleInitializationFromSQLiteRawValue() {
        let realValue: SQLiteRawValue = .real(3.14)
        let doubleValue = Double(realValue)
        #expect(doubleValue != nil)
        #expect(doubleValue == 3.14)
        
        let intValue: SQLiteRawValue = .int(42)
        let doubleFromInt = Double(intValue)
        #expect(doubleFromInt != nil)
        #expect(doubleFromInt == 42.0)
    }
    
    @Test func testInitializationFailureFromInvalidSQLiteRawValue() {
        let nullValue: SQLiteRawValue = .null
        #expect(Float(nullValue) == nil)
        #expect(Double(nullValue) == nil)
        
        let textValue: SQLiteRawValue = .text("Invalid")
        #expect(Float(textValue) == nil)
        #expect(Double(textValue) == nil)
    }
}
