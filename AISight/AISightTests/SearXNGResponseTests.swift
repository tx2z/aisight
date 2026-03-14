import Testing
import Foundation
@testable import AISight

struct SearXNGResponseTests {

    @Test func decodesFullResponse() throws {
        let json = """
        {
            "query": "test query",
            "results": [
                {
                    "url": "https://example.com",
                    "title": "Example",
                    "content": "Some content",
                    "engine": "google",
                    "score": 1.5,
                    "engines": ["google", "bing"],
                    "positions": [1, 2],
                    "category": "general",
                    "publishedDate": "2025-01-01"
                }
            ],
            "number_of_results": 100,
            "answers": ["Direct answer"],
            "suggestions": ["suggestion1"],
            "infoboxes": [
                {
                    "infobox": "Test Title",
                    "content": "Infobox content"
                }
            ],
            "unresponsive_engines": [["engine1", "timeout"]]
        }
        """
        let response = try TestFixtures.decodeSearXNGResponse(from: json)
        #expect(response.query == "test query")
        #expect(response.results.count == 1)
        #expect(response.results[0].url == "https://example.com")
        #expect(response.results[0].engines == ["google", "bing"])
        #expect(response.numberOfResults == 100)
        #expect(response.answers == ["Direct answer"])
        #expect(response.suggestions == ["suggestion1"])
        #expect(response.infoboxes?.count == 1)
        #expect(response.infoboxes?[0].infobox == "Test Title")
    }

    @Test func decodesResponseWithNilOptionals() throws {
        let json = """
        {
            "results": [
                {
                    "url": "https://example.com",
                    "title": "Example"
                }
            ]
        }
        """
        let response = try TestFixtures.decodeSearXNGResponse(from: json)
        #expect(response.query == nil)
        #expect(response.results.count == 1)
        #expect(response.numberOfResults == nil)
        #expect(response.answers == nil)
        #expect(response.suggestions == nil)
        #expect(response.infoboxes == nil)
        #expect(response.unresponsiveEngines == nil)
    }

    @Test func decodesEmptyResultsArray() throws {
        let json = """
        {
            "results": []
        }
        """
        let response = try TestFixtures.decodeSearXNGResponse(from: json)
        #expect(response.results.isEmpty)
    }
}
