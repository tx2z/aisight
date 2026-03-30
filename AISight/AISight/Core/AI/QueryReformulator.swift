import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
@MainActor
final class QueryReformulator {

    /// Generates multiple optimized search queries from a conversational user question.
    /// Uses a fresh, lightweight on-device LLM session (no shared context).
    /// Returns 1-3 keyword-based queries for parallel search.
    func reformulate(_ query: String, language: String = "en") async -> [String] {
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
        - CRITICAL: Preserve all specific names, brands, qualifiers, and key terms \
        from the original question. Do not drop or replace them. If the user mentions a \
        specific name, sub-topic, or qualifier (e.g. "witches saga" not just "Discworld"), \
        include it in every query to maintain specificity
        - Include the current year if the question is about recent/latest things
        - No numbering, no bullets, no explanations — just the queries
        - IMPORTANT: Generate all queries in the same language as the user's question. \
        Never translate queries into a different language.
        """

        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(to: trimmed)
            let lines = response.content
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map(String.init)
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
        Date.now.formatted(.iso8601.year().month().day().dateSeparator(.dash))
    }
}
