import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = HistoryViewModel()
    @State private var selectedEntry: QueryEntry?
    @State private var showClearConfirmation = false

    var body: some View {
        Group {
            if viewModel.entries.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Your search history will appear here after you ask your first question.")
                )
            } else {
                List {
                    ForEach(viewModel.entries) { entry in
                        Button {
                            selectedEntry = entry
                        } label: {
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.accent)
                                    .frame(width: 3, height: 44)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(entry.query)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)

                                    Text(strippedMarkdown(entry.answer))
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)

                                    HStack {
                                        Text(entry.timestamp, format: .relative(presentation: .named))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)

                                        Spacer()

                                        Text("\(entry.sources.count) source\(entry.sources.count == 1 ? "" : "s")")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteEntry(entry, modelContext: modelContext)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #endif
            }
        }
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if !viewModel.entries.isEmpty {
                    Button("Clear All", role: .destructive) {
                        showClearConfirmation = true
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .confirmationDialog("Clear All History?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("Clear All", role: .destructive) {
                viewModel.clearAll(modelContext: modelContext)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all saved queries and answers.")
        }
        .sheet(item: $selectedEntry) { entry in
            NavigationStack {
                HistoryDetailView(entry: entry)
            }
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.loadEntries(modelContext: modelContext)
        }
    }

    /// Strip markdown syntax for plain-text preview in the list.
    private func strippedMarkdown(_ text: String) -> String {
        var result = text
        // Remove headings
        result = result.replacingOccurrences(of: "#{1,6}\\s+", with: "", options: .regularExpression)
        // Remove bold/italic markers
        result = result.replacingOccurrences(of: "\\*+", with: "", options: .regularExpression)
        // Remove (via domain) attributions
        result = result.replacingOccurrences(of: "\\(via [^)]+\\)", with: "", options: .regularExpression)
        // Collapse whitespace
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct HistoryDetailView: View {
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

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(for: QueryEntry.self, inMemory: true)
}
