import SwiftUI

struct HomeView: View {
    @EnvironmentObject var cart: CartViewModel
    @EnvironmentObject var home: HomeViewModel
    @Binding var selectedTab: AppTab

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                // KEY FIX: VStack inside ScrollView — no ZStack blocking scroll
                VStack(spacing: 0) {
                    topBar
                    headingSection
                    searchBar
                    promoBanner
                    SectionHeader(title: "Category", onAction: nil)
                    categoriesRow
                    SectionHeader(title: "Popular Near You", onAction: nil)
                    foodGrid
                }
                // Bottom padding = safe area so last item isn't hidden under tab bar
                .padding(.bottom, 20)
            }
            .background(Color.bgBase)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // Location pill
            HStack(spacing: 9) {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=80&q=80")) { phase in
                    if case .success(let img) = phase { img.resizable().scaledToFill() }
                    else { Color.brandPale }
                }
                .frame(width: 34, height: 34).clipShape(Circle())
                .overlay(Circle().stroke(Color.brand.opacity(0.25), lineWidth: 2))

                VStack(alignment: .leading, spacing: 1) {
                    Text("DELIVER TO")
                        .font(EFFont.semibold(10)).foregroundStyle(Color.inkTertiary).tracking(0.4)
                    HStack(spacing: 3) {
                        Text("Kololo, Kampala")
                            .font(EFFont.bold(13)).foregroundStyle(Color.inkPrimary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold)).foregroundStyle(Color.inkTertiary)
                    }
                }
            }
            .padding(.vertical, 6).padding(.horizontal, 12)
            .background(Color.bgCard)
            .clipShape(Capsule()).efShadow()

            Spacer()

            // Cart icon
            Button { selectedTab = .cart } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                        .frame(width: 38, height: 38)
                        .background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: EFRadius.md)).efShadow()

                    if cart.itemCount > 0 {
                        Text("\(cart.itemCount)")
                            .font(.system(size: 9, weight: .black)).foregroundStyle(.white)
                            .frame(width: 16, height: 16).background(Color.brand)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.bgCard, lineWidth: 1.5))
                            .offset(x: 4, y: -4)
                            .transition(.scale(scale: 0.3).combined(with: .opacity))
                            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: cart.itemCount)
                    }
                }
            }
            .buttonStyle(SpringButtonStyle())
        }
        .padding(.horizontal, EFSpacing.xl)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Heading
    private var headingSection: some View {
        Group {
            Text("Get Your Favorite\nDishes ")
                .font(EFFont.black(26)).foregroundStyle(Color.inkPrimary)
            + Text("Delivered Fresh")
                .font(EFFont.black(26)).foregroundStyle(Color.brand)
        }
        .lineSpacing(2)
        .tracking(-0.8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, EFSpacing.xl)
        .padding(.bottom, 16)
    }

    // MARK: - Search
    private var searchBar: some View {
        HStack(spacing: 8) {
            HStack(spacing: 9) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14)).foregroundStyle(Color.inkQuartern)
                Text("Search food, restaurants…")
                    .font(EFFont.regular(13)).foregroundStyle(Color.inkQuartern)
                Spacer()
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(Color.inkQuartern.opacity(0.2), lineWidth: 1))
            .efShadow()

            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                .frame(width: 44, height: 44).background(Color.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: EFRadius.md)).efShadow()
        }
        .padding(.horizontal, EFSpacing.xl).padding(.bottom, 18)
    }

    // MARK: - Promo Banner
    private var promoBanner: some View {
        ZStack {
            LinearGradient.promoBanner
            // Food photo
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&q=90")) { phase in
                if case .success(let img) = phase {
                    img.resizable().scaledToFill()
                        .frame(width: 156, height: 160).clipShape(Circle()).opacity(0.92)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, -4).padding(.top, -14)
            .clipped()
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text("🔥 LIMITED OFFER")
                    .font(EFFont.semibold(10)).foregroundStyle(.white.opacity(0.75)).tracking(0.6)
                Text("Order a set\nwith 40% off")
                    .font(EFFont.black(20)).foregroundStyle(.white).lineSpacing(1)
                Button {
                    // Quick add first item to cart for demo
                    cart.add(MockData.foods[0])
                    withAnimation { selectedTab = .cart }
                } label: {
                    Text("Order Now →")
                        .font(EFFont.bold(11)).foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.35), lineWidth: 1))
                }
                .buttonStyle(SpringButtonStyle()).padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 18)
        }
        .frame(height: 130)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.xxl))
        .shadow(color: Color.brand.opacity(0.22), radius: 18, x: 0, y: 8)
        .padding(.horizontal, EFSpacing.xl).padding(.bottom, 20)
    }

    // MARK: - Categories
    private var categoriesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FoodCategory.allCases) { cat in
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                            home.selectedCategory = cat
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(cat.emoji).font(.system(size: 15))
                            Text(cat.rawValue).font(EFFont.semibold(12))
                                .foregroundStyle(home.selectedCategory == cat ? .white : Color.inkSecond)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(home.selectedCategory == cat ? Color.inkPrimary : Color.bgCard)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(
                            home.selectedCategory == cat ? Color.clear : Color.inkQuartern.opacity(0.25),
                            lineWidth: 1.5))
                        .shadow(color: .black.opacity(home.selectedCategory == cat ? 0.12 : 0.04), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(SpringButtonStyle())
                }
            }
            .padding(.horizontal, EFSpacing.xl)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Food Grid
    // KEY FIX: LazyVGrid inside a regular VStack — scrollable because parent is ScrollView
    private var foodGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(home.filteredFoods) { food in
                NavigationLink(destination: FoodDetailView(food: food)) {
                    FoodCardView(food: food) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            cart.add(food)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .padding(.horizontal, EFSpacing.xl)
        .animation(.spring(response: 0.38, dampingFraction: 0.75), value: home.selectedCategory)
    }
}

// MARK: - Food Card
struct FoodCardView: View {
    let food: FoodItem
    var onAddToCart: () -> Void
    @EnvironmentObject var home: HomeViewModel
    @State private var added = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            ZStack(alignment: .bottomLeading) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: food.imageURL)) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: Color.bgSubtle.overlay(ProgressView().tint(Color.brand))
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 128).clipped()

                    // Favourite button
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.5)) {
                            home.toggleSaved(food)
                        }
                    } label: {
                        Image(systemName: home.isSaved(food) ? "heart.fill" : "heart")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(home.isSaved(food) ? Color.red : Color.inkPrimary)
                            .frame(width: 28, height: 28)
                            .liquidGlass(cornerRadius: 9)
                    }
                    .buttonStyle(SpringButtonStyle())
                    .padding(8)
                }

                // Rating
                RatingBadge(rating: food.rating).padding(8)
            }
            .frame(height: 128).clipped()

            // Info section
            VStack(alignment: .leading, spacing: 0) {
                Text(food.name)
                    .font(EFFont.bold(13)).foregroundStyle(Color.inkPrimary).lineLimit(1)
                Text("\(food.deliveryTime) min · \(food.calories) kcal")
                    .font(EFFont.regular(11)).foregroundStyle(Color.inkTertiary).lineLimit(1)
                    .padding(.top, 2)

                HStack(alignment: .center) {
                    Text(food.price.ugxFormatted)
                        .font(EFFont.black(13)).foregroundStyle(Color.inkPrimary)
                    Spacer()
                    // Add to cart — instant feedback
                    Button {
                        onAddToCart()
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.55)) { added = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation { added = false }
                        }
                    } label: {
                        Image(systemName: added ? "checkmark" : "plus")
                            .font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(added ? Color.success : Color.inkPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .animation(.spring(response: 0.22, dampingFraction: 0.55), value: added)
                    }
                    .buttonStyle(SpringButtonStyle())
                }
                .padding(.top, 8)
            }
            .padding(11)
            .background(Color.bgCard)
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.xl))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.xl).stroke(Color.inkQuartern.opacity(0.12), lineWidth: 1))
        .efShadow()
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(CartViewModel())
        .environmentObject(HomeViewModel())
}
