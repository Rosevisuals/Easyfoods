import SwiftUI

struct CartView: View {
    @EnvironmentObject var cart: CartViewModel
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Cart")
                        .font(EFFont.black(24)).foregroundStyle(Color.inkPrimary)
                    Spacer()
                    if !cart.isEmpty {
                        Button("Clear all") {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { cart.clear() }
                        }
                        .font(EFFont.semibold(13)).foregroundStyle(Color.inkTertiary)
                    }
                }
                .padding(.horizontal, EFSpacing.xl)
                .padding(.top, 8)
                .padding(.bottom, 16)

                if cart.isEmpty {
                    emptyState
                } else {
                    // Scrollable content — KEY FIX: no ZStack overlap
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(cart.items) { item in
                                CartItemRow(item: item)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.96)),
                                        removal: .opacity.combined(with: .move(edge: .trailing))
                                    ))
                            }
                            summaryCard.padding(.top, 4)
                        }
                        .padding(.horizontal, EFSpacing.lg)
                        .padding(.bottom, 24)
                        .animation(.spring(response: 0.32, dampingFraction: 0.75), value: cart.items.count)
                    }

                    // CTA pinned below scroll — never overlaps content
                    VStack(spacing: 0) {
                        Divider().opacity(0.4)
                        NavigationLink(value: "checkout") {
                            HStack {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("\(cart.itemCount) item\(cart.itemCount == 1 ? "" : "s")")
                                        .font(EFFont.semibold(12)).foregroundStyle(.white.opacity(0.75))
                                    Text(cart.total.ugxFormatted)
                                        .font(EFFont.black(15)).foregroundStyle(.white)
                                }
                                Spacer()
                                Text("Checkout →")
                                    .font(EFFont.bold(15)).foregroundStyle(.white)
                            }
                            .padding(.horizontal, 22)
                            .padding(.vertical, 16)
                            .background(LinearGradient.brand)
                            .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
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
            .navigationDestination(for: String.self) { dest in
                if dest == "checkout" { CheckoutView() }
            }
        }
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: 0) {
            summaryRow(label: "Subtotal", value: cart.subtotal.ugxFormatted, bold: false)
            Divider().padding(.vertical, 6)
            summaryRow(label: "Delivery fee", value: cart.deliveryFee.ugxFormatted, bold: false)
            summaryRow(label: "Service fee", value: cart.serviceFee.ugxFormatted, bold: false)
            Divider().padding(.vertical, 6)
            summaryRow(label: "Total", value: cart.total.ugxFormatted, bold: true)
        }
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.xl))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.xl).stroke(Color.inkQuartern.opacity(0.12), lineWidth: 1))
        .efShadow()
    }

    private func summaryRow(label: String, value: String, bold: Bool) -> some View {
        HStack {
            Text(label)
                .font(bold ? EFFont.black(15) : EFFont.regular(13))
                .foregroundStyle(bold ? Color.inkPrimary : Color.inkTertiary)
            Spacer()
            Text(value)
                .font(bold ? EFFont.black(15) : EFFont.semibold(13))
                .foregroundStyle(bold ? Color.brand : Color.inkSecond)
        }
        .padding(.vertical, bold ? 0 : 2)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "cart")
                .font(.system(size: 52, weight: .thin))
                .foregroundStyle(Color.inkQuartern)
            Text("Your cart is empty")
                .font(EFFont.bold(18)).foregroundStyle(Color.inkSecond)
            Text("Browse the menu and add something\ndelicious to get started")
                .font(EFFont.regular(14)).foregroundStyle(Color.inkQuartern)
                .multilineTextAlignment(.center).lineSpacing(3)
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
            .frame(width: 82, height: 88).clipped()

            // Details
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.food.name)
                            .font(EFFont.bold(13)).foregroundStyle(Color.inkPrimary).lineLimit(1)
                        Text(item.food.price.ugxFormatted)
                            .font(EFFont.semibold(12)).foregroundStyle(Color.brand)
                    }
                    Spacer()
                    // Remove
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { cart.remove(item) }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold)).foregroundStyle(Color.inkTertiary)
                            .frame(width: 22, height: 22).background(Color.bgSubtle)
                            .clipShape(Circle())
                    }
                    .buttonStyle(SpringButtonStyle())
                }

                // Quantity controls + subtotal
                HStack(spacing: 0) {
                    // Minus
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { cart.decrement(item) }
                    } label: {
                        Image(systemName: item.quantity == 1 ? "trash" : "minus")
                            .font(.system(size: 11, weight: .semibold)).foregroundStyle(Color.inkSecond)
                            .frame(width: 28, height: 28).background(Color.bgSubtle)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.inkQuartern.opacity(0.25), lineWidth: 1))
                    }
                    .buttonStyle(SpringButtonStyle())

                    Text("\(item.quantity)")
                        .font(EFFont.bold(14)).foregroundStyle(Color.inkPrimary)
                        .frame(width: 32, alignment: .center)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.28, dampingFraction: 0.7), value: item.quantity)

                    // Plus
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { cart.increment(item) }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 28, height: 28).background(Color.inkPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(SpringButtonStyle())

                    Spacer()

                    Text(item.subtotal.ugxFormatted)
                        .font(EFFont.bold(12)).foregroundStyle(Color.inkSecond)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 12).padding(.vertical, 12)
            .frame(maxWidth: .infinity)
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(Color.inkQuartern.opacity(0.12), lineWidth: 1))
        .efShadow()
    }
}

#Preview {
    CartView().environmentObject({
        let vm = CartViewModel()
        vm.add(MockData.foods[0], quantity: 2)
        vm.add(MockData.foods[2])
        return vm
    }())
    .environmentObject(HomeViewModel())
}
