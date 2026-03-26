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

    @Test func normalizeURL_emptyString() {
        let result = service.normalizeURL("")
        #expect(result == "")
    }

    @Test func normalizeURL_rootDomain() {
        let result = service.normalizeURL("https://example.com")
        #expect(result == "example.com")
    }

    @Test func normalizeURL_allTrackingParams_resultsInCleanURL() {
        let result = service.normalizeURL("https://example.com/page?utm_source=a&utm_medium=b&utm_campaign=c&utm_term=d&utm_content=e")
        #expect(result == "example.com/page")
    }

    @Test func normalizeURL_httpScheme() {
        let result = service.normalizeURL("http://example.com/page")
        #expect(result == "example.com/page")
    }

    @Test func normalizeURL_deepPath() {
        let result = service.normalizeURL("https://docs.example.com/en/stable/api/v2/reference")
        #expect(result == "docs.example.com/en/stable/api/v2/reference")
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

    @Test func processResults_allFilteredOut_returnsEmpty() {
        // All results have snippets below minSnippetLength
        let results = [
            TestFixtures.makeResult(url: "https://a.com", content: "tiny"),
            TestFixtures.makeResult(url: "https://b.com", content: "also tiny"),
        ]
        let processed = service.processResults(results)
        #expect(processed.isEmpty)
    }

    @Test func processResults_dedup_keepsLongerSnippet() {
        let short = TestFixtures.makeResult(
            url: "https://example.com/page",
            content: String(repeating: "a", count: 40),
            score: 10.0,
            engines: ["google"]
        )
        let long = TestFixtures.makeResult(
            url: "https://www.example.com/page",
            content: String(repeating: "b", count: 200),
            score: 1.0,
            engines: ["bing"]
        )
        let processed = service.processResults([short, long])
        #expect(processed.count == 1)
        #expect(processed[0].snippetLength == 200)
    }

    @Test func processResults_nilScores_doesNotCrash() {
        let results = [
            TestFixtures.makeResult(url: "https://a.com", content: String(repeating: "x", count: 50), score: nil, engines: ["google"]),
            TestFixtures.makeResult(url: "https://b.com", content: String(repeating: "y", count: 50), score: nil, engines: ["bing"]),
        ]
        let processed = service.processResults(results)
        #expect(!processed.isEmpty)
    }

    @Test func processResults_singleResult_returnsIt() {
        let results = [
            TestFixtures.makeResult(url: "https://a.com", content: String(repeating: "x", count: 50), engines: ["google"]),
        ]
        let processed = service.processResults(results)
        #expect(processed.count == 1)
        #expect(processed[0].url == "https://a.com")
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

    @Test func buildEngineRankings_emptyInput() {
        let rankings = service.buildEngineRankings([])
        #expect(rankings.isEmpty)
    }

    @Test func buildEngineRankings_duplicateURLsInSameEngine_keepsBestScore() {
        let results = [
            TestFixtures.makeResult(url: "https://a.com", score: 2.0, engines: ["google"]),
            TestFixtures.makeResult(url: "https://a.com", score: 8.0, engines: ["google"]),
            TestFixtures.makeResult(url: "https://b.com", score: 5.0, engines: ["google"]),
        ]
        let rankings = service.buildEngineRankings(results)
        // a.com has best score 8.0, b.com has 5.0 → a.com should rank 1st
        #expect(rankings["google"]?["a.com"] == 1)
        #expect(rankings["google"]?["b.com"] == 2)
    }

    @Test func buildEngineRankings_nilScores_treatedAsZero() {
        let results = [
            TestFixtures.makeResult(url: "https://a.com", score: nil, engines: ["google"]),
            TestFixtures.makeResult(url: "https://b.com", score: 5.0, engines: ["google"]),
        ]
        let rankings = service.buildEngineRankings(results)
        // b.com has higher score, should rank first
        #expect(rankings["google"]?["b.com"] == 1)
        #expect(rankings["google"]?["a.com"] == 2)
    }
}
