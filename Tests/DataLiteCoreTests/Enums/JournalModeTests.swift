import Testing
import DataLiteCore

struct JournalModeTests {
    @Test func rawValue() {
        #expect(JournalMode.delete.rawValue == "DELETE")
        #expect(JournalMode.truncate.rawValue == "TRUNCATE")
        #expect(JournalMode.persist.rawValue == "PERSIST")
        #expect(JournalMode.memory.rawValue == "MEMORY")
        #expect(JournalMode.wal.rawValue == "WAL")
        #expect(JournalMode.off.rawValue == "OFF")
    }
    
    @Test func initRawValue() {
        #expect(JournalMode(rawValue: "DELETE") == .delete)
        #expect(JournalMode(rawValue: "delete") == .delete)
        
        #expect(JournalMode(rawValue: "TRUNCATE") == .truncate)
        #expect(JournalMode(rawValue: "truncate") == .truncate)
        
        #expect(JournalMode(rawValue: "PERSIST") == .persist)
        #expect(JournalMode(rawValue: "persist") == .persist)
        
        #expect(JournalMode(rawValue: "MEMORY") == .memory)
        #expect(JournalMode(rawValue: "memory") == .memory)
        
        #expect(JournalMode(rawValue: "WAL") == .wal)
        #expect(JournalMode(rawValue: "wal") == .wal)
        
        #expect(JournalMode(rawValue: "OFF") == .off)
        #expect(JournalMode(rawValue: "off") == .off)
    }
}
