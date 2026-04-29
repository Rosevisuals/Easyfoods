import SwiftUI
import MapKit
import Combine

// MARK: - Tracking Map
struct TrackingMapView: View {
    @Environment(\.dismiss) var dismiss
    let rider: RiderProfile

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.3476, longitude: 32.5825),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
    @State private var showChat    = false
    @State private var showCall    = false
    @State private var showProfile = false

    let routeCoords: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 0.3310, longitude: 32.5820),
        CLLocationCoordinate2D(latitude: 0.3380, longitude: 32.5820),
        CLLocationCoordinate2D(latitude: 0.3380, longitude: 32.5880),
        CLLocationCoordinate2D(latitude: 0.3450, longitude: 32.5880),
        CLLocationCoordinate2D(latitude: 0.3450, longitude: 32.5825),
        CLLocationCoordinate2D(latitude: 0.3476, longitude: 32.5825),
    ]

    var riderCoord: CLLocationCoordinate2D {
        let progress = 0.62; let total = routeCoords.count - 1
        let p = progress * Double(total); let idx = Int(p); let f = p - Double(idx)
        guard idx < total else { return routeCoords.last! }
        let from = routeCoords[idx]; let to = routeCoords[idx + 1]
        return CLLocationCoordinate2D(latitude: from.latitude + (to.latitude - from.latitude) * f,
                                      longitude: from.longitude + (to.longitude - from.longitude) * f)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: annotations) { ann in
                MapAnnotation(coordinate: ann.coord) { ann.pin }
            }
            .overlay(RouteOverlay(coords: routeCoords))
            .ignoresSafeArea()

            // ETA pill over map — liquid glass ✓
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                            .frame(width: 36, height: 36).liquidGlass(cornerRadius: 12)
                    }.buttonStyle(SpringButtonStyle())
                    Spacer()
                    HStack(spacing: 8) {
                        Text("🛵").font(.system(size: 16))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Arriving in 28 min").font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                            Text("James is on the way").font(.system(size: 11)).foregroundStyle(Color.inkTertiary)
                        }
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .liquidGlass(cornerRadius: 20)
                    Spacer()
                    Spacer().frame(width: 36)
                }
                .padding(.horizontal, 16).padding(.top, 58)
                Spacer()
            }

            // Bottom panel
            bottomPanel
        }
        .sheet(isPresented: $showChat) { ChatView(rider: rider) }
        .sheet(isPresented: $showCall) { CallView(rider: rider) }
        .sheet(isPresented: $showProfile) { RiderProfileView(rider: rider) }
        .navigationBarHidden(true)
    }

    private var annotations: [MapPinItem] {
        [MapPinItem(id: "home", coord: routeCoords.first!, type: .home),
         MapPinItem(id: "dest", coord: routeCoords.last!, type: .destination),
         MapPinItem(id: "rider", coord: riderCoord, type: .rider)]
    }

    private var bottomPanel: some View {
        VStack(spacing: 14) {
            // Rider row — tap name/avatar to view profile
            HStack(spacing: 10) {
                Button { showProfile = true } label: {
                    AsyncImage(url: URL(string: rider.avatarURL)) { phase in
                        if case .success(let img) = phase { img.resizable().scaledToFill() }
                        else { Color.bgSubtle }
                    }
                    .frame(width: 46, height: 46).clipShape(Circle())
                    .overlay(Circle().stroke(Color.brandMid, lineWidth: 2))
                }.buttonStyle(SpringButtonStyle())

                VStack(alignment: .leading, spacing: 2) {
                    Button { showProfile = true } label: {
                        Text(rider.name).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                    }.buttonStyle(SpringButtonStyle())
                    Text("Rider · ★ \(String(format: "%.1f", rider.rating))")
                        .font(.system(size: 11)).foregroundStyle(Color.inkTertiary)
                }
                Spacer()
                // Chat + Call
                HStack(spacing: 8) {
                    Button { showChat = true } label: {
                        Image(systemName: "message.fill")
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.brand)
                            .frame(width: 40, height: 40)
                            .background(Color.brandPale)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandMid, lineWidth: 1))
                    }.buttonStyle(SpringButtonStyle())

                    Button { showCall = true } label: {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.success)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(SpringButtonStyle())
                }
            }

            // Progress bar
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { i in
                    Capsule().fill(i < 3 ? Color.brand : Color.inkQuartern.opacity(0.2)).frame(height: 3)
                }
            }

            // Steps
            VStack(spacing: 0) {
                statusRow("checkmark.circle.fill", Color.success, "Order confirmed", "9:41", false)
                statusRow("checkmark.circle.fill", Color.success, "Preparing your food", "9:44", false)
                statusRow("circle.fill",           Color.brand,   "Rider on the way",   "Now",  true)
                statusRow("circle",                Color.inkQuartern.opacity(0.3), "Delivered", "~10:10", false, dim: true)
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 16)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -4)
    }

    private func statusRow(_ icon: String, _ color: Color, _ text: String, _ time: String, _ active: Bool, dim: Bool = false) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 12)).foregroundStyle(color)
            Text(text)
                .font(.system(size: 12, weight: active ? .semibold : .regular))
                .foregroundStyle(active ? Color.brand : (dim ? Color.inkQuartern : Color.inkSecond))
            Spacer()
            Text(time).font(.system(size: 11)).foregroundStyle(active ? Color.brand : Color.inkQuartern)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) { if !dim { Divider().opacity(0.5) } }
    }
}

// MARK: - Map Pin
struct MapPinItem: Identifiable {
    let id: String; let coord: CLLocationCoordinate2D
    enum PinType { case home, destination, rider }
    let type: PinType

    @ViewBuilder var pin: some View {
        switch type {
        case .home:
            ZStack {
                Circle().fill(Color.success.opacity(0.2)).frame(width: 32, height: 32)
                Circle().fill(Color.success).frame(width: 18, height: 18)
                Image(systemName: "house.fill").font(.system(size: 8)).foregroundStyle(.white)
            }
        case .destination:
            ZStack {
                Circle().fill(Color.brand.opacity(0.2)).frame(width: 32, height: 32)
                Circle().fill(Color.brand).frame(width: 18, height: 18)
                Image(systemName: "mappin").font(.system(size: 8, weight: .bold)).foregroundStyle(.white)
            }
        case .rider:
            ZStack {
                Circle().fill(Color.brand.opacity(0.25)).frame(width: 36, height: 36)
                Circle().fill(Color.brand).frame(width: 22, height: 22)
                Text("🛵").font(.system(size: 10))
            }
        }
    }
}

// MARK: - Route Overlay
struct RouteOverlay: UIViewRepresentable {
    let coords: [CLLocationCoordinate2D]
    func makeUIView(context: Context) -> MKMapView {
        let mv = MKMapView(); mv.isUserInteractionEnabled = false; mv.delegate = context.coordinator
        mv.addOverlay(MKPolyline(coordinates: coords, count: coords.count)); mv.backgroundColor = .clear; return mv
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let poly = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: poly)
                r.strokeColor = UIColor(Color.brand).withAlphaComponent(0.7); r.lineWidth = 3
                r.lineDashPattern = [6, 5]; return r
            }
            return MKOverlayRenderer()
        }
    }
}

// MARK: - Rider Profile Sheet
struct RiderProfileView: View {
    let rider: RiderProfile
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule().fill(Color.inkQuartern.opacity(0.3)).frame(width: 36, height: 4).padding(.top, 12)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero
                    ZStack(alignment: .bottom) {
                        AsyncImage(url: URL(string: rider.avatarURL)) { phase in
                            if case .success(let img) = phase { img.resizable().scaledToFill() }
                            else { Color.bgSubtle }
                        }
                        .frame(maxWidth: .infinity).frame(height: 220).clipped()
                        LinearGradient(colors: [.clear, Color.bgCard], startPoint: .top, endPoint: .bottom)
                    }
                    .frame(height: 220)

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(rider.name).font(.system(size: 22, weight: .bold)).foregroundStyle(Color.inkPrimary)
                                Text("Delivery Rider · Joined \(rider.joinedYear)")
                                    .font(.system(size: 13)).foregroundStyle(Color.inkTertiary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                HStack(spacing: 3) {
                                    Image(systemName: "star.fill").font(.system(size: 13)).foregroundStyle(Color(hex: "#F59E0B"))
                                    Text(String(format: "%.1f", rider.rating)).font(.system(size: 16, weight: .bold)).foregroundStyle(Color.inkPrimary)
                                }
                                Text("\(rider.deliveries) deliveries").font(.system(size: 11)).foregroundStyle(Color.inkTertiary)
                            }
                        }
                        .padding(.bottom, 16)

                        // Stats bar
                        HStack(spacing: 0) {
                            statCell(value: String(format: "%.1f", rider.rating), label: "Rating")
                            Divider().frame(height: 32)
                            statCell(value: "\(rider.deliveries)+", label: "Deliveries")
                            Divider().frame(height: 32)
                            statCell(value: "\(2025 - rider.joinedYear)y", label: "Experience")
                        }
                        .background(Color.bgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: EFRadius.lg))
                        .overlay(RoundedRectangle(cornerRadius: EFRadius.lg).stroke(Color.inkQuartern.opacity(0.15), lineWidth: 1))
                        .padding(.bottom, 18)

                        // Bio
                        Text("About").font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.inkPrimary).padding(.bottom, 6)
                        Text(rider.bio).font(.system(size: 13)).foregroundStyle(Color.inkSecond).lineSpacing(4)
                            .padding(.bottom, 20)

                        // Phone
                        HStack(spacing: 10) {
                            Image(systemName: "phone.fill").font(.system(size: 14)).foregroundStyle(Color.success)
                                .frame(width: 36, height: 36).background(Color(hex: "#F0FFF4"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(rider.phone).font(.system(size: 14, weight: .medium)).foregroundStyle(Color.inkPrimary)
                            Spacer()
                            Text("Verified").font(.system(size: 11)).foregroundStyle(Color.success)
                                .padding(.horizontal, 9).padding(.vertical, 4)
                                .background(Color(hex: "#F0FFF4")).clipShape(Capsule())
                        }
                        .padding(14).background(Color.bgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: EFRadius.md))
                        .overlay(RoundedRectangle(cornerRadius: EFRadius.md).stroke(Color.inkQuartern.opacity(0.15), lineWidth: 1))
                    }
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 32)
                }
            }
        }
        .background(Color.bgCard)
        .presentationDetents([.fraction(0.88)])
        .presentationCornerRadius(24)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 16, weight: .bold)).foregroundStyle(Color.inkPrimary)
            Text(label).font(.system(size: 10)).foregroundStyle(Color.inkTertiary)
        }.frame(maxWidth: .infinity).padding(.vertical, 12)
    }
}

// MARK: - Chat View
struct ChatView: View {
    let rider: RiderProfile
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: ChatViewModel
    @FocusState private var focused: Bool

    init(rider: RiderProfile) {
        self.rider = rider
        _vm = StateObject(wrappedValue: ChatViewModel(riderName: rider.name))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: rider.avatarURL)) { phase in
                    if case .success(let img) = phase { img.resizable().scaledToFill() }
                    else { Color.bgSubtle }
                }
                .frame(width: 38, height: 38).clipShape(Circle()).overlay(Circle().stroke(Color.brandMid, lineWidth: 2))

                VStack(alignment: .leading, spacing: 2) {
                    Text(rider.name).font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.inkPrimary)
                    HStack(spacing: 4) {
                        Circle().fill(Color.success).frame(width: 7, height: 7)
                        Text("Online · On delivery").font(.system(size: 11)).foregroundStyle(Color.inkTertiary)
                    }
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.inkSecond)
                        .frame(width: 30, height: 30).background(Color.bgSubtle).clipShape(Circle())
                }.buttonStyle(SpringButtonStyle())
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            Divider().opacity(0.4)

            // Messages
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(vm.messages) { msg in
                            MessageBubble(message: msg).id(msg.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: msg.isFromUser ? .trailing : .leading).combined(with: .opacity),
                                    removal: .opacity))
                        }
                        if vm.isRiderTyping {
                            TypingIndicator(name: rider.name).transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    .animation(.spring(response: 0.35, dampingFraction: 0.78), value: vm.messages.count)
                    .animation(.easeInOut(duration: 0.2), value: vm.isRiderTyping)
                }
                .onChange(of: vm.messages.count) { _ in
                    if let last = vm.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onChange(of: vm.isRiderTyping) { _ in
                    withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                }
            }

            // Input bar
            VStack(spacing: 0) {
                Divider().opacity(0.4)
                HStack(spacing: 10) {
                    TextField("Type a message…", text: $vm.inputText)
                        .font(.system(size: 14)).foregroundStyle(Color.inkPrimary)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Color.bgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .focused($focused)
                        .onSubmit { vm.send() }

                    Button {
                        vm.send()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.inkQuartern : Color.brand)
                    }
                    .disabled(vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .buttonStyle(SpringButtonStyle())
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Color.bgCard)
            }
        }
        .background(Color.bgBase)
        .presentationDetents([.fraction(0.82)])
        .presentationCornerRadius(24)
        .onAppear { focused = true }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 60) }
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .font(.system(size: 14)).foregroundStyle(message.isFromUser ? .white : Color.inkPrimary)
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(message.isFromUser ? LinearGradient.brand : LinearGradient(colors: [Color.bgCard, Color.bgCard], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 18,
                        style: .continuous))
                    .shadow(color: .black.opacity(message.isFromUser ? 0 : 0.05), radius: 4, x: 0, y: 2)

                Text(timeString(message.timestamp))
                    .font(.system(size: 10)).foregroundStyle(Color.inkQuartern)
            }
            if !message.isFromUser { Spacer(minLength: 60) }
        }
    }
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter(); f.timeStyle = .short; return f.string(from: date)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    let name: String
    @State private var dot = 0
    var body: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle().fill(Color.inkQuartern).frame(width: 7, height: 7)
                        .scaleEffect(dot == i ? 1.4 : 1.0)
                        .animation(.easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15), value: dot)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(Color.bgCard).clipShape(RoundedRectangle(cornerRadius: 18))
            .efShadow()
            Spacer()
        }
        .id("typing")
        .onAppear { dot = 1 }
    }
}

// MARK: - Call View
struct CallView: View {
    let rider: RiderProfile
    @Environment(\.dismiss) var dismiss
    @State private var callDuration = 0
    @State private var isMuted = false
    @State private var isSpeaker = false
    @State private var callState: CallState = .ringing
    @State private var pulse = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum CallState { case ringing, connected, ended }

    var body: some View {
        ZStack {
            // Background — blurred rider photo
            AsyncImage(url: URL(string: rider.avatarURL)) { phase in
                if case .success(let img) = phase {
                    img.resizable().scaledToFill().ignoresSafeArea()
                        .overlay(Color.black.opacity(0.6))
                        .blur(radius: 12)
                }
            }

            VStack(spacing: 0) {
                Spacer()

                // Avatar
                ZStack {
                    Circle().fill(.white.opacity(0.08)).frame(width: 120, height: 120)
                        .scaleEffect(pulse && callState == .ringing ? 1.25 : 1.0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

                    AsyncImage(url: URL(string: rider.avatarURL)) { phase in
                        if case .success(let img) = phase { img.resizable().scaledToFill() }
                        else { Color.bgSubtle }
                    }
                    .frame(width: 100, height: 100).clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 2))
                }
                .padding(.bottom, 16)

                Text(rider.name).font(.system(size: 24, weight: .bold)).foregroundStyle(.white)
                Text(statusLabel).font(.system(size: 14)).foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 4)

                if callState == .connected {
                    Text(durationString).font(.system(size: 14, weight: .medium)).foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 2)
                }

                Spacer()

                // Control buttons
                HStack(spacing: 36) {
                    callControl(icon: isMuted ? "mic.slash.fill" : "mic.fill",
                                label: isMuted ? "Unmute" : "Mute",
                                active: isMuted, tint: .white) { isMuted.toggle() }

                    callControl(icon: isSpeaker ? "speaker.wave.3.fill" : "speaker.fill",
                                label: "Speaker", active: isSpeaker, tint: .white) { isSpeaker.toggle() }

                    callControl(icon: "chevron.down", label: "Hide", active: false, tint: .white) { dismiss() }
                }
                .padding(.bottom, 32)

                // End call
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { callState = .ended }
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                } label: {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 24, weight: .semibold)).foregroundStyle(.white)
                        .frame(width: 68, height: 68)
                        .background(callState == .ended ? Color.inkTertiary : Color.red)
                        .clipShape(Circle())
                        .shadow(color: .red.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(SpringButtonStyle())
                .disabled(callState == .ended)

                Text(callState == .ended ? "Call ended" : "End call")
                    .font(.system(size: 12)).foregroundStyle(.white.opacity(0.6)).padding(.top, 8)

                Spacer(minLength: 40)
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(32)
        .onAppear {
            pulse = true
            // Simulate answer after 2.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { callState = .connected }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
        .onReceive(timer) { _ in if callState == .connected { callDuration += 1 } }
    }

    private var statusLabel: String {
        switch callState {
        case .ringing: return "Calling…"
        case .connected: return "Connected"
        case .ended: return "Call Ended"
        }
    }

    private var durationString: String {
        let m = callDuration / 60; let s = callDuration % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func callControl(icon: String, label: String, active: Bool, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold)).foregroundStyle(tint)
                    .frame(width: 52, height: 52)
                    .background(active ? .white.opacity(0.3) : .white.opacity(0.12))
                    .clipShape(Circle())
                Text(label).font(.system(size: 11)).foregroundStyle(.white.opacity(0.7))
            }
        }.buttonStyle(SpringButtonStyle())
    }
}

#Preview { NavigationStack { TrackingMapView(rider: MockData.rider) } }
