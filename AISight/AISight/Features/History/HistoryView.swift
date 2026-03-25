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
                        HistoryRowView(entry: entry) {
                            selectedEntry = entry
                        }
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
        } message: {
            Text("This will permanently delete all saved queries and answers.")
        }
        .sheet(item: $selectedEntry) { entry in
            NavigationStack {
                HistoryDetailView(entry: entry)
            }
            .presentationDragIndicator(.visible)
        }
        .task {
            viewModel.loadEntries(modelContext: modelContext)
        }
    }

}

// MARK: - History Row

private struct HistoryRowView: View {
    let entry: QueryEntry
    let onTap: () -> Void

    private let strippedAnswer: String

    private var sourceCountLabel: String {
        let usedCount = entry.sources.count(where: \.wasUsed)
        let totalCount = entry.sources.count
        guard totalCount > 0 else { return "" }
        if usedCount < totalCount {
            return "\(usedCount) of \(totalCount) sources"
        }
        return "\(totalCount) sources"
    }

    init(entry: QueryEntry, onTap: @escaping () -> Void) {
        self.entry = entry
        self.onTap = onTap
        self.strippedAnswer = Self.stripMarkdown(entry.answer)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(entry.isDeepSearch ? Color.purple : .accent)
                    .frame(width: 3, height: 44)

                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.query)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(strippedAnswer)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        Text(entry.timestamp, format: .relative(presentation: .named))
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if entry.isDeepSearch {
                            Label("Deep", systemImage: "sparkle.magnifyingglass")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.purple)
                        }

                        Spacer()

                        Text(sourceCountLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
    }

    private static func stripMarkdown(_ text: String) -> String {
        var result = text
        result = result.replacing(/#{1,6}\s+/, with: "")
        result = result.replacing(/\*+/, with: "")
        result = result.replacing(/\(via [^)]+\)/, with: "")
        result = result.replacing(/\s+/, with: " ")
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(for: QueryEntry.self, inMemory: true)
}
