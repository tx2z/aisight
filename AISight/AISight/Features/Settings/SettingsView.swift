import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var serverURL: String = AppConfig.effectiveSearXNGBaseURL
    @State private var isTesting = false
    @State private var testResult: TestResult?
    @State private var selectedLanguage: String = UserDefaults.standard.string(forKey: "search_language") ?? AppConfig.defaultSearchLanguage
    @State private var selectedAppLanguage: String = {
        if let preferred = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let first = preferred.first {
            // Normalize "es-ES" → "es"
            return String(first.prefix(2))
        }
        return Locale.current.language.languageCode?.identifier ?? "en"
    }()
    @State private var showRestartAlert = false
    @State private var showClearConfirmation = false
    @State private var showClearError = false

    // swiftlint:disable:next force_unwrapping
    private static let searxngURL = URL(string: "https://searxng.org")!

    private let supportedLanguages: [(code: String, name: String)] = [
        ("en", "English"),
        ("de", "Deutsch"),
        ("fr", "Fran\u{00E7}ais"),
        ("es", "Espa\u{00F1}ol"),
        ("it", "Italiano"),
        ("ja", "\u{65E5}\u{672C}\u{8A9E}"),
        ("ko", "\u{D55C}\u{AD6D}\u{C5B4}"),
        ("zh", "\u{4E2D}\u{6587}"),
        ("pt", "Portugu\u{00EA}s")
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
                        if validateAndSaveURL(serverURL) {
                            testResult = nil
                        } else {
                            testResult = TestResult(success: false, message: String(localized: "Invalid URL. Use http:// or https://."))
                        }
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

                if isTesting {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.trianglehead.2.counterclockwise")
                            .foregroundStyle(.secondary)
                            .symbolEffect(.pulse)
                        Text("Testing...")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                } else if let testResult {
                    HStack(spacing: 8) {
                        Image(systemName: testResult.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(testResult.success ? .green : .red)
                            .symbolEffect(.appear)

                        Text(testResult.message)
                            .font(.callout)
                            .foregroundStyle(testResult.success ? .green : .red)
                    }
                }
            }

            Section("Preferences") {
                Picker("App Language", selection: $selectedAppLanguage) {
                    ForEach(supportedLanguages, id: \.code) { language in
                        Text(language.name).tag(language.code)
                    }
                }
                .onChange(of: selectedAppLanguage) {
                    UserDefaults.standard.set([selectedAppLanguage], forKey: "AppleLanguages")
                    UserDefaults.standard.synchronize()
                    // Sync search language to match app language
                    selectedLanguage = selectedAppLanguage
                    UserDefaults.standard.set(selectedAppLanguage, forKey: "search_language")
                    showRestartAlert = true
                }

                Picker("Search Language", selection: $selectedLanguage) {
                    ForEach(supportedLanguages, id: \.code) { language in
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
        .alert("Language Changed", isPresented: $showRestartAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please close and reopen the app for the language change to take effect.")
        }
        .alert("Failed to Clear Data", isPresented: $showClearError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your search history could not be deleted. Please try again.")
        }
        .confirmationDialog("Clear Cache?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("Clear All Data", role: .destructive) {
                clearCache()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all cached data including search history.")
        }
    }

    @discardableResult
    private func validateAndSaveURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host() != nil else {
            return false
        }
        UserDefaults.standard.set(urlString, forKey: "searxng_base_url")
        return true
    }

    private func testConnection() async {
        guard validateAndSaveURL(serverURL) else {
            testResult = TestResult(success: false, message: String(localized: "Invalid URL. Use http:// or https://."))
            return
        }
        isTesting = true
        let start = Date()
        let service = SearXNGService()
        let available = await service.checkAvailability()
        let latency = Date().timeIntervalSince(start)

        await MainActor.run {
            isTesting = false
            if available {
                let ms = Int(latency * 1000)
                testResult = TestResult(success: true, message: String(localized: "Connected (\(ms)ms)"))
            } else {
                testResult = TestResult(success: false, message: String(localized: "Connection failed"))
            }
        }
    }

    private func clearCache() {
        do {
            try modelContext.delete(model: QueryEntry.self)
            try modelContext.save()
        } catch {
            showClearError = true
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
