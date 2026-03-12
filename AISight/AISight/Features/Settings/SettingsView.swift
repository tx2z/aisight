import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var serverURL: String = AppConfig.effectiveSearXNGBaseURL
    @State private var isTesting = false
    @State private var testResult: TestResult?
    @State private var selectedLanguage: String = UserDefaults.standard.string(forKey: "search_language") ?? AppConfig.defaultSearchLanguage
    @State private var showClearConfirmation = false

    // swiftlint:disable:next force_unwrapping
    private static let searxngURL = URL(string: "https://searxng.org")!

    private let languages: [(code: String, name: String)] = [
        ("en", "English"),
        ("de", "Deutsch"),
        ("fr", "Fran\u{00E7}ais"),
        ("es", "Espa\u{00F1}ol"),
        ("ja", "\u{65E5}\u{672C}\u{8A9E}"),
        ("zh", "\u{4E2D}\u{6587}")
    ]

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }

    var body: some View {
        Form {
            Section("Search Server") {
                TextField("SearXNG Server URL", text: $serverURL, prompt: Text("https://search.yourdomain.com"))
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    #endif
                    .onSubmit {
                        UserDefaults.standard.set(serverURL, forKey: "searxng_base_url")
                        testResult = nil
                    }

                HStack(spacing: 12) {
                    Button {
                        Task { await testConnection() }
                    } label: {
                        HStack(spacing: 6) {
                            if isTesting {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text("Test Connection")
                        }
                    }
                    .disabled(isTesting || serverURL.isEmpty)

                    Spacer()

                    Button("Reset to Default") {
                        serverURL = AppConfig.defaultSearXNGBaseURL
                        UserDefaults.standard.removeObject(forKey: "searxng_base_url")
                        testResult = nil
                    }
                    .foregroundStyle(.secondary)
                    .font(.callout)
                }

                if let testResult {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(testResult.success ? .green : .red)
                            .frame(width: 10, height: 10)

                        Text(testResult.message)
                            .font(.callout)
                            .foregroundStyle(testResult.success ? .green : .red)
                    }
                }
            }

            Section("Server Status") {
                ServerStatusView(
                    isAvailable: appState.serverAvailable,
                    lastChecked: appState.lastServerCheck
                ) {
                    await appState.checkServerAvailability()
                }
            }

            Section("Preferences") {
                Picker("Search Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.code) { language in
                        Text(language.name).tag(language.code)
                    }
                }
                .onChange(of: selectedLanguage) {
                    UserDefaults.standard.set(selectedLanguage, forKey: "search_language")
                }
            }

            Section("Data") {
                Button("Clear Cache", role: .destructive) {
                    showClearConfirmation = true
                }
            }

            Section("About") {
                Link(destination: Self.searxngURL) {
                    HStack {
                        Text("Powered by SearXNG")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.accent)
                    }
                }

                HStack {
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .confirmationDialog("Clear Cache?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("Clear All Data", role: .destructive) {
                clearCache()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all cached data including search history.")
        }
    }

    private func testConnection() async {
        UserDefaults.standard.set(serverURL, forKey: "searxng_base_url")
        isTesting = true
        let start = Date()
        let service = SearXNGService()
        let available = await service.checkAvailability()
        let latency = Date().timeIntervalSince(start)

        await MainActor.run {
            isTesting = false
            if available {
                let ms = Int(latency * 1000)
                testResult = TestResult(success: true, message: "Connected (\(ms)ms)")
            } else {
                testResult = TestResult(success: false, message: "Connection failed")
            }
        }
    }

    private func clearCache() {
        do {
            try modelContext.delete(model: QueryEntry.self)
            try modelContext.save()
        } catch {
            // Handle silently
        }
    }
}

private struct TestResult {
    let success: Bool
    let message: String
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppState())
    .modelContainer(for: QueryEntry.self, inMemory: true)
}
