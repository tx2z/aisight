import Testing
@testable import AISight

struct CitationTextTests {

    // MARK: - parseBlocks

    @Test func parseBlocks_heading() {
        let blocks = CitationText.parseBlocks("## Hello World")
        #expect(blocks.count == 1)
        guard case .heading(let level, let text) = blocks[0] else {
            Issue.record("Expected heading block")
            return
        }
        #expect(level == 2)
        #expect(text == "Hello World")
    }

    @Test func parseBlocks_headingLevels() {
        for level in 1...6 {
            let prefix = String(repeating: "#", count: level)
            let blocks = CitationText.parseBlocks("\(prefix) Title")
            guard case .heading(let parsedLevel, _) = blocks[0] else {
                Issue.record("Expected heading at level \(level)")
                return
            }
            #expect(parsedLevel == level)
        }
    }

    @Test func parseBlocks_unorderedList_dash() {
        let blocks = CitationText.parseBlocks("- Item one")
        #expect(blocks.count == 1)
        guard case .listItem(let text, let num) = blocks[0] else {
            Issue.record("Expected list item")
            return
        }
        #expect(text == "Item one")
        #expect(num == nil)
    }

    @Test func parseBlocks_unorderedList_asterisk() {
        let blocks = CitationText.parseBlocks("* Item one")
        guard case .listItem(_, let num) = blocks[0] else {
            Issue.record("Expected list item")
            return
        }
        #expect(num == nil)
    }

    @Test func parseBlocks_orderedList() {
        let blocks = CitationText.parseBlocks("1. First item\n2. Second item")
        #expect(blocks.count == 2)
        guard case .listItem(let text, let num) = blocks[0] else {
            Issue.record("Expected ordered list item")
            return
        }
        #expect(text == "First item")
        #expect(num == 1)
    }

    @Test func parseBlocks_codeBlock() {
        let input = "```\nlet x = 1\nprint(x)\n```"
        let blocks = CitationText.parseBlocks(input)
        #expect(blocks.count == 1)
        guard case .codeBlock(let code) = blocks[0] else {
            Issue.record("Expected code block")
            return
        }
        #expect(code.contains("let x = 1"))
        #expect(code.contains("print(x)"))
    }

    @Test func parseBlocks_paragraph() {
        let blocks = CitationText.parseBlocks("Just a paragraph of text.")
        #expect(blocks.count == 1)
        guard case .paragraph(let text) = blocks[0] else {
            Issue.record("Expected paragraph")
            return
        }
        #expect(text == "Just a paragraph of text.")
    }

    @Test func parseBlocks_emptyLineParagraphBreak() {
        let blocks = CitationText.parseBlocks("Paragraph one.\n\nParagraph two.")
        #expect(blocks.count == 2)
        guard case .paragraph(let p1) = blocks[0],
              case .paragraph(let p2) = blocks[1] else {
            Issue.record("Expected two paragraphs")
            return
        }
        #expect(p1 == "Paragraph one.")
        #expect(p2 == "Paragraph two.")
    }

    @Test func parseBlocks_unclosedCodeBlock() {
        let input = "```\nlet x = 1\nno closing"
        let blocks = CitationText.parseBlocks(input)
        #expect(blocks.count == 1)
        guard case .codeBlock(let code) = blocks[0] else {
            Issue.record("Expected code block")
            return
        }
        #expect(code.contains("let x = 1"))
    }

    @Test func parseBlocks_emptyInput() {
        let blocks = CitationText.parseBlocks("")
        #expect(blocks.isEmpty)
    }

    @Test func parseBlocks_mixedContent() {
        let input = """
        ## Title
        Some text.

        - Item 1
        - Item 2

        1. First
        2. Second

        ```
        code()
        ```
        """
        let blocks = CitationText.parseBlocks(input)
        // heading, paragraph, 2 unordered items, 2 ordered items, code block
        #expect(blocks.count == 7)
    }

    // MARK: - escapeAttributions

    @Test func escapeAttributions_extractsDomain() {
        let ct = CitationText(text: "")
        let (escaped, domains) = ct.escapeAttributions("Hello (via example.com) world")
        #expect(domains == ["example.com"])
        #expect(!escaped.contains("(via"))
    }

    @Test func escapeAttributions_multipleAttributions() {
        let ct = CitationText(text: "")
        let (_, domains) = ct.escapeAttributions("A (via a.com) and B (via b.com)")
        #expect(domains.count == 2)
        #expect(domains.contains("a.com"))
        #expect(domains.contains("b.com"))
    }

    @Test func escapeAttributions_noAttributions() {
        let ct = CitationText(text: "")
        let (escaped, domains) = ct.escapeAttributions("Plain text with no citations")
        #expect(domains.isEmpty)
        #expect(escaped == "Plain text with no citations")
    }

    @Test func escapeAttributions_emptyDomainRejected() {
        let ct = CitationText(text: "")
        let (_, domains) = ct.escapeAttributions("Text (via ) more")
        #expect(domains.isEmpty)
    }

    @Test func escapeAttributions_longDomainRejected() {
        let ct = CitationText(text: "")
        let longDomain = String(repeating: "a", count: 101)
        let (_, domains) = ct.escapeAttributions("Text (via \(longDomain)) more")
        #expect(domains.isEmpty)
    }
}
