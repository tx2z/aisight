import SwiftUI

struct HistoryDetailView: View {
    let entry: QueryEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(entry.query)
                    .font(.title2.weight(.semibold))

                HStack(spacing: 6) {
                    Text(entry.timestamp, format: .dateTime.month().day().year().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if entry.isDeepSearch {
                        Label("Deep Search", systemImage: "sparkle.magnifyingglass")
                            .font(.caption)
                            .foregroundStyle(.purple)
                    }
                }

                Divider()

                CitationText(text: entry.answer)

                Button("Copy Answer", systemImage: "doc.on.doc", action: copyAnswer)
                    .font(.caption)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)

                if !entry.sources.isEmpty {
                    Divider()

                    let usedSources = entry.sources.filter(\.wasUsed)
                    let unusedSources = entry.sources.filter { !$0.wasUsed }

                    if !usedSources.isEmpty {
                        Text("Sources")
                            .font(.title2.weight(.semibold))

                        ForEach(usedSources.enumerated(), id: \.offset) { index, source in
                            SourceCardView(
                                result: SearXNGResult(
                                    url: source.url,
                                    title: source.title,
                                    content: nil,
                                    engine: source.engine,
                                    score: nil,
                                    engines: nil,
                                    positions: nil,
                                    category: nil,
                                    publishedDate: nil
                                ),
                                index: index + 1
                            )
                        }
                    }

                    if !unusedSources.isEmpty {
                        MoreResultsSection(sources: unusedSources)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private func copyAnswer() {
        #if os(iOS)
        UIPasteboard.general.string = entry.answer
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(entry.answer, forType: .string)
        #endif
    }
}

private struct MoreResultsSection: View {
    let sources: [SourceInfo]
    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) { isExpanded.toggle() }
        } label: {
            HStack {
                Label("\(sources.count) more results", systemImage: isExpanded ? "minus.circle" : "plus.circle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .buttonStyle(.plain)

        if isExpanded {
            ForEach(sources.enumerated(), id: \.offset) { _, source in
                SourceCardView(
                    result: SearXNGResult(
                        url: source.url,
                        title: source.title,
                        content: nil,
                        engine: source.engine,
                        score: nil,
                        engines: nil,
                        positions: nil,
                        category: nil,
                        publishedDate: nil
                    ),
                    isUsed: false
                )
            }
        }
    }
}
