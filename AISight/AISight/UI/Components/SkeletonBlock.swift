import SwiftUI

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
