//
//  VisitedPlaceDetailView.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  PrivateView
//

import MapKit
import SwiftUI

struct VisitedPlaceDetailView: View {
    let place: VisitedPlace
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingPhotoMoments = false
    @State private var isFavorite: Bool

    init(place: VisitedPlace) {
        self.place = place
        self._isFavorite = State(initialValue: place.isFavorite)
    }

    var body: some View {
        LuxuryStandardNavController(
            title: place.name ?? "Unknown Place",
            showBackButton: true,
            onBack: { dismiss() }
        ) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: LuxurySpacing.lg) {
                    // Map preview
                    LuxuryCard {
                        Map(
                            coordinateRegion: .constant(
                                MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(
                                        latitude: place.latitude,
                                        longitude: place.longitude
                                    ),
                                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                                )),
                            interactionModes: [],
                            showsUserLocation: false,
                            annotationItems: [place]
                        ) { place in
                            MapMarker(
                                coordinate: CLLocationCoordinate2D(
                                    latitude: place.latitude,
                                    longitude: place.longitude
                                ))
                        }

                        .frame(height: 200)
                        .cornerRadius(LuxurySpacing.cornerRadiusSmall)
                        .clipped()
                    }

                    // Place information
                    VStack(alignment: .leading, spacing: LuxurySpacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: LuxurySpacing.xs) {
                                Text(place.name ?? "Unknown Place")
                                    .font(LuxuryTypography.title)
                                    .foregroundColor(LuxuryColorPalette.textPrimary)

                                Text("\(place.city ?? ""), \(place.country ?? "")")
                                    .font(LuxuryTypography.body)
                                    .foregroundColor(LuxuryColorPalette.textSecondary)
                            }

                            Spacer()

                            Button(action: {
                                withAnimation(LuxuryAnimation.ButtonPress.select) {
                                    isFavorite.toggle()
                                    place.isFavorite = isFavorite
                                    place.updatedAt = Date()
                                    CoreDataStack.shared.save(context: viewContext)
                                    LuxuryAnimation.CardSelection.select()
                                }
                            }) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 24))
                                    .foregroundColor(
                                        isFavorite
                                            ? LuxuryColorPalette.richRed
                                            : LuxuryColorPalette.textTertiary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // Visit information
                        VStack(alignment: .leading, spacing: LuxurySpacing.sm) {
                            Text("Visit Information")
                                .font(LuxuryTypography.subtitle)
                                .foregroundColor(LuxuryColorPalette.textPrimary)

                            if let firstVisit = place.firstVisitDate {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16))
                                        .foregroundColor(LuxuryColorPalette.softGold)

                                    Text("First visited: \(firstVisit, formatter: dateFormatter)")
                                        .font(LuxuryTypography.body)
                                        .foregroundColor(LuxuryColorPalette.textPrimary)

                                    Spacer()
                                }
                            }

                            if let lastVisit = place.lastVisitDate {
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: 16))
                                        .foregroundColor(LuxuryColorPalette.softGold)

                                    Text("Last visited: \(lastVisit, formatter: dateFormatter)")
                                        .font(LuxuryTypography.body)
                                        .foregroundColor(LuxuryColorPalette.textPrimary)

                                    Spacer()
                                }
                            }

                            HStack {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(LuxuryColorPalette.softGold)

                                Text("\(place.photoCount) Photos")
                                    .font(LuxuryTypography.body)
                                    .foregroundColor(LuxuryColorPalette.textPrimary)

                                Spacer()

                                Button("View Moments") {
                                    showingPhotoMoments = true
                                }
                                .font(LuxuryTypography.body)
                                .foregroundColor(LuxuryColorPalette.premiumBlue)
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                    // Notes section
                    if let notes = place.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: LuxurySpacing.sm) {
                            Text("Notes")
                                .font(LuxuryTypography.subtitle)
                                .foregroundColor(LuxuryColorPalette.textPrimary)

                            Text(notes)
                                .font(LuxuryTypography.body)
                                .foregroundColor(LuxuryColorPalette.textPrimary)
                                .padding(LuxurySpacing.sm)
                                .background(LuxuryColorPalette.secondaryBackground)
                                .cornerRadius(LuxurySpacing.cornerRadiusSmall)
                        }
                    }

                    // Coordinates
                    VStack(alignment: .leading, spacing: LuxurySpacing.sm) {
                        Text("Coordinates")
                            .font(LuxuryTypography.subtitle)
                            .foregroundColor(LuxuryColorPalette.textPrimary)

                        Text(
                            LuxuryTypography.formatCoordinates(
                                latitude: place.latitude, longitude: place.longitude)
                        )
                        .font(LuxuryTypography.body)
                        .foregroundColor(LuxuryColorPalette.textSecondary)
                    }

                    // Action buttons
                    VStack(spacing: LuxurySpacing.sm) {
                        PremiumButton(
                            title: "Edit Place",
                            style: .secondary,
                            icon: "pencil",
                            action: {
                                showingEditSheet = true
                            }
                        )

                        PremiumButton(
                            title: "Share Location",
                            style: .tertiary,
                            icon: "square.and.arrow.up",
                            action: {
                                shareLocation()
                            }
                        )
                    }
                }
                .padding(LuxurySpacing.md)
            }
            .background(LuxuryColorPalette.warmWhite)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditVisitedPlaceView(place: place)
        }
        .sheet(isPresented: $showingPhotoMoments) {
            TravelMomentsView(place: place)
        }
    }

    private func createPlaceAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: place.latitude,
            longitude: place.longitude
        )
        annotation.title = place.name
        annotation.subtitle = "\(place.city ?? ""), \(place.country ?? "")"
        return annotation
    }

    private func shareLocation() {
        let activityViewController = UIActivityViewController(
            activityItems: [
                "I visited \(place.name ?? "this place") in \(place.city ?? ""), \(place.country ?? "")!",
                "https://maps.apple.com/?ll=\(place.latitude),\(place.longitude)",
            ],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = windowScene.windows.first?.rootViewController
        {
            rootViewController.present(activityViewController, animated: true)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

// MARK: - Edit Visited Place View

struct EditVisitedPlaceView: View {
    let place: VisitedPlace
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var notes: String
    @State private var isFavorite: Bool

    init(place: VisitedPlace) {
        self.place = place
        self._name = State(initialValue: place.name ?? "")
        self._notes = State(initialValue: place.notes ?? "")
        self._isFavorite = State(initialValue: place.isFavorite)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Place Information")) {
                    TextField("Place Name", text: $name)
                        .font(LuxuryTypography.body)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .font(LuxuryTypography.body)
                }

                Section {
                    Toggle("Favorite Place", isOn: $isFavorite)
                        .font(LuxuryTypography.body)
                }
            }
            .navigationTitle("Edit Place")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            // Load current values
            name = place.name ?? ""
            notes = place.notes ?? ""
            isFavorite = place.isFavorite
        }
    }

    private func saveChanges() {
        place.name = name.isEmpty ? nil : name
        place.notes = notes.isEmpty ? nil : notes
        place.isFavorite = isFavorite
        place.updatedAt = Date()

        CoreDataStack.shared.save(context: viewContext)
        dismiss()
    }
}

// MARK: - Travel Moments View

struct TravelMomentsView: View {
    let place: VisitedPlace
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TravelMoment.momentDate, ascending: false)],
        predicate: nil,
        animation: .default)
    private var moments: FetchedResults<TravelMoment>

    init(place: VisitedPlace) {
        self.place = place
        self._moments = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \TravelMoment.momentDate, ascending: false)
            ],
            predicate: NSPredicate(format: "visitedPlace == %@", place)
        )
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(moments, id: \.objectID) { moment in
                    TravelMomentRow(moment: moment)
                }
            }
            .navigationTitle("Travel Moments")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .emptyState(if: moments.isEmpty) {
                VStack(spacing: LuxurySpacing.md) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 48))
                        .foregroundColor(LuxuryColorPalette.textTertiary)

                    Text("No Moments Yet")
                        .font(LuxuryTypography.title)
                        .foregroundColor(LuxuryColorPalette.textPrimary)

                    Text("Photo moments will appear here as you capture memories at this location.")
                        .font(LuxuryTypography.body)
                        .foregroundColor(LuxuryColorPalette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(LuxurySpacing.lg)
            }
        }
    }
}

struct TravelMomentRow: View {
    let moment: TravelMoment
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack(spacing: LuxurySpacing.sm) {
            // Placeholder for photo thumbnail
            RoundedRectangle(cornerRadius: LuxurySpacing.cornerRadiusSmall)
                .fill(LuxuryColorPalette.luxuryGoldGradient)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "photo.fill")
                        .font(.system(size: 20))
                        .foregroundColor(LuxuryColorPalette.pearlWhite)
                )

            VStack(alignment: .leading, spacing: LuxurySpacing.xs) {
                Text(moment.title ?? "Moment")
                    .font(LuxuryTypography.listItemTitle)
                    .foregroundColor(LuxuryColorPalette.textPrimary)

                if let momentDate = moment.momentDate {
                    Text(momentDate, formatter: DateFormatter.short)
                        .font(LuxuryTypography.caption)
                        .foregroundColor(LuxuryColorPalette.textSecondary)
                }

                if let description = moment.descriptionText, !description.isEmpty {
                    Text(description)
                        .font(LuxuryTypography.caption)
                        .foregroundColor(LuxuryColorPalette.textTertiary)
                        .lineLimit(2)
                }
            }

            Spacer()

            if moment.isHighlight {
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(LuxuryColorPalette.softGold)
            }
        }
        .padding(.vertical, LuxurySpacing.xs)
    }
}

extension DateFormatter {
    fileprivate static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

extension View {
    @ViewBuilder
    func emptyState<Content: View>(if condition: Bool, @ViewBuilder content: () -> Content)
        -> some View
    {
        if condition {
            content()
        } else {
            self
        }
    }
}

// MARK: - Preview

struct VisitedPlaceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VisitedPlaceDetailView(place: VisitedPlace.preview)
            .environment(\.managedObjectContext, CoreDataStack.preview.viewContext)
            .previewDisplayName("Visited Place Detail")
    }
}
