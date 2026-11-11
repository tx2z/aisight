import SwiftUI

/// Caption under an answer naming the model that generated it.
struct ModelBadge: View {
    let model: GeneratedModel

    private var icon: String {
        switch model.kind {
        case .onDevice: "cpu"
        case .appleCloud: "apple.intelligence"
        case .custom: "server.rack"
        }
    }

    private var label: String {
        switch model.kind {
        case .onDevice:
            if let reason = model.fallbackReason {
                String(localized: "Generated on-device (\(reason.shortDescription))")
            } else {
                String(localized: "Generated on-device")
            }
        case .appleCloud:
            String(localized: "Generated with Apple Private Cloud Compute")
        case .custom:
            String(localized: "Generated with \(model.customModelName ?? "")")
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .symbolEffect(.appear)
                .accessibilityHidden(true)
            Text(label)
                .multilineTextAlignment(.center)
        }
        .font(.caption)
    }
}
