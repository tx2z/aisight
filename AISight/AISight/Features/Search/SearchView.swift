import SwiftUI
import SwiftData
import StoreKit

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    var body: some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            SearchContentView()
        } else {
            ContentUnavailableView(
                "Apple Intelligence Required",
                systemImage: "apple.intelligence",
                description: Text("AISight requires Apple Intelligence. Enable it in Settings \u{2192} Apple Intelligence & Siri.")
            )
        }
    }
}

struct Suggestion: Identifiable {
    let id = UUID()
    let title: String
    let query: String
}

let searchSuggestions: [Suggestion] = [
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
    #if !SETAPP
    @Environment(\.requestReview) private var requestReview
    #endif
    @Environment(AppState.self) private var appState
    @Environment(StoreManager.self) private var storeManager

    @State private var viewModel = SearchViewModel()
    @State private var isDeepSearchEnabled: Bool = false
    @State private var currentPairIndex: Int = 0
    @State private var showPaywall = false
    @State private var paywallReason: PaywallReason = .dailyLimitReached
    @FocusState private var isInputFocused: Bool

    private var currentSuggestions: [Suggestion] {
        let all = AISight.searchSuggestions
        let startIndex = (currentPairIndex * 2) % all.count
        return [all[startIndex], all[(startIndex + 1) % all.count]]
    }

    private var trimmedQuery: String {
        viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasResults: Bool {
        !viewModel.streamingText.isEmpty || viewModel.isGenerating || viewModel.isSearching || !viewModel.queryGroups.isEmpty || viewModel.errorMessage != nil
    }

    var body: some View {
        Group {
            if hasResults {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !trimmedQuery.isEmpty {
                            HStack {
                                Spacer()
                                Text(viewModel.query)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(viewModel.isDeepSearch ? .purple : .blue, in: .rect(cornerRadius: 18))
                            }

                            if viewModel.isDeepSearch {
                                HStack {
                                    Spacer()
                                    Label("Deep Search", systemImage: "sparkle.magnifyingglass")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(.purple)
                                }
                            }
                        }

                        if let error = viewModel.errorMessage {
                            Label(error, systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.orange.opacity(0.1), in: .rect(cornerRadius: 10))
                        }

                        if (viewModel.isSearching || viewModel.isGenerating) && viewModel.streamingText.isEmpty {
                            SearchLoadingView(stepDescription: viewModel.searchStepDescription)
                        } else if !viewModel.streamingText.isEmpty || viewModel.isGenerating {
                            StreamingAnswerView(
                                streamingText: viewModel.streamingText,
                                isGenerating: viewModel.isGenerating
                            )
                            .animation(.easeIn(duration: 0.2), value: viewModel.streamingText.isEmpty)
                        }

                        if !viewModel.queryGroups.isEmpty {
                            SourceResultsSection(
                                queryGroups: viewModel.queryGroups,
                                usedSourceURLs: viewModel.usedSourceURLs
                            )
                        }

                        if !viewModel.streamingText.isEmpty && !viewModel.isGenerating {
                            VStack(spacing: 6) {
                                HStack(spacing: 4) {
                                    Image(systemName: "apple.intelligence")
                                        .font(.caption)
                                        .symbolEffect(.appear)
                                        .accessibilityHidden(true)
                                    Text("Generated on-device")
                                        .font(.caption)
                                }

                                Text("AI-generated answers may be inaccurate. Verify important information with original sources.")
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                        }
                    }
                    .padding()
                    #if os(macOS)
                    .frame(maxWidth: 720)
                    .frame(maxWidth: .infinity)
                    #endif
                }
            } else {
                SearchEmptyStateView(
                    currentSuggestions: currentSuggestions,
                    currentPairIndex: $currentPairIndex,
                    hasResults: hasResults,
                    remaining: storeManager.remainingQueries,
                    onSuggestionTapped: { query in
                        viewModel.query = query
                        handleSearch()
                    }
                )
            }
        }
        .navigationTitle(hasResults ? "AISight" : "")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            if hasResults {
                ToolbarItem(placement: .automatic) {
                    Button("New Search", systemImage: "square.and.pencil", action: viewModel.resetSearch)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !hasResults {
                SearchBarSection(
                    query: $viewModel.query,
                    isDeepSearchEnabled: $isDeepSearchEnabled,
                    isInputFocused: $isInputFocused,
                    onSearch: handleSearch,
                    onDeepSearchToggled: { enabled in
                        viewModel.isDeepSearch = enabled
                    }
                )
            }
        }
        .onAppear { isInputFocused = true }
        .onChange(of: hasResults) { _, hasResults in
            if !hasResults { isInputFocused = true }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(reason: paywallReason)
        }
        #if !SETAPP
        .onChange(of: viewModel.isGenerating) { wasGenerating, isGenerating in
            // Request review when the 3rd search starts generating
            if !wasGenerating && isGenerating {
                requestReviewIfNeeded()
            }
        }
        #endif
    }

    #if !SETAPP
    private func requestReviewIfNeeded() {
        let key = "completedSearchCount"
        let count = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(count, forKey: key)

        // Ask on the 3rd successful search
        if count == 3 {
            requestReview()
        }
    }
    #endif

    private func handleSearch() {
        if isDeepSearchEnabled && !storeManager.canDeepSearch {
            paywallReason = .deepSearchRequiresPro
            showPaywall = true
            return
        }
        if storeManager.canSearch {
            storeManager.recordQuery()
            viewModel.performSearch(modelContext: modelContext)
        } else {
            paywallReason = .dailyLimitReached
            showPaywall = true
        }
    }
}

// MARK: - Empty State

private struct SearchEmptyStateView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let currentSuggestions: [Suggestion]
    @Binding var currentPairIndex: Int
    let hasResults: Bool
    let remaining: Int
    let onSuggestionTapped: (String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            AppIconView(size: 64)

            Text("AISight")
                .font(.title.bold())
                .fixedSize()

            VStack(spacing: 4) {
                Text("Search the web.")
                Text("Get answers on-device.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Text("Powered by Apple Intelligence")
                .font(.caption)
                .foregroundStyle(.tertiary)

            if remaining == 0 {
                Label(
                    String(localized: "Daily search limit reached"),
                    systemImage: "clock.badge.exclamationmark"
                )
                .font(.caption)
                .foregroundStyle(.orange)
            } else if remaining <= 5 {
                QueryLimitBannerView(remaining: remaining)
            }

            VStack(spacing: 10) {
                ForEach(currentSuggestions) { suggestion in
                    SuggestionChip(suggestion.title) {
                        onSuggestionTapped(suggestion.query)
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
            currentPairIndex = Int.random(in: 0..<AISight.searchSuggestions.count / 2)
        }
        .task(id: hasResults) {
            guard !hasResults else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(6))
                if reduceMotion {
                    currentPairIndex = (currentPairIndex + 1) % (AISight.searchSuggestions.count / 2)
                } else {
                    withAnimation(.spring(duration: 0.45, bounce: 0.15)) {
                        currentPairIndex = (currentPairIndex + 1) % (AISight.searchSuggestions.count / 2)
                    }
                }
            }
        }
    }
}

// MARK: - Loading State

private struct SearchLoadingView: View {
    let stepDescription: String?

    var body: some View {
        VStack(spacing: 12) {
            AppIconView(size: 48)

            if let step = stepDescription {
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
}

// MARK: - Search Bar

private struct SearchBarSection: View {
    @Environment(StoreManager.self) private var storeManager
    @Binding var query: String
    @Binding var isDeepSearchEnabled: Bool
    var isInputFocused: FocusState<Bool>.Binding
    let onSearch: () -> Void
    let onDeepSearchToggled: (Bool) -> Void

    private var isQueryEmpty: Bool {
        query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 8) {
            if isDeepSearchEnabled {
                Text("Deep Search uses multiple AI research passes to find better answers. This takes longer (15-25 seconds vs 5-10 seconds) and uses more on-device processing. Best for complex questions that need thorough research.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    isDeepSearchEnabled.toggle()
                    onDeepSearchToggled(isDeepSearchEnabled)
                }
            } label: {
                HStack(spacing: 4) {
                    Label("Deep Search", systemImage: "sparkle.magnifyingglass")
                    if !storeManager.canDeepSearch {
                        Text("PRO")
                            .font(.caption.bold())
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(.accent.opacity(0.2), in: .capsule)
                    }
                }
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(isDeepSearchEnabled ? AnyShapeStyle(.accent.opacity(0.15)) : AnyShapeStyle(.regularMaterial))
                )
                .foregroundStyle(isDeepSearchEnabled ? .accent : .secondary)
            }
            .buttonStyle(.plain)

            HStack(alignment: .center, spacing: 8) {
                TextField("Ask anything...", text: $query, axis: .vertical)
                    .focused(isInputFocused)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .onChange(of: query) { _, newValue in
                        if newValue.count > 500 {
                            query = String(newValue.prefix(500))
                        }
                    }

                Button("Send", systemImage: "arrow.up.circle.fill", action: onSearch)
                    .buttonStyle(.plain)
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .foregroundStyle(isQueryEmpty ? Color.secondary : Color.accentColor)
                    .symbolEffect(.bounce, value: !isQueryEmpty)
                    .disabled(isQueryEmpty)
            }
            .padding(.horizontal, 12)
            #if os(macOS)
            .padding(.vertical, 10)
            #else
            .padding(.vertical, 6)
            #endif
            .background(.regularMaterial, in: .rect(cornerRadius: 20))
            .shadow(radius: 8, y: 4)
        }
        #if os(macOS)
        .frame(maxWidth: 720)
        #endif
        .frame(maxWidth: .infinity)
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

// MARK: - More Results Toggle

private struct MoreResultsToggle<Content: View>: View {
    let count: Int
    @ViewBuilder let content: Content
    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) { isExpanded.toggle() }
        } label: {
            HStack {
                Label("\(count) more results", systemImage: isExpanded ? "minus.circle" : "plus.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .buttonStyle(.plain)

        if isExpanded {
            content
        }
    }
}

// MARK: - Source Results

private struct SourceResultsSection: View {
    let queryGroups: [SearchQueryGroup]
    let usedSourceURLs: Set<String>

    private var allResults: [SearXNGResult] {
        deduplicatedResults(from: queryGroups)
    }

    var body: some View {
        let used = allResults.filter { usedSourceURLs.contains($0.url) }
        let unused = allResults.filter { !usedSourceURLs.contains($0.url) }

        if !used.isEmpty {
            Section {
                ForEach(used.enumerated(), id: \.element.id) { index, result in
                    SourceCardView(result: result, index: index + 1)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))
                }
            } header: {
                Label("Sources", systemImage: "doc.text")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        if !unused.isEmpty {
            MoreResultsToggle(count: unused.count) {
                ForEach(unused) { result in
                    SourceCardView(result: result, isUsed: false)
                }
            }
        }
    }
}

// MARK: - Helpers

private func deduplicatedResults(from groups: [SearchQueryGroup]) -> [SearXNGResult] {
    var seen = Set<String>()
    var results: [SearXNGResult] = []
    for result in groups.flatMap(\.results) {
        if seen.insert(result.url).inserted {
            results.append(result)
        }
    }
    return results
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .environment(AppState())
    .environment(StoreManager())
    .modelContainer(for: QueryEntry.self, inMemory: true)
}
