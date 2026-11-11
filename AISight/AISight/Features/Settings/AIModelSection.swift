import SwiftUI

/// Settings section for choosing the model that writes answers: on-device, Apple Private Cloud Compute or a custom provider.
struct AIModelSection: View {
    @Environment(StoreManager.self) private var storeManager
    @Bindable var settings: AIModelSettings

    var body: some View {
        Group {
            if settings.isVisible {
                content
            }
        }
        .onAppear(perform: settings.refreshCloudStatus)
    }

    private var content: some View {
        Group {
            Section {
                Picker("Model", selection: $settings.preference) {
                    Text("On-device").tag(LanguageModelKind.onDevice)
                    if settings.showsCloud {
                        Text(storeManager.canUseCloudModel ? "Apple Private Cloud Compute" : "Apple Private Cloud Compute (Pro)")
                            .tag(LanguageModelKind.appleCloud)
                    }
                    if settings.showsCustom {
                        Text("Custom (OpenAI-compatible)").tag(LanguageModelKind.custom)
                    }
                }

                if let status = settings.statusMessage(canUseCloudModel: storeManager.canUseCloudModel) {
                    Text(status)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                if settings.preference == .custom {
                    CustomProviderFields(settings: settings)
                }
            } header: {
                Text("AI Model")
            } footer: {
                AIModelFooter(showsCloud: settings.showsCloud, showsCustom: settings.showsCustom)
            }
            .onChange(of: settings.preference) { old, new in
                settings.preferenceChanged(from: old, to: new, canUseCloudModel: storeManager.canUseCloudModel)
            }
            .sheet(isPresented: $settings.showPaywall, onDismiss: paywallDismissed) {
                PaywallView(reason: .cloudModelRequiresPro)
            }
            .alert(
                "Send your questions to \(settings.consentHost)?",
                isPresented: $settings.showConsentAlert
            ) {
                Button("Allow", action: settings.allowConsent)
                Button("Cancel", role: .cancel, action: settings.declineConsent)
            } message: {
                Text("Your question, text extracted from web sources and the AI instructions will be sent to \(settings.consentHost) under its own terms. Deep Search makes several requests.")
            }
        }
    }

    private func paywallDismissed() {
        settings.paywallDismissed(canUseCloudModel: storeManager.canUseCloudModel)
    }
}
