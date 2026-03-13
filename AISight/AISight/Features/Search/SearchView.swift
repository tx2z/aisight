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

private struct Suggestion: Identifiable {
    let id = UUID()
    let title: String
    let query: String
}

private let suggestions: [Suggestion] = [
    Suggestion(title: String(localized: "What is liquid glass?"), query: String(localized: "What is liquid glass in iOS 26?")),
    Suggestion(title: String(localized: "Why is the sky blue?"), query: String(localized: "Why is the sky blue?")),
    Suggestion(title: String(localized: "Best coffee brewing methods"), query: String(localized: "Best coffee brewing methods compared")),
    Suggestion(title: String(localized: "How do black holes form?"), query: String(localized: "How do black holes form?")),
    Suggestion(title: String(localized: "Swift concurrency patterns"), query: String(localized: "Best Swift concurrency patterns")),
    Suggestion(title: String(localized: "History of the Internet"), query: String(localized: "History of the Internet")),
    Suggestion(title: String(localized: "How does mRNA work?"), query: String(localized: "How do mRNA vaccines work?")),
    Suggestion(title: String(localized: "Tips for better sleep"), query: String(localized: "Science-backed tips for better sleep")),
    Suggestion(title: String(localized: "How do planes fly?"), query: String(localized: "How do airplanes generate lift?")),
    Suggestion(title: String(localized: "Best hiking trails in Europe"), query: String(localized: "Best hiking trails in Europe")),
    Suggestion(title: String(localized: "What causes northern lights?"), query: String(localized: "What causes the aurora borealis?")),
    Suggestion(title: String(localized: "Beginner guitar chords"), query: String(localized: "Essential beginner guitar chords")),
    Suggestion(title: String(localized: "How does Wi-Fi work?"), query: String(localized: "How does Wi-Fi technology work?")),
    Suggestion(title: String(localized: "Mediterranean diet basics"), query: String(localized: "Mediterranean diet basics and benefits")),
    Suggestion(title: String(localized: "Mars colonization challenges"), query: String(localized: "Challenges of colonizing Mars")),
    Suggestion(title: String(localized: "How to start journaling"), query: String(localized: "How to start a journaling habit")),
    Suggestion(title: String(localized: "What is quantum computing?"), query: String(localized: "What is quantum computing explained simply?")),
    Suggestion(title: String(localized: "Best stretches for desk workers"), query: String(localized: "Best stretches for people who sit all day")),
    Suggestion(title: String(localized: "How do tides work?"), query: String(localized: "How do ocean tides work?")),
    Suggestion(title: String(localized: "Stoic philosophy basics"), query: String(localized: "Introduction to Stoic philosophy")),
    Suggestion(title: String(localized: "How does GPS work?"), query: String(localized: "How does GPS satellite navigation work?")),
    Suggestion(title: String(localized: "Benefits of reading daily"), query: String(localized: "Science-backed benefits of reading every day")),
    Suggestion(title: String(localized: "How do volcanoes erupt?"), query: String(localized: "How and why do volcanoes erupt?")),
    Suggestion(title: String(localized: "Best productivity methods"), query: String(localized: "Most effective productivity methods compared")),
]

@available(iOS 26.0, macOS 26.0, *)
private struct SearchContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var viewModel = SearchViewModel()
    @State private var isDeepSearchEnabled: Bool = false
    @State private var currentPairIndex: Int = 0
    @FocusState private var isInputFocused: Bool

    private var currentSuggestions: [Suggestion] {
        let startIndex = (currentPairIndex * 2) % suggestions.count
        return [suggestions[startIndex], suggestions[(startIndex + 1) % suggestions.count]]
    }

    private var hasResults: Bool {
        !viewModel.streamingText.isEmpty || viewModel.isGenerating || viewModel.isSearching || !viewModel.queryGroups.isEmpty || viewModel.errorMessage != nil
    }

    var body: some View {
        Group {
            if hasResults {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(viewModel.query)
                                .font(.body.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 16, style: .continuous))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

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
        .navigationTitle(hasResults ? "AISight" : "")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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
                ForEach(currentSuggestions) { suggestion in
                    SuggestionChip(suggestion.title) {
                        viewModel.query = suggestion.query
                        viewModel.performSearch(modelContext: modelContext)
                    }
                    .id(suggestion.id)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .move(edge: .top)).combined(with: .scale(scale: 0.95))
                    ))
                }
            }
            .padding(.top, 8)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .onAppear {
            currentPairIndex = Int.random(in: 0..<suggestions.count / 2)
        }
        .task(id: hasResults) {
            guard !hasResults else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(6))
                withAnimation(.spring(duration: 0.45, bounce: 0.15)) {
                    currentPairIndex = (currentPairIndex + 1) % (suggestions.count / 2)
                }
            }
        }
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
            if isDeepSearchEnabled {
                Text("Deep Search uses multiple AI research passes to find better answers. " +
                     "This takes longer (15-25 seconds vs 5-10 seconds) and uses more " +
                     "on-device processing. Best for complex questions that need thorough research.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

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

            HStack(alignment: .bottom, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    if viewModel.query.isEmpty {
                        Text("Ask anything...")
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    TextEditor(text: $viewModel.query)
                        .focused($isInputFocused)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 36, maxHeight: 120)
                        .fixedSize(horizontal: false, vertical: true)
                        .onChange(of: viewModel.query) { _, newValue in
                            if newValue.count > 500 {
                                viewModel.query = String(newValue.prefix(500))
                            }
                        }
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
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.regularMaterial, in: .rect(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
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
