import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
@MainActor
final class QueryReformulator {

    /// Generates multiple optimized search queries from a conversational user question.
    /// Uses a fresh, lightweight on-device LLM session (no shared context).
    /// Returns 1-3 keyword-based queries for parallel search.
    func reformulate(_ query: String) async -> [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Very short queries are already keyword-like — use as-is
        if trimmed.split(separator: " ").count <= 3 {
            return [trimmed]
        }

        let dateString = Self.currentDateString()

        let instructions = """
        You are a search query optimizer. Given a user question, generate \
        exactly 3 different keyword-based web search queries that approach \
        the topic from different angles. Today is \(dateString).

        Rules:
        - Output exactly 3 queries, one per line
        - Use short keyword phrases, not full sentences
        - Each query should cover a different aspect of the question
        - CRITICAL: Keep all specific names, brands, and key terms from the \
        original question in every query. For example, if the user asks about \
        "Marvel superheroes", every query MUST include "Marvel"
        - Include the current year if the question is about recent/latest things
        - No numbering, no bullets, no explanations — just the queries
        """

        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(to: trimmed)
            let lines = response.content
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && $0.count < 200 }

            if !lines.isEmpty {
                return Array(lines.prefix(3))
            }
        } catch {
            // Fall back to original query on any error
        }

        return [trimmed]
    }

    static func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
