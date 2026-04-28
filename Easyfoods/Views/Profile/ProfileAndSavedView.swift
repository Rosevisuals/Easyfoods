import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var home: HomeViewModel

    private let menuItems: [(icon: String, bg: Color, border: Color, label: String, badge: String?)] = [
        ("📦", Color(hex: "#FFF3EC"), Color(hex: "#FFE4D0"), "My Orders", "47"),
        ("📍", Color(hex: "#EEF5FF"), Color(hex: "#D0E4FF"), "Saved Addresses", nil),
        ("💳", Color(hex: "#F0FFF4"), Color(hex: "#C6F0D4"), "Payment Methods", nil),
        ("🔔", Color(hex: "#FFF8EE"), Color(hex: "#FFE4D0"), "Notifications", nil),
        ("🎁", Color(hex: "#F5F0FF"), Color(hex: "#E0D0FF"), "Refer & Earn", "UGX 5K"),
        ("⚙️", Color(hex: "#F5F5F5"), Color(hex: "#EBEBEB"), "Settings", nil),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Hero
                        profileHero
                            .padding(.bottom, 20)

                        // Menu
                        VStack(spacing: 0) {
                            ForEach(menuItems.indices, id: \.self) { i in
                                let item = menuItems[i]
                                menuRow(
                                    icon: item.icon, bg: item.bg, border: item.border,
                                    label: item.label, badge: item.badge
                                )
                                if i < menuItems.count - 1 {
                                    Divider()
                                        .padding(.leading, 60)
                                        .padding(.trailing, EFSpacing.lg)
                                }
                            }
                        }
                        .background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: EFRadius.xl))
                        .overlay(RoundedRectangle(cornerRadius: EFRadius.xl).stroke(Color.inkQuartern.opacity(0.15), lineWidth: 1))
                        .efShadow()
                        .padding(.horizontal, EFSpacing.lg)

                        // Sign out
                        Button("Sign Out") {}
                            .font(EFFont.semibold(13))
                            .foregroundStyle(Color(hex: "#CC3333"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color(hex: "#CC3333").opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
                            .overlay(RoundedRectangle(cornerRadius: EFRadius.md).stroke(Color(hex: "#CC3333").opacity(0.22), lineWidth: 1.5))
                            .padding(.horizontal, EFSpacing.lg)
                            .padding(.top, 14)
                    }
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Profile Hero
    private var profileHero: some View {
        VStack(spacing: 10) {
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=200&q=80")) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { Color.brandPale }
            }
            .frame(width: 82, height: 82)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.bgCard, lineWidth: 3))
            .overlay(Circle().stroke(Color.brandMid, lineWidth: 2).padding(-1))
            .efShadowMedium()

            Text("Rose Nakato")
                .font(EFFont.black(20))
                .foregroundStyle(Color.inkPrimary)
                .tracking(-0.3)

            Text("rose.nakato@gmail.com")
                .font(EFFont.regular(12))
                .foregroundStyle(Color.inkTertiary)

            // Stats
            HStack(spacing: 0) {
                statBox(value: "47", label: "Orders")
                Divider().frame(height: 32)
                statBox(value: "\(home.savedFoods.count)", label: "Saved")
                Divider().frame(height: 32)
                statBox(value: "4.8★", label: "Rating")
            }
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(Color.inkQuartern.opacity(0.15), lineWidth: 1))
            .efShadow()
            .padding(.horizontal, EFSpacing.lg)
            .padding(.top, 4)
        }
        .padding(.top, 10)
    }

    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(EFFont.black(18)).foregroundStyle(Color.inkPrimary)
            Text(label).font(EFFont.regular(10)).foregroundStyle(Color.inkTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private func menuRow(icon: String, bg: Color, border: Color, label: String, badge: String?) -> some View {
        HStack(spacing: 12) {
            Text(icon).font(.system(size: 15))
                .frame(width: 34, height: 34)
                .background(bg)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(border, lineWidth: 1))

            Text(label).font(EFFont.semibold(14)).foregroundStyle(Color.inkPrimary)

            Spacer()

            if let badge {
                Text(badge)
                    .font(EFFont.bold(11))
                    .foregroundStyle(Color.brand)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(Color.brandPale)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.brandMid, lineWidth: 1))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.inkQuartern)
        }
        .padding(.horizontal, EFSpacing.lg)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Saved View
struct SavedView: View {
    @EnvironmentObject var home: HomeViewModel
    @EnvironmentObject var cart: CartViewModel
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Segmented control
                    HStack(spacing: 6) {
                        segmentTab(label: "Dishes", index: 0)
                        segmentTab(label: "Restaurants", index: 1)
                    }
                    .padding(.horizontal, EFSpacing.xl)
                    .padding(.bottom, 14)

                    ScrollView {
                        if selectedTab == 0 {
                            dishesTab
                        } else {
                            restaurantsTab
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.bottom, 100)
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Dishes
    private var dishesTab: some View {
        VStack(spacing: 10) {
            if home.savedFoods.isEmpty {
                VStack(spacing: 10) {
                    Text("🔖").font(.system(size: 48)).opacity(0.2)
                    Text("Nothing saved yet")
                        .font(EFFont.bold(16)).foregroundStyle(Color.inkSecond)
                    Text("Heart items on the menu to save them here")
                        .font(EFFont.regular(13)).foregroundStyle(Color.inkQuartern)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                ForEach(home.savedFoods) { food in
                    savedItemRow(food: food)
                }
            }
        }
        .padding(.horizontal, EFSpacing.lg)
        .padding(.bottom, 20)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: home.savedFoods.count)
    }

    private func savedItemRow(food: FoodItem) -> some View {
        HStack(spacing: 0) {
            AsyncImage(url: URL(string: food.imageURL)) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { Color.bgSubtle }
            }
            .frame(width: 82, height: 82).clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(food.name).font(EFFont.bold(13)).foregroundStyle(Color.inkPrimary).lineLimit(1)
                Text(food.subtitle).font(EFFont.regular(11)).foregroundStyle(Color.inkTertiary)
                HStack {
                    Text(food.price.ugxFormatted).font(EFFont.black(13)).foregroundStyle(Color.brand)
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            cart.add(food)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.inkPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(SpringButtonStyle())
                }
                .padding(.top, 4)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(Color.inkQuartern.opacity(0.15), lineWidth: 1))
        .efShadow()
    }

    // MARK: - Restaurants
    private var restaurantsTab: some View {
        VStack(spacing: 10) {
            ForEach(MockData.restaurants) { restaurant in
                restaurantCard(restaurant)
            }
        }
        .padding(.horizontal, EFSpacing.lg)
        .padding(.bottom, 20)
    }

    private func restaurantCard(_ restaurant: Restaurant) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: restaurant.imageURL)) { phase in
                    if case .success(let img) = phase { img.resizable().scaledToFill() }
                    else { Color.bgSubtle }
                }
                .frame(maxWidth: .infinity).frame(height: 110).clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top, endPoint: .bottom
                )

                Text(restaurant.name)
                    .font(EFFont.bold(15)).foregroundStyle(.white)
                    .padding(10)
            }
            .frame(height: 110)
            .clipped()

            HStack(spacing: 6) {
                ForEach(restaurant.categories, id: \.self) { cat in
                    Text(cat)
                        .font(EFFont.semibold(11)).foregroundStyle(Color.inkSecond)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Color.bgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.inkQuartern.opacity(0.2), lineWidth: 1))
                }
                Spacer()
                Text("★ \(String(format: "%.1f", restaurant.rating))")
                    .font(EFFont.bold(11)).foregroundStyle(Color.inkSecond)
                Text("· \(restaurant.deliveryTime)")
                    .font(EFFont.regular(11)).foregroundStyle(Color.inkTertiary)
            }
            .padding(10)
            .background(Color.bgCard)
        }
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(Color.inkQuartern.opacity(0.15), lineWidth: 1))
        .efShadow()
    }

    private func segmentTab(label: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = index }
        } label: {
            Text(label)
                .font(EFFont.bold(13))
                .foregroundStyle(selectedTab == index ? .white : Color.inkTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(selectedTab == index ? Color.inkPrimary : Color.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
                .overlay(RoundedRectangle(cornerRadius: EFRadius.md).stroke(Color.inkQuartern.opacity(selectedTab == index ? 0 : 0.3), lineWidth: 1.5))
        }
        .buttonStyle(SpringButtonStyle())
    }
}

#Preview { ProfileView().environmentObject(HomeViewModel()) }
#Preview { SavedView().environmentObject(HomeViewModel()).environmentObject(CartViewModel()) }
