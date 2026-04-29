//
//  ProfileAndOrdersView.swift
//  Easyfoods
//
//  Created by Rose Visuals on 29/04/2026.
//

import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var home: HomeViewModel
    @EnvironmentObject var history: OrderHistoryViewModel

    private let menuItems: [(icon: String, bg: String, label: String, badge: String?)] = [
        ("shippingbox.fill",   "#FFF3EC", "My Orders",       "47"),
        ("mappin.and.ellipse", "#EEF5FF", "Saved Addresses", nil),
        ("creditcard.fill",    "#F0FFF4", "Payment Methods", nil),
        ("bell.fill",          "#FFF8EE", "Notifications",   nil),
        ("gift.fill",          "#F5F0FF", "Refer & Earn",    "UGX 5K"),
        ("gearshape.fill",     "#F5F5F5", "Settings",        nil),
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                profileHero.padding(.bottom, 20)

                // Menu card
                VStack(spacing: 0) {
                    ForEach(menuItems.indices, id: \.self) { i in
                        let item = menuItems[i]
                        HStack(spacing: 12) {
                            Image(systemName: item.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.brand)
                                .frame(width: 34, height: 34)
                                .background(Color(hex: item.bg))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            Text(item.label)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.inkPrimary)
                            Spacer()

                            if let badge = item.badge {
                                Text(badge)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.brand)
                                    .padding(.horizontal, 9).padding(.vertical, 3)
                                    .background(Color.brandPale).clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.brandMid, lineWidth: 1))
                            }

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11)).foregroundStyle(Color.inkQuartern)
                        }
                        .padding(.horizontal, EFSpacing.lg)
                        .padding(.vertical, 13)
                        .contentShape(Rectangle())

                        if i < menuItems.count - 1 {
                            Divider().padding(.leading, 60).padding(.trailing, EFSpacing.lg)
                        }
                    }
                }
                .background(Color.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: EFRadius.xl))
                .overlay(RoundedRectangle(cornerRadius: EFRadius.xl).stroke(Color.inkQuartern.opacity(0.1), lineWidth: 1))
                .efShadow()
                .padding(.horizontal, EFSpacing.lg)

                // Sign out
                Button("Sign Out") {}
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(hex: "#CC3333"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(hex: "#CC3333").opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(hex: "#CC3333").opacity(0.2), lineWidth: 1.5))
                    .padding(.horizontal, EFSpacing.lg)
                    .padding(.top, 14)

                Spacer(minLength: 24)
            }
            .padding(.bottom, 20)
        }
        .background(Color.bgBase)
        .navigationBarHidden(true)
    }

    // MARK: - Hero
    private var profileHero: some View {
        VStack(spacing: 10) {
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=200&q=80")) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { Color.brandPale }
            }
            .frame(width: 82, height: 82).clipShape(Circle())
            .overlay(Circle().stroke(Color.bgCard, lineWidth: 3))
            .overlay(Circle().stroke(Color.brandMid, lineWidth: 2).padding(-1))
            .efShadowMedium()

            Text("Rose Nakato")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.inkPrimary)
                .tracking(-0.2)

            Text("rose.nakato@gmail.com")
                .font(.system(size: 12))
                .foregroundStyle(Color.inkTertiary)

            // Stats
            HStack(spacing: 0) {
                statCell(value: "\(history.orders.count)", label: "Orders")
                Divider().frame(height: 30)
                statCell(value: "\(home.savedFoods.count)", label: "Saved")
                Divider().frame(height: 30)
                statCell(value: "4.8★", label: "Rating")
            }
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(Color.inkQuartern.opacity(0.1), lineWidth: 1))
            .efShadow()
            .padding(.horizontal, EFSpacing.lg)
            .padding(.top, 4)
        }
        .padding(.top, 12)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 17, weight: .bold)).foregroundStyle(Color.inkPrimary)
            Text(label).font(.system(size: 10)).foregroundStyle(Color.inkTertiary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
    }
}

// MARK: - Order History View (replaces Saved tab)
struct OrderHistoryView: View {
    @EnvironmentObject var history: OrderHistoryViewModel
    @EnvironmentObject var cart: CartViewModel
    @State private var selectedFilter: OrderStatus? = nil

    var filtered: [Order] {
        guard let f = selectedFilter else { return history.orders }
        return history.orders.filter { $0.status == f }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Header ──
                HStack {
                    Text("My Orders")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.inkPrimary)
                    Spacer()
                    Text("\(history.orders.count) orders")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.inkTertiary)
                }
                .padding(.horizontal, EFSpacing.xl)
                .padding(.top, 8)
                .padding(.bottom, 12)

                // ── Filter chips ──
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        filterChip(label: "All", active: selectedFilter == nil) {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) { selectedFilter = nil }
                        }
                        ForEach(OrderStatus.allCases, id: \.self) { status in
                            filterChip(label: status.rawValue, active: selectedFilter == status) {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                                    selectedFilter = (selectedFilter == status) ? nil : status
                                }
                            }
                        }
                    }
                    .padding(.horizontal, EFSpacing.xl)
                }
                .padding(.bottom, 12)

                Divider().opacity(0.35)

                // ── Order list ──
                if filtered.isEmpty {
                    emptyState
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(filtered) { order in
                                NavigationLink(destination: OrderDetailView(order: order)) {
                                    OrderRow(order: order) {
                                        // Order again — re-add items
                                        for item in order.items {
                                            cart.add(item.food, quantity: item.quantity, addons: item.selectedAddons)
                                        }
                                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .transition(.opacity.combined(with: .scale(scale: 0.97)))
                            }
                        }
                        .padding(.horizontal, EFSpacing.lg)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: filtered.count)
                    }
                }
            }
            .background(Color.bgBase)
            .navigationBarHidden(true)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 44, weight: .thin))
                .foregroundStyle(Color.inkQuartern)
            Text("No orders yet")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.inkSecond)
            Text("Your order history will appear here")
                .font(.system(size: 13))
                .foregroundStyle(Color.inkQuartern)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func filterChip(label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: active ? .semibold : .regular))
                .foregroundStyle(active ? .white : Color.inkSecond)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(active ? Color.inkPrimary : Color.bgCard)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(active ? Color.clear : Color.inkQuartern.opacity(0.25), lineWidth: 1.5))
                .shadow(color: .black.opacity(active ? 0.1 : 0.04), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Order Row
struct OrderRow: View {
    let order: Order
    var onOrderAgain: () -> Void
    @State private var didOrderAgain = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top row
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Order #\(order.id)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.inkPrimary)
                    Text(relativeDate(order.placedAt))
                        .font(.system(size: 11))
                        .foregroundStyle(Color.inkTertiary)
                }
                Spacer()
                // Status badge
                Text(order.status.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(order.statusColor)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(order.statusColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.bottom, 10)

            Divider().opacity(0.35).padding(.bottom, 10)

            // Items preview
            HStack(spacing: -8) {
                ForEach(order.items.prefix(3)) { item in
                    AsyncImage(url: URL(string: item.food.imageURL)) { phase in
                        if case .success(let img) = phase { img.resizable().scaledToFill() }
                        else { Color.bgSubtle }
                    }
                    .frame(width: 36, height: 36).clipShape(Circle())
                    .overlay(Circle().stroke(Color.bgCard, lineWidth: 2))
                }
                if order.items.count > 3 {
                    Text("+\(order.items.count - 3)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.inkTertiary)
                        .frame(width: 36, height: 36)
                        .background(Color.bgSubtle)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.bgCard, lineWidth: 2))
                }
            }

            Text(order.items.map { "\($0.food.name)\($0.quantity > 1 ? " ×\($0.quantity)" : "")" }.joined(separator: ", "))
                .font(.system(size: 12))
                .foregroundStyle(Color.inkTertiary)
                .lineLimit(1)
                .padding(.top, 6)

            // Bottom row
            HStack {
                Text(order.total.ugxFormatted)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.inkPrimary)
                Spacer()
                // Order again button
                Button {
                    onOrderAgain()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) { didOrderAgain = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { didOrderAgain = false }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: didOrderAgain ? "checkmark" : "arrow.clockwise")
                            .font(.system(size: 12, weight: .semibold))
                        Text(didOrderAgain ? "Added!" : "Order Again")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(didOrderAgain ? .white : Color.brand)
                    .padding(.horizontal, 14)
                    .frame(height: 34)
                    .background(didOrderAgain ? Color.success : Color.brandPale)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(didOrderAgain ? Color.success : Color.brandMid, lineWidth: 1))
                    .animation(.spring(response: 0.25, dampingFraction: 0.65), value: didOrderAgain)
                }
                .buttonStyle(SpringButtonStyle())
            }
            .padding(.top, 10)
        }
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.xl))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.xl).stroke(Color.inkQuartern.opacity(0.1), lineWidth: 1))
        .efShadow()
    }

    private func relativeDate(_ date: Date) -> String {
        let diff = Date().timeIntervalSince(date)
        if diff < 3600 { return "Just now" }
        if diff < 86400 { return "\(Int(diff/3600))h ago" }
        let days = Int(diff / 86400)
        return "\(days) day\(days == 1 ? "" : "s") ago"
    }
}

// MARK: - Order Detail View
struct OrderDetailView: View {
    let order: Order
    @Environment(\.dismiss) var dismiss
    @State private var showChat  = false
    @State private var showCall  = false

    var body: some View {
        VStack(spacing: 0) {
            // Nav
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.inkPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.bgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
                }
                .buttonStyle(SpringButtonStyle())
                Text("Order #\(order.id)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.inkPrimary)
                Spacer()
                Text(order.status.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(order.statusColor)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(order.statusColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, EFSpacing.xl).padding(.vertical, 12)
            Divider().opacity(0.35)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    // Items
                    detailCard(title: "Items Ordered") {
                        ForEach(order.items) { item in
                            HStack(spacing: 10) {
                                AsyncImage(url: URL(string: item.food.imageURL)) { phase in
                                    if case .success(let img) = phase { img.resizable().scaledToFill() }
                                    else { Color.bgSubtle }
                                }
                                .frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 10)).clipped()

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.food.name).font(.system(size: 13, weight: .medium)).foregroundStyle(Color.inkPrimary)
                                    if !item.selectedAddons.isEmpty {
                                        Text(item.selectedAddons.map(\.name).joined(separator: ", "))
                                            .font(.system(size: 11)).foregroundStyle(Color.inkTertiary)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("×\(item.quantity)").font(.system(size: 12)).foregroundStyle(Color.inkTertiary)
                                    Text(item.subtotal.ugxFormatted).font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.inkSecond)
                                }
                            }
                            .padding(.vertical, 4)
                            if item.id != order.items.last?.id { Divider() }
                        }
                    }

                    // Price breakdown
                    detailCard(title: "Payment") {
                        priceRow("Subtotal", order.subtotal.ugxFormatted)
                        Divider().padding(.vertical, 6)
                        priceRow("Delivery", order.deliveryFee.ugxFormatted)
                        priceRow("Service",  order.serviceFee.ugxFormatted)
                        Divider().padding(.vertical, 6)
                        HStack {
                            Text("Total").font(.system(size: 14, weight: .bold)).foregroundStyle(Color.inkPrimary)
                            Spacer()
                            Text(order.total.ugxFormatted).font(.system(size: 14, weight: .bold)).foregroundStyle(Color.brand)
                        }
                        HStack(spacing: 6) {
                            Text(order.paymentMethod.emoji)
                            Text(order.paymentMethod.rawValue).font(.system(size: 12)).foregroundStyle(Color.inkTertiary)
                        }
                        .padding(.top, 6)
                    }

                    // Rider
                    detailCard(title: "Rider") {
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: order.rider.avatarURL)) { phase in
                                if case .success(let img) = phase { img.resizable().scaledToFill() }
                                else { Color.bgSubtle }
                            }
                            .frame(width: 44, height: 44).clipShape(Circle())
                            .overlay(Circle().stroke(Color.brandMid, lineWidth: 2))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(order.rider.name).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                                Text("★ \(String(format: "%.1f", order.rider.rating)) · \(order.rider.deliveries)+ deliveries")
                                    .font(.system(size: 11)).foregroundStyle(Color.inkTertiary)
                            }
                            Spacer()

                            if order.status == .onTheWay {
                                HStack(spacing: 8) {
                                    Button { showChat = true } label: {
                                        Image(systemName: "message.fill")
                                            .font(.system(size: 13)).foregroundStyle(Color.brand)
                                            .frame(width: 34, height: 34).background(Color.brandPale)
                                            .clipShape(RoundedRectangle(cornerRadius: 9))
                                    }.buttonStyle(SpringButtonStyle())
                                    Button { showCall = true } label: {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 13)).foregroundStyle(.white)
                                            .frame(width: 34, height: 34).background(Color.success)
                                            .clipShape(RoundedRectangle(cornerRadius: 9))
                                    }.buttonStyle(SpringButtonStyle())
                                }
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, EFSpacing.lg).padding(.top, 12).padding(.bottom, 24)
            }
        }
        .background(Color.bgBase)
        .navigationBarHidden(true)
        .sheet(isPresented: $showChat) { ChatView(rider: order.rider) }
        .sheet(isPresented: $showCall) { CallView(rider: order.rider) }
    }

    private func detailCard<C: View>(title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.inkTertiary)
                .tracking(0.8)
                .padding(.bottom, 10)
            content()
        }
        .padding(16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: EFRadius.xl))
        .overlay(RoundedRectangle(cornerRadius: EFRadius.xl).stroke(Color.inkQuartern.opacity(0.1), lineWidth: 1))
        .efShadow()
    }

    private func priceRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundStyle(Color.inkTertiary)
            Spacer()
            Text(value).font(.system(size: 13, weight: .medium)).foregroundStyle(Color.inkSecond)
        }
        .padding(.vertical, 2)
    }
}

#Preview { ProfileView().environmentObject(HomeViewModel()).environmentObject(OrderHistoryViewModel()) }
#Preview { OrderHistoryView().environmentObject(OrderHistoryViewModel()).environmentObject(CartViewModel()) }
