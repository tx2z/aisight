import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(StoreManager.self) private var storeManager

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
    @State private var showPaywall = false

    // swiftlint:disable:next force_unwrapping
    private static let searxngURL = URL(string: "https://github.com/searxng/searxng")!
    private static var supportURL: URL {
        let locale = Locale.current.language.languageCode?.identifier ?? "en"
        let path = locale == "en" ? "" : "\(locale)/"
        // swiftlint:disable:next force_unwrapping
        return URL(string: "https://private-search-intelligence.app/\(path)contact/")!
    }

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
            ProSettingsSection(showPaywall: $showPaywall)

            Section {
                TextField("SearXNG Server URL", text: $serverURL, prompt: Text("https://search.yourdomain.com"))
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    #endif
                    .onSubmit {
                        if validateAndSaveURL(serverURL) {
                            testResult = nil
                            storeManager.refreshCustomServerStatus()
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

                    if storeManager.isUsingCustomServer {
                        Button("Reset to Default") {
                            serverURL = AppConfig.defaultSearXNGBaseURL
                            UserDefaults.standard.removeObject(forKey: "searxng_base_url")
                            testResult = nil
                            storeManager.refreshCustomServerStatus()
                        }
                        .foregroundStyle(.secondary)
                        .font(.callout)
                    }
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

                if storeManager.isUsingCustomServer {
                    Label(String(localized: "All features unlocked with your own server"), systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(.accent)
                } else if !storeManager.isPro {
                    Text("Use your own SearXNG server to unlock all features for free")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Search Server")
            }

            Section("Preferences") {
                Picker("App Language", selection: $selectedAppLanguage) {
                    ForEach(supportedLanguages, id: \.code) { language in
                        Text(language.name).tag(language.code)
                    }
                }
                .onChange(of: selectedAppLanguage) { _, newValue in
                    UserDefaults.standard.set([newValue], forKey: "AppleLanguages")
                    // Sync search language to match app language
                    selectedLanguage = newValue
                    UserDefaults.standard.set(newValue, forKey: "search_language")
                    showRestartAlert = true
                }

                Picker("Search Language", selection: $selectedLanguage) {
                    ForEach(supportedLanguages, id: \.code) { language in
                        Text(language.name).tag(language.code)
                    }
                }
                .onChange(of: selectedLanguage) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "search_language")
                }
            }

            Section("Data") {
                Button("Delete All Data", role: .destructive) {
                    showClearConfirmation = true
                }
            }

            Section("Legal") {
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }

                NavigationLink {
                    TermsOfUseView()
                } label: {
                    Label("Terms of Use", systemImage: "doc.text.fill")
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

                Link(destination: Self.supportURL) {
                    HStack {
                        Text("Contact Support")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "envelope.fill")
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
        } message: {
            Text("Please close and reopen the app for the language change to take effect.")
        }
        .alert("Failed to Clear Data", isPresented: $showClearError) {
        } message: {
            Text("Your search history could not be deleted. Please try again.")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .confirmationDialog("Delete All Data?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("Delete All Data", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("This will permanently delete all your search history and saved answers. This action cannot be undone.")
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
        let start = Date.now
        let service = SearXNGService()
        let available = await service.checkAvailability()
        let latency = Date.now.timeIntervalSince(start)

        isTesting = false
        if available {
            let ms = Int(latency * 1000)
            testResult = TestResult(success: true, message: String(localized: "Connected (\(ms)ms)"))
        } else {
            testResult = TestResult(success: false, message: String(localized: "Connection failed"))
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
    .environment(StoreManager())
    .modelContainer(for: QueryEntry.self, inMemory: true)
}
