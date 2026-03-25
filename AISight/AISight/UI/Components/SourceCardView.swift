import SwiftUI

struct SourceCardView: View {
    let result: SearXNGResult
    var index: Int? = nil
    var isUsed: Bool = true

    @State private var isExpanded = false

    private var domain: String {
        URL(string: result.url).flatMap { $0.host() }?
            .replacing("www.", with: "") ?? result.url
    }

    var body: some View {
        if let url = URL(string: result.url) {
            Link(destination: url) {
                SourceCardContent(
                    result: result,
                    domain: domain,
                    index: index,
                    isExpanded: $isExpanded
                )
            }
            .buttonStyle(.plain)
        } else {
            SourceCardContent(
                result: result,
                domain: domain,
                index: index,
                isExpanded: $isExpanded
            )
        }
    }
}

private struct SourceCardContent: View {
    let result: SearXNGResult
    let domain: String
    var index: Int? = nil
    @Binding var isExpanded: Bool
    @State private var isTruncated = false
    @ScaledMetric(relativeTo: .caption) private var badgeSize: Double = 14

    private var domainInitial: String {
        String(domain.prefix(1)).uppercased()
    }

    private var domainColor: Color {
        let hash = abs(domain.hashValue)
        let colors: [Color] = [.blue, .purple, .orange, .pink, .teal, .indigo, .mint, .cyan]
        return colors[hash % colors.count]
    }

    var body: some View {
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
                        .font(.system(size: badgeSize * 0.64, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: badgeSize, height: badgeSize)
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
                    Button {
                        withAnimation(.spring(duration: 0.3)) { isExpanded.toggle() }
                    } label: {
                        HStack(alignment: .top, spacing: 4) {
                            Text(snippet)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(isExpanded ? nil : 2)
                                .background {
                                    Text(snippet)
                                        .font(.caption)
                                        .lineLimit(nil)
                                        .hidden()
                                        .onGeometryChange(for: CGFloat.self) { proxy in
                                            proxy.size.height
                                        } action: { fullHeight in
                                            // Caption font at 2 lines is ~32pt; if full height exceeds that, text is truncated
                                            isTruncated = fullHeight > 34
                                        }
                                }

                            if isTruncated || isExpanded {
                                Spacer(minLength: 0)

                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                    .animation(.spring(duration: 0.3), value: isExpanded)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(!isTruncated && !isExpanded)
                    .accessibilityLabel(isExpanded ? "Collapse snippet" : "Expand snippet")
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
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
