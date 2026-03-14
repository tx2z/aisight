import SwiftUI

struct ProSettingsSection: View {
    @Environment(StoreManager.self) private var storeManager
    @State private var showPaywall = false

    var body: some View {
        Section("AISight Pro") {
            if storeManager.isPro {
                Label("AISight Pro Active", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.accent)
            } else {
                HStack {
                    Text("Searches used today")
                    Spacer()
                    Text("\(storeManager.dailyQueriesUsed) / \(StoreManager.dailyLimit)")
                        .foregroundStyle(.secondary)
                }

                Button("Upgrade to AISight Pro", action: showUpgrade)

                #if !SETAPP
                Button("Restore Purchases", action: handleRestore)
                    .foregroundStyle(.secondary)
                #endif
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private func showUpgrade() {
        showPaywall = true
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
    Form {
        ProSettingsSection()
    }
    .environment(StoreManager())
}
