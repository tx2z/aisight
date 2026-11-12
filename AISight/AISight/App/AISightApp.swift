import SwiftUI
import SwiftData

@main
struct AISightApp: App {
    @State private var appState = AppState()
    @State private var storeManager = StoreManager()
    @State private var showWhatsNew = false

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .animation(.easeIn(duration: 0.3), value: appState.hasSeenOnboarding)
            .onAppear {
                showWhatsNew = AppState.shouldShowWhatsNew(
                    hasSeenOnboarding: appState.hasSeenOnboarding,
                    lastSeenVersion: appState.lastSeenWhatsNewVersion,
                    supportsNewFeatures: LanguageModelProvider.supportsCustomModels
                )
            }
            .sheet(isPresented: $showWhatsNew, onDismiss: {
                appState.lastSeenWhatsNewVersion = AppState.currentWhatsNewVersion
            }) {
                WhatsNewView()
            }
            .environment(appState)
            .environment(storeManager)
        }
        .modelContainer(for: QueryEntry.self)
        #if os(macOS)
        .defaultSize(width: 1100, height: 800)
        #endif
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Search", systemImage: "magnifyingglass") {
                NavigationStack {
                    SearchView()
                }
            }

            Tab("History", systemImage: "clock.arrow.circlepath") {
                NavigationStack {
                    HistoryView()
                }
            }

            Tab("Settings", systemImage: "gearshape") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        #if os(iOS)
        .tabBarMinimizeBehavior(.onScrollDown)
        #endif
    }
}
