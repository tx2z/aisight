import Foundation
import FoundationModels
import NaturalLanguage

@available(iOS 26.0, macOS 26.0, *)
@MainActor
final class QueryReformulator {

    /// Number of keyword queries taken from the model, in addition to the original question.
    nonisolated static let keywordQueryCount = 2

    /// Builds the search query list for a conversational question: the original question first,
    /// followed by up to `keywordQueryCount` keyword queries from a fresh on-device session (never the cloud model).
    /// `languageCode` is the detected question language, nil when unknown. Short questions skip the model
    /// and any model error falls back to the question alone, both still getting the recency year.
    func reformulate(_ query: String, languageCode: String?) async -> [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let year = AppConfig.currentYear()

        // Very short queries are already keyword-like — no model call
        if Self.wordCount(trimmed) <= 3 {
            return Self.buildQueries(question: trimmed, modelOutput: "", year: year, languageCode: languageCode)
        }

        let instructions = Self.instructions(languageName: languageCode.flatMap(AppConfig.englishLanguageName(for:)))

        do {
            let session = LanguageModelProvider.makeOnDeviceSession(instructions: instructions)
            let response = try await session.respond(to: trimmed)
            return Self.buildQueries(question: trimmed, modelOutput: response.content, year: year, languageCode: languageCode)
        } catch {
            return Self.buildQueries(question: trimmed, modelOutput: "", year: year, languageCode: languageCode)
        }
    }

    // MARK: - Instructions

    nonisolated static func instructions(languageName: String?) -> String {
        let languageRules: String
        if let languageName {
            languageRules = """
            The question is in \(languageName). Write the queries in \(languageName), \
            in the same script, keeping all accents.
            """
        } else {
            languageRules = "Write the queries in the same language as the question, in the same script, keeping all accents."
        }
        return """
        Turn the user's question into \(keywordQueryCount) web search queries.
        \(languageRules)
        Never translate any word, even a word from another language.
        Each query is 2 to 6 keywords from the question, not a question.
        Keep every name, brand, acronym, number and year exactly as written.
        Do not add topics, names or dates the question does not mention.
        Write one query per line and nothing else.
        """
    }

    // MARK: - Word count

    nonisolated static func wordCount(_ text: String) -> Int {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var count = 0
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { _, _ in
            count += 1
            return true
        }
        return count
    }

    // MARK: - Output processing

    /// The original question followed by up to `keywordQueryCount` cleaned model lines. Lines repeating the
    /// question or each other, or containing a number the question lacks, are dropped before the cap.
    /// A recency question gets `year` appended to the first model line, or to the question itself when no line remains.
    nonisolated static func buildQueries(question: String, modelOutput: String, year: Int, languageCode: String? = nil) -> [String] {
        let trimmed = collapseWhitespace(question)

        let questionNumbers = standaloneNumbers(in: trimmed)
        var seen: Set<String> = [comparisonKey(trimmed)]
        var lines = modelOutput
            .split(whereSeparator: \.isNewline)
            .compactMap { cleanLine(String($0)) }
            .filter { standaloneNumbers(in: $0).isSubset(of: questionNumbers) }
            .filter { seen.insert(comparisonKey($0)).inserted }
        lines = Array(lines.prefix(keywordQueryCount))

        if needsCurrentYear(question: trimmed, languageCode: languageCode) {
            if lines.isEmpty {
                lines = ["\(withoutQuestionPunctuation(trimmed)) \(year)"]
            } else {
                lines[0] += " \(year)"
            }
        }

        return [trimmed] + lines
    }

    /// Form used to compare queries: folded case, accents and width, without punctuation, symbols or repeated spaces.
    private nonisolated static func comparisonKey(_ text: String) -> String {
        let folded = text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
        let kept = folded.unicodeScalars.filter {
            !CharacterSet.punctuationCharacters.contains($0) && !CharacterSet.symbols.contains($0)
        }
        return collapseWhitespace(String(String.UnicodeScalarView(kept)))
    }

    private nonisolated static let listMarkerPattern =
        #"^\s*(?:[0-9０-９]+(?:[.)](?![0-9０-９])\s+|[．、](?![0-9０-９])\s*)|[-*•]\s+|・\s*)"#
    private nonisolated static let quotePairs: [(Character, Character)] = [("\"", "\""), ("“", "”"), ("«", "»"), ("'", "'")]

    /// Cleans one model output line; nil when the line is unusable.
    nonisolated static func cleanLine(_ raw: String) -> String? {
        var line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        line = line.replacingOccurrences(of: listMarkerPattern, with: "", options: .regularExpression)
        line = line.replacingOccurrences(of: "**", with: "")
        line = line.trimmingCharacters(in: .whitespacesAndNewlines)

        if line.count >= 2, let first = line.first, let last = line.last,
           quotePairs.contains(where: { $0.0 == first && $0.1 == last }) {
            let inner = line.dropFirst().dropLast()
            if !inner.contains(first) && !inner.contains(last) {
                line = inner.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        guard !line.isEmpty, line.count < 200, !line.hasSuffix(":"), !line.hasSuffix("：") else {
            return nil
        }
        return collapseWhitespace(line)
    }

    /// Question without leading inverted marks and trailing question or exclamation marks.
    private nonisolated static func withoutQuestionPunctuation(_ text: String) -> String {
        var result = Substring(text)
        while let first = result.first, "¿¡".contains(first) { result.removeFirst() }
        while let last = result.last, "?？!！.".contains(last) { result.removeLast() }
        return collapseWhitespace(String(result))
    }

    // MARK: - Numbers

    /// ASCII digits for full-width digits.
    private nonisolated static func halfwidth(_ text: String) -> String {
        text.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? text
    }

    /// Numbers that stand alone in the text, with thousands separators removed. Numbers glued to letters
    /// or joined to them by a hyphen ("5G", "Web3", "COVID-19") are not included.
    nonisolated static func standaloneNumbers(in text: String) -> Set<String> {
        let ascii = halfwidth(text).replacingOccurrences(
            of: "(?<=[0-9])[,.\u{202F}\u{2009}\u{00A0}](?=[0-9]{3}(?![0-9]))", with: "", options: .regularExpression)
        let pattern = #"(?<![\p{L}\p{N}])(?<!\p{L}-)(?<![0-9][.,])[0-9]++(?:[.,][0-9]++)*+(?![\p{L}\p{N}])(?!-\p{L})"#
        var found: Set<String> = []
        var searchRange = ascii.startIndex..<ascii.endIndex
        while let range = ascii.range(of: pattern, options: .regularExpression, range: searchRange) {
            found.insert(String(ascii[range]))
            searchRange = range.upperBound..<ascii.endIndex
        }
        return found
    }

    private nonisolated static func containsYear(_ text: String) -> Bool {
        halfwidth(text).range(of: #"(?<![0-9])(19|20)[0-9]{2}(?![0-9])"#, options: .regularExpression) != nil
    }

    // MARK: - Recency

    /// Recency cues per language code of `AppConfig.supportedLanguages`.
    private nonisolated static let recencyCues: [String: [String]] = [
        "en": ["latest", "newest", "recent", "recently", "currently", "right now", "today",
               "this year", "this week", "this month"],
        "es": ["último", "última", "últimos", "últimas", "actual", "actuales", "actualmente",
               "reciente", "recientes", "hoy", "ahora", "este año"],
        "fr": ["dernier", "dernière", "derniers", "dernières", "actuel", "actuelle", "actuellement",
               "récent", "aujourd'hui", "cette année"],
        "de": ["neueste", "neuesten", "aktuell", "aktuelle", "aktuellen", "heute", "jetzt", "dieses jahr"],
        "it": ["ultimo", "ultima", "ultime", "ultimi", "attuale", "attualmente", "recente", "oggi", "quest'anno"],
        "pt": ["atual", "atuais", "atualmente", "recente", "recentes", "hoje", "agora", "este ano"],
        "ja": ["現在", "最近", "最新", "今年", "今日", "今週"],
        "zh": ["现在", "現在", "最近", "最新", "今年", "今天"],
        "ko": ["최신", "최근", "요즘", "올해", "오늘", "현재"]
    ]

    /// True when the question asks for recent information and does not name a year itself.
    /// Only the cues of `languageCode` are checked; all cues when it is nil.
    nonisolated static func needsCurrentYear(question: String, languageCode: String? = nil) -> Bool {
        guard !containsYear(question) else { return false }
        let cues = languageCode.flatMap { recencyCues[$0] } ?? Array(recencyCues.values.joined())
        let text = foldedForCues(question)
        return cues.contains { cue in
            let folded = foldedForCues(cue)
            let isLatinCue = folded.unicodeScalars.allSatisfy { $0.value < 0x250 }
            if !isLatinCue { return text.contains(folded) }
            let pattern = "(?<![\\p{L}\\p{N}])" + NSRegularExpression.escapedPattern(for: folded) + "(?![\\p{L}\\p{N}])"
            return text.range(of: pattern, options: .regularExpression) != nil
        }
    }

    private nonisolated static func foldedForCues(_ text: String) -> String {
        collapseWhitespace(
            text.replacingOccurrences(of: "’", with: "'")
                .folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
        )
    }

    private nonisolated static func collapseWhitespace(_ text: String) -> String {
        text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }
}
