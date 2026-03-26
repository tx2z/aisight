import SwiftUI

struct ProSettingsSection: View {
    @Environment(StoreManager.self) private var storeManager
    @Binding var showPaywall: Bool

    var body: some View {
        Section("AISight Pro") {
            if storeManager.isPro {
                Label("AISight Pro Active", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.accent)
            } else if storeManager.isUsingCustomServer {
                Label(String(localized: "All features unlocked"), systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.accent)
                Text("Using your own search server")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                HStack {
                    Text("Searches used today")
                    Spacer()
                    Text("\(storeManager.dailyQueriesUsed) / \(StoreManager.dailyLimit)")
                        .foregroundStyle(.secondary)
                }

                Button("Upgrade to AISight Pro") {
                    showPaywall = true
                }

                #if !SETAPP
                Button("Restore Purchases", action: handleRestore)
                    .foregroundStyle(.secondary)
                #endif
            }
        }
    }

    #if !SETAPP
    private func handleRestore() {
        Task {
            await storeManager.restorePurchases()
        }
    }
    #endif
}

#Preview {
    @Previewable @State var show = false
    Form {
        ProSettingsSection(showPaywall: $show)
    }
    .environment(StoreManager())
}
