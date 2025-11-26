//
//  InteractiveGlobeView.swift
//  Wanderlux
//
//  Created by Wanderlux Team on 11/26/2025.
//  Copyright © 2025 Wanderlux. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation

struct InteractiveGlobeView: View {
    @StateObject private var mapController = MapInteractionController()
    @StateObject private var locationAnnotationManager = LocationAnnotationManager()

    @State private var selectedPlace: VisitedPlace?
    @State private var showingDetail = false
    @State private var mapStyle: GlobeMapStyle = .realistic
    @State private var showingLayerControls = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main Globe Map
                Map(coordinateRegion: $mapController.region,
                     interactionModes: [.all],
                     showsUserLocation: true,
                     userTrackingMode: $mapController.userTrackingMode,
                     annotations: locationAnnotationManager.annotations)
                .mapStyle(mapStyle.mapStyle)
                .onAppear {
                    setupInitialRegion()
                    loadAnnotations()
                }
                .onChange(of: mapController.region) { _ in
                    updateAnnotationsForVisibleRegion()
                }

                // Map Controls Overlay
                VStack {
                    HStack {
                        // Layer controls button
                        Button(action: {
                            withAnimation(LuxuryAnimation.Modal.present) {
                                showingLayerControls.toggle()
                            }
                        }) {
                            Image(systemName: "layers.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(LuxuryColorPalette.textPrimary)
                                .padding(LuxurySpacing.sm)
                                .background(LuxuryColorPalette.pearlWhite.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: LuxuryColorPalette.Shadow.medium.color, radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Spacer()

                        // Map style selector
                        Menu {
                            ForEach(GlobeMapStyle.allCases, id: \.self) { style in
                                Button(action: {
                                    withAnimation(LuxuryAnimation.Modal.present) {
                                        mapStyle = style
                                    }
                                }) {
                                    HStack {
                                        Text(style.displayName)
                                        Spacer()
                                        if mapStyle == style {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(LuxuryColorPalette.softGold)
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: LuxurySpacing.xs) {
                                Image(systemName: mapStyle.iconName)
                                    .font(.system(size: 16))
                                Text(mapStyle.displayName)
                                    .font(LuxuryTypography.caption)
                            }
                            .foregroundColor(LuxuryColorPalette.textPrimary)
                            .padding(.horizontal, LuxurySpacing.sm)
                            .padding(.vertical, LuxurySpacing.xs)
                            .background(LuxuryColorPalette.pearlWhite.opacity(0.9))
                            .cornerRadius(LuxurySpacing.cornerRadiusSmall)
                            .shadow(color: LuxuryColorPalette.Shadow.medium.color, radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(LuxurySpacing.md)

                    Spacer()

                    // Globe controls
                    HStack {
                        // Zoom to current location
                        Button(action: {
                            mapController.zoomToCurrentLocation()
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(LuxuryColorPalette.premiumBlue)
                                .padding(LuxurySpacing.sm)
                                .background(LuxuryColorPalette.pearlWhite.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: LuxuryColorPalette.Shadow.medium.color, radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Zoom to world view
                        Button(action: {
                            mapController.zoomToWorldView()
                        }) {
                            Image(systemName: "globe")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(LuxuryColorPalette.textPrimary)
                                .padding(LuxurySpacing.sm)
                                .background(LuxuryColorPalette.pearlWhite.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: LuxuryColorPalette.Shadow.medium.color, radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Spacer()
                    }
                    .padding(LuxurySpacing.md)
                }

                // Layer controls panel
                if showingLayerControls {
                    VStack {
                        HStack {
                            Text("Map Layers")
                                .font(LuxuryTypography.subtitle)
                                .foregroundColor(LuxuryColorPalette.textPrimary)

                            Spacer()

                            Button(action: {
                                withAnimation(LuxuryAnimation.Modal.dismiss) {
                                    showingLayerControls = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(LuxuryColorPalette.textSecondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(LuxurySpacing.md)

                        // Layer toggles
                        VStack(spacing: LuxurySpacing.sm) {
                            LayerToggleRow(
                                title: "Visited Places",
                                icon: "heart.fill",
                                color: LuxuryColorPalette.visitedPlaceGold,
                                isEnabled: locationAnnotationManager.showVisitedPlaces
                            ) {
                                locationAnnotationManager.showVisitedPlaces.toggle()
                            }

                            LayerToggleRow(
                                title: "Wanted Destinations",
                                icon: "star.fill",
                                color: LuxuryColorPalette.wantedPlaceSilver,
                                isEnabled: locationAnnotationManager.showWantedDestinations
                            ) {
                                locationAnnotationManager.showWantedDestinations.toggle()
                            }

                            LayerToggleRow(
                                title: "Current Location",
                                icon: "location.fill",
                                color: LuxuryColorPalette.currentLocationBlue,
                                isEnabled: locationAnnotationManager.showCurrentLocation
                            ) {
                                locationAnnotationManager.showCurrentLocation.toggle()
                            }
                        }
                        .padding(.horizontal, LuxurySpacing.md)
                        .padding(.bottom, LuxurySpacing.md)
                    }
                    .background(LuxuryColorPalette.pearlWhite)
                    .cornerRadius(LuxurySpacing.cornerRadiusMedium)
                    .shadow(color: LuxuryColorPalette.Shadow.heavy.color, radius: 16, x: 0, y: 8)
                    .padding(LuxurySpacing.md)
                    .transition(LuxuryAnimation.Modal.present)
                }
            }
        }
        .sheet(item: $selectedPlace) { place in
            VisitedPlaceDetailView(place: place)
        }
    }

    private func setupInitialRegion() {
        // Start with a world view
        mapController.zoomToWorldView()
    }

    private func loadAnnotations() {
        locationAnnotationManager.loadAnnotations()
    }

    private func updateAnnotationsForVisibleRegion() {
        let region = mapController.region
        locationAnnotationManager.updateAnnotationsForRegion(region)
    }
}

// MARK: - Globe Map Styles

enum GlobeMapStyle: CaseIterable {
    case realistic
    case minimal
    case night
    case vintage

    var displayName: String {
        switch self {
        case .realistic: return "Realistic"
        case .minimal: return "Minimal"
        case .night: return "Night"
        case .vintage: return "Vintage"
        }
    }

    var iconName: String {
        switch self {
        case .realistic: return "globe.americas.fill"
        case .minimal: return "globe.europe.africa.fill"
        case .night: return "globe.central.south.asia.fill"
        case .vintage: return "map.fill"
        }
    }

    var mapStyle: MapStyle {
        switch self {
        case .realistic:
            return .imagery
        case .minimal:
            return .standard
        case .night:
            return .hybrid
        case .vintage:
            return .standard
        }
    }
}

// MARK: - Layer Toggle Row

struct LayerToggleRow: View {
    let title: String
    let icon: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: LuxurySpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isEnabled ? color : LuxuryColorPalette.textTertiary)
                    .frame(width: 24)

                Text(title)
                    .font(LuxuryTypography.body)
                    .foregroundColor(isEnabled ? LuxuryColorPalette.textPrimary : LuxuryColorPalette.textSecondary)

                Spacer()

                // Toggle switch
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? color : LuxuryColorPalette.textTertiary.opacity(0.3))
                    .frame(width: 44, height: 24)
                    .overlay(
                        Circle()
                            .fill(LuxuryColorPalette.pearlWhite)
                            .frame(width: 18, height: 18)
                            .offset(x: isEnabled ? 11 : -11)
                            .animation(LuxuryAnimation.springy, value: isEnabled)
                    )
            }
            .padding(.vertical, LuxurySpacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Map Interaction Controller

class MapInteractionController: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
    )
    @Published var userTrackingMode: MKUserTrackingMode = .none

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        requestLocationPermissions()
    }

    func zoomToCurrentLocation() {
        guard let location = locationManager.location else {
            requestLocationAuthorizationAndZoom()
            return
        }

        withAnimation(LuxuryAnimation.Navigation.push) {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
            )
        }
    }

    func zoomToWorldView() {
        withAnimation(LuxuryAnimation.Navigation.push) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
            )
        }
    }

    func zoomToLocation(_ coordinate: CLLocationCoordinate2D, radius: CLLocationDistance = 50000) {
        withAnimation(LuxuryAnimation.Navigation.push) {
            let span = MKCoordinateSpan(
                latitudeDelta: radius / 111000.0, // Rough conversion to degrees
                longitudeDelta: radius / 111000.0
            )
            region = MKCoordinateRegion(center: coordinate, span: span)
        }
    }

    func requestLocationAuthorizationAndZoom() {
        locationManager.requestWhenInUseAuthorization()
    }

    private func requestLocationPermissions() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension MapInteractionController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            // Auto-zoom to user location on first update
            if self.userTrackingMode == .none {
                self.zoomToCurrentLocation()
                self.userTrackingMode = .follow
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.startUpdatingLocation()
            case .denied, .restricted:
                self.userTrackingMode = .none
            default:
                break
            }
        }
    }
}

// MARK: - Location Annotation Manager

class LocationAnnotationManager: NSObject, ObservableObject {
    @Published var annotations: [MKPointAnnotation] = []
    @Published var showVisitedPlaces = true
    @Published var showWantedDestinations = true
    @Published var showCurrentLocation = true

    private let coreDataStack = CoreDataStack.shared

    func loadAnnotations() {
        loadVisitedPlaceAnnotations()
        loadLuxuryDestinationAnnotations()
    }

    func updateAnnotationsForRegion(_ region: MKCoordinateRegion) {
        // Filter annotations based on visible region for performance
        let visibleAnnotations = annotations.filter { annotation in
            let latitude = annotation.coordinate.latitude
            let longitude = annotation.coordinate.longitude

            return latitude >= region.center.latitude - region.span.latitudeDelta &&
                   latitude <= region.center.latitude + region.span.latitudeDelta &&
                   longitude >= region.center.longitude - region.span.longitudeDelta &&
                   longitude <= region.center.longitude + region.span.longitudeDelta
        }

        // Update with visible annotations
        DispatchQueue.main.async {
            self.annotations = visibleAnnotations
        }
    }

    private func loadVisitedPlaceAnnotations() {
        let places = coreDataStack.fetch(entity: VisitedPlace.self)

        DispatchQueue.main.async {
            let placeAnnotations = places.compactMap { place -> MKPointAnnotation? in
                guard let latitude = place.latitude,
                      let longitude = place.longitude,
                      let name = place.name else { return nil }

                let annotation = LocationAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = name
                annotation.subtitle = "\(place.city ?? ""), \(place.country ?? "")"
                annotation.type = .visitedPlace
                annotation.visitedPlace = place

                return annotation
            }

            self.annotations.append(contentsOf: placeAnnotations)
        }
    }

    private func loadLuxuryDestinationAnnotations() {
        let destinations = coreDataStack.fetch(entity: LuxuryDestination.self)

        DispatchQueue.main.async {
            let destinationAnnotations = destinations.compactMap { destination -> MKPointAnnotation? in
                guard let latitude = destination.latitude,
                      let longitude = destination.longitude,
                      let name = destination.name else { return nil }

                let annotation = LocationAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = name
                annotation.subtitle = "Luxury Destination • \(destination.luxuryRating) Star"
                annotation.type = .wantedDestination
                annotation.luxuryDestination = destination

                return annotation
            }

            self.annotations.append(contentsOf: destinationAnnotations)
        }
    }
}

// MARK: - Custom Location Annotation

enum AnnotationType {
    case visitedPlace
    case wantedDestination
    case currentLocation
}

class LocationAnnotation: MKPointAnnotation {
    var type: AnnotationType = .visitedPlace
    var visitedPlace: VisitedPlace?
    var luxuryDestination: LuxuryDestination?

    // Custom view for the annotation
    func annotationView() -> MKAnnotationView {
        switch type {
        case .visitedPlace:
            return VisitedPlaceAnnotationView(annotation: self, reuseIdentifier: "VisitedPlacePin")
        case .wantedDestination:
            return WantedDestinationAnnotationView(annotation: self, reuseIdentifier: "WantedDestinationPin")
        case .currentLocation:
            return CurrentLocationAnnotationView(annotation: self, reuseIdentifier: "CurrentLocationPin")
        }
    }
}

// MARK: - Custom Annotation Views

class VisitedPlaceAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        image = createPinImage(color: LuxuryColorPalette.visitedPlaceGold)
        centerOffset = CGPoint(x: 0, y: -image!.size.height / 2)
    }

    private func createPinImage(color: Color) -> UIImage {
        let size = CGSize(width: 30, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Draw pin shape
            let path = UIBezierPath()
            path.move(to: CGPoint(x: size.width / 2, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height * 0.6))
            path.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.6),
                controlPoint: CGPoint(x: size.width / 2, y: size.height * 0.3)
            )
            path.close()

            UIColor(color).setFill()
            path.fill()

            // Add gold circle at top
            let circlePath = UIBezierPath(ovalIn: CGRect(
                x: size.width / 2 - 8,
                y: size.height * 0.2 - 8,
                width: 16,
                height: 16
            ))
            UIColor(LuxuryColorPalette.pearlWhite).setFill()
            circlePath.fill()
        }
    }
}

class WantedDestinationAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        image = createPinImage(color: LuxuryColorPalette.wantedPlaceSilver)
        centerOffset = CGPoint(x: 0, y: -image!.size.height / 2)
    }

    private func createPinImage(color: Color) -> UIImage {
        let size = CGSize(width: 30, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let path = UIBezierPath()
            path.move(to: CGPoint(x: size.width / 2, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height * 0.6))
            path.addQuadCurve(
                to: CGPoint(x: size.width, y: size.height * 0.6),
                controlPoint: CGPoint(x: size.width / 2, y: size.height * 0.3)
            )
            path.close()

            UIColor(color).setFill()
            path.fill()

            let circlePath = UIBezierPath(ovalIn: CGRect(
                x: size.width / 2 - 8,
                y: size.height * 0.2 - 8,
                width: 16,
                height: 16
            ))
            UIColor(LuxuryColorPalette.pearlWhite).setFill()
            circlePath.fill()
        }
    }
}

class CurrentLocationAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        image = createPulsingDot()
    }

    private func createPulsingDot() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let outerCircle = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
            UIColor(LuxuryColorPalette.currentLocationBlue).withAlphaComponent(0.3).setFill()
            outerCircle.fill()

            let innerCircle = UIBezierPath(ovalIn: CGRect(
                x: size.width / 2 - 6,
                y: size.height / 2 - 6,
                width: 12,
                height: 12
            ))
            UIColor(LuxuryColorPalette.currentLocationBlue).setFill()
            innerCircle.fill()
        }
    }
}

// MARK: - Preview

struct InteractiveGlobeView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveGlobeView()
            .previewDisplayName("Interactive Globe")
    }
}