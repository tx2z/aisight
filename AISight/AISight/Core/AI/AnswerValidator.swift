import Foundation

enum AnswerValidator {

    /// Check what fraction of list items in the answer are grounded in source content.
    /// Returns 0.0 (nothing grounded) to 1.0 (everything grounded).
    /// Returns 1.0 if no list items are found (non-list answers skip the check).
    static func checkSourceGrounding(
        answer: String,
        sources: [(index: Int, title: String, snippet: String, url: String)]
    ) -> Double {
        let listItems = extractListItems(answer)
        guard !listItems.isEmpty else { return 1.0 }

        // Combine all source text into a single searchable string
        let sourceText = sources
            .map { "\($0.title) \($0.snippet)" }
            .joined(separator: " ")
            .lowercased()

        var groundedCount = 0
        for item in listItems {
            // Extract significant words (4+ chars to skip articles/prepositions)
            let words = item.lowercased()
                .components(separatedBy: .alphanumerics.inverted)
                .filter { $0.count >= 4 }
            guard !words.isEmpty else { continue }

            let matchCount = words.filter { sourceText.contains($0) }.count
            let overlapRatio = Double(matchCount) / Double(words.count)
            // Item is grounded if at least 40% of its significant words appear in sources
            if overlapRatio >= 0.4 { groundedCount += 1 }
        }

        return Double(groundedCount) / Double(listItems.count)
    }

    /// Extract list items from markdown-style text (numbered lists, bullets).
    static func extractListItems(_ text: String) -> [String] {
        text.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .compactMap { line -> String? in
                // Match: "1. ...", "- ...", "● ...", "• ...", "* ..."
                if let range = line.range(of: #"^(\d+[\.\)]\s*|[-●•\*]\s+)"#, options: .regularExpression) {
                    let content = String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    return content.isEmpty ? nil : content
                }
                return nil
            }
    }

    /// Detect if the model is looping (same line repeated 3+ times).
    /// Returns trimmed text (up to first repetition) if a loop is found, nil otherwise.
    static func detectAndTrimRepetition(_ text: String) -> String? {
        let lines = text.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
        guard lines.count >= 6 else { return nil }

        var counts: [String: Int] = [:]
        var firstOccurrence: [String: Int] = [:]
        for (index, line) in lines.enumerated() {
            // Skip very short lines (blank, bullets, etc.)
            guard line.count >= 15 else { continue }
            counts[line, default: 0] += 1
            if firstOccurrence[line] == nil { firstOccurrence[line] = index }
            if counts[line]! >= 3 {
                // Trim to just before the second occurrence of the repeated line
                let cutIndex = firstOccurrence[line]! + 1
                let trimmed = lines.prefix(cutIndex).joined(separator: "\n")
                return trimmed
            }
        }
        return nil
    }
}
