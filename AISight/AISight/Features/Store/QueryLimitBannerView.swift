import SwiftUI

struct QueryLimitBannerView: View {
    let remaining: Int

    var body: some View {
        Label(
            String(localized: "\(remaining) searches remaining today"),
            systemImage: "hourglass"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    QueryLimitBannerView(remaining: 3)
}
