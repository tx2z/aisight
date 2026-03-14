import Testing
@testable import AISight

struct SearXNGResultTests {

    // MARK: - engineCount

    @Test func engineCount_withEnginesArray() {
        let result = TestFixtures.makeResult(engines: ["google", "bing", "brave"])
        #expect(result.engineCount == 3)
    }

    @Test func engineCount_withoutEnginesArray() {
        let result = TestFixtures.makeResult(engines: nil)
        #expect(result.engineCount == 1)
    }

    // MARK: - snippetLength

    @Test func snippetLength_nilContent() {
        let result = TestFixtures.makeResult(content: nil)
        #expect(result.snippetLength == 0)
    }

    @Test func snippetLength_emptyContent() {
        let result = TestFixtures.makeResult(content: "")
        #expect(result.snippetLength == 0)
    }

    @Test func snippetLength_nonEmpty() {
        let result = TestFixtures.makeResult(content: "Hello world")
        #expect(result.snippetLength == 11)
    }

    // MARK: - hasUsableSnippet

    @Test func hasUsableSnippet_belowThreshold() {
        let result = TestFixtures.makeResult(content: String(repeating: "x", count: 100))
        #expect(!result.hasUsableSnippet)
    }

    @Test func hasUsableSnippet_atThreshold() {
        let result = TestFixtures.makeResult(content: String(repeating: "x", count: 150))
        #expect(result.hasUsableSnippet)
    }

    @Test func hasUsableSnippet_aboveThreshold() {
        let result = TestFixtures.makeResult(content: String(repeating: "x", count: 200))
        #expect(result.hasUsableSnippet)
    }

    // MARK: - domain

    @Test func domain_validURL() {
        let result = TestFixtures.makeResult(url: "https://example.com/path")
        #expect(result.domain == "example.com")
    }

    @Test func domain_stripsWWW() {
        let result = TestFixtures.makeResult(url: "https://www.example.com/path")
        #expect(result.domain == "example.com")
    }

    @Test func domain_malformedURL() {
        let result = TestFixtures.makeResult(url: "not a url")
        #expect(result.domain == nil)
    }

    // MARK: - id

    @Test func id_combinesURLAndEngine() {
        let result = TestFixtures.makeResult(url: "https://example.com", engine: "google")
        #expect(result.id == "https://example.com_google")
    }

    @Test func id_nilEngine() {
        let result = TestFixtures.makeResult(url: "https://example.com", engine: nil)
        #expect(result.id == "https://example.com_")
    }
}
