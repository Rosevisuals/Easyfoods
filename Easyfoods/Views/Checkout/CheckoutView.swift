import SwiftUI

// MARK: - Checkout
struct CheckoutView: View {
    @EnvironmentObject var cart: CartViewModel
    @EnvironmentObject var history: OrderHistoryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isPlacing = false
    @State private var goSuccess = false

    var body: some View {
        VStack(spacing: 0) {

            // ── Nav ──
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.inkPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.bgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: EFRadius.md).stroke(Color.inkQuartern.opacity(0.18), lineWidth: 1))
                }
                .buttonStyle(SpringButtonStyle())

                Text("Checkout")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color.inkPrimary)
                Spacer()
            }
            .padding(.horizontal, EFSpacing.xl)
            .padding(.vertical, 12)

            Divider().opacity(0.35)

            // ── Scrollable sections ──
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    // Deliver to
                    sectionCard {
                        sectionLabel("Deliver To")
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.brand)
                                .frame(width: 36, height: 36)
                                .background(Color.brandPale)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Home — Kololo")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.inkPrimary)
                                Text("Plot 23, Prince Charles Drive, Kampala")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.inkTertiary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.inkQuartern)
                        }
                    }

                    // Payment
                    sectionCard {
                        sectionLabel("Payment Method")
                        ForEach(PaymentMethod.allCases) { method in
                            VStack(spacing: 0) {
                                Button {
                                    withAnimation(.spring(response: 0.22, dampingFraction: 0.7)) {
                                        cart.selectedPayment = method
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        Text(method.emoji)
                                            .font(.system(size: 16))
                                            .frame(width: 34, height: 34)
                                            .background(Color.bgSubtle)
                                            .clipShape(RoundedRectangle(cornerRadius: 9))

                                        Text(method.rawValue)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(Color.inkPrimary)
                                        Spacer()

                                        // Radio dot
                                        ZStack {
                                            Circle()
                                                .stroke(cart.selectedPayment == method ? Color.brand : Color.inkQuartern.opacity(0.4), lineWidth: 2)
                                            if cart.selectedPayment == method {
                                                Circle().fill(Color.brand).frame(width: 10, height: 10)
                                                    .transition(.scale.combined(with: .opacity))
                                            }
                                        }
                                        .frame(width: 20, height: 20)
                                        .animation(.spring(response: 0.22, dampingFraction: 0.7), value: cart.selectedPayment)
                                    }
                                    .padding(.vertical, 11)
                                }
                                .buttonStyle(SpringButtonStyle())

                                if method != PaymentMethod.allCases.last {
                                    Divider().padding(.leading, 44)
                                }
                            }
                        }
                    }

                    // Order summary
                    sectionCard {
                        sectionLabel("Order Summary")
                        ForEach(cart.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("\(item.food.name)\(item.quantity > 1 ? " ×\(item.quantity)" : "")")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.inkSecond)
                                        .lineLimit(1)
                                    if !item.selectedAddons.isEmpty {
                                        Text(item.selectedAddons.map { $0.name }.joined(separator: ", "))
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.inkTertiary)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                                Text(item.subtotal.ugxFormatted)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.inkSecond)
                            }
                            .padding(.vertical, 3)
                        }
                        Divider().padding(.vertical, 8)
                        HStack {
                            Text("Total")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.inkPrimary)
                            Spacer()
                            Text(cart.total.ugxFormatted)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.brand)
                        }
                    }
                }
                .padding(.horizontal, EFSpacing.lg)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            // ── Place order CTA ──
            VStack(spacing: 0) {
                Divider().opacity(0.35)
                Button {
                    Task { await placeOrder() }
                } label: {
                    HStack(spacing: 8) {
                        if isPlacing {
                            ProgressView().tint(.white).scaleEffect(0.8)
                            Text("Placing order…")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                        } else {
                            Text("🎉")
                            Text("Place Order · \(cart.total.ugxFormatted)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(AnyShapeStyle(isPlacing ? AnyShapeStyle(Color.inkTertiary) : AnyShapeStyle(LinearGradient.brand)))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .efShadowOrange()
                    .animation(.easeOut(duration: 0.2), value: isPlacing)
                }
                .buttonStyle(SpringButtonStyle())
                .disabled(isPlacing)
                .padding(.horizontal, EFSpacing.lg)
                .padding(.vertical, 12)
                .background(Color.bgCard)
            }
        }
        .background(Color.bgBase)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $goSuccess) {
            SuccessView()
        }
    }

    private func placeOrder() async {
        withAnimation { isPlacing = true }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        await cart.placeOrder()
        // Add to order history
        if let order = cart.currentOrder { history.addOrder(order) }
        withAnimation { isPlacing = false }
        goSuccess = true
    }

    private func sectionCard<C: View>(@ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 0) { content() }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: EFRadius.xl))
            .overlay(RoundedRectangle(cornerRadius: EFRadius.xl).stroke(Color.inkQuartern.opacity(0.1), lineWidth: 1))
            .efShadow()
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Color.inkTertiary)
            .tracking(0.8)
            .padding(.bottom, 10)
    }
}

// MARK: - Success View
struct SuccessView: View {
    @EnvironmentObject var cart: CartViewModel
    @EnvironmentObject var history: OrderHistoryViewModel
    @State private var checkScale: CGFloat = 0.2
    @State private var checkOpacity: Double = 0
    @State private var bodyOpacity: Double = 0
    @State private var bodyOffset: CGFloat = 18
    @State private var goTracking = false
    @State private var goHome = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    Spacer(minLength: 28)

                    // Animated check circle
                    ZStack {
                        Circle()
                            .fill(Color.success.opacity(0.08))
                            .frame(width: 120, height: 120)
                        Circle()
                            .fill(Color.success)
                            .frame(width: 96, height: 96)
                            .scaleEffect(checkScale)
                            .opacity(checkOpacity)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundStyle(.white)
                                    .opacity(checkOpacity)
                            )
                    }

                    VStack(spacing: 6) {
                        Text("Order Placed!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.inkPrimary)
                            .tracking(-0.3)

                        Text("Your food is being prepared\nand will arrive soon 🛵")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.inkTertiary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }

                    // Order ID pill
                    Text("Order #\(cart.currentOrder?.id ?? "EF-2847")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.brand)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color.brandPale)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.brandMid, lineWidth: 1))

                    // Rider card
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: MockData.rider.avatarURL)) { phase in
                            if case .success(let img) = phase { img.resizable().scaledToFill() }
                            else { Color.bgSubtle }
                        }
                        .frame(width: 46, height: 46).clipShape(Circle())
                        .overlay(Circle().stroke(Color.brandMid, lineWidth: 2))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(MockData.rider.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.inkPrimary)
                            Text("Delivery Rider · ★ \(String(format: "%.1f", MockData.rider.rating))")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.inkTertiary)
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            riderActionBtn("message.fill", Color.brandPale, Color.brand)
                            riderActionBtn("phone.fill", Color(hex: "#F0FFF4"), Color.success)
                        }
                    }
                    .padding(14)
                    .background(Color.bgSubtle)
                    .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
                    .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(Color.inkQuartern.opacity(0.15), lineWidth: 1))

                    // ETA row
                    HStack(spacing: 8) {
                        etaBox(icon: "clock", value: "30–40 min", label: "Est. arrival")
                        etaBox(icon: "location.fill", value: "On the way", label: "Status")
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 28)
            }
            .opacity(bodyOpacity)
            .offset(y: bodyOffset)

            // ── Pinned CTAs ──
            VStack(spacing: 8) {
                Divider().opacity(0.35)
                NavigationLink(destination: TrackingMapView(rider: MockData.rider), isActive: $goTracking) { EmptyView() }
                PrimaryButton("Track Order 🗺️") { goTracking = true }
                    .padding(.horizontal, EFSpacing.lg)

                GhostButton(title: "Back to Home") { goHome = true }
                    .padding(.horizontal, EFSpacing.lg)
                    .padding(.bottom, 8)
            }
            .background(Color.bgCard)
        }
        .background(Color.bgCard)
        .navigationBarHidden(true)
        .overlay(alignment: .top) { ConfettiView().allowsHitTesting(false) }
        .onAppear {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.55, dampingFraction: 0.58).delay(0.1)) {
                checkScale = 1; checkOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.45).delay(0.3)) {
                bodyOpacity = 1; bodyOffset = 0
            }
        }
        // goHome pops entire nav stack
        .onChange(of: goHome) { val in
            if val {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.windows.first?.rootViewController {
                    root.dismiss(animated: true)
                }
            }
        }
    }

    private func riderActionBtn(_ icon: String, _ bg: Color, _ fg: Color) -> some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(fg)
            .frame(width: 36, height: 36)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func etaBox(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 18)).foregroundStyle(Color.brand)
            Text(value).font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.inkPrimary)
            Text(label).font(.system(size: 10)).foregroundStyle(Color.inkTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.bgSubtle)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.md).stroke(Color.inkQuartern.opacity(0.15), lineWidth: 1))
    }
}

// MARK: - Confetti
struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let v = UIView(); v.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { addEmitter(to: v) }
        return v
    }
    func updateUIView(_ uiView: UIView, context: Context) {}

    private func addEmitter(to view: UIView) {
        let e = CAEmitterLayer()
        e.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        e.emitterShape = .line
        e.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        let colors: [UIColor] = [
            UIColor(Color.brand), UIColor(Color.brandLight),
            .systemGreen, .systemBlue, .systemPink, .white, .black
        ]
        e.emitterCells = colors.map { color in
            let c = CAEmitterCell()
            c.birthRate = 5; c.lifetime = 5; c.velocity = 260; c.velocityRange = 100
            c.emissionLongitude = .pi; c.emissionRange = .pi / 4
            c.spin = 2; c.spinRange = 3; c.scaleRange = 0.5; c.scaleSpeed = -0.05
            c.color = color.cgColor
            c.contents = UIImage(systemName: "square.fill")?.cgImage; c.scale = 0.06
            return c
        }
        view.layer.addSublayer(e)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { e.birthRate = 0 }
    }
}

// MARK: - Processing (inline overlay)
struct ProcessingView: View {
    @State private var rot: Double = 0
    var body: some View {
        ZStack {
            Color.bgCard.opacity(0.96).ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle().stroke(Color.brandPale, lineWidth: 4).frame(width: 68, height: 68)
                    Circle().trim(from: 0, to: 0.75)
                        .stroke(LinearGradient.brand, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 68, height: 68)
                        .rotationEffect(.degrees(rot))
                        .onAppear {
                            withAnimation(.linear(duration: 0.85).repeatForever(autoreverses: false)) { rot = 360 }
                        }
                }
                Text("Processing Order")
                    .font(.system(size: 19, weight: .bold)).foregroundStyle(Color.inkPrimary)
                Text("Confirming with restaurant…")
                    .font(.system(size: 13)).foregroundStyle(Color.inkTertiary)
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { i in BouncingDot(delay: Double(i) * 0.15) }
                }
            }
        }
        .transition(.opacity)
    }
}

struct BouncingDot: View {
    let delay: Double
    @State private var on = false
    var body: some View {
        Circle().fill(Color.brand).frame(width: 7, height: 7)
            .scaleEffect(on ? 1 : 0.4).opacity(on ? 1 : 0.2)
            .animation(.easeInOut(duration: 0.45).repeatForever().delay(delay), value: on)
            .onAppear { on = true }
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
            .environmentObject({ let vm = CartViewModel(); vm.add(MockData.foods[0], quantity: 2); return vm }())
            .environmentObject(OrderHistoryViewModel())
            .environmentObject(HomeViewModel())
    }
}
