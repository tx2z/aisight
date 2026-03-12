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

                if !viewModel.streamingText.isEmpty || viewModel.isGenerating {
                    StreamingAnswerView(
                        streamingText: viewModel.streamingText,
                        isGenerating: viewModel.isGenerating
                    )
                }

                if !viewModel.sources.isEmpty {
                    Section {
                        ForEach(Array(viewModel.sources.enumerated()), id: \.element.id) { index, result in
                            SourceCardView(result: result, index: index)
                        }
                    } header: {
                        Text("Sources")
                            .font(.headline)
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
        .searchable(text: $viewModel.query, prompt: "Ask anything...")
        .onSubmit(of: .search) {
            viewModel.performSearch(modelContext: modelContext)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Circle()
                    .fill(appState.serverAvailable == nil ? .gray : (appState.serverAvailable == true ? .green : .red))
                    .frame(width: 8, height: 8)
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
