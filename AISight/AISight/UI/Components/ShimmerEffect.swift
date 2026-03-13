import SwiftUI

struct ShimmerModifier: ViewModifier {
    let active: Bool

    func body(content: Content) -> some View {
        if active {
            content
                .mask {
                    TimelineView(.animation) { timeline in
                        let now = timeline.date.timeIntervalSinceReferenceDate
                        let phase = now.truncatingRemainder(dividingBy: 1.5) / 1.5
                        shimmerGradient(phase: phase)
                    }
                }
        } else {
            content
        }
    }

    private func shimmerGradient(phase: Double) -> some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: max(0, phase - 0.3)),
                .init(color: .primary, location: phase),
                .init(color: .clear, location: min(1, phase + 0.3))
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension View {
    func shimmer(active: Bool = true) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}
