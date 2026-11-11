import SwiftUI

/// Footer of the AI Model section, describing only the options that are shown.
struct AIModelFooter: View {
    let showsCloud: Bool
    let showsCustom: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("The on-device model never sends anything off your device.")
            if showsCloud {
                Text("Apple Private Cloud Compute runs on Apple's servers and can use more source text. It falls back to on-device when it's unavailable or the daily limit is reached.")
            }
            if showsCustom {
                Text("A custom provider receives your question, web source text and the AI instructions under its own terms.")
            }
        }
    }
}
