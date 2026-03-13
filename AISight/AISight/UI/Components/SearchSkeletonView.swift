import SwiftUI

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
