import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let trailingTitle: String?
    let titleFont: Font
    let titleColor: Color
    let trailingFont: Font
    let trailingColor: Color
    let horizontalPadding: CGFloat
    let action: (() -> Void)?

    init(
        title: String,
        trailingTitle: String? = "View All",
        titleFont: Font = .title3.bold(),
        titleColor: Color = .white,
        trailingFont: Font = .title3.bold(),
        trailingColor: Color = .white,
        horizontalPadding: CGFloat = 16,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.trailingTitle = trailingTitle
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.trailingFont = trailingFont
        self.trailingColor = trailingColor
        self.horizontalPadding = horizontalPadding
        self.action = action
    }

    var body: some View {
        HStack {
            Text(title)
                .font(titleFont)
                .foregroundColor(titleColor)
                .padding(.horizontal, horizontalPadding)

            Spacer()

            if let trailingTitle {
                Text(trailingTitle)
                    .font(trailingFont)
                    .foregroundColor(trailingColor)
                    .padding(.horizontal, horizontalPadding)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        action?()
                    }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeaderView(title: "Categories") {
            Log.info("Categories tapped")
        }
        SectionHeaderView(title: "Expenses", trailingTitle: "Show All") {
            Log.info("Show All tapped")
        }
        SectionHeaderView(
            title: "Custom",
            trailingTitle: nil, // Hide trailing action
            titleFont: .title.bold(),
            trailingFont: .body,
            horizontalPadding: 8
        )
    }
    .background(Color.black.ignoresSafeArea())
}
