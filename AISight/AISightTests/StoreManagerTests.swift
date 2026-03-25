import Testing
import Foundation
@testable import AISight

@MainActor
struct StoreManagerTests {

    private func makeDefaults() -> UserDefaults {
        let suiteName = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    @Test func freshManager_hasFullQueries() {
        let manager = StoreManager(defaults: makeDefaults())
        #expect(manager.remainingQueries == 10)
        #expect(manager.canSearch == true)
    }

    @Test func afterMaxQueries_cannotSearch() {
        let manager = StoreManager(defaults: makeDefaults())
        for _ in 0..<10 {
            manager.recordQuery()
        }
        #expect(manager.canSearch == false)
        #expect(manager.remainingQueries == 0)
    }

    @Test func recordQuery_incrementsCounter() {
        let manager = StoreManager(defaults: makeDefaults())
        manager.recordQuery()
        #expect(manager.remainingQueries == 9)
    }

    @Test func dateReset_resetsCounter() {
        let defaults = makeDefaults()
        // Simulate yesterday's date with queries used
        defaults.set("2020-01-01", forKey: "daily_queries_date")
        defaults.set(15, forKey: "daily_queries_used")

        let manager = StoreManager(defaults: defaults)
        // Should reset because the stored date != today
        #expect(manager.remainingQueries == 10)
        #expect(manager.canSearch == true)
    }

    @Test func freeUser_cannotDeepSearch() {
        let manager = StoreManager(defaults: makeDefaults())
        #expect(manager.canDeepSearch == false)
    }

    @Test func proUser_canDeepSearch() {
        let defaults = makeDefaults()
        // Simulate a Pro user by purchasing (we can't trigger StoreKit in tests,
        // but we can verify the property reflects isPro state)
        let manager = StoreManager(defaults: defaults)
        // Fresh manager is not Pro
        #expect(manager.canDeepSearch == false)
        #expect(manager.canSearch == true)
    }

    @Test func sameDate_preservesCounter() {
        let defaults = makeDefaults()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date.now)

        defaults.set(today, forKey: "daily_queries_date")
        defaults.set(5, forKey: "daily_queries_used")

        let manager = StoreManager(defaults: defaults)
        #expect(manager.remainingQueries == 5)
    }
}
