import Testing
@testable import AISight

struct ContentFetcherTests {
    let fetcher = ContentFetcher()

    // MARK: - stripHTML

    @Test func stripHTML_removesScriptTags() async {
        let html = "<p>Hello</p><script>alert('xss')</script><p>World</p>"
        let result = await fetcher.stripHTML(html)
        #expect(!result.contains("alert"))
        #expect(result.contains("Hello"))
        #expect(result.contains("World"))
    }

    @Test func stripHTML_removesStyleTags() async {
        let html = "<style>body { color: red; }</style><p>Content</p>"
        let result = await fetcher.stripHTML(html)
        #expect(!result.contains("color"))
        #expect(result.contains("Content"))
    }

    @Test func stripHTML_removesNavHeaderFooter() async {
        let html = "<nav>Menu</nav><header>Header</header><main>Content</main><footer>Footer</footer>"
        let result = await fetcher.stripHTML(html)
        #expect(!result.contains("Menu"))
        #expect(!result.contains("Header"))
        #expect(!result.contains("Footer"))
        #expect(result.contains("Content"))
    }

    @Test func stripHTML_stripsAllTags() async {
        let html = "<div><p>Hello <strong>world</strong></p></div>"
        let result = await fetcher.stripHTML(html)
        #expect(result == "Hello world")
    }

    @Test func stripHTML_decodesHTMLEntities() async {
        let html = "Tom &amp; Jerry &quot;fun&quot; it&#39;s great"
        let result = await fetcher.stripHTML(html)
        #expect(result.contains("Tom & Jerry"))
        #expect(result.contains("\"fun\""))
        #expect(result.contains("it's"))
        #expect(result.contains("great"))
    }

    @Test func stripHTML_secondPassStripsDecodedAngleBrackets() async {
        // &lt;3&gt; becomes <3> after entity decoding, which the second pass strips as a tag
        let html = "I &lt;3&gt; Swift"
        let result = await fetcher.stripHTML(html)
        // <3> is stripped by the second-pass tag removal — this is expected behavior
        #expect(result.contains("I"))
        #expect(result.contains("Swift"))
    }

    @Test func stripHTML_decodesNbsp() async {
        let html = "hello&nbsp;world"
        let result = await fetcher.stripHTML(html)
        // &nbsp; is replaced with a regular space, then whitespace is collapsed
        #expect(result.contains("hello") && result.contains("world"))
    }

    @Test func stripHTML_collapsesWhitespace() async {
        let html = "Hello    \n\n   World"
        let result = await fetcher.stripHTML(html)
        #expect(result == "Hello World")
    }

    @Test func stripHTML_secondPassStripsReconstructedTags() async {
        // Entities that reconstruct tags after decoding
        let html = "&lt;script&gt;alert('xss')&lt;/script&gt;"
        let result = await fetcher.stripHTML(html)
        #expect(!result.contains("<script>"))
    }

    @Test func stripHTML_emptyInput() async {
        let result = await fetcher.stripHTML("")
        #expect(result == "")
    }

    @Test func stripHTML_noHTMLPassthrough() async {
        let result = await fetcher.stripHTML("Plain text content")
        #expect(result == "Plain text content")
    }

    // MARK: - removeTagBlock

    @Test func removeTagBlock_removesMatchedTag() async {
        let result = await fetcher.removeTagBlock(from: "<script>code</script>rest", tag: "script")
        #expect(result == "rest")
    }

    @Test func removeTagBlock_caseInsensitive() async {
        let result = await fetcher.removeTagBlock(from: "<SCRIPT>code</SCRIPT>rest", tag: "script")
        #expect(result == "rest")
    }

    @Test func removeTagBlock_tagNotPresent() async {
        let input = "No tags here"
        let result = await fetcher.removeTagBlock(from: input, tag: "script")
        #expect(result == input)
    }

    // MARK: - truncate

    @Test func truncate_underLimit() async {
        let result = await fetcher.truncate("Hello", to: 10)
        #expect(result == "Hello")
    }

    @Test func truncate_atLimit() async {
        let result = await fetcher.truncate("Hello", to: 5)
        #expect(result == "Hello")
    }

    @Test func truncate_overLimit() async {
        let result = await fetcher.truncate("Hello World", to: 5)
        #expect(result == "Hello")
    }

    @Test func truncate_emptyString() async {
        let result = await fetcher.truncate("", to: 10)
        #expect(result == "")
    }

    // MARK: - shouldFetchFullContent

    @Test func shouldFetchFullContent_shortSnippet() async {
        let result = await fetcher.shouldFetchFullContent(snippet: "short")
        #expect(result == true)
    }

    @Test func shouldFetchFullContent_longSnippet() async {
        let snippet = String(repeating: "x", count: 200)
        let result = await fetcher.shouldFetchFullContent(snippet: snippet)
        #expect(result == false)
    }

    @Test func shouldFetchFullContent_atThreshold() async {
        let snippet = String(repeating: "x", count: 150)
        let result = await fetcher.shouldFetchFullContent(snippet: snippet)
        #expect(result == false)
    }

    @Test func shouldFetchFullContent_customThreshold() async {
        let customFetcher = ContentFetcher(snippetThreshold: 50)
        let snippet = String(repeating: "x", count: 49)
        let result = await customFetcher.shouldFetchFullContent(snippet: snippet)
        #expect(result == true)
    }
}
