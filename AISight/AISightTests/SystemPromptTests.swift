import Testing
@testable import AISight

struct SystemPromptTests {

    // MARK: - build with sources

    @Test func buildWithSources_containsSourceTags() {
        let sources = [(index: 1, title: "Test", snippet: "Content", url: "https://example.com")]
        let prompt = SystemPrompt.build(query: "test", sources: sources)
        #expect(prompt.contains("<sources>"))
        #expect(prompt.contains("</sources>"))
    }

    @Test func buildWithSources_containsDomain() {
        let sources = [(index: 1, title: "Test", snippet: "Content", url: "https://example.com/page")]
        let prompt = SystemPrompt.build(query: "test", sources: sources)
        #expect(prompt.contains("example.com"))
    }

    @Test func buildWithSources_containsTitle() {
        let sources = [(index: 1, title: "My Article Title", snippet: "Content", url: "https://example.com")]
        let prompt = SystemPrompt.build(query: "test", sources: sources)
        #expect(prompt.contains("My Article Title"))
    }

    @Test func buildWithSources_containsSnippet() {
        let sources = [(index: 1, title: "Test", snippet: "Unique snippet content here", url: "https://example.com")]
        let prompt = SystemPrompt.build(query: "test", sources: sources)
        #expect(prompt.contains("Unique snippet content here"))
    }

    // MARK: - build without sources

    @Test func buildWithoutSources_mentionsNoResults() {
        let prompt = SystemPrompt.build(query: "test", sources: [])
        #expect(prompt.contains("No search results"))
    }

    @Test func buildWithoutSources_noSourceTags() {
        let prompt = SystemPrompt.build(query: "test", sources: [])
        #expect(!prompt.contains("<sources>"))
    }

    // MARK: - direct answers

    @Test func buildWithDirectAnswers() {
        let sources = [(index: 1, title: "Test", snippet: "Content", url: "https://example.com")]
        let prompt = SystemPrompt.build(query: "test", sources: sources, directAnswers: ["42 is the answer"])
        #expect(prompt.contains("42 is the answer"))
        #expect(prompt.contains("Direct Answers"))
    }

    // MARK: - infoboxes

    @Test func buildWithInfoboxes() {
        let sources = [(index: 1, title: "Test", snippet: "Content", url: "https://example.com")]
        let infobox = TestFixtures.makeInfobox(title: "Swift Language", content: "A programming language")
        let prompt = SystemPrompt.build(query: "test", sources: sources, infoboxes: [infobox])
        #expect(prompt.contains("Swift Language"))
        #expect(prompt.contains("A programming language"))
        #expect(prompt.contains("Knowledge Panel"))
    }

    @Test func buildWithInfoboxes_truncatesLongContent() {
        let sources = [(index: 1, title: "Test", snippet: "Content", url: "https://example.com")]
        let longContent = String(repeating: "A", count: 1000)
        let infobox = TestFixtures.makeInfobox(content: longContent)
        let prompt = SystemPrompt.build(query: "test", sources: sources, infoboxes: [infobox])
        // 800 chars + ellipsis
        #expect(!prompt.contains(longContent))
        #expect(prompt.contains("…"))
    }

    // MARK: - languageInstruction

    @Test func languageInstruction_english() {
        let result = SystemPrompt.languageInstruction(for: "en")
        #expect(result == "")
    }

    @Test(arguments: [
        ("de", "German"),
        ("fr", "French"),
        ("es", "Spanish"),
        ("it", "Italian"),
        ("ja", "Japanese"),
        ("ko", "Korean"),
        ("zh", "Chinese"),
        ("pt", "Portuguese"),
    ])
    func languageInstruction_nonEnglish(code: String, name: String) {
        let result = SystemPrompt.languageInstruction(for: code)
        #expect(result.contains(name))
    }

    @Test func languageInstruction_unknownCode() {
        let result = SystemPrompt.languageInstruction(for: "xx")
        #expect(result == "")
    }
}
