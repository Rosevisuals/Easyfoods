import SwiftUI

// MARK: - Brand Colors
extension Color {
    static let brand       = Color(hex: "#FF6200")
    static let brandLight  = Color(hex: "#FF8533")
    static let brandPale   = Color(hex: "#FFF3EC")
    static let brandMid    = Color(hex: "#FFE4D0")

    static let inkPrimary  = Color(hex: "#111111")
    static let inkSecond   = Color(hex: "#444444")
    static let inkTertiary = Color(hex: "#888888")
    static let inkQuartern = Color(hex: "#BBBBBB")

    static let bgBase      = Color(hex: "#F8F7F4")
    static let bgCard      = Color(hex: "#FFFFFF")
    static let bgSubtle    = Color(hex: "#F2F0EC")

    static let success     = Color(hex: "#22C55E")
    static let successLight = Color(hex: "#F0FFF4")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
struct EFFont {
    static func black(_ size: CGFloat) -> Font  { .system(size: size, weight: .black,  design: .default) }
    static func bold(_ size: CGFloat) -> Font   { .system(size: size, weight: .bold,   design: .default) }
    static func semibold(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold) }
    static func medium(_ size: CGFloat) -> Font { .system(size: size, weight: .medium) }
    static func regular(_ size: CGFloat) -> Font { .system(size: size, weight: .regular) }
}

// MARK: - Spacing
struct EFSpacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - Corner Radius
struct EFRadius {
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 20
    static let xxl: CGFloat = 24
    static let pill: CGFloat = 100
}

// MARK: - Shadows
extension View {
    func efShadow() -> some View {
        self.shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
    func efShadowMedium() -> some View {
        self.shadow(color: .black.opacity(0.10), radius: 20, x: 0, y: 6)
    }
    func efShadowOrange() -> some View {
        self.shadow(color: Color.brand.opacity(0.30), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Brand Gradient
extension LinearGradient {
    static let brand = LinearGradient(
        colors: [Color.brand, Color.brandLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let promoBanner = LinearGradient(
        colors: [Color(hex: "#C44000"), Color.brand, Color(hex: "#FFAD66")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Format helpers
extension Int {
    var ugxFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return "UGX \(formatter.string(from: NSNumber(value: self)) ?? "\(self)")"
    }
}
