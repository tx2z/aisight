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
        !viewModel.streamingText.isEmpty || viewModel.isGenerating || viewModel.isSearching || !viewModel.queryGroups.isEmpty || viewModel.errorMessage != nil
    }

    var body: some View {
        Group {
            if hasResults {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let error = viewModel.errorMessage {
                            Label(error, systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.orange.opacity(0.1), in: .rect(cornerRadius: 10))
                        }

                        if (viewModel.isSearching || viewModel.isGenerating) && viewModel.streamingText.isEmpty {
                            loadingState
                        } else if !viewModel.streamingText.isEmpty || viewModel.isGenerating {
                            StreamingAnswerView(
                                streamingText: viewModel.streamingText,
                                isGenerating: viewModel.isGenerating
                            )
                            .animation(.easeIn(duration: 0.2), value: viewModel.streamingText.isEmpty)
                        }

                        if !viewModel.queryGroups.isEmpty {
                            ForEach(viewModel.queryGroups) { group in
                                Section {
                                    ForEach(group.results) { result in
                                        SourceCardView(result: result)
                                            .transition(.asymmetric(
                                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                                removal: .opacity
                                            ))
                                    }
                                } header: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                        Text(group.query)
                                            .font(.footnote)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                            }
                        }

                        if !viewModel.streamingText.isEmpty && !viewModel.isGenerating {
                            HStack(spacing: 4) {
                                Image(systemName: "apple.intelligence")
                                    .font(.caption2)
                                    .symbolEffect(.appear)
                                Text("Generated on-device")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                        }
                    }
                    .padding()
                }
            } else {
                emptyState
            }
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
                searchBarSection
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "apple.intelligence")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .symbolEffect(.breathe.pulse.byLayer)

            Text("AISight")
                .font(.title.weight(.semibold))
                .fixedSize()

            VStack(spacing: 4) {
                Text("Search the web.")
                Text("Get answers on-device.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Image(systemName: "apple.intelligence")
                    .font(.caption2)
                Text("Powered by Apple Intelligence")
                    .font(.caption2)
            }
            .foregroundStyle(.tertiary)

            VStack(spacing: 10) {
                SuggestionChip("What is liquid glass?") {
                    viewModel.query = "What is liquid glass?"
                    viewModel.performSearch(modelContext: modelContext)
                }
                SuggestionChip("Swift concurrency patterns") {
                    viewModel.query = "Best Swift concurrency patterns"
                    viewModel.performSearch(modelContext: modelContext)
                }
            }
            .padding(.top, 8)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 12) {
            Image(systemName: "apple.intelligence")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
                .symbolEffect(.breathe.pulse.byLayer)

            if let step = viewModel.searchStepDescription {
                Text(step)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: step)
            } else {
                Text("Thinking...")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical) { height, _ in
            height * 0.5
        }
    }

    // MARK: - Search Bar

    private var searchBarSection: some View {
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
                        .symbolEffect(.bounce, value: !viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .disabled(viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: .capsule)
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .padding(.bottom, 4)

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    isDeepSearchEnabled.toggle()
                    viewModel.isDeepSearch = isDeepSearchEnabled
                }
            } label: {
                Label("Deep Search", systemImage: "sparkle.magnifyingglass")
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        isDeepSearchEnabled ? AnyShapeStyle(.accent.opacity(0.15)) : AnyShapeStyle(.regularMaterial),
                        in: .capsule
                    )
                    .foregroundStyle(isDeepSearchEnabled ? .accent : .secondary)
            }
            .buttonStyle(.plain)

            if isDeepSearchEnabled {
                Text("Deep Search uses multiple AI research passes to find better answers. " +
                     "This takes longer (15-25 seconds vs 5-10 seconds) and uses more " +
                     "on-device processing. Best for complex questions that need thorough research.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Suggestion Chip

private struct SuggestionChip: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.regularMaterial, in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .environment(AppState())
    .modelContainer(for: QueryEntry.self, inMemory: true)
}
