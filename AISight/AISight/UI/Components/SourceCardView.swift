import SwiftUI

struct SourceCardView: View {
    let result: SearXNGResult
    var index: Int? = nil

    @State private var isExpanded = false

    private var domain: String {
        URL(string: result.url).flatMap { $0.host() }?
            .replacingOccurrences(of: "www.", with: "") ?? result.url
    }

    private var domainInitial: String {
        String(domain.prefix(1)).uppercased()
    }

    private var domainColor: Color {
        let hash = abs(domain.hashValue)
        let colors: [Color] = [.blue, .purple, .orange, .pink, .teal, .indigo, .mint, .cyan]
        return colors[hash % colors.count]
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
        HStack(alignment: .top, spacing: 10) {
            // Favicon with index overlay
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: "https://\(domain)/favicon.ico")) { image in
                    image.resizable()
                        .frame(width: 28, height: 28)
                        .clipShape(.rect(cornerRadius: 6))
                } placeholder: {
                    Text(domainInitial)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(domainColor, in: .rect(cornerRadius: 6))
                }

                if let index {
                    Text("\(index)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 14, height: 14)
                        .background(.accent, in: .circle)
                        .offset(x: 4, y: 4)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(domain)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(result.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if let snippet = result.content, !snippet.isEmpty {
                    HStack(alignment: .top, spacing: 4) {
                        Text(snippet)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(isExpanded ? nil : 2)

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.spring(duration: 0.3), value: isExpanded)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.3)) { isExpanded.toggle() }
                    }
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.6)
                .scaleEffect(phase.isIdentity ? 1 : 0.97)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
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
                index: 1
            )

            SourceCardView(
                result: SearXNGResult(
                    url: "https://developer.apple.com/swift",
                    title: "Swift Programming Language",
                    content: "Swift is a powerful and intuitive programming language for all Apple platforms.",
                    engine: "brave",
                    score: 1.2,
                    engines: ["brave"],
                    positions: [2],
                    category: "general",
                    publishedDate: nil
                ),
                index: 2
            )
        }
        .padding()
    }
}
