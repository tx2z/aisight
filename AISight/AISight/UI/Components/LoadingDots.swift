import SwiftUI

struct LoadingDots: View {
    var body: some View {
        ProgressView()
            .controlSize(.small)
    }
}

#Preview {
    LoadingDots()
        .padding()
}
