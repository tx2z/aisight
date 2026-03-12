import Foundation

enum SystemPrompt {
    static func build(
        query: String,
        sources: [(index: Int, title: String, snippet: String, url: String)],
        directAnswers: [String] = [],
        infoboxes: [SearXNGInfobox] = []
    ) -> String {
        guard !sources.isEmpty else {
            return """
            You are AISight — a private, on-device answer engine.

            The user asked: "\(query)"

            No search results were available for this query. Respond honestly by saying \
            you don't have enough information to answer this question accurately. \
            Suggest the user try rephrasing their query or checking their internet connection.
            """
        }

        var prompt = """
        You are AISight — a private, on-device answer engine. Your job is to provide \
        accurate, well-sourced answers based ONLY on the search results provided below.

        ## Rules
        - Answer concisely in 2-4 paragraphs.
        - Cite EVERY factual claim using inline references like [1], [2].
        - Synthesize information across sources into a coherent answer. Do NOT \
        summarize each source sequentially.
        - When sources conflict, present both viewpoints with their respective citations.
        - If the sources do not contain enough information to answer confidently, say \
        "I don't have enough information to answer this accurately" rather than guessing.
        - NEVER fabricate or hallucinate information beyond what the sources provide.
        - NEVER use prior knowledge — only the provided sources.
        - Write in clear, accessible language.
        """

        // Include direct answers from search engines (e.g. instant answers)
        if !directAnswers.isEmpty {
            prompt += "\n\n## Direct Answers (from search engines)"
            for answer in directAnswers {
                prompt += "\n- \(answer)"
            }
        }

        // Include infobox data (e.g. Wikipedia summaries)
        if !infoboxes.isEmpty {
            prompt += "\n\n## Knowledge Panel"
            for box in infoboxes {
                if let title = box.infobox {
                    prompt += "\n### \(title)"
                }
                if let content = box.content {
                    let truncated = content.count > 800 ? String(content.prefix(800)) + "…" : content
                    prompt += "\n\(truncated)"
                }
            }
        }

        prompt += "\n\n## Sources"

        for source in sources {
            prompt += """

            [\(source.index)] \(source.title)
            URL: \(source.url)
            Content: \(source.snippet)
            """
        }

        prompt += """


        ## User Query
        \(query)
        """

        return prompt
    }
}
