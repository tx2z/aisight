import SwiftUI

struct LegalSectionView: View {
    let title: LocalizedStringKey
    let content: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
