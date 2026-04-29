import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var nameOpacity: Double = 0
    @State private var nameOffset: CGFloat = 10
    @State private var progressWidth: CGFloat = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#FFF5EE"),
                    Color(hex: "#FFE8D0"),
                    Color(hex: "#FFDBB8")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                // Logo icon with liquid glass
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.white.opacity(0.70))
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(.white.opacity(0.9), lineWidth: 1.5)
                        )
                        .shadow(color: Color.brand.opacity(0.20), radius: 24, x: 0, y: 12)

                    Text("🍽️")
                        .font(.system(size: 52))
                }
                .scaleEffect(scale)
                .opacity(opacity)

                // App name
                VStack(spacing: 4) {
                    Text("Easy Foods")
                        .font(EFFont.black(34))
                        .foregroundStyle(Color.inkPrimary)
                        .tracking(-1.2)

                    Text("Order in seconds. Delivered fresh.")
                        .font(EFFont.regular(13))
                        .foregroundStyle(Color.inkTertiary)
                        .italic()
                }
                .opacity(nameOpacity)
                .offset(y: nameOffset)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.08)).frame(height: 3)
                        Capsule()
                            .fill(LinearGradient.brand)
                            .frame(width: progressWidth * geo.size.width, height: 3)
                    }
                }
                .frame(width: 44, height: 3)
                .opacity(nameOpacity)
                .padding(.top, 8)
            }
        }
        .onAppear { animate() }
    }

    private func animate() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
            scale = 1; opacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
            nameOpacity = 1; nameOffset = 0
        }
        withAnimation(.easeInOut(duration: 1.8).delay(0.8)) {
            progressWidth = 1
        }
    }
}

#Preview { SplashView() }

