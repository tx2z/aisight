import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    var body: some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            SearchContentView()
                .environment(appState)
        } else {
            ContentUnavailableView(
                "Apple Intelligence Required",
                systemImage: "apple.intelligence",
                description: Text("AISight requires Apple Intelligence. Enable it in Settings \u{2192} Apple Intelligence & Siri.")
            )
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
private struct SearchContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var viewModel = SearchViewModel()
    @State private var isDeepSearchEnabled: Bool = false
    @FocusState private var isInputFocused: Bool

    private var hasResults: Bool {
        !viewModel.streamingText.isEmpty || viewModel.isGenerating || !viewModel.queryGroups.isEmpty || viewModel.errorMessage != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let error = viewModel.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.orange.opacity(0.1), in: .rect(cornerRadius: 10))
                }

                if viewModel.isGenerating && viewModel.streamingText.isEmpty {
                    ProgressView(viewModel.searchStepDescription ?? "Thinking...")
                        .frame(maxWidth: .infinity)
                        .containerRelativeFrame(.vertical) { height, _ in
                            height * 0.6
                        }
                } else if !viewModel.streamingText.isEmpty || viewModel.isGenerating {
                    StreamingAnswerView(
                        streamingText: viewModel.streamingText,
                        isGenerating: viewModel.isGenerating
                    )
                }

                if !viewModel.queryGroups.isEmpty {
                    ForEach(viewModel.queryGroups) { group in
                        Section {
                            ForEach(group.results) { result in
                                SourceCardView(result: result)
                            }
                        } header: {
                            Label(group.query, systemImage: "magnifyingglass")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if !viewModel.streamingText.isEmpty && !viewModel.isGenerating {
                    Label("Generated on-device by Apple Intelligence", systemImage: "apple.intelligence")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
            }
            .padding()
        }
        .navigationTitle("AISight")
        .toolbar {
            if hasResults {
                ToolbarItem(placement: .automatic) {
                    Button {
                        viewModel.resetSearch()
                    } label: {
                        Label("New Search", systemImage: "square.and.pencil")
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !hasResults {
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        TextField("Ask anything...", text: $viewModel.query)
                            .textFieldStyle(.plain)
                            .focused($isInputFocused)
                            .onSubmit {
                                viewModel.performSearch(modelContext: modelContext)
                            }

                        Button {
                            viewModel.performSearch(modelContext: modelContext)
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        ? .gray : .accent
                                )
                        }
                        .disabled(viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: .capsule)

                    Toggle(isOn: $isDeepSearchEnabled) {
                        Label("Deep Search", systemImage: "sparkle.magnifyingglass")
                            .font(.subheadline)
                    }
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                    .onChange(of: isDeepSearchEnabled) {
                        viewModel.isDeepSearch = isDeepSearchEnabled
                    }
                    .padding(.horizontal, 20)

                    if isDeepSearchEnabled {
                        Text("Deep Search uses multiple AI research passes to find better answers. " +
                             "This takes longer (15-25 seconds vs 5-10 seconds) and uses more " +
                             "on-device processing. Best for complex questions that need thorough research.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
    }

}

#Preview {
    NavigationStack {
        SearchView()
    }
    .environment(AppState())
    .modelContainer(for: QueryEntry.self, inMemory: true)
}
