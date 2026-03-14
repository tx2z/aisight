import Foundation
@testable import AISight

enum TestFixtures {
    static func makeResult(
        url: String = "https://example.com/article",
        title: String = "Test Article",
        content: String? = "This is a test snippet with enough content to pass the minimum length filter easily.",
        engine: String? = "google",
        score: Double? = 1.0,
        engines: [String]? = nil,
        positions: [Int]? = nil,
        category: String? = nil,
        publishedDate: String? = nil
    ) -> SearXNGResult {
        SearXNGResult(
            url: url,
            title: title,
            content: content,
            engine: engine,
            score: score,
            engines: engines,
            positions: positions,
            category: category,
            publishedDate: publishedDate
        )
    }

    static func makeInfobox(
        title: String? = "Test Infobox",
        content: String? = "Infobox content here."
    ) -> SearXNGInfobox {
        SearXNGInfobox(infobox: title, content: content, urls: nil)
    }

    static func decodeSearXNGResponse(from json: String) throws -> SearXNGResponse {
        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(SearXNGResponse.self, from: data)
    }
}
