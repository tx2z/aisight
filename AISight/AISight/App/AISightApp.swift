import SwiftUI
import SwiftData

@main
struct AISightApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.hasSeenOnboarding {
                    mainTabView
                } else {
                    OnboardingView()
                }
            }
            .environment(appState)
            .task {
                await appState.checkServerAvailability()
            }
        }
        .modelContainer(for: QueryEntry.self)
    }

    private var mainTabView: some View {
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
