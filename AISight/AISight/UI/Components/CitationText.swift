import SwiftUI

struct CitationText: View {
    let text: String

    var body: some View {
        Text(parseCitations(text))
            .textSelection(.enabled)
    }

    private func parseCitations(_ text: String) -> AttributedString {
        var result = AttributedString()
        var currentIndex = text.startIndex

        while currentIndex < text.endIndex {
            if text[currentIndex] == "[" {
                let afterBracket = text.index(after: currentIndex)
                if afterBracket < text.endIndex {
                    var numEnd = afterBracket
                    while numEnd < text.endIndex && text[numEnd].isNumber {
                        numEnd = text.index(after: numEnd)
                    }
                    if numEnd < text.endIndex && text[numEnd] == "]" && numEnd > afterBracket {
                        let numberString = String(text[afterBracket..<numEnd])
                        if let _ = Int(numberString) {
                            var citation = AttributedString(" [\(numberString)] ")
                            citation.foregroundColor = .white
                            citation.backgroundColor = .blue
                            citation.font = .caption2.bold()
                            result.append(citation)
                            currentIndex = text.index(after: numEnd)
                            continue
                        }
                    }
                }
            }

            var charStr = AttributedString(String(text[currentIndex]))
            charStr.font = .body
            result.append(charStr)
            currentIndex = text.index(after: currentIndex)
        }

        return result
    }
}

#Preview {
    CitationText(text: "Swift is a programming language [1]. It was introduced in 2014 [2].")
        .padding()
}
