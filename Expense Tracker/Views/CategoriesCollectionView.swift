import SwiftUI

struct CategoriesCollectionView: View {
    // Share the same view model instance so data remains consistent
    @ObservedObject var categoriesVM: CategoriesViewModel

    // 3-column grid like the preview on the parent
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeaderView(title: "All Categories", trailingTitle: nil)

                if categoriesVM.categories.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.6))
                        Text("No categories yet")
                            .foregroundColor(.white.opacity(0.8))
                        Text("Add some categories to get started.")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.footnote)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(categoriesVM.categories) { category in
                            CategoryCard(category: category)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 24)
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // Preview with a local VM
    let vm = CategoriesViewModel()
    return NavigationStack {
        CategoriesCollectionView(categoriesVM: vm)
            .background(Color.black.ignoresSafeArea())
    }
}
