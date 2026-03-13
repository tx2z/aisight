import SwiftUI

struct CitationBadge: View {
    let number: Int

    var body: some View {
        Text("[\(number)]")
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(.accent, in: .rect(cornerRadius: 4))
    }
}

#Preview {
    HStack {
        CitationBadge(number: 1)
        CitationBadge(number: 2)
        CitationBadge(number: 3)
    }
    .padding()
}
