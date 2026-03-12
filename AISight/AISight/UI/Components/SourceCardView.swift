import SwiftUI

struct SourceCardView: View {
    let result: SearXNGResult
    let index: Int

    @State private var isExpanded = false

    private var domain: String {
        URL(string: result.url).flatMap { $0.host() }?
            .replacingOccurrences(of: "www.", with: "") ?? result.url
    }

    var body: some View {
        if let url = URL(string: result.url) {
            Link(destination: url) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?sz=32&domain=\(domain)")) { image in
                    image.resizable().frame(width: 16, height: 16)
                } placeholder: {
                    Image(systemName: "globe")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(domain)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                CitationBadge(number: index + 1)
            }

            Text(result.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)

            if let engine = result.engine {
                Text("via \(engine.capitalized)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.fill, in: .capsule)
            }

            if let snippet = result.content, !snippet.isEmpty {
                Text(snippet)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(isExpanded ? nil : 2)
                    .onTapGesture {
                        withAnimation { isExpanded.toggle() }
                    }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
    }
}

#Preview {
    SourceCardView(
        result: SearXNGResult(
            url: "https://www.example.com/article/some-long-path",
            title: "Example Article Title That Might Be Long",
            content: "This is a snippet of the search result content that gives a preview of what the page contains.",
            engine: "google",
            score: 1.5,
            engines: ["google"],
            positions: [1],
            category: "general",
            publishedDate: nil
        ),
        index: 0
    )
    .padding()
}
