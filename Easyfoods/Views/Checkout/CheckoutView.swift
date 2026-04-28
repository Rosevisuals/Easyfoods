import SwiftUI

// MARK: - Checkout
struct CheckoutView: View {
    @EnvironmentObject var cart: CartViewModel
    @State private var isPlacingOrder = false
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            Color.bgBase.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Deliver To
                    sectionCard {
                        sectionLabel("Deliver To")
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.brand)
                                .frame(width: 36, height: 36)
                                .background(Color.brandPale)
                                .clipShape(RoundedRectangle(cornerRadius: EFRadius.sm))
                                .overlay(RoundedRectangle(cornerRadius: EFRadius.sm).stroke(Color.brandMid, lineWidth: 1))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Home — Kololo")
                                    .font(EFFont.bold(14))
                                    .foregroundStyle(Color.inkPrimary)
                                Text("Plot 23, Prince Charles Drive, Kampala")
                                    .font(EFFont.regular(12))
                                    .foregroundStyle(Color.inkTertiary)
                            }
                        }
                    }

                    // Payment
                    sectionCard {
                        sectionLabel("Payment Method")
                        VStack(spacing: 0) {
                            ForEach(PaymentMethod.allCases) { method in
                                PaymentOptionRow(method: method, selected: $cart.selectedPayment)
                                if method != PaymentMethod.allCases.last {
                                    Divider().padding(.leading, 50)
                                }
                            }
                        }
                    }

                    // Summary
                    sectionCard {
                        sectionLabel("Order Summary")
                        VStack(spacing: 4) {
                            ForEach(cart.items) { item in
                                HStack {
                                    Text("\(item.food.name)\(item.quantity > 1 ? " ×\(item.quantity)" : "")")
                                        .font(EFFont.regular(13))
                                        .foregroundStyle(Color.inkSecond)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(item.subtotal.ugxFormatted)
                                        .font(EFFont.semibold(13))
                                        .foregroundStyle(Color.inkSecond)
                                }
                            }
                            Divider().padding(.vertical, 6)
                            HStack {
                                Text("Total")
                                    .font(EFFont.black(15))
                                    .foregroundStyle(Color.inkPrimary)
                                Spacer()
                                Text(cart.total.ugxFormatted)
                                    .font(EFFont.black(15))
                                    .foregroundStyle(Color.brand)
                            }
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)

            // CTA
            VStack {
                Spacer()
                PrimaryButton("🎉  Place Order") {
                    Task { await placeOrder() }
                }
                .padding(.horizontal, EFSpacing.lg)
                .padding(.vertical, 10)
                .background(
                    Color.bgCard.opacity(0.95)
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea(edges: .bottom)
                )
            }

            // Overlays
            if isPlacingOrder { ProcessingView() }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $showSuccess) {
            SuccessView()
        }
    }

    private func placeOrder() async {
        withAnimation { isPlacingOrder = true }
        await cart.placeOrder()
        withAnimation { isPlacingOrder = false }
        showSuccess = true
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) { content() }
            .padding(16)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: EFRadius.xl))
            .overlay(RoundedRectangle(cornerRadius: EFRadius.xl).stroke(Color.inkQuartern.opacity(0.15), lineWidth: 1))
            .efShadow()
            .padding(.horizontal, EFSpacing.lg)
            .padding(.bottom, 10)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(EFFont.semibold(10))
            .foregroundStyle(Color.inkTertiary)
            .tracking(0.8)
            .padding(.bottom, 10)
    }
}

// MARK: - Payment Option Row
struct PaymentOptionRow: View {
    let method: PaymentMethod
    @Binding var selected: PaymentMethod

    var body: some View {
        Button { withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { selected = method } } label: {
            HStack(spacing: 10) {
                Text(method.emoji)
                    .font(.system(size: 16))
                    .frame(width: 34, height: 34)
                    .background(Color.bgSubtle)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.inkQuartern.opacity(0.25), lineWidth: 1))

                Text(method.rawValue)
                    .font(EFFont.semibold(13))
                    .foregroundStyle(Color.inkPrimary)

                Spacer()

                // Radio
                ZStack {
                    Circle().stroke(selected == method ? Color.brand : Color.inkQuartern.opacity(0.5), lineWidth: 2)
                    if selected == method {
                        Circle()
                            .fill(Color.brand)
                            .frame(width: 10, height: 10)
                            .transition(.scale)
                    }
                }
                .frame(width: 20, height: 20)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selected)
            }
            .padding(.vertical, 11)
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Processing View
struct ProcessingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Color.bgCard.opacity(0.96).ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.brandPale, lineWidth: 4)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(LinearGradient.brand, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(.linear(duration: 0.85).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                }

                Text("Processing Order")
                    .font(EFFont.black(20))
                    .foregroundStyle(Color.inkPrimary)

                Text("Confirming with restaurant…")
                    .font(EFFont.regular(13))
                    .foregroundStyle(Color.inkTertiary)

                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { i in
                        BouncingDot(delay: Double(i) * 0.15)
                    }
                }
            }
        }
        .transition(.opacity)
    }
}

struct BouncingDot: View {
    let delay: Double
    @State private var bouncing = false
    var body: some View {
        Circle()
            .fill(Color.brand)
            .frame(width: 7, height: 7)
            .scaleEffect(bouncing ? 1 : 0.5)
            .opacity(bouncing ? 1 : 0.2)
            .animation(.easeInOut(duration: 0.45).repeatForever().delay(delay), value: bouncing)
            .onAppear { bouncing = true }
    }
}

// MARK: - Success View
struct SuccessView: View {
    @EnvironmentObject var cart: CartViewModel
    @State private var showCheck = false
    @State private var showContent = false
    @State private var navigateToTracking = false
    @State private var navigateHome = false

    var body: some View {
        ZStack {
            Color.bgCard.ignoresSafeArea()
            ConfettiView()

            VStack(spacing: 16) {
                Spacer()

                // Check circle
                ZStack {
                    Circle()
                        .fill(Color.success.opacity(0.1))
                        .frame(width: 110, height: 110)
                    Circle()
                        .fill(Color.success)
                        .frame(width: showCheck ? 96 : 20, height: 96)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundStyle(.white)
                                .opacity(showCheck ? 1 : 0)
                        )
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.15), value: showCheck)

                Text("Order Placed!")
                    .font(EFFont.black(28))
                    .foregroundStyle(Color.inkPrimary)
                    .tracking(-0.5)

                Text("Your food is being prepared\nand will arrive soon 🛵")
                    .font(EFFont.regular(14))
                    .foregroundStyle(Color.inkTertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                // Order ID
                Text("Order #\(cart.currentOrder?.id ?? "EF-2847")")
                    .font(EFFont.bold(13))
                    .foregroundStyle(Color.brand)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Color.brandPale)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.brandMid, lineWidth: 1))

                // Rider card
                HStack(spacing: 10) {
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&q=80")) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFill()
                        } else { Color.bgSubtle }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.brandMid, lineWidth: 2))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("James Kato")
                            .font(EFFont.bold(14)).foregroundStyle(Color.inkPrimary)
                        Text("Delivery Rider · ★ 4.9")
                            .font(EFFont.regular(11)).foregroundStyle(Color.inkTertiary)
                    }

                    Spacer()

                    HStack(spacing: 7) {
                        iconActionBtn("message")
                        iconActionBtn("phone")
                    }
                }
                .padding(14)
                .background(Color.bgSubtle)
                .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
                .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(Color.inkQuartern.opacity(0.2), lineWidth: 1))

                // ETA row
                HStack(spacing: 8) {
                    etaCard(icon: "⏱️", value: "30–40 min", label: "Estimated ETA")
                    etaCard(icon: "📍", value: "On the way", label: "Status")
                }

                Spacer()

                // CTAs
                VStack(spacing: 8) {
                    NavigationLink(destination: TrackingMapView(), isActive: $navigateToTracking) { EmptyView() }
                    PrimaryButton("Track Order 🗺️") { navigateToTracking = true }

                    GhostButton(title: "Back to Home") { navigateHome = true }
                }

                NavigationLink(destination: EmptyView(), isActive: $navigateHome) { EmptyView() }
            }
            .padding(.horizontal, 22)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showCheck = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { showContent = true }
        }
    }

    private func iconActionBtn(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.inkSecond)
            .frame(width: 34, height: 34)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: EFRadius.sm))
            .efShadow()
    }

    private func etaCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(icon).font(.system(size: 20))
            Text(value).font(EFFont.bold(13)).foregroundStyle(Color.inkPrimary)
            Text(label).font(EFFont.regular(10)).foregroundStyle(Color.inkTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.bgSubtle)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.md).stroke(Color.inkQuartern.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Confetti
struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            addConfetti(to: view)
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}

    private func addConfetti(to view: UIView) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)

        let colors: [UIColor] = [.systemOrange, UIColor(red: 1, green: 0.4, blue: 0, alpha: 1), .systemGreen, .systemBlue, .systemPink, .white, .black]

        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 4
            cell.lifetime = 5
            cell.velocity = 250
            cell.velocityRange = 100
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 2
            cell.spinRange = 3
            cell.scaleRange = 0.5
            cell.scaleSpeed = -0.05
            cell.color = color.cgColor
            cell.contents = UIImage(systemName: "square.fill")?.cgImage
            cell.scale = 0.06
            return cell
        }

        view.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            emitter.birthRate = 0
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView().environmentObject({
            let vm = CartViewModel()
            vm.add(MockData.foods[0], quantity: 2)
            return vm
        }())
    }
}
