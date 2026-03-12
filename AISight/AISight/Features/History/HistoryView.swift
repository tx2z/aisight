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
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.query)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)

                                Text(entry.answer)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)

                                HStack {
                                    Text(entry.timestamp, style: .relative)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text("ago")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Text("\(entry.sources.count) source\(entry.sources.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
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
        }
        .onAppear {
            viewModel.loadEntries(modelContext: modelContext)
        }
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

                    ForEach(Array(entry.sources.enumerated()), id: \.offset) { index, source in
                        HStack(alignment: .top, spacing: 8) {
                            CitationBadge(number: index + 1)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(source.title)
                                    .font(.headline)
                                    .lineLimit(2)

                                if let url = URL(string: source.url) {
                                    Link(destination: url) {
                                        Text(source.url)
                                            .font(.caption)
                                            .foregroundStyle(.accent)
                                            .lineLimit(1)
                                    }
                                }

                                if let engine = source.engine {
                                    Text("via \(engine.capitalized)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
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
