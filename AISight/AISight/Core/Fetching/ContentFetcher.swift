import Foundation

actor ContentFetcher {
    private let urlSession: URLSession
    private let snippetThreshold: Int
    private let maxSnippetLength: Int

    init(timeout: TimeInterval = 10, snippetThreshold: Int = 150, maxSnippetLength: Int = 1600) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        self.urlSession = URLSession(configuration: configuration)
        self.snippetThreshold = snippetThreshold
        self.maxSnippetLength = maxSnippetLength
    }

    func fetchContent(from url: String) async throws -> String {
        guard let requestURL = URL(string: url) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await urlSession.data(from: requestURL)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let html = String(data: data, encoding: .utf8)
                ?? String(data: data, encoding: .ascii) else {
            throw URLError(.cannotDecodeContentData)
        }

        let cleaned = stripHTML(html)
        return truncate(cleaned, to: maxSnippetLength)
    }

    func shouldFetchFullContent(snippet: String) -> Bool {
        return snippet.count < snippetThreshold
    }

    // MARK: - HTML Stripping

    private func stripHTML(_ html: String) -> String {
        var text = html

        // Remove script tags and their content
        text = removeTagBlock(from: text, tag: "script")
        // Remove style tags and their content
        text = removeTagBlock(from: text, tag: "style")
        // Remove nav tags and their content
        text = removeTagBlock(from: text, tag: "nav")
        // Remove header tags and their content
        text = removeTagBlock(from: text, tag: "header")
        // Remove footer tags and their content
        text = removeTagBlock(from: text, tag: "footer")

        // Remove all remaining HTML tags
        text = text.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )

        // Decode common HTML entities
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&#39;", with: "'")
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")

        // Collapse whitespace
        text = text.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func removeTagBlock(from text: String, tag: String) -> String {
        return text.replacingOccurrences(
            of: "<\(tag)[^>]*>[\\s\\S]*?</\(tag)>",
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
    }

    private func truncate(_ text: String, to maxLength: Int) -> String {
        guard text.count > maxLength else { return text }
        return String(text.prefix(maxLength))
    }
}
