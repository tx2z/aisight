import SwiftUI

struct PaywallView: View {
    @Environment(StoreManager.self) private var storeManager
    @Environment(\.dismiss) private var dismiss

    var reason: PaywallReason = .dailyLimitReached
    @State private var cloudStatus: CloudModelStatus = .notOffered

    private var subtitle: String {
        switch reason {
        case .dailyLimitReached:
            return String(localized: "You've used all \(StoreManager.dailyLimit) free searches today")
        case .deepSearchRequiresPro:
            return String(localized: "Deep Search is a Pro feature")
        case .cloudModelRequiresPro:
            return String(localized: "Apple Private Cloud Compute is a Pro feature")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 20)

                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .imageScale(.large)
                        .foregroundStyle(.accent)
                        .symbolEffect(.bounce, options: .nonRepeating)

                    VStack(spacing: 8) {
                        Text("AISight Pro")
                            .font(.title.bold())

                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        PaywallFeatureRow(icon: "magnifyingglass", title: String(localized: "Unlimited searches"))
                        PaywallFeatureRow(icon: "sparkle.magnifyingglass", title: String(localized: "Deep Search"))
                        if cloudStatus != .notOffered {
                            PaywallFeatureRow(icon: "apple.intelligence", title: String(localized: "Apple Private Cloud Compute"))
                        }
                        PaywallFeatureRow(icon: "heart.fill", title: String(localized: "Support AISight development"))
                        PaywallFeatureRow(icon: "gift", title: String(localized: "Future features included"))
                    }
                    .padding()
                    .background(.quaternary.opacity(0.3), in: .rect(cornerRadius: 16))

                    VStack(spacing: 4) {
                        Text("Or use your own SearXNG server")
                            .font(.subheadline.weight(.medium))
                        Text("Connect your own server in Settings to unlock unlimited searches and Deep Search for free.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        #if !SETAPP
                        Button(action: handlePurchase) {
                            Text("Unlock for $4.99")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        Button("Restore Purchases", action: handleRestore)
                            .font(.subheadline)
                        #endif
                    }

                    if let error = storeManager.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    if reason == .dailyLimitReached {
                        Text("Or come back tomorrow")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationTitle("AISight Pro")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
            }
        }
        .onAppear { cloudStatus = LanguageModelProvider.cloudStatus() }
        .onChange(of: storeManager.isPro) {
            if storeManager.isPro {
                dismiss()
            }
        }
    }

    #if !SETAPP
    private func handlePurchase() {
        Task {
            await storeManager.purchase()
        }
    }

    private func handleRestore() {
        Task {
            await storeManager.restorePurchases()
        }
    }
    #endif
}

private struct PaywallFeatureRow: View {
    let icon: String
    let title: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.body)
    }
}

#Preview {
    PaywallView()
        .environment(StoreManager())
}
