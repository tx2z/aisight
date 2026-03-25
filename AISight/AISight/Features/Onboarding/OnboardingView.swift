import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var showLegalSheet: LegalSheet?

    private enum LegalSheet: Identifiable {
        case privacy, terms
        var id: Self { self }
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                AppIconView(size: 80)

                Text("AISight")
                    .font(.largeTitle.bold())
            }

            VStack(spacing: 12) {
                Text("AISight answers your questions using web sources and on-device AI. All AI processing happens privately on your device \u{2014} your data never leaves to a cloud AI service. For best results, ask clear factual questions; complex research or real-time topics may be beyond what on-device AI can handle.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text("Search is powered by a private SearXNG server. No queries are stored or tracked.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 16) {
                FeatureRow(
                    icon: "lock.shield.fill",
                    title: "Privacy First",
                    description: "AI runs entirely on your device."
                )

                FeatureRow(
                    icon: "bolt.fill",
                    title: "Fast Answers",
                    description: "Cited answers from multiple sources."
                )

                FeatureRow(
                    icon: "doc.text.magnifyingglass",
                    title: "Sourced Information",
                    description: "Verify answers with linked sources."
                )
            }
            .padding(.horizontal, 16)

            Spacer()

            VStack(spacing: 12) {
                Button(action: completeOnboarding) {
                    Text("Start Searching")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.accent, in: .rect(cornerRadius: 10))
                }
                .padding(.horizontal, 24)

                Text("By continuing, you agree to our [Terms of Use](aisight://terms) and [Privacy Policy](aisight://privacy).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .environment(\.openURL, OpenURLAction { url in
                        if url.scheme == "aisight" {
                            showLegalSheet = url.host() == "privacy" ? .privacy : .terms
                        }
                        return .handled
                    })
            }
            .padding(.bottom, 32)
        }
        .sheet(item: $showLegalSheet) { sheet in
            NavigationStack {
                Group {
                    switch sheet {
                    case .privacy:
                        PrivacyPolicyView()
                    case .terms:
                        TermsOfUseView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            showLegalSheet = nil
                        }
                    }
                }
            }
        }
    }

    private func completeOnboarding() {
        withAnimation {
            appState.hasSeenOnboarding = true
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.accent)
                .frame(width: 32, height: 32)
                .symbolRenderingMode(.hierarchical)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
