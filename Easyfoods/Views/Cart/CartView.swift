import SwiftUI

struct CartView: View {
    @EnvironmentObject var cart: CartViewModel
    @State private var goCheckout = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Header ──
                HStack {
                    Text("My Cart")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.inkPrimary)
                    Spacer()
                    if !cart.isEmpty {
                        Button("Clear all") {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { cart.clear() }
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.inkTertiary)
                    }
                }
                .padding(.horizontal, EFSpacing.xl)
                .padding(.top, 8)
                .padding(.bottom, 14)

                Divider().opacity(0.35)

                if cart.isEmpty {
                    emptyState
                } else {
                    // ── Scrollable content ──
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(cart.items) { item in
                                CartItemRow(item: item)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.97)),
                                        removal: .opacity.combined(with: .move(edge: .trailing))
                                    ))
                            }
                            summaryCard.padding(.top, 4)
                        }
                        .padding(.horizontal, EFSpacing.lg)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                        .animation(.spring(response: 0.32, dampingFraction: 0.75), value: cart.items.count)
                    }

                    // ── Pinned CTA ──
                    VStack(spacing: 0) {
                        Divider().opacity(0.35)
                        NavigationLink(destination: CheckoutView(), isActive: $goCheckout) { EmptyView() }

                        Button {
                            goCheckout = true
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("\(cart.itemCount) item\(cart.itemCount == 1 ? "" : "s")")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(.white.opacity(0.75))
                                    Text(cart.total.ugxFormatted)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                                Text("Checkout →")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 22)
                            .frame(height: 44)
                            .background(LinearGradient.brand)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .efShadowOrange()
                        }
                        .buttonStyle(SpringButtonStyle())
                        .padding(.horizontal, EFSpacing.lg)
                        .padding(.vertical, 12)
                        .background(Color.bgCard)
                    }
                }
            }
            .background(Color.bgBase)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: 0) {
            summaryRow("Subtotal",    cart.subtotal.ugxFormatted,    bold: false)
            Divider().padding(.vertical, 7)
            summaryRow("Delivery fee", cart.deliveryFee.ugxFormatted, bold: false)
            summaryRow("Service fee",  cart.serviceFee.ugxFormatted,  bold: false)
            Divider().padding(.vertical, 7)
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
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.xl))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.xl).stroke(Color.inkQuartern.opacity(0.12), lineWidth: 1))
        .efShadow()
    }

    private func summaryRow(_ label: String, _ value: String, bold: Bool) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: bold ? .semibold : .regular))
                .foregroundStyle(bold ? Color.inkPrimary : Color.inkTertiary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: bold ? .semibold : .medium))
                .foregroundStyle(bold ? Color.brand : Color.inkSecond)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "cart")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(Color.inkQuartern)
            Text("Your cart is empty")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.inkSecond)
            Text("Browse the menu and add something\ndelicious to get started")
                .font(.system(size: 13))
                .foregroundStyle(Color.inkQuartern)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cart: CartViewModel

    var body: some View {
        HStack(spacing: 0) {
            // Food image
            AsyncImage(url: URL(string: item.food.imageURL)) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { Color.bgSubtle }
            }
            .frame(width: 84, height: 90).clipped()

            // Details
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.food.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.inkPrimary)
                            .lineLimit(1)

                        // Show selected addons if any
                        if !item.selectedAddons.isEmpty {
                            Text(item.selectedAddons.map { $0.name }.joined(separator: ", "))
                                .font(.system(size: 11))
                                .foregroundStyle(Color.inkTertiary)
                                .lineLimit(1)
                        }

                        Text(item.unitPrice.ugxFormatted)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.brand)
                    }
                    Spacer()
                    // Remove X
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { cart.remove(item) }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.inkTertiary)
                            .frame(width: 22, height: 22)
                            .background(Color.bgSubtle)
                            .clipShape(Circle())
                    }
                    .buttonStyle(SpringButtonStyle())
                }

                // Qty controls + subtotal
                HStack(spacing: 0) {
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { cart.decrement(item) }
                    } label: {
                        Image(systemName: item.quantity == 1 ? "trash" : "minus")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.inkSecond)
                            .frame(width: 28, height: 28)
                            .background(Color.bgSubtle)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.inkQuartern.opacity(0.2), lineWidth: 1))
                    }
                    .buttonStyle(SpringButtonStyle())

                    Text("\(item.quantity)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.inkPrimary)
                        .frame(width: 32, alignment: .center)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.28, dampingFraction: 0.7), value: item.quantity)

                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { cart.increment(item) }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.inkPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(SpringButtonStyle())

                    Spacer()

                    Text(item.subtotal.ugxFormatted)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.inkSecond)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(Color.inkQuartern.opacity(0.1), lineWidth: 1))
        .efShadow()
    }
}

#Preview {
    CartView().environmentObject({
        let vm = CartViewModel()
        vm.add(MockData.foods[0], quantity: 2, addons: [MockData.foods[0].addons[0]])
        vm.add(MockData.foods[2])
        return vm
    }())
    .environmentObject(HomeViewModel())
}

