import SwiftUI

struct HomeView: View {
    @EnvironmentObject var cart: CartViewModel
    @EnvironmentObject var home: HomeViewModel
    @Binding var selectedTab: AppTab
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar
                    if showSearch { searchPanel.transition(.move(edge: .top).combined(with: .opacity)) }
                    headingSection
                    promoBanner
                    SectionHeader(title: "Category")
                    categoriesRow
                    SectionHeader(title: "Popular Near You")
                    foodGrid
                    Spacer(minLength: 20)
                }
            }
            .background(Color.bgBase)
            .navigationBarHidden(true)
            .animation(.spring(response: 0.32, dampingFraction: 0.78), value: showSearch)
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 10) {
            // Avatar + location
            HStack(spacing: 9) {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=80&q=80")) { phase in
                    if case .success(let img) = phase { img.resizable().scaledToFill() }
                    else { Color.brandPale }
                }
                .frame(width: 34, height: 34).clipShape(Circle())
                .overlay(Circle().stroke(Color.brand.opacity(0.2), lineWidth: 2))

                VStack(alignment: .leading, spacing: 1) {
                    Text("DELIVER TO")
                        .font(.system(size: 10, weight: .medium)).foregroundStyle(Color.inkTertiary).tracking(0.5)
                    HStack(spacing: 3) {
                        Text("Kololo, Kampala").font(EFFont.semibold(13)).foregroundStyle(Color.inkPrimary)
                        Image(systemName: "chevron.down").font(.system(size: 10, weight: .semibold)).foregroundStyle(Color.inkTertiary)
                    }
                }
            }
            .padding(.vertical, 6).padding(.horizontal, 12)
            .background(Color.bgCard).clipShape(Capsule()).efShadow()

            Spacer()

            // Search toggle
            Button { withAnimation { showSearch.toggle() } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                    .frame(width: 36, height: 36).background(Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: EFRadius.md)).efShadow()
            }.buttonStyle(SpringButtonStyle())

            // Cart
            Button { selectedTab = .cart } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                        .frame(width: 36, height: 36).background(Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: EFRadius.md)).efShadow()
                    if cart.itemCount > 0 {
                        Text("\(cart.itemCount)")
                            .font(.system(size: 9, weight: .black)).foregroundStyle(.white)
                            .frame(width: 16, height: 16).background(Color.brand).clipShape(Circle())
                            .overlay(Circle().stroke(Color.bgCard, lineWidth: 1.5))
                            .offset(x: 4, y: -4)
                            .transition(.scale(scale: 0.3).combined(with: .opacity))
                            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: cart.itemCount)
                    }
                }
            }.buttonStyle(SpringButtonStyle())
        }
        .padding(.horizontal, EFSpacing.xl).padding(.top, 8).padding(.bottom, 12)
    }

    // MARK: - Search Panel (shown when search tapped)
    private var searchPanel: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.system(size: 14)).foregroundStyle(Color.inkTertiary)
                TextField("Search food, restaurants…", text: $home.searchText)
                    .font(EFFont.regular(14)).foregroundStyle(Color.inkPrimary)
                if !home.searchText.isEmpty {
                    Button { home.searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(Color.inkQuartern)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(home.searchText.isEmpty ? Color.inkQuartern.opacity(0.2) : Color.brand.opacity(0.4), lineWidth: 1))
            .efShadow()
            .padding(.horizontal, EFSpacing.xl)

            // Quick filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(FoodCategory.allCases.filter { $0 != .all }) { cat in
                        Button { home.selectedCategory = cat; home.searchText = cat.rawValue } label: {
                            HStack(spacing: 5) {
                                Text(cat.emoji).font(.system(size: 13))
                                Text(cat.rawValue).font(EFFont.medium(12)).foregroundStyle(Color.inkSecond)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 7)
                            .background(Color.bgCard).clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.inkQuartern.opacity(0.25), lineWidth: 1))
                            .efShadow()
                        }.buttonStyle(SpringButtonStyle())
                    }
                }.padding(.horizontal, EFSpacing.xl)
            }
        }
        .padding(.bottom, 12)
    }

    // MARK: - Heading
    private var headingSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("What are you")
                .font(.system(size: 26, weight: .semibold)).foregroundStyle(Color.inkPrimary)
            (Text("craving today?").font(.system(size: 26, weight: .bold)).foregroundStyle(Color.inkPrimary))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, EFSpacing.xl).padding(.bottom, 16)
    }

    // MARK: - Promo Banner
    private var promoBanner: some View {
        ZStack {
            LinearGradient.promoBanner
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&q=90")) { phase in
                if case .success(let img) = phase {
                    img.resizable().scaledToFill()
                        .frame(width: 150, height: 154).clipShape(Circle()).opacity(0.9)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing).padding(.trailing, -4).padding(.top, -14).clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text("🔥  Limited offer").font(.system(size: 11, weight: .medium)).foregroundStyle(.white.opacity(0.8))
                Text("Order a set\nwith 40% off").font(.system(size: 20, weight: .bold)).foregroundStyle(.white).lineSpacing(1)
                Button { cart.add(MockData.foods[0]); withAnimation { selectedTab = .cart } } label: {
                    Text("Order Now →").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(.white.opacity(0.2)).clipShape(Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.35), lineWidth: 1))
                }.buttonStyle(SpringButtonStyle()).padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 18)
        }
        .frame(height: 128)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.xxl))
        .shadow(color: Color.brand.opacity(0.20), radius: 16, x: 0, y: 6)
        .padding(.horizontal, EFSpacing.xl).padding(.bottom, 20)
    }

    // MARK: - Categories
    private var categoriesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FoodCategory.allCases) { cat in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) { home.selectedCategory = cat }
                    } label: {
                        HStack(spacing: 6) {
                            Text(cat.emoji).font(.system(size: 15))
                            Text(cat.rawValue)
                                .font(.system(size: 12, weight: home.selectedCategory == cat ? .semibold : .regular))
                                .foregroundStyle(home.selectedCategory == cat ? .white : Color.inkSecond)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(home.selectedCategory == cat ? Color.inkPrimary : Color.bgCard)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(
                            home.selectedCategory == cat ? Color.clear : Color.inkQuartern.opacity(0.25), lineWidth: 1.5))
                        .shadow(color: .black.opacity(home.selectedCategory == cat ? 0.1 : 0.04), radius: 5, x: 0, y: 2)
                    }.buttonStyle(SpringButtonStyle())
                }
            }.padding(.horizontal, EFSpacing.xl)
        }.padding(.bottom, 16)
    }

    // MARK: - Food Grid
    private var foodGrid: some View {
        Group {
            if home.filteredFoods.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36, weight: .thin))
                        .foregroundStyle(Color.inkQuartern)
                    Text("No results found").font(EFFont.semibold(16)).foregroundStyle(Color.inkSecond)
                    Text("Try a different search or category")
                        .font(EFFont.regular(13)).foregroundStyle(Color.inkTertiary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 40)
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(home.filteredFoods) { food in
                        NavigationLink(destination: FoodDetailView(food: food)) {
                            FoodCardView(food: food) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { cart.add(food) }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }
                }
                .padding(.horizontal, EFSpacing.xl)
                .animation(.spring(response: 0.38, dampingFraction: 0.75), value: home.selectedCategory)
                .animation(.spring(response: 0.38, dampingFraction: 0.75), value: home.searchText)
            }
        }
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
            // Image
            ZStack(alignment: .bottomLeading) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: food.imageURL)) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: Color.bgSubtle.overlay(ProgressView().tint(Color.brand))
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 126).clipped()

                    // Heart — no glass rectangle
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.5)) { home.toggleSaved(food) }
                    } label: {
                        Image(systemName: home.isSaved(food) ? "heart.fill" : "heart")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(home.isSaved(food) ? Color.red : .white)
                            .shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 1)
                            .padding(10)
                    }.buttonStyle(SpringButtonStyle())
                }

                // Rating — plain text, no glass box
                HStack(spacing: 3) {
                    Image(systemName: "star.fill").font(.system(size: 10)).foregroundStyle(Color(hex: "#F59E0B"))
                    Text(String(format: "%.1f", food.rating)).font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(.black.opacity(0.35)).clipShape(Capsule())
                .padding(8)
            }
            .frame(height: 126).clipped()

            // Body
            VStack(alignment: .leading, spacing: 0) {
                Text(food.name).font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.inkPrimary).lineLimit(1)
                Text("\(food.deliveryTime) min · \(food.calories) kcal")
                    .font(.system(size: 11, weight: .regular)).foregroundStyle(Color.inkTertiary).lineLimit(1).padding(.top, 2)

                HStack(alignment: .center) {
                    Text(food.price.ugxFormatted).font(.system(size: 13, weight: .bold)).foregroundStyle(Color.inkPrimary)
                    Spacer()
                    Button {
                        onAddToCart()
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.55)) { added = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { withAnimation { added = false } }
                    } label: {
                        Image(systemName: added ? "checkmark" : "plus")
                            .font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(added ? Color.success : Color.inkPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .animation(.spring(response: 0.22, dampingFraction: 0.55), value: added)
                    }.buttonStyle(SpringButtonStyle())
                }.padding(.top, 8)
            }
            .padding(11).background(Color.bgCard)
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.xl))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.xl).stroke(Color.inkQuartern.opacity(0.1), lineWidth: 1))
        .efShadow()
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home)).environmentObject(CartViewModel()).environmentObject(HomeViewModel())
}

