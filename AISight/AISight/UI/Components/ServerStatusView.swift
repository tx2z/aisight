import SwiftUI

struct ServerStatusView: View {
    let isAvailable: Bool?
    let lastChecked: Date?
    var onTap: (() async -> Void)?

    private var statusColor: Color {
        switch isAvailable {
        case true: return .green
        case false: return .red
        case nil: return .gray
        }
    }

    private var statusText: String {
        switch isAvailable {
        case true: return "Server available"
        case false: return "Server unavailable"
        case nil: return "Not checked"
        }
    }

    private var lastCheckedText: String? {
        guard let lastChecked else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Checked \(formatter.localizedString(for: lastChecked, relativeTo: Date()))"
    }

    private var statusIcon: String {
        switch isAvailable {
        case true: return "checkmark.circle.fill"
        case false: return "xmark.circle.fill"
        case nil: return "questionmark.circle"
        }
    }

    var body: some View {
        Button {
            Task {
                await onTap?()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                    .symbolEffect(.appear)

                VStack(alignment: .leading, spacing: 2) {
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(.primary)

                    if let lastCheckedText {
                        Text(lastCheckedText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        ServerStatusView(isAvailable: true, lastChecked: Date())
        ServerStatusView(isAvailable: false, lastChecked: Date().addingTimeInterval(-120))
        ServerStatusView(isAvailable: nil, lastChecked: nil)
    }
    .padding()
}
