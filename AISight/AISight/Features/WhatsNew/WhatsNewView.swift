import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    private let showsCloud = LanguageModelProvider.cloudStatus() != .notOffered

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("What's New")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity)
                        .accessibilityAddTraits(.isHeader)

                    if showsCloud {
                        FeatureRow(
                            icon: "apple.intelligence",
                            title: "Apple Private Cloud Compute",
                            description: "A more powerful Apple model, available with AISight Pro."
                        )
                    }

                    FeatureRow(
                        icon: "server.rack",
                        title: "Your Own AI Provider",
                        description: "Use OpenAI, Mistral, Claude, Ollama and more, for free, in Settings → AI Model."
                    )

                    FeatureRow(
                        icon: "cpu",
                        title: "Smarter On-Device AI",
                        description: "A more capable model reads more of each source."
                    )

                    FeatureRow(
                        icon: "clock.arrow.circlepath",
                        title: "Model in History",
                        description: "See which model answered each question."
                    )

                    FeatureRow(
                        icon: "arrow.clockwise",
                        title: "Try again",
                        description: "Retry with one tap when an answer fails."
                    )
                }
                .padding(24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }

            Button(action: dismiss.callAsFunction) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .frame(maxWidth: 560)
        }
        #if os(macOS)
        .frame(minWidth: 520, minHeight: 620)
        #endif
    }
}

#Preview {
    WhatsNewView()
}
