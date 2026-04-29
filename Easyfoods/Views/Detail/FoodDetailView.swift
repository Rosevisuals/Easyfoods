import SwiftUI

struct FoodDetailView: View {
    let food: FoodItem
    @EnvironmentObject var cart: CartViewModel
    @EnvironmentObject var home: HomeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var quantity = 1
    @State private var selectedAddons: Set<UUID> = []
    @State private var addedToCart = false

    private var chosenAddons: [FoodAddon] { food.addons.filter { selectedAddons.contains($0.id) } }
    private var addonTotal: Int { chosenAddons.reduce(0) { $0 + $1.price } }
    private var unitPrice: Int { food.price + addonTotal }
    private var lineTotal: Int { unitPrice * quantity }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    heroImage
                    contentArea
                }
            }
            footer
        }
        .background(Color.bgCard)
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }

    // MARK: - Hero
    private var heroImage: some View {
        ZStack(alignment: .top) {
            AsyncImage(url: URL(string: food.imageURL)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Color.bgSubtle.overlay(ProgressView().tint(Color.brand))
                }
            }
            .frame(maxWidth: .infinity).frame(height: 280).clipped()

            LinearGradient(colors: [.clear, .clear, Color.bgCard], startPoint: .top, endPoint: .bottom)
                .frame(height: 280)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                        .frame(width: 36, height: 36).liquidGlass(cornerRadius: 12)
                }.buttonStyle(SpringButtonStyle())
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.5)) { home.toggleSaved(food) }
                } label: {
                    Image(systemName: home.isSaved(food) ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(home.isSaved(food) ? Color.red : Color.inkPrimary)
                        .frame(width: 36, height: 36).liquidGlass(cornerRadius: 12)
                }.buttonStyle(SpringButtonStyle())
            }
            .padding(.horizontal, 16).padding(.top, 58)
        }
        .frame(height: 280)
    }

    // MARK: - Content
    private var contentArea: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Name + price
            HStack(alignment: .top, spacing: 8) {
                Text(food.name)
                    .font(.system(size: 22, weight: .bold)).foregroundStyle(Color.inkPrimary).tracking(-0.3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(food.price.ugxFormatted)
                    .font(.system(size: 18, weight: .bold)).foregroundStyle(Color.brand)
            }
            .padding(.bottom, 6)

            // Rating — plain, no glass
            StarRating(rating: food.rating, count: food.ratingCount).padding(.bottom, 14)

            // Meta chips
            HStack(spacing: 8) {
                metaChip("⏱️", food.deliveryTime + " min", "Delivery")
                metaChip("🔥", "\(food.calories)", "Kcal")
                metaChip("📦", "Free", "Shipping")
            }
            .padding(.bottom, 18)

            // Description
            Text("About this dish")
                .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.inkPrimary).padding(.bottom, 5)
            Text(food.description)
                .font(.system(size: 13, weight: .regular)).foregroundStyle(Color.inkSecond)
                .lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 16)

            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) { ForEach(food.tags, id: \.self) { TagChip(label: $0) } }
            }.padding(.bottom, 22)

            // Addons / Toppings / Flavours
            if !food.addons.isEmpty {
                addonsSection
            }
        }
        .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 28)
    }

    // MARK: - Addons Section
    private var addonsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Customise your order")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                Spacer()
                Text("Optional").font(.system(size: 11, weight: .regular)).foregroundStyle(Color.inkTertiary)
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(Color.bgSubtle).clipShape(Capsule())
            }

            ForEach(food.addons) { addon in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        if selectedAddons.contains(addon.id) { selectedAddons.remove(addon.id) }
                        else { selectedAddons.insert(addon.id) }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Text(addon.emoji).font(.system(size: 22))
                            .frame(width: 44, height: 44)
                            .background(Color.bgSubtle)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(addon.name).font(.system(size: 13, weight: .medium)).foregroundStyle(Color.inkPrimary)
                            Text(addon.price == 0 ? "Free" : "+ \(addon.price.ugxFormatted)")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(addon.price == 0 ? Color.success : Color.inkTertiary)
                        }
                        Spacer()

                        // Checkbox
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(selectedAddons.contains(addon.id) ? Color.brand : Color.inkQuartern.opacity(0.4), lineWidth: 1.5)
                                .frame(width: 22, height: 22)
                            if selectedAddons.contains(addon.id) {
                                RoundedRectangle(cornerRadius: 7).fill(Color.brand).frame(width: 22, height: 22)
                                Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                            }
                        }
                        .animation(.spring(response: 0.22, dampingFraction: 0.65), value: selectedAddons.contains(addon.id))
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(selectedAddons.contains(addon.id) ? Color.brandPale : Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
                    .overlay(RoundedRectangle(cornerRadius: EFRadius.md)
                        .stroke(selectedAddons.contains(addon.id) ? Color.brandMid : Color.inkQuartern.opacity(0.15), lineWidth: 1))
                }
                .buttonStyle(SpringButtonStyle())
            }
        }
    }

    private func metaChip(_ icon: String, _ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(icon).font(.system(size: 14))
            Text(value).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.inkPrimary)
            Text(label).font(.system(size: 10, weight: .regular)).foregroundStyle(Color.inkTertiary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(Color.bgSubtle)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.md).stroke(Color.inkQuartern.opacity(0.15), lineWidth: 1))
    }

    // MARK: - Footer
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.4)
            HStack(spacing: 12) {
                QuantityStepper(quantity: $quantity)
                Button {
                    cart.add(food, quantity: quantity, addons: chosenAddons)
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) { addedToCart = true }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { withAnimation { addedToCart = false } }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: addedToCart ? "checkmark" : "cart.badge.plus")
                            .font(.system(size: 13, weight: .semibold))
                        VStack(alignment: .leading, spacing: 0) {
                            Text(addedToCart ? "Added!" : "Add to Cart")
                                .font(.system(size: 14, weight: .semibold))
                            if !addedToCart && addonTotal > 0 {
                                Text(lineTotal.ugxFormatted).font(.system(size: 11, weight: .regular)).opacity(0.8)
                            }
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(height: 44).frame(maxWidth: .infinity)
                    .background(AnyShapeStyle(addedToCart ? AnyShapeStyle(Color.success) : AnyShapeStyle(LinearGradient.brand)))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .efShadowOrange()
                    .animation(.spring(response: 0.28, dampingFraction: 0.7), value: addedToCart)
                }.buttonStyle(SpringButtonStyle())
            }
            .padding(.horizontal, 18).padding(.vertical, 12)
            .background(Color.bgCard)
        }
    }
}

#Preview {
    NavigationStack { FoodDetailView(food: MockData.foods[0]) }
        .environmentObject(CartViewModel()).environmentObject(HomeViewModel())
}

