import SwiftUI

struct TypingCursor: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        PhaseAnimator([true, false]) { phase in
            Rectangle()
                .fill(.primary)
                .frame(width: 2, height: 16)
                .opacity(phase ? 1 : 0)
        } animation: { _ in
            reduceMotion ? nil : .easeInOut(duration: 0.5)
        }
        .accessibilityLabel(Text("Generating response"))
    }
}

#Preview {
    HStack(spacing: 0) {
        Text("Generating answer")
            .font(.body)
        TypingCursor()
    }
    .padding()
}
