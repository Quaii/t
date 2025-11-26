//
//  TripPlanningView.swift
//  Wanderlux
//
//  Created by Wanderlux Team on 11/26/2025.
//  Copyright © 2025 Wanderlux. All rights reserved.
//

import SwiftUI
import CoreData

struct TripPlanningView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var discoveryService = DiscoveryService()
    @StateObject private var favoritesManager = FavoritesManager()

    @State private var currentStep = PlanningStep.destination
    @State private var tripName = ""
    @State private var selectedDestination: DiscoveredPlace?
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
    @State private var travelerCount = 1
    @State private var budgetAmount: Double = 1000
    @State private var accommodationBudget: Double = 0
    @State private var foodBudget: Double = 0
    @State private var activitiesBudget: Double = 0
    @State private var transportBudget: Double = 0
    @State private var selectedAccommodation: AirbnbListing?
    @State private var showingAccommodations = false
    @State private var showingAirbnb = false
    @State private var tripNotes = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator

                // Content based on current step
                ScrollView {
                    LazyVStack(spacing: 24) {
                        switch currentStep {
                        case .destination:
                            destinationStepView
                        case .dates:
                            datesStepView
                        case .accommodation:
                            accommodationStepView
                        case .budget:
                            budgetStepView
                        case .activities:
                            activitiesStepView
                        case .review:
                            reviewStepView
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .background(ModernColorPalette.primaryBackground)

                // Navigation buttons
                navigationButtons
            }
            .navigationTitle("Plan Your Trip")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(ModernTypography.buttonLabel)
                    .foregroundColor(ModernColorPalette.vibrantBlue)
                }
            }
        }
        .onAppear {
            updateBudgetAllocations()
        }
        .onChange(of: budgetAmount) { _ in
            updateBudgetAllocations()
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: 8) {
            Text("Step \(currentStep.rawValue + 1) of \(PlanningStep.allCases.count)")
                .font(ModernTypography.captionMedium)
                .foregroundColor(ModernColorPalette.secondaryText)

            HStack(spacing: 4) {
                ForEach(0..<PlanningStep.allCases.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index <= currentStep.rawValue ? ModernColorPalette.vibrantBlue : ModernColorPalette.surfaceBackground)
                        .frame(height: 4)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(ModernColorPalette.cardBackground)
    }

    // MARK: - Step 1: Destination

    private var destinationStepView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ModernTypography.modernHeading("Choose Destination")

            // Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ModernColorPalette.tertiaryText)

                TextField("Where do you want to go?", text: $searchText)
                    .font(ModernTypography.searchField)
                    .foregroundColor(ModernColorPalette.primaryText)
                    .tint(ModernColorPalette.vibrantBlue)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(ModernColorPalette.surfaceBackground)
                    .cornerRadius(10)
            }

            // Favorite destinations
            if !favoritesManager.favoritePlaces.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Favorite Destinations")
                        .font(ModernTypography.headline)
                        .foregroundColor(ModernColorPalette.primaryText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(favoritesManager.favoritePlaces, id: \.id) { favoritePlace in
                                FavoriteDestinationCard(favoritePlace: favoritePlace) {
                                    selectedDestination = DiscoveredPlace(
                                        id: UUID(),
                                        name: favoritePlace.name,
                                        category: "Place of Interest",
                                        location: favoritePlace.place?.location,
                                        address: favoritePlace.place?.address,
                                        description: favoritePlace.notes,
                                        rating: favoritePlace.place?.photoCount ?? 0
                                    )
                                    currentStep = .dates
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }

            // Search results
            if !discoveryService.recommendedPlaces.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recommended Destinations")
                        .font(ModernTypography.headline)
                        .foregroundColor(ModernColorPalette.primaryText)

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(discoveryService.recommendedPlaces, id: \.id) { place in
                            RecommendedDestinationCard(place: place) {
                                selectedDestination = place
                                currentStep = .dates
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 2: Dates

    private var datesStepView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ModernTypography.modernHeading("Select Travel Dates")

            VStack(alignment: .leading, spacing: 16) {
                // Start date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Date")
                        .font(ModernTypography.captionMedium)
                        .foregroundColor(ModernColorPalette.secondaryText)

                    DatePicker("", selection: $startDate, in: Date()...)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accentColor(ModernColorPalette.vibrantBlue)
                        .colorScheme(.dark)
                }

                // End date
                VStack(alignment: .leading, spacing: 8) {
                    Text("End Date")
                        .font(ModernTypography.captionMedium)
                        .foregroundColor(ModernColorPalette.secondaryText)

                    DatePicker("", selection: $endDate, in: startDate...)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accentColor(ModernColorPalette.vibrantBlue)
                        .colorScheme(.dark)
                }

                // Duration display
                let daysBetween = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(ModernColorPalette.vibrantBlue)

                    Text("\(daysBetween) days")
                        .font(ModernTypography.body)
                        .foregroundColor(ModernColorPalette.primaryText)

                    Spacer()

                    Text("\(startDate, formatter: DateFormatter.short) - \(endDate, formatter: DateFormatter.short)")
                        .font(ModernTypography.captionRegular)
                        .foregroundColor(ModernColorPalette.secondaryText)
                }
                .padding(12)
                .background(ModernColorPalette.surfaceBackground)
                .cornerRadius(12)
            }

            // Traveler count
            VStack(alignment: .leading, spacing: 8) {
                Text("Number of Travelers")
                    .font(ModernTypography.captionMedium)
                    .foregroundColor(ModernColorPalette.secondaryText)

                HStack {
                    Button(action: {
                        travelerCount = max(1, travelerCount - 1)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(ModernColorPalette.vibrantBlue)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Text("\(travelerCount)")
                        .font(ModernTypography.title3)
                        .foregroundColor(ModernColorPalette.primaryText)
                        .frame(minWidth: 40)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        travelerCount += 1
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(ModernColorPalette.vibrantBlue)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }
                .padding(12)
                .background(ModernColorPalette.surfaceBackground)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Step 3: Accommodation

    private var accommodationStepView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ModernTypography.modernHeading("Choose Accommodation")

            // Search nearby hotels
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Hotels Near \(selectedDestination?.name ?? "Destination")")
                        .font(ModernTypography.headline)
                        .foregroundColor(ModernColorPalette.primaryText)

                    Spacer()

                    Button("Search Hotels") {
                        discoveryService.discoverNearbyPlaces(category: .hotels)
                    }
                    .font(ModernTypography.buttonTertiary)
                    .foregroundColor(ModernColorPalette.vibrantBlue)
                    .buttonStyle(PlainButtonStyle())
                }

                if discoveryService.isSearching {
                    ProgressView()
                        .tint(ModernColorPalette.vibrantBlue)
                }

                if !discoveryService.nearbyHotels.isEmpty {
                    LazyVStack(spacing: 12) {
                        ForEach(discoveryService.nearbyHotels, id: \.id) { hotel in
                            HotelSelectionCard(hotel: hotel) {
                                selectedAccommodation = nil // Would create trip accommodation record
                            }
                        }
                    }
                }

                // Airbnb integration
                Divider()
                    .background(ModernColorPalette.lightCharcoal)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Need a place to stay?")
                            .font(ModernTypography.body)
                            .foregroundColor(ModernColorPalette.primaryText)

                        Text("Find unique accommodations on Airbnb")
                            .font(ModernTypography.captionRegular)
                            .foregroundColor(ModernColorPalette.secondaryText)
                    }

                    Spacer()

                    Button("Find on Airbnb") {
                        showingAirbnb = true
                    }
                    .font(ModernTypography.buttonTertiary)
                    .foregroundColor(ModernColorPalette.vibrantBlue)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 16)
            }

            // Selected accommodation display
            if let accommodation = selectedAccommodation {
                SelectedAccommodationCard(accommodation: accommodation) {
                    selectedAccommodation = nil
                }
            }
        }
        .sheet(isPresented: $showingAirbnb) {
            AirbnbIntegrationView(
                destination: selectedDestination,
                startDate: startDate,
                endDate: endDate,
                travelers: travelerCount,
                onAccommodationSelected: { accommodation in
                    selectedAccommodation = accommodation
                    showingAirbnb = false
                }
            )
        }
    }

    // MARK: - Step 4: Budget

    private var budgetStepView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ModernTypography.modernHeading("Set Your Budget")

            VStack(alignment: .leading, spacing: 16) {
                // Total budget
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Budget")
                        .font(ModernTypography.captionMedium)
                        .foregroundColor(ModernColorPalette.secondaryText)

                    HStack {
                        Text("$")
                            .font(ModernTypography.title2)
                            .foregroundColor(ModernColorPalette.primaryText)

                        TextField("Amount", value: $budgetAmount, format: .currency(code: "USD"))
                            .font(ModernTypography.title2)
                            .foregroundColor(ModernColorPalette.primaryText)
                            .tint(ModernColorPalette.vibrantBlue)
                            .textFieldStyle(PlainTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
                .padding(16)
                .background(ModernColorPalette.surfaceBackground)
                .cornerRadius(12)

                // Budget allocation
                VStack(alignment: .leading, spacing: 12) {
                    Text("Budget Allocation")
                        .font(ModernTypography.headline)
                        .foregroundColor(ModernColorPalette.primaryText)

                    VStack(spacing: 8) {
                        BudgetAllocationRow(
                            title: "Accommodation",
                            amount: $accommodationBudget,
                            color: ModernColorPalette.mintGreen
                        )

                        BudgetAllocationRow(
                            title: "Food & Dining",
                            amount: $foodBudget,
                            color: ModernColorPalette.warmOrange
                        )

                        BudgetAllocationRow(
                            title: "Activities",
                            amount: $activitiesBudget,
                            color: ModernColorPalette.purpleAccent
                        )

                        BudgetAllocationRow(
                            title: "Transport",
                            amount: $transportBudget,
                            color: ModernColorPalette.vibrantBlue
                        )
                    }
                    .padding(16)
                    .background(ModernColorPalette.surfaceBackground)
                    .cornerRadius(12)

                    // Remaining budget
                    let remainingBudget = budgetAmount - (accommodationBudget + foodBudget + activitiesBudget + transportBudget)
                    HStack {
                        Text("Remaining:")
                            .font(ModernTypography.captionMedium)
                            .foregroundColor(ModernColorPalette.secondaryText)

                        Spacer()

                        ModernTypography.formatCurrency(remainingBudget)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
    }

    // MARK: - Step 5: Activities

    private var activitiesStepView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ModernTypography.modernHeading("Plan Activities")

            VStack(alignment: .leading, spacing: 16) {
                // Trip notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Notes")
                        .font(ModernTypography.captionMedium)
                        .foregroundColor(ModernColorPalette.secondaryText)

                    TextEditor(text: $tripNotes)
                        .font(ModernTypography.formValue)
                        .foregroundColor(ModernColorPalette.primaryText)
                        .tint(ModernColorPalette.vibrantBlue)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(ModernColorPalette.surfaceBackground)
                        .cornerRadius(12)
                }

                // Recommended activities
                Text("Popular Activities")
                    .font(ModernTypography.headline)
                    .foregroundColor(ModernColorPalette.primaryText)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(sampleActivities, id: \.id) { activity in
                        ActivityCard(activity: activity)
                    }
                }
            }
        }
    }

    // MARK: - Step 6: Review

    private var reviewStepView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ModernTypography.modernHeading("Review Your Trip")

                // Trip summary card
                TripSummaryCard(
                    name: tripName,
                    destination: selectedDestination?.name ?? "Selected Destination",
                    startDate: startDate,
                    endDate: endDate,
                    travelers: travelerCount,
                    budget: budgetAmount,
                    accommodation: selectedAccommodation
                )

                // Create trip button
                Button("Create Trip") {
                    createTrip()
                }
                .font(ModernTypography.buttonPrimary)
                .foregroundColor(ModernColorPalette.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(ModernColorPalette.vibrantBlue)
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack {
            // Previous button
            if currentStep != PlanningStep.allCases.first {
                Button("Previous") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = PlanningStep(rawValue: max(0, currentStep.rawValue - 1))!
                    }
                }
                .font(ModernTypography.buttonSecondary)
                .foregroundColor(ModernColorPalette.vibrantBlue)
                .buttonStyle(PlainButtonStyle())
            }

            Spacer()

            // Next button
            Button("Next") {
                if canProceedToNextStep() {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = PlanningStep(rawValue: min(PlanningStep.allCases.count - 1, currentStep.rawValue + 1))!
                    }
                }
            }
            .font(ModernTypography.buttonPrimary)
            .foregroundColor(canProceedToNextStep() ? ModernColorPalette.primaryText : ModernColorPalette.tertiaryText)
            .frame(width: 100, height: 40)
            .background(canProceedToNextStep() ? ModernColorPalette.vibrantBlue : ModernColorPalette.surfaceBackground)
            .cornerRadius(8)
            .disabled(!canProceedToNextStep())
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}

// MARK: - Supporting Views

struct FavoriteDestinationCard: View {
    let favoritePlace: FavoritePlace
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(favoritePlace.name)
                            .font(ModernTypography.listItemTitle)
                            .foregroundColor(ModernColorPalette.primaryText)

                        if let address = favoritePlace.place?.address {
                            Text(address)
                                .font(ModernTypography.captionRegular)
                                .foregroundColor(ModernColorPalette.secondaryText)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(ModernColorPalette.tertiaryText)
                }
            }
            .padding(12)
            .background(ModernColorPalette.cardBackground)
            .cornerRadius(12)
            .shadow(color: ModernColorPalette.mediumShadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecommendedDestinationCard: View {
    let place: DiscoveredPlace
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name)
                            .font(ModernTypography.destinationName)
                            .foregroundColor(ModernColorPalette.primaryText)

                        Text(place.category)
                            .font(ModernTypography.captionRegular)
                            .foregroundColor(ModernColorPalette.vibrantBlue)
                        Text(place.address ?? "")
                            .font(ModernTypography.captionRegular)
                            .foregroundColor(ModernColorPalette.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(ModernColorPalette.tertiaryText)
                    }
                }
            }
            .padding(12)
            .background(ModernColorPalette.cardBackground)
            .cornerRadius(12)
            .shadow(color: ModernColorPalette.mediumShadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HotelSelectionCard: View {
    let hotel: Hotel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Hotel image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(ModernColorPalette.surfaceBackground)
                    .frame(width: 80, height: 60)
                    .overlay(
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 24))
                            .foregroundColor(ModernColorPalette.secondaryText)
                    )

                // Hotel info
                VStack(alignment: .leading, spacing: 4) {
                    Text(hotel.name)
                        .font(ModernTypography.listItemTitle)
                        .foregroundColor(ModernColorPalette.primaryText)

                    HStack {
                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { index in
                                Image(systemName: index < Int(hotel.rating) ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(ModernColorPalette.goldAccent)
                            }
                        }

                        Spacer()

                        Text(hotel.priceRange)
                            .font(ModernTypography.captionMedium)
                            .foregroundColor(ModernColorPalette.secondaryText)
                    }

                    Text(hotel.address)
                        .font(ModernTypography.captionRegular)
                        .foregroundColor(ModernColorPalette.tertiaryText)
                        .lineLimit(2)
                }

                Spacer()
            }
        }
        .padding(12)
        .background(ModernColorPalette.cardBackground)
        .cornerRadius(12)
        .shadow(color: ModernColorPalette.mediumShadow, radius: 4, x: 0, y: 2)
        .buttonStyle(PlainButtonStyle())
    }
}

struct AirbnbIntegrationView: View {
    let destination: DiscoveredPlace?
    let startDate: Date
    let endDate: Date
    let travelers: Int
    let onAccommodationSelected: (AirbnbListing) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var listings: [AirbnbListing] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Airbnb options...")
                        .tint(ModernColorPalette.vibrantBlue)
                } else {
                    List(listings, id: \.id) { listing in
                        AirbnbListingCard(listing: listing) {
                            onAccommodationSelected(listing)
                            dismiss()
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Airbnb")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadAirbnbListings()
        }
    }

    private func loadAirbnbListings() {
        Task {
            if let location = destination?.location {
                listings = await discoveryService.getAirbnbRecommendations(
                    for: location,
                    checkIn: startDate,
                    checkOut: endDate
                )
                isLoading = false
            }
        }
    }
}

struct AirbnbListingCard: View {
    let listing: AirbnbListing
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Listing image
                RoundedRectangle(cornerRadius: 8)
                    .fill(ModernColorPalette.surfaceBackground)
                    .frame(width: 100, height: 80)
                    .overlay(
                        // Would load actual image
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(ModernColorPalette.secondaryText)

                            if listing.instantBook {
                                HStack(spacing: 4) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(ModernColorPalette.mintGreen)

                                    Text("Instant Book")
                                        .font(.system(size: 8))
                                        .foregroundColor(ModernColorPalette.mintGreen)
                                }
                                .padding(4)
                                .background(ModernColorPalette.mintGreen.opacity(0.1))
                                .cornerRadius(4)
                            }
                        }
                    )

                // Listing info
                VStack(alignment: .leading, spacing: 4) {
                    Text(listing.title)
                        .font(ModernTypography.listItemTitle)
                        .foregroundColor(ModernColorPalette.primaryText)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { index in
                                Image(systemName: index < Int(listing.rating) ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(ModernColorPalette.goldAccent)
                            }
                        }

                        Text("(\(listing.bedrooms) bed, \(listing.bathrooms) bath)")
                            .font(ModernTypography.caption1)
                            .foregroundColor(ModernColorPalette.tertiaryText)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(listing.formattedPrice)
                            .font(ModernTypography.priceText)
                            .foregroundColor(ModernColorPalette.vibrantBlue)

                        Text("Hosted by \(listing.hostName)")
                            .font(ModernTypography.caption2)
                            .foregroundColor(ModernColorPalette.tertiaryText)
                    }
                }
            }
        }
        .padding(12)
        .background(ModernColorPalette.cardBackground)
        .cornerRadius(12)
        .shadow(color: ModernColorPalette.mediumShadow, radius: 4, x: 0, y: 2)
        .buttonStyle(PlainButtonStyle())
    }
}

struct SelectedAccommodationCard: View {
    let accommodation: AirbnbListing
    let removeAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Selected Accommodation")
                    .font(ModernTypography.captionMedium)
                    .foregroundColor(ModernColorPalette.secondaryText)

                Text(accommodation.title)
                    .font(ModernTypography.listItemTitle)
                    .foregroundColor(ModernColorPalette.primaryText)

                Text(accommodation.formattedPrice)
                    .font(ModernTypography.priceText)
                    .foregroundColor(ModernColorPalette.vibrantBlue)
            }

            Spacer()

            Button("Remove") {
                removeAction()
            }
            .font(ModernTypography.captionMedium)
            .foregroundColor(ModernColorPalette.softRed)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(ModernColorPalette.successButton.opacity(0.2))
        .cornerRadius(12)
    }
}

struct BudgetAllocationRow: View {
    let title: String
    @Binding var amount: Double
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .font(ModernTypography.body)
                .foregroundColor(ModernColorPalette.primaryText)

            Spacer()

            Text("$\(Int(amount))")
                .font(ModernTypography.body)
                .foregroundColor(color)
        }
    }
}

struct ActivityCard: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: activity.icon)
                .font(.system(size: 24))
                .foregroundColor(activity.color)

            Text(activity.name)
                .font(ModernTypography.body)
                .foregroundColor(ModernColorPalette.primaryText)

            Text(activity.description)
                .font(ModernTypography.captionRegular)
                .foregroundColor(ModernColorPalette.secondaryText)
                .lineLimit(2)
        }
        .padding(16)
        .background(ModernColorPalette.cardBackground)
        .cornerRadius(12)
        .shadow(color: ModernColorPalette.mediumShadow, radius: 4, x: 0, y: 2)
    }
}

struct TripSummaryCard: View {
    let name: String
    let destination: String
    let startDate: Date
    let endDate: Date
    let travelers: Int
    let budget: Double
    let accommodation: AirbnbListing?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ModernTypography.modernHeading(name.isEmpty ? "Untitled Trip" : name)

            VStack(alignment: .leading, spacing: 12) {
                InfoRow(title: "Destination", value: destination)
                InfoRow(title: "Dates", value: "\(startDate, formatter: DateFormatter.short) - \(endDate, formatter: DateFormatter.short)")
                InfoRow(title: "Travelers", value: "\(travelers)")
                InfoRow(title: "Budget", value: ModernTypography.formatCurrency(budget))

                if let accommodation = accommodation {
                    InfoRow(title: "Accommodation", value: accommodation.title)
                }
            }
        }
        .padding(20)
        .background(ModernColorPalette.cardBackground)
        .cornerRadius(16)
        .shadow(color: ModernColorPalette.heavyShadow, radius: 12, x: 0, y: 4)
    }
}

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(ModernTypography.captionMedium)
                .foregroundColor(ModernColorPalette.secondaryText)

            Spacer()

            Text(value)
                .font(ModernTypography.body)
                .foregroundColor(ModernColorPalette.primaryText)
        }
    }
}

// MARK: - Enums and Data

enum PlanningStep: Int, CaseIterable {
    case destination = 0
    case dates = 1
    case accommodation = 2
    case budget = 3
    case activities = 4
    case review = 5
}

struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
}

struct DiscoveredPlace: Identifiable {
    let id: UUID
    let name: String
    let category: String
    let location: CLLocation?
    let address: String?
    let description: String?
    let rating: Double
}

// MARK: - Sample Data

private let sampleActivities: [Activity] = [
    Activity(
        name: "City Walking Tour",
        description: "Explore the city with a local guide",
        icon: "figure.walk",
        color: ModernColorPalette.vibrantBlue
    ),
    Activity(
        name: "Food Tour",
        description: "Taste local cuisine and specialties",
        icon: "fork.knife",
        color: ModernColorPalette.warmOrange
    ),
    Activity(
        name: "Museum Visit",
        description: "Discover local history and culture",
        icon: "building.columns",
        color: ModernColorPalette.purpleAccent
    ),
    Activity(
        name: "Sunset Viewpoint",
        description: "Watch the sunset from a scenic spot",
        icon: "sunset.fill",
        color: ModernColorPalette.softRed
    )
]

// MARK: - Extensions

extension TripPlanningView {
    private var searchText: String {
        get { /* Search text state would be here */ "" }
        set { /* Update search */ }
    }

    private func updateBudgetAllocations() {
        let accommodationPercent = 0.5
        let foodPercent = 0.25
        let activitiesPercent = 0.15
        let transportPercent = 0.1

        accommodationBudget = budgetAmount * accommodationPercent
        foodBudget = budgetAmount * foodPercent
        activitiesBudget = budgetAmount * activitiesPercent
        transportBudget = budgetAmount * transportPercent
    }

    private func canProceedToNextStep() -> Bool {
        switch currentStep {
        case .destination:
            return selectedDestination != nil
        case .dates:
            return startDate < endDate && startDate > Date()
        case .accommodation:
            return true // Accommodation is optional
        case .budget:
            return budgetAmount > 0
        case .activities:
            return true
        case .review:
            return true
        default:
            return false
        }
    }

    private func createTrip() {
        // Create Core Data trip object
        let trip = TripPlan(context: viewContext)
        trip.id = UUID()
        trip.tripName = tripName.isEmpty ? "Trip to \(selectedDestination?.name ?? "Destination")" : tripName
        trip.startDate = startDate
        trip.endDate = endDate
        trip.travelerCount = Int16(travelerCount)
        trip.totalBudget = budgetAmount
        trip.accommodationBudget = accommodationBudget
        trip.diningBudget = foodBudget
        trip.activitiesBudget = activitiesBudget
        trip.transportBudget = transportBudget
        trip.status = "planning"
        trip.createdAt = Date()
        trip.updatedAt = Date()

        CoreDataStack.shared.save(context: viewContext)
        dismiss()
    }
}

// MARK: - Preview

struct TripPlanningView_Previews: PreviewProvider {
    static var previews: some View {
        TripPlanningView()
            .environment(\.managedObjectContext, CoreDataStack.preview.viewContext)
            .preferredColorScheme(.dark)
            .previewDisplayName("Trip Planning")
    }
}