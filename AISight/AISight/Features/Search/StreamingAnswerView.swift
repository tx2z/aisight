import SwiftUI

struct StreamingAnswerView: View {
    let streamingText: String
    let isGenerating: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isGenerating && streamingText.isEmpty {
                ProgressView("Thinking...")
                    .padding(.vertical)
            } else if !streamingText.isEmpty {
                CitationText(text: streamingText)

                if isGenerating {
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

#Preview {
    VStack(spacing: 20) {
        StreamingAnswerView(
            streamingText: "",
            isGenerating: true
        )

        StreamingAnswerView(
            streamingText: "Swift is a programming language developed by Apple [1]. It was introduced in 2014 [2] and has since become the primary language for iOS development [3].",
            isGenerating: false
        )
    }
    .padding()
}
