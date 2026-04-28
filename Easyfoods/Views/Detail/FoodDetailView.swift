import SwiftUI

struct FoodDetailView: View {
    let food: FoodItem
    @EnvironmentObject var cart: CartViewModel
    @EnvironmentObject var home: HomeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var quantity = 1
    @State private var addedToCart = false
    @State private var imageOffset: CGFloat = 0

    var total: Int { food.price * quantity }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.bgCard.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Hero image
                    heroImage

                    // Content sheet
                    VStack(alignment: .leading, spacing: 0) {
                        // Name + Price
                        HStack(alignment: .top) {
                            Text(food.name)
                                .font(EFFont.black(22))
                                .foregroundStyle(Color.inkPrimary)
                                .tracking(-0.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(food.price.ugxFormatted)
                                .font(EFFont.black(20))
                                .foregroundStyle(Color.brand)
                        }
                        .padding(.bottom, 8)

                        // Meta chips
                        HStack(spacing: 8) {
                            metaChip(icon: "⭐", value: String(format: "%.1f", food.rating), label: "Rating")
                            metaChip(icon: "⏱️", value: food.deliveryTime, label: "Minutes")
                            metaChip(icon: "🔥", value: "\(food.calories)", label: "Kcal")
                        }
                        .padding(.bottom, 18)

                        // Description
                        Text("Description")
                            .font(EFFont.bold(14))
                            .foregroundStyle(Color.inkPrimary)
                            .padding(.bottom, 6)

                        Text(food.description)
                            .font(EFFont.regular(13))
                            .foregroundStyle(Color.inkTertiary)
                            .lineSpacing(4)
                            .padding(.bottom, 14)

                        // Tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 7) {
                                ForEach(food.tags, id: \.self) { tag in
                                    TagChip(label: tag)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .ignoresSafeArea(edges: .top)
            .scrollIndicators(.hidden)

            // Bottom footer
            footer
        }
        .navigationBarHidden(true)
    }

    // MARK: - Hero Image
    private var heroImage: some View {
        ZStack(alignment: .top) {
            AsyncImage(url: URL(string: food.imageURL)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Color.bgSubtle
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .clipped()

            // Gradient fade to white
            LinearGradient(
                colors: [.clear, .clear, Color.bgCard],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)

            // Back + Fav buttons (liquid glass ✓ — over image)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.inkPrimary)
                        .frame(width: 36, height: 36)
                        .liquidGlass(cornerRadius: 12)
                }
                .buttonStyle(SpringButtonStyle())

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        home.toggleSaved(food)
                    }
                } label: {
                    Text(home.isSaved(food) ? "❤️" : "🤍")
                        .font(.system(size: 16))
                        .frame(width: 36, height: 36)
                        .liquidGlass(cornerRadius: 12)
                }
                .buttonStyle(SpringButtonStyle())
            }
            .padding(.horizontal, 14)
            .padding(.top, 56) // below status bar
        }
        .frame(height: 280)
    }

    // MARK: - Meta Chip
    private func metaChip(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(icon).font(.system(size: 14))
            Text(value).font(EFFont.bold(12)).foregroundStyle(Color.inkPrimary)
            Text(label).font(EFFont.regular(10)).foregroundStyle(Color.inkTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.bgSubtle)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.md).stroke(Color.inkQuartern.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Footer
    private var footer: some View {
        HStack(spacing: 12) {
            QuantityStepper(quantity: $quantity)

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    cart.add(food, quantity: quantity)
                    addedToCart = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation { addedToCart = false }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: addedToCart ? "checkmark" : "cart.badge.plus")
                        .font(.system(size: 13, weight: .bold))
                    Text(addedToCart ? "Added!" : "Add to Cart")
                        .font(EFFont.bold(14))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: EFRadius.md)
                        .fill(addedToCart ? AnyShapeStyle(Color.success) : AnyShapeStyle(LinearGradient.brand))
                )
                .efShadowOrange()
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: addedToCart)
            }
            .buttonStyle(SpringButtonStyle())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .background(
            Color.bgCard.opacity(0.95)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            Divider().opacity(0.5)
        }
    }
}

#Preview {
    NavigationStack {
        FoodDetailView(food: MockData.foods[0])
            .environmentObject(CartViewModel())
            .environmentObject(HomeViewModel())
    }
}
