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

            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.accent, in: .rect(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .frame(maxWidth: 560)
        }
        #if os(macOS)
        .frame(minWidth: 520, minHeight: 620)
        #endif
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
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    WhatsNewView()
}
