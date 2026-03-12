import SwiftUI

struct CitationText: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(parseBlocks(text).enumerated()), id: \.offset) { _, block in
                renderBlock(block)
            }
        }
        .textSelection(.enabled)
    }

    // MARK: - Block Types

    private enum Block {
        case heading(Int, String)      // level, content
        case listItem(String, Int?)    // content, ordered number (nil = unordered)
        case paragraph(String)
        case codeBlock(String)
    }

    // MARK: - Block Parsing

    private func parseBlocks(_ text: String) -> [Block] {
        var blocks: [Block] = []
        let lines = text.components(separatedBy: "\n")
        var i = 0
        var paragraphLines: [String] = []

        func flushParagraph() {
            let content = paragraphLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                blocks.append(.paragraph(content))
            }
            paragraphLines = []
        }

        while i < lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Code block (```)
            if trimmed.hasPrefix("```") {
                flushParagraph()
                var codeLines: [String] = []
                i += 1
                while i < lines.count {
                    let codeLine = lines[i]
                    if codeLine.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                        i += 1
                        break
                    }
                    codeLines.append(codeLine)
                    i += 1
                }
                let code = codeLines.joined(separator: "\n")
                if !code.isEmpty {
                    blocks.append(.codeBlock(code))
                }
                continue
            }

            // Heading (## ...)
            if trimmed.hasPrefix("#") {
                flushParagraph()
                var level = 0
                var idx = trimmed.startIndex
                while idx < trimmed.endIndex && trimmed[idx] == "#" && level < 6 {
                    level += 1
                    idx = trimmed.index(after: idx)
                }
                if idx < trimmed.endIndex && trimmed[idx] == " " {
                    let content = String(trimmed[trimmed.index(after: idx)...])
                    blocks.append(.heading(level, content))
                    i += 1
                    continue
                }
            }

            // Unordered list item (- or * )
            if (trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ")) && trimmed.count > 2 {
                flushParagraph()
                let content = String(trimmed.dropFirst(2))
                blocks.append(.listItem(content, nil))
                i += 1
                continue
            }

            // Ordered list item (1. 2. etc.)
            if let dotIndex = trimmed.firstIndex(of: "."),
               dotIndex > trimmed.startIndex,
               let num = Int(trimmed[trimmed.startIndex..<dotIndex]),
               trimmed.index(after: dotIndex) < trimmed.endIndex,
               trimmed[trimmed.index(after: dotIndex)] == " " {
                flushParagraph()
                let content = String(trimmed[trimmed.index(dotIndex, offsetBy: 2)...])
                blocks.append(.listItem(content, num))
                i += 1
                continue
            }

            // Empty line = paragraph break
            if trimmed.isEmpty {
                flushParagraph()
                i += 1
                continue
            }

            // Regular text line — accumulate into paragraph
            paragraphLines.append(line)
            i += 1
        }

        flushParagraph()
        return blocks
    }

    // MARK: - Block Rendering

    @ViewBuilder
    private func renderBlock(_ block: Block) -> some View {
        switch block {
        case .heading(let level, let text):
            renderInline(text)
                .font(fontForHeading(level))
                .fontWeight(.bold)
                .padding(.top, level <= 2 ? 4 : 2)

        case .listItem(let text, let ordered):
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                if let num = ordered {
                    Text("\(num).")
                        .foregroundStyle(.secondary)
                } else {
                    Text("•")
                        .foregroundStyle(.secondary)
                }
                renderInline(text)
            }
            .padding(.leading, 4)

        case .paragraph(let text):
            renderInline(text)

        case .codeBlock(let code):
            Text(code)
                .font(.system(.callout, design: .monospaced))
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary, in: .rect(cornerRadius: 8))
        }
    }

    private func fontForHeading(_ level: Int) -> Font {
        switch level {
        case 1: return .title
        case 2: return .title2
        case 3: return .title3
        default: return .headline
        }
    }

    // MARK: - Inline Rendering (Markdown + Source Attribution)

    private func renderInline(_ text: String) -> Text {
        let (escaped, domains) = escapeAttributions(text)

        var attributed: AttributedString
        if let parsed = try? AttributedString(
            markdown: escaped
        ) {
            attributed = parsed
        } else {
            attributed = AttributedString(escaped)
        }

        // Replace attribution placeholders with styled badges
        for domain in domains {
            let placeholder = "\(attrPrefix)\(domain)\(attrSuffix)"
            while let range = attributed.range(of: placeholder) {
                var badge = AttributedString(" via \(domain) ")
                badge.foregroundColor = .secondary
                badge.font = .caption2
                attributed.replaceSubrange(range, with: badge)
            }
        }

        return Text(attributed)
    }

    // MARK: - Attribution Escaping

    private let attrPrefix = "\u{FFFC}V"
    private let attrSuffix = "\u{FFFC}"

    /// Escape `(via domain.com)` patterns into placeholders before markdown parsing.
    private func escapeAttributions(_ text: String) -> (String, [String]) {
        var result = ""
        var domains: [String] = []
        var currentIndex = text.startIndex

        while currentIndex < text.endIndex {
            // Match (via domain.com) pattern
            if text[currentIndex] == "(" {
                let remaining = text[currentIndex...]
                if remaining.hasPrefix("(via ") {
                    // Find the closing paren
                    if let closeIdx = remaining.firstIndex(of: ")") {
                        let viaStart = text.index(currentIndex, offsetBy: 5) // skip "(via "
                        let domain = String(text[viaStart..<closeIdx])
                            .trimmingCharacters(in: .whitespaces)
                        if !domain.isEmpty && domain.count < 100 {
                            domains.append(domain)
                            result += "\(attrPrefix)\(domain)\(attrSuffix)"
                            currentIndex = text.index(after: closeIdx)
                            continue
                        }
                    }
                }
            }

            result.append(text[currentIndex])
            currentIndex = text.index(after: currentIndex)
        }

        return (result, domains)
    }
}

#Preview {
    ScrollView {
        CitationText(text: """
        ## Spanish Soccer Matches Today
        **Yes**, there are several soccer matches in Spain today.

        ### Major Matches
        - **Mallorca vs. Espanyol** kicks off at 13:00 (via marca.com)
        - **Barcelona vs. Sevilla** at 15:15 (via espn.com)
        - **Real Betis vs. Celta Vigo** at 17:00 (via bbc.co.uk)

        ### Code Example
        ```
        let score = getScore()
        print(score)
        ```

        There are also **several other matches** across the country (via marca.com).
        """)
        .padding()
    }
}
