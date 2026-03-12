import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.accent)
                    .symbolRenderingMode(.hierarchical)

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
                featureRow(
                    icon: "lock.shield.fill",
                    title: "Privacy First",
                    description: "AI runs entirely on your device. Nothing is sent to external AI services."
                )

                featureRow(
                    icon: "bolt.fill",
                    title: "Fast Answers",
                    description: "Get concise, cited answers from multiple search engines in seconds."
                )

                featureRow(
                    icon: "doc.text.magnifyingglass",
                    title: "Sourced Information",
                    description: "Every answer includes citations so you can verify the information."
                )
            }
            .padding(.horizontal, 16)

            Spacer()

            Button {
                withAnimation {
                    appState.hasSeenOnboarding = true
                }
            } label: {
                Text("Start Searching")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.accent, in: .rect(cornerRadius: 10))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
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
