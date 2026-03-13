import SwiftUI

struct LoadingDots: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var active = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.secondary)
                    .frame(width: 6, height: 6)
                    .offset(y: active ? -4 : 2)
                    .animation(
                        reduceMotion ? nil :
                            .spring(duration: 0.4, bounce: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15),
                        value: active
                    )
            }
        }
        .onAppear { active = true }
    }
}

#Preview {
    LoadingDots()
        .padding()
}
