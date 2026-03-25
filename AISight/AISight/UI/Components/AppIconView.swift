import SwiftUI

/// Displays the app icon from the asset catalog, adapting to light/dark mode.
struct AppIconView: View {
    let size: CGFloat

    var body: some View {
        Image("AppIconImage")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(.rect(cornerRadius: size * 0.22))
    }
}
