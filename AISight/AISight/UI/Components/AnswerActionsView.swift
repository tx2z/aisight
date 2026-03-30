import SwiftUI

struct AnswerActionsView: View {
    let wasRegenerated: Bool
    let canRegenerate: Bool
    let onRegenerate: () -> Void
    let onSearchAgain: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if wasRegenerated {
                Label(
                    String(localized: "This answer was automatically regenerated because the first attempt contained unverified information."),
                    systemImage: "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90"
                )
                .font(.caption)
                .foregroundStyle(.orange)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.1), in: .rect(cornerRadius: 8))
            }

            HStack(spacing: 12) {
                Button("Regenerate", systemImage: "arrow.trianglehead.counterclockwise", action: onRegenerate)
                    .font(.caption.weight(.medium))
                    .disabled(!canRegenerate)

                Button("Search again", systemImage: "arrow.clockwise", action: onSearchAgain)
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
        }
    }
}
