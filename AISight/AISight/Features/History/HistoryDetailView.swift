import SwiftUI

struct HistoryDetailView: View {
    let entry: QueryEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(entry.query)
                    .font(.title2.weight(.semibold))

                Text(entry.timestamp, format: .dateTime.month().day().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                CitationText(text: entry.answer)

                if !entry.sources.isEmpty {
                    Divider()

                    Text("Sources")
                        .font(.title2.weight(.semibold))

                    ForEach(Array(entry.sources.enumerated()), id: \.offset) { _, source in
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
                            )
                        )
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
}
