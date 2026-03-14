import Testing
@testable import AISight

struct SearXNGServiceTests {
    let service = SearXNGService()

    // MARK: - normalizeURL

    @Test func normalizeURL_stripsScheme() {
        let result = service.normalizeURL("https://example.com/page")
        #expect(result == "example.com/page")
    }

    @Test func normalizeURL_stripsWWW() {
        let result = service.normalizeURL("https://www.example.com/page")
        #expect(result == "example.com/page")
    }

    @Test func normalizeURL_stripsTrackingParams() {
        let result = service.normalizeURL("https://example.com/page?utm_source=test&utm_medium=email&valid=1")
        #expect(result == "example.com/page?valid=1")
    }

    @Test func normalizeURL_stripsFbclid() {
        let result = service.normalizeURL("https://example.com/page?fbclid=abc123")
        #expect(result == "example.com/page")
    }

    @Test func normalizeURL_stripsGclid() {
        let result = service.normalizeURL("https://example.com/page?gclid=abc&msclkid=def")
        #expect(result == "example.com/page")
    }

    @Test func normalizeURL_stripsFragment() {
        let result = service.normalizeURL("https://example.com/page#section")
        #expect(result == "example.com/page")
    }

    @Test func normalizeURL_stripsTrailingSlash() {
        let result = service.normalizeURL("https://example.com/page/")
        #expect(result == "example.com/page")
    }

    @Test func normalizeURL_lowercases() {
        let result = service.normalizeURL("https://EXAMPLE.COM/Page")
        #expect(result == "example.com/page")
    }

    @Test func normalizeURL_preservesNonTrackingQueryParams() {
        let result = service.normalizeURL("https://example.com/search?q=swift&lang=en")
        #expect(result.contains("q=swift"))
        #expect(result.contains("lang=en"))
    }

    @Test func normalizeURL_handlesMalformed() {
        let result = service.normalizeURL("not a url")
        #expect(result == "not a url")
    }

    // MARK: - processResults

    @Test func processResults_filtersShortSnippets() {
        let results = [
            TestFixtures.makeResult(url: "https://a.com", content: "short"),
            TestFixtures.makeResult(url: "https://b.com", content: String(repeating: "x", count: 50)),
        ]
        let processed = service.processResults(results)
        #expect(processed.count == 1)
        #expect(processed[0].url == "https://b.com")
    }

    @Test func processResults_deduplicatesByNormalizedURL() {
        let results = [
            TestFixtures.makeResult(url: "https://example.com/page", content: String(repeating: "a", count: 40)),
            TestFixtures.makeResult(url: "https://www.example.com/page", content: String(repeating: "b", count: 100)),
        ]
        let processed = service.processResults(results)
        #expect(processed.count == 1)
        // Keeps the longer snippet
        #expect(processed[0].snippetLength == 100)
    }

    @Test func processResults_limitsToMaxResults() {
        let results = (0..<10).map { i in
            TestFixtures.makeResult(
                url: "https://example\(i).com/page",
                content: String(repeating: "x", count: 50),
                score: Double(10 - i)
            )
        }
        let processed = service.processResults(results)
        #expect(processed.count <= 5)
    }

    @Test func processResults_emptyInputReturnsEmpty() {
        let processed = service.processResults([])
        #expect(processed.isEmpty)
    }

    @Test func processResults_multiEngineResultsRankHigher() {
        let singleEngine = TestFixtures.makeResult(
            url: "https://single.com/page",
            content: String(repeating: "x", count: 50),
            engine: "google",
            score: 5.0,
            engines: ["google"]
        )
        let multiEngine = TestFixtures.makeResult(
            url: "https://multi.com/page",
            content: String(repeating: "y", count: 50),
            engine: "google",
            score: 3.0,
            engines: ["google", "bing", "brave"]
        )
        let processed = service.processResults([singleEngine, multiEngine])
        #expect(processed.count == 2)
        #expect(processed[0].url == "https://multi.com/page")
    }

    // MARK: - buildEngineRankings

    @Test func buildEngineRankings_singleEngine() {
        let results = [
            TestFixtures.makeResult(url: "https://a.com", score: 10.0, engines: ["google"]),
            TestFixtures.makeResult(url: "https://b.com", score: 5.0, engines: ["google"]),
        ]
        let rankings = service.buildEngineRankings(results)
        #expect(rankings["google"]?["a.com"] == 1)
        #expect(rankings["google"]?["b.com"] == 2)
    }

    @Test func buildEngineRankings_multipleEngines() {
        let results = [
            TestFixtures.makeResult(url: "https://a.com", score: 10.0, engines: ["google", "bing"]),
            TestFixtures.makeResult(url: "https://b.com", score: 5.0, engines: ["google"]),
        ]
        let rankings = service.buildEngineRankings(results)
        #expect(rankings["google"] != nil)
        #expect(rankings["bing"] != nil)
        #expect(rankings["google"]?["a.com"] == 1)
        #expect(rankings["bing"]?["a.com"] == 1)
    }

    @Test func buildEngineRankings_nilEnginesFallsBackToEngineField() {
        let results = [
            TestFixtures.makeResult(url: "https://a.com", engine: "duckduckgo", score: 10.0, engines: nil),
        ]
        let rankings = service.buildEngineRankings(results)
        #expect(rankings["duckduckgo"] != nil)
    }
}
