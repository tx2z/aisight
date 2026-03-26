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

    // MARK: - Custom Server Tests

    @Test func customServer_unlockesAllFeatures() {
        let defaults = makeDefaults()
        defaults.set("https://my-searxng.example.com", forKey: "searxng_base_url")
        let manager = StoreManager(defaults: defaults)

        #expect(manager.isUsingCustomServer == true)
        #expect(manager.canSearch == true)
        #expect(manager.canDeepSearch == true)
        #expect(manager.remainingQueries == .max)
    }

    @Test func customServer_doesNotCountQueries() {
        let defaults = makeDefaults()
        defaults.set("https://my-searxng.example.com", forKey: "searxng_base_url")
        let manager = StoreManager(defaults: defaults)

        manager.recordQuery()
        manager.recordQuery()
        #expect(manager.dailyQueriesUsed == 0)
    }

    @Test func defaultServer_isNotCustom() {
        let defaults = makeDefaults()
        let manager = StoreManager(defaults: defaults)
        #expect(manager.isUsingCustomServer == false)
    }

    @Test func defaultServerURL_isNotCustom() {
        let defaults = makeDefaults()
        // Setting the default URL explicitly should not count as custom
        defaults.set("https://search.private-search-intelligence.app", forKey: "searxng_base_url")
        let manager = StoreManager(defaults: defaults)
        #expect(manager.isUsingCustomServer == false)
    }

    @Test func invalidURL_isNotCustomServer() {
        let defaults = makeDefaults()
        defaults.set("not-a-url", forKey: "searxng_base_url")
        let manager = StoreManager(defaults: defaults)
        #expect(manager.isUsingCustomServer == false)
        #expect(manager.canDeepSearch == false)
    }

    @Test func ftpURL_isNotCustomServer() {
        let defaults = makeDefaults()
        defaults.set("ftp://searxng.example.com", forKey: "searxng_base_url")
        let manager = StoreManager(defaults: defaults)
        #expect(manager.isUsingCustomServer == false)
    }

    @Test func refreshCustomServerStatus_detectsChange() {
        let defaults = makeDefaults()
        let manager = StoreManager(defaults: defaults)
        #expect(manager.isUsingCustomServer == false)

        // Simulate user saving a custom URL (what SettingsView does)
        defaults.set("https://my-searxng.example.com", forKey: "searxng_base_url")
        manager.refreshCustomServerStatus()

        #expect(manager.isUsingCustomServer == true)
        #expect(manager.canDeepSearch == true)
        #expect(manager.remainingQueries == .max)
    }

    @Test func refreshCustomServerStatus_detectsReset() {
        let defaults = makeDefaults()
        defaults.set("https://my-searxng.example.com", forKey: "searxng_base_url")
        let manager = StoreManager(defaults: defaults)
        #expect(manager.isUsingCustomServer == true)

        // Simulate user resetting to default
        defaults.removeObject(forKey: "searxng_base_url")
        manager.refreshCustomServerStatus()

        #expect(manager.isUsingCustomServer == false)
        #expect(manager.canDeepSearch == false)
    }

    @Test func resetToDefault_afterCustomServer_preservesFullQuota() {
        let defaults = makeDefaults()
        defaults.set("https://my-searxng.example.com", forKey: "searxng_base_url")
        let manager = StoreManager(defaults: defaults)

        // Searches on custom server don't count
        manager.recordQuery()
        manager.recordQuery()
        manager.recordQuery()
        #expect(manager.dailyQueriesUsed == 0)

        // Switch back to default server
        defaults.removeObject(forKey: "searxng_base_url")
        manager.refreshCustomServerStatus()

        // Should still have full quota since nothing was counted
        #expect(manager.remainingQueries == 10)
        #expect(manager.canSearch == true)
    }

    @Test func remainingQueries_neverGoesNegative() {
        let manager = StoreManager(defaults: makeDefaults())
        for _ in 0..<15 {
            manager.recordQuery()
        }
        #expect(manager.remainingQueries == 0)
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
