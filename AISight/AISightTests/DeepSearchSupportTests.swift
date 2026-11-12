import Testing
@testable import AISight

struct DeepSearchSupportTests {

    // MARK: - isNoRelevantInfo

    @Test func marker_exact() {
        #expect(DeepSearchSupport.isNoRelevantInfo("NO_RELEVANT_INFO"))
    }

    @Test func marker_lowercase() {
        #expect(DeepSearchSupport.isNoRelevantInfo("no_relevant_info"))
    }

    @Test func marker_withTrailingPeriodAndWhitespace() {
        #expect(DeepSearchSupport.isNoRelevantInfo("  NO_RELEVANT_INFO.\n"))
    }

    @Test func marker_withQuotesOrBackticks() {
        #expect(DeepSearchSupport.isNoRelevantInfo("`NO_RELEVANT_INFO`"))
        #expect(DeepSearchSupport.isNoRelevantInfo("\"NO_RELEVANT_INFO\""))
    }

    @Test func marker_embeddedInLongerText_isNotMarker() {
        #expect(!DeepSearchSupport.isNoRelevantInfo("NO_RELEVANT_INFO, but OVHcloud is a French provider."))
        #expect(!DeepSearchSupport.isNoRelevantInfo("The answer is NO_RELEVANT_INFO"))
    }

    @Test func marker_emptyOrUnrelated_isNotMarker() {
        #expect(!DeepSearchSupport.isNoRelevantInfo(""))
        #expect(!DeepSearchSupport.isNoRelevantInfo("Hetzner offers cheap servers."))
    }

    // MARK: - researchedSources

    private func group(_ urls: [String]) -> SearchQueryGroup {
        SearchQueryGroup(query: "q", results: urls.map { TestFixtures.makeResult(url: $0) })
    }

    @Test func researchedSources_dedupesByURLKeepingOrder() {
        let groups = [
            group(["https://a.com", "https://b.com"]),
            group(["https://b.com", "https://c.com"]),
        ]
        let urls = DeepSearchSupport.researchedSources(in: groups).map(\.url)
        #expect(urls == ["https://a.com", "https://b.com", "https://c.com"])
    }

    @Test func researchedSources_capsEachGroupAtMaxResults() {
        let many = (0..<(AppConfig.maxResults + 3)).map { "https://site\($0).com" }
        let urls = DeepSearchSupport.researchedSources(in: [group(many)]).map(\.url)
        #expect(urls == Array(many.prefix(AppConfig.maxResults)))
    }

    @Test func researchedSources_emptyGroups() {
        #expect(DeepSearchSupport.researchedSources(in: []).isEmpty)
    }
}
