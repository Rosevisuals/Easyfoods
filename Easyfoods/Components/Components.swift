import SwiftUI

// MARK: - Primary Button  h=44, radius=30
struct PrimaryButton: View {
    let title: String
    let icon: String?
    var isFullWidth = true
    var action: () -> Void

    init(_ title: String, icon: String? = nil, isFullWidth: Bool = true, action: @escaping () -> Void) {
        self.title = title; self.icon = icon; self.isFullWidth = isFullWidth; self.action = action
    }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon { Text(icon).font(.system(size: 14)) }
                Text(title).font(EFFont.semibold(15))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(height: 44)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(LinearGradient.brand)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .efShadowOrange()
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Ghost Button  h=44, radius=30
struct GhostButton: View {
    let title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(EFFont.semibold(15)).foregroundStyle(Color.inkSecond)
                .frame(height: 44).frame(maxWidth: .infinity)
                .background(Color.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.inkQuartern.opacity(0.4), lineWidth: 1.5))
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Quantity Stepper
struct QuantityStepper: View {
    @Binding var quantity: Int
    var body: some View {
        HStack(spacing: 12) {
            Button {
                if quantity > 1 { withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { quantity -= 1 } }
            } label: {
                Image(systemName: "minus").font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                    .frame(width: 30, height: 30).background(Color.bgSubtle)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.inkQuartern.opacity(0.25), lineWidth: 1))
            }.buttonStyle(SpringButtonStyle())

            Text("\(quantity)").font(EFFont.semibold(15)).foregroundStyle(Color.inkPrimary)
                .frame(minWidth: 24).contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: quantity)

            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { quantity += 1 }
            } label: {
                Image(systemName: "plus").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 30, height: 30).background(Color.inkPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
            }.buttonStyle(SpringButtonStyle())
        }
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(Color.bgSubtle)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.md).stroke(Color.inkQuartern.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Liquid Glass — ONLY over images / coloured backgrounds
struct LiquidGlass: ViewModifier {
    var cornerRadius: CGFloat = 14
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .overlay(LinearGradient(colors: [.white.opacity(0.40), .clear, .white.opacity(0.10)],
                startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(.white.opacity(0.55), lineWidth: 1))
    }
}
extension View {
    func liquidGlass(cornerRadius: CGFloat = 14) -> some View { modifier(LiquidGlass(cornerRadius: cornerRadius)) }
}

// MARK: - Spring Button Style
struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Star Rating (plain — no glass rectangle)
struct StarRating: View {
    let rating: Double
    let count: Int
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 11)).foregroundStyle(Color(hex: "#F59E0B"))
            Text(String(format: "%.1f", rating))
                .font(EFFont.semibold(12)).foregroundStyle(Color.inkSecond)
            Text("(\(count))")
                .font(EFFont.regular(11)).foregroundStyle(Color.inkTertiary)
        }
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let label: String
    var body: some View {
        Text(label).font(EFFont.medium(11)).foregroundStyle(Color.brand)
            .padding(.horizontal, 11).padding(.vertical, 5)
            .background(Color.brandPale).clipShape(Capsule())
            .overlay(Capsule().stroke(Color.brandMid, lineWidth: 1))
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String; var onAction: (() -> Void)? = nil
    var body: some View {
        HStack {
            Text(title).font(EFFont.semibold(15)).foregroundStyle(Color.inkPrimary)
            Spacer()
            if let onAction {
                Button("See All", action: onAction).font(EFFont.medium(13)).foregroundStyle(Color.brand)
            }
        }
        .padding(.horizontal, EFSpacing.xl).padding(.bottom, 10)
    }
}

// MARK: - AppTab  (saved → orders)
enum AppTab: String, CaseIterable, Identifiable {
    case home, cart, orders, profile
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .home:    return "house.fill"
        case .cart:    return "cart.fill"
        case .orders:  return "list.bullet.rectangle.fill"
        case .profile: return "person.fill"
        }
    }
    var label: String {
        switch self {
        case .home:    return "Home"
        case .cart:    return "Cart"
        case .orders:  return "Orders"
        case .profile: return "Profile"
        }
    }
}

// MARK: - Tab Bar — white, SF Symbols, clean
struct FloatingTabBar: View {
    @Binding var selected: AppTab
    let cartCount: Int

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.black.opacity(0.07)).frame(height: 0.5)
            HStack(spacing: 0) {
                ForEach(AppTab.allCases) { tab in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) { selected = tab }
                    } label: {
                        VStack(spacing: 4) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 21, weight: selected == tab ? .bold : .regular))
                                    .foregroundStyle(selected == tab ? Color.brand : Color(hex: "#AAAAAA"))
                                    .frame(width: 28, height: 28)
                                    .scaleEffect(selected == tab ? 1.08 : 1.0)
                                    .animation(.spring(response: 0.28, dampingFraction: 0.6), value: selected)

                                if tab == .cart && cartCount > 0 {
                                    Text("\(min(cartCount, 9))")
                                        .font(.system(size: 9, weight: .black)).foregroundStyle(.white)
                                        .frame(width: 16, height: 16).background(Color.brand)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.bgCard, lineWidth: 1.5))
                                        .offset(x: 10, y: -5)
                                        .transition(.scale(scale: 0.3).combined(with: .opacity))
                                        .animation(.spring(response: 0.3, dampingFraction: 0.55), value: cartCount)
                                }
                            }
                            Text(tab.label)
                                .font(.system(size: 10, weight: selected == tab ? .semibold : .regular))
                                .foregroundStyle(selected == tab ? Color.brand : Color(hex: "#AAAAAA"))
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                    }
                    .buttonStyle(SpringButtonStyle())
                }
            }
            .padding(.horizontal, 8).padding(.bottom, 8)
            .background(Color.bgCard)
        }
        .background(Color.bgCard)
    }
}

