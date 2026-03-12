import SwiftUI

struct ShimmerModifier: ViewModifier {
    let active: Bool
    @State private var phase: CGFloat = 0

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
                .init(color: .white, location: phase),
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

struct SkeletonBlock: View {
    var height: CGFloat = 14
    var width: CGFloat? = nil

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(.quaternary)
            .frame(maxWidth: width ?? .infinity)
            .frame(height: height)
    }
}

struct SearchSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Paragraph skeleton
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBlock()
                SkeletonBlock()
                SkeletonBlock(width: 260)
                SkeletonBlock()
                SkeletonBlock(width: 200)
            }

            // Source card skeletons
            ForEach(0..<2, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.quaternary)
                            .frame(width: 20, height: 20)
                        SkeletonBlock(height: 12, width: 120)
                    }
                    SkeletonBlock(height: 16, width: 220)
                    SkeletonBlock(height: 12)
                }
                .padding(14)
                .background(.regularMaterial, in: .rect(cornerRadius: 14))
            }
        }
        .shimmer()
    }
}

#Preview {
    SearchSkeletonView()
        .padding()
}
