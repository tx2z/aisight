import SwiftUI

struct StreamingAnswerView: View {
    let streamingText: String
    let isGenerating: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                CitationText(text: streamingText)

                if isGenerating {
                    TypingCursor()
                }
            }

            if !isGenerating && !streamingText.isEmpty {
                Button("Copy Answer", systemImage: "doc.on.doc", action: copyAnswer)
                    .font(.caption)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity)
    }

    private func copyAnswer() {
        #if os(iOS)
        UIPasteboard.general.string = streamingText
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(streamingText, forType: .string)
        #endif
    }
}

#Preview {
    VStack(spacing: 20) {
        StreamingAnswerView(
            streamingText: "**Swift** is a programming language developed by Apple. It was introduced in *2014* and has since become the primary language for iOS development (via developer.apple.com).",
            isGenerating: true
        )
    }
    .padding()
}
