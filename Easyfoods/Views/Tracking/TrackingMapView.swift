import SwiftUI
import MapKit

struct TrackingMapView: View {
    @Environment(\.dismiss) var dismiss

    // Kampala coordinates
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.3476, longitude: 32.5825),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )

    @State private var riderProgress: Double = 0.62
    @State private var animateRider = false

    // Route points: Home (Kololo) → Restaurant (Kampala) → Delivery
    let routeCoords: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 0.3310, longitude: 32.5820), // start
        CLLocationCoordinate2D(latitude: 0.3380, longitude: 32.5820), // waypoint 1
        CLLocationCoordinate2D(latitude: 0.3380, longitude: 32.5880), // waypoint 2
        CLLocationCoordinate2D(latitude: 0.3450, longitude: 32.5880), // waypoint 3
        CLLocationCoordinate2D(latitude: 0.3450, longitude: 32.5825), // waypoint 4
        CLLocationCoordinate2D(latitude: 0.3476, longitude: 32.5825), // destination
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map
            Map(coordinateRegion: $region, annotationItems: mapAnnotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    annotation.view
                }
            }
            .overlay(RouteOverlay(coords: routeCoords))
            .ignoresSafeArea(edges: .top)

            // ETA glass pill (liquid glass ✓ — over map image)
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Text("🛵").font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Arriving in 28 minutes")
                            .font(EFFont.bold(14))
                            .foregroundStyle(Color.inkPrimary)
                        Text("James Kato is on the way")
                            .font(EFFont.regular(11))
                            .foregroundStyle(Color.inkTertiary)
                    }
                    Spacer()
                    Text("📍").font(.system(size: 18))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .liquidGlass(cornerRadius: EFRadius.xl)
                .padding(.horizontal, EFSpacing.lg)
                .padding(.top, 60)

                Spacer()
            }

            // Back button
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.inkPrimary)
                            .frame(width: 36, height: 36)
                            .liquidGlass(cornerRadius: EFRadius.md)
                    }
                    .buttonStyle(SpringButtonStyle())
                    .padding(.leading, EFSpacing.lg)
                    .padding(.top, 56)
                    Spacer()
                }
                Spacer()
            }

            // Bottom panel
            bottomPanel
        }
        .navigationBarHidden(true)
    }

    // MARK: - Map Annotations
    private var mapAnnotations: [MapPin] {
        var pins: [MapPin] = []
        // Home pin
        pins.append(MapPin(id: "home", coordinate: routeCoords.first!, type: .home))
        // Destination pin
        pins.append(MapPin(id: "dest", coordinate: routeCoords.last!, type: .destination))
        // Rider pin (interpolated along route)
        pins.append(MapPin(id: "rider", coordinate: riderCoordinate, type: .rider))
        return pins
    }

    private var riderCoordinate: CLLocationCoordinate2D {
        let total = routeCoords.count - 1
        let progress = riderProgress * Double(total)
        let idx = Int(progress)
        let frac = progress - Double(idx)
        guard idx < total else { return routeCoords.last! }
        let from = routeCoords[idx], to = routeCoords[idx + 1]
        return CLLocationCoordinate2D(
            latitude: from.latitude + (to.latitude - from.latitude) * frac,
            longitude: from.longitude + (to.longitude - from.longitude) * frac
        )
    }

    // MARK: - Bottom Panel
    private var bottomPanel: some View {
        VStack(spacing: 14) {
            // Rider row
            HStack(spacing: 10) {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&q=80")) { phase in
                    if case .success(let img) = phase { img.resizable().scaledToFill() }
                    else { Color.bgSubtle }
                }
                .frame(width: 44, height: 44).clipShape(Circle())
                .overlay(Circle().stroke(Color.brandMid, lineWidth: 2))

                VStack(alignment: .leading, spacing: 2) {
                    Text("James Kato").font(EFFont.bold(14)).foregroundStyle(Color.inkPrimary)
                    Text("Delivery Rider · ★ 4.9").font(EFFont.regular(11)).foregroundStyle(Color.inkTertiary)
                }
                Spacer()
                HStack(spacing: 7) {
                    actionBtn("message")
                    actionBtn("phone")
                }
            }

            // Progress steps
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { i in
                    Capsule()
                        .fill(i < 3 ? Color.brand : (i == 2 ? Color.brand : Color.inkQuartern.opacity(0.2)))
                        .frame(height: 3)
                        .animation(.easeInOut(duration: 0.5), value: i)
                }
            }

            // Status list
            VStack(spacing: 0) {
                statusRow(dot: Color.success, text: "✓ Order confirmed", time: "9:41", active: false)
                statusRow(dot: Color.success, text: "✓ Preparing your food", time: "9:44", active: false)
                statusRow(dot: Color.brand, text: "🛵 Rider on the way", time: "Now", active: true)
                statusRow(dot: Color.inkQuartern.opacity(0.4), text: "Delivered", time: "~10:10", active: false, dim: true)
            }
        }
        .padding(.horizontal, EFSpacing.lg)
        .padding(.vertical, 16)
        .background(
            Color.bgCard
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.10), radius: 20, x: 0, y: -4)
        )
        .padding(.horizontal, 0)
    }

    private func actionBtn(_ sym: String) -> some View {
        Image(systemName: sym)
            .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.inkSecond)
            .frame(width: 34, height: 34).background(Color.bgSubtle)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.inkQuartern.opacity(0.25), lineWidth: 1))
    }

    private func statusRow(dot: Color, text: String, time: String, active: Bool, dim: Bool = false) -> some View {
        HStack(spacing: 10) {
            Circle().fill(dot).frame(width: 8, height: 8)
                .shadow(color: active ? Color.brand.opacity(0.5) : .clear, radius: 4)
            Text(text)
                .font(active ? EFFont.semibold(12) : EFFont.regular(12))
                .foregroundStyle(active ? Color.brand : (dim ? Color.inkQuartern : Color.inkSecond))
            Spacer()
            Text(time).font(EFFont.regular(11))
                .foregroundStyle(active ? Color.brand : Color.inkQuartern)
        }
        .padding(.vertical, 7)
        .overlay(alignment: .bottom) { Divider().opacity(dim ? 0 : 0.5) }
    }
}

// MARK: - Map Pin Model
struct MapPin: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let type: PinType

    enum PinType { case home, destination, rider }

    @ViewBuilder
    var view: some View {
        switch type {
        case .home:
            ZStack {
                Circle().fill(Color.success.opacity(0.2)).frame(width: 32, height: 32)
                Circle().fill(Color.success).frame(width: 18, height: 18)
                Text("H").font(EFFont.bold(9)).foregroundStyle(.white)
            }
        case .destination:
            ZStack {
                Circle().fill(Color.brand.opacity(0.2)).frame(width: 32, height: 32)
                Circle().fill(Color.brand).frame(width: 18, height: 18)
                Image(systemName: "house.fill").font(.system(size: 8)).foregroundStyle(.white)
            }
        case .rider:
            ZStack {
                Circle().fill(Color.brand.opacity(0.25)).frame(width: 36, height: 36)
                Circle().fill(Color.brand).frame(width: 22, height: 22)
                Text("🛵").font(.system(size: 10))
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: coordinate.latitude)
        }
    }
}

// MARK: - Route Overlay (polyline)
struct RouteOverlay: UIViewRepresentable {
    let coords: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mv = MKMapView()
        mv.isUserInteractionEnabled = false
        mv.delegate = context.coordinator
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        mv.addOverlay(polyline)
        mv.backgroundColor = .clear
        return mv
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let poly = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: poly)
                r.strokeColor = UIColor(Color.brand).withAlphaComponent(0.75)
                r.lineWidth = 3
                r.lineDashPattern = [6, 5]
                return r
            }
            return MKOverlayRenderer()
        }
    }
}

#Preview { NavigationStack { TrackingMapView() } }
