//
//  MainDashboardView.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import SwiftUI

struct MainDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var privacyManager = PrivacyManager()
    @State private var showingFloatingMenu = false
    @State private var searchText = ""
    @State private var selectedTab = DashboardTab.explore
    @State private var showingOnboarding = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VisitedPlace.lastVisitDate, ascending: false)],
        fetchLimit: 5
    )
    private var recentPlaces: FetchedResults<VisitedPlace>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TripPlan.startDate, ascending: true)]
    )
    private var upcomingTrips: FetchedResults<TripPlan>

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Header
                headerView

                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    ExploreView()
                        .tag(DashboardTab.explore)

                    FavoritesView()
                        .tag(DashboardTab.favorites)

                    TripsView()
                        .tag(DashboardTab.trips)

                    DiscoverView()
                        .tag(DashboardTab.discover)

                    ProfileView()
                        .tag(DashboardTab.profile)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: selectedTab)

                // Custom tab bar
                customTabBar
            }

            // Floating action menu
            if showingFloatingMenu {
                FloatingActionMenu(
                    isVisible: $showingFloatingMenu
                )
                .transition(.opacity.combined(with: .scale))
            }

            // Onboarding overlay
            if showingOnboarding {
                OnboardingOverlay(
                    isVisible: $showingOnboarding
                )
            }
        }
        .background(ModernColorPalette.primaryBackground)
        .onAppear {
            checkFirstLaunch()
            loadRecentData()
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ModernColorPalette.tertiaryText)

                TextField("Search places, restaurants, hotels...", text: $searchText)
                    .font(ModernTypography.searchField)
                    .foregroundColor(ModernColorPalette.primaryText)
                    .tint(ModernColorPalette.vibrantBlue)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(ModernColorPalette.surfaceBackground)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .background(ModernColorPalette.lightCharcoal)
        }
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack {
            ForEach(DashboardTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 20, weight: selectedTab == tab ? .medium : .regular))
                            .foregroundColor(selectedTab == tab ? ModernColorPalette.vibrantBlue : ModernColorPalette.tertiaryText)

                        Text(tab.displayName)
                            .font(ModernTypography.caption1)
                            .foregroundColor(selectedTab == tab ? ModernColorPalette.vibrantBlue : ModernColorPalette.tertiaryText)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(ModernColorPalette.secondaryBackground)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: ModernColorPalette.heavyShadow, radius: 10, x: 0, y: -5)
    }

    // MARK: - Tab Content Views

    @ViewBuilder
    private func tabContent(for tab: DashboardTab) -> some View {
        switch tab {
        case .explore:
            ExploreView()
        case .favorites:
            FavoritesView()
        case .trips:
            TripsView()
        case .discover:
            DiscoverView()
        case .profile:
            ProfileView()
        }
    }

    // MARK: - Helper Methods

    private func checkFirstLaunch() {
        if privacyManager.isFirstLaunch {
            showingOnboarding = true
        }
    }

    private func loadRecentData() {
        // Data is loaded through @FetchRequest
    }
}

// MARK: - Dashboard Tab Enum

enum DashboardTab: CaseIterable {
    case explore
    case favorites
    case trips
    case discover
    case profile

    var displayName: String {
        switch self {
        case .explore:
            return "Explore"
        case .favorites:
            return "Favorites"
        case .trips:
            return "Trips"
        case .discover:
            return "Discover"
        case .profile:
            return "Profile"
        }
    }

    var iconName: String {
        switch self {
        case .explore:
            return "map.fill"
        case .favorites:
            return "heart.fill"
        case .trips:
            return "airplane"
        case .discover:
            return "safari.fill"
        case .profile:
            return "person.fill"
        }
    }
}

// MARK: - Explore View

struct ExploreView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingSearchResults = false
    @State private var searchResults: [SearchResult] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Quick actions
                quickActionsSection

                // Recent places
                recentPlacesSection

                // Recommended destinations
                recommendedSection

                // Popular restaurants nearby
                restaurantsSection

                // Hotels nearby
                hotelsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(ModernTypography.sectionHeader)
                .foregroundColor(ModernColorPalette.primaryText)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                QuickActionCard(
                    title: "Add Place",
                    icon: "plus.circle.fill",
                    color: ModernColorPalette.vibrantBlue,
                    action: { /* Add place action */ }
                )

                QuickActionCard(
                    title: "Scan Photos",
                    icon: "photo.stack.fill",
                    color: ModernColorPalette.mintGreen,
                    action: { /* Scan photos action */ }
                )

                QuickActionCard(
                    title: "Find Hotels",
                    icon: "bed.double.fill",
                    color: ModernColorPalette.purpleAccent,
                    action: { /* Find hotels action */ }
                )

                QuickActionCard(
                    title: "Restaurants",
                    icon: "fork.knife",
                    color: ModernColorPalette.warmOrange,
                    action: { /* Restaurants action */ }
                )
            }
        }
    }

    private var recentPlacesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Places")
                    .font(ModernTypography.sectionHeader)
                    .foregroundColor(ModernColorPalette.primaryText)

                Spacer()

                Button("See All") {
                    // Navigate to all places
                }
                .font(ModernTypography.captionMedium)
                .foregroundColor(ModernColorPalette.vibrantBlue)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    // Sample recent places
                    ForEach(0..<5, id: \.self) { _ in
                        PlaceCard(place: samplePlace)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended for You")
                .font(ModernTypography.sectionHeader)
                .foregroundColor(ModernColorPalette.primaryText)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(recommendedDestinations, id: \.id) { destination in
                    DestinationCard(destination: destination)
                }
            }
        }
    }

    private var restaurantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Restaurants Nearby")
                .font(ModernTypography.sectionHeader)
                .foregroundColor(ModernColorPalette.primaryText)

            LazyVStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    RestaurantRow(restaurant: sampleRestaurant)
                }
            }
        }
    }

    private var hotelsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hotels Nearby")
                .font(ModernTypography.sectionHeader)
                .foregroundColor(ModernColorPalette.primaryText)

            LazyVStack(spacing: 12) {
                ForEach(0..<2, id: \.self) { _ in
                    HotelRow(hotel: sampleHotel)
                }
            }
        }
    }

    // Sample data (would be replaced with actual data)
    private var samplePlace: VisitedPlace {
        let place = VisitedPlace()
        place.name = "Central Park"
        place.city = "New York"
        place.country = "USA"
        place.photoCount = 42
        place.isFavorite = true
        return place
    }

    private var recommendedDestinations: [RecommendedDestination] {
        [
            RecommendedDestination(id: 1, name: "Paris", country: "France", image: "paris", rating: 4.8),
            RecommendedDestination(id: 2, name: "Tokyo", country: "Japan", image: "tokyo", rating: 4.9),
            RecommendedDestination(id: 3, name: "Barcelona", country: "Spain", image: "barcelona", rating: 4.7),
            RecommendedDestination(id: 4, name: "Rome", country: "Italy", image: "rome", rating: 4.6)
        ]
    }

    private var sampleRestaurant: Restaurant {
        Restaurant(name: "The Modern", cuisine: "American", rating: 4.5, price: "$$$", distance: "0.3 mi")
    }

    private var sampleHotel: Hotel {
        Hotel(name: "The Plaza Hotel", rating: 4.8, price: "$$$$", distance: "0.5 mi")
    }
}

// MARK: - Supporting Views

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)

                Text(title)
                    .font(ModernTypography.captionMedium)
                    .foregroundColor(ModernColorPalette.primaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(ModernColorPalette.surfaceBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ModernColorPalette.lightCharcoal, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlaceCard: View {
    let place: VisitedPlace

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder image
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [ModernColorPalette.vibrantBlue, ModernColorPalette.softBlue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 120)
                .overlay(
                    VStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 24))
                            .foregroundColor(ModernColorPalette.primaryText)

                        Text(place.name ?? "Unknown")
                            .font(ModernTypography.destinationName)
                            .foregroundColor(ModernColorPalette.primaryText)
                            .multilineTextAlignment(.center)
                    }
                )

            // Place info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(place.city ?? ""), \(place.country ?? "")")
                    .font(ModernTypography.captionRegular)
                    .foregroundColor(ModernColorPalette.secondaryText)

                HStack {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 12))
                        .foregroundColor(ModernColorPalette.vibrantBlue)

                    Text("\(place.photoCount) photos")
                        .font(ModernTypography.caption1)
                        .foregroundColor(ModernColorPalette.secondaryText)

                    Spacer()

                    if place.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(ModernColorPalette.goldAccent)
                    }
                }
            }
        }
        .frame(width: 160)
        .background(ModernColorPalette.cardBackground)
        .cornerRadius(12)
        .shadow(color: ModernColorPalette.mediumShadow, radius: 8, x: 0, y: 4)
    }
}

struct RecommendedDestination: Identifiable {
    let id: Int
    let name: String
    let country: String
    let image: String
    let rating: Double
}

struct DestinationCard: View {
    let destination: RecommendedDestination

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [ModernColorPalette.vibrantBlue, ModernColorPalette.purpleAccent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 120)
                .overlay(
                    VStack {
                        Text(destination.name)
                            .font(ModernTypography.destinationName)
                            .foregroundColor(ModernColorPalette.primaryText)

                        Text(destination.country)
                            .font(ModernTypography.captionRegular)
                            .foregroundColor(ModernColorPalette.secondaryText)
                    }
                )

            // Rating
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < Int(destination.rating) ? "star.fill" : "star")
                        .font(.system(size: 12))
                        .foregroundColor(ModernColorPalette.goldAccent)
                }

                Spacer()

                Text(String(format: "%.1f", destination.rating))
                    .font(ModernTypography.captionMedium)
                    .foregroundColor(ModernColorPalette.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .background(ModernColorPalette.cardBackground)
        .cornerRadius(12)
        .shadow(color: ModernColorPalette.mediumShadow, radius: 8, x: 0, y: 4)
    }
}

struct Restaurant {
    let name: String
    let cuisine: String
    let rating: Double
    let price: String
    let distance: String
}

struct Hotel {
    let name: String
    let rating: Double
    let price: String
    let distance: String
}

struct RestaurantRow: View {
    let restaurant: Restaurant

    var body: some View {
        HStack(spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(ModernColorPalette.surfaceBackground)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 20))
                        .foregroundColor(ModernColorPalette.secondaryText)
                )

            // Restaurant info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(ModernTypography.listItemTitle)
                    .foregroundColor(ModernColorPalette.primaryText)

                HStack {
                    Text(restaurant.cuisine)
                        .font(ModernTypography.captionRegular)
                        .foregroundColor(ModernColorPalette.secondaryText)

                    Spacer()

                    Text(restaurant.price)
                        .font(ModernTypography.captionMedium)
                        .foregroundColor(ModernColorPalette.secondaryText)
                }

                HStack {
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < Int(restaurant.rating) ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(ModernColorPalette.goldAccent)
                        }
                    }

                    Spacer()

                    Text(restaurant.distance)
                        .font(ModernTypography.caption1)
                        .foregroundColor(ModernColorPalette.tertiaryText)
                }
            }
        }
        .padding(12)
        .background(ModernColorPalette.cardBackground)
        .cornerRadius(12)
    }
}

struct HotelRow: View {
    let hotel: Hotel

    var body: some View {
        HStack(spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(ModernColorPalette.surfaceBackground)
                .frame(width: 80, height: 60)
                .overlay(
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 20))
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

                    Text(hotel.price)
                        .font(ModernTypography.captionMedium)
                        .foregroundColor(ModernColorPalette.secondaryText)
                }

                HStack {
                    Text(hotel.distance)
                        .font(ModernTypography.caption1)
                        .foregroundColor(ModernColorPalette.tertiaryText)

                    Spacer()

                    Button("Book Now") {
                        // Booking action
                    }
                    .font(ModernTypography.captionMedium)
                    .foregroundColor(ModernColorPalette.vibrantBlue)
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(12)
        .background(ModernColorPalette.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Placeholder Views

struct FavoritesView: View {
    var body: some View {
        Text("Favorites")
            .font(ModernTypography.title2)
            .foregroundColor(ModernColorPalette.primaryText)
    }
}

struct TripsView: View {
    var body: some View {
        Text("Trips")
            .font(ModernTypography.title2)
            .foregroundColor(ModernColorPalette.primaryText)
    }
}

struct DiscoverView: View {
    var body: some View {
        Text("Discover")
            .font(ModernTypography.title2)
            .foregroundColor(ModernColorPalette.primaryText)
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
            .font(ModernTypography.title2)
            .foregroundColor(ModernColorPalette.primaryText)
    }
}

// MARK: - Floating Action Menu

struct FloatingActionMenu: View {
    @Binding var isVisible: Bool
    @State private var animatedScale: CGFloat = 0.1
    @State private var animatedOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Overlay
            Color.black.opacity(0.3)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isVisible = false
                    }
                }
                .opacity(animatedOpacity)

            // Menu content
            VStack(spacing: 16) {
                menuButton(title: "Add Place", icon: "plus.circle.fill") {
                    // Add place action
                    isVisible = false
                }

                menuButton(title: "Scan Photos", icon: "photo.stack.fill") {
                    // Scan photos action
                    isVisible = false
                }

                menuButton(title: "Plan Trip", icon: "map.fill") {
                    // Plan trip action
                    isVisible = false
                }
            }
            .padding(24)
            .background(ModernColorPalette.cardBackground)
            .cornerRadius(16)
            .shadow(color: ModernColorPalette.heavyShadow, radius: 20, x: 0, y: 10)
            .scaleEffect(animatedScale)
            .opacity(animatedOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedScale = 1.0
                animatedOpacity = 1.0
            }
        }
        .onChange(of: isVisible) { newValue in
            if newValue {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animatedScale = 1.0
                    animatedOpacity = 1.0
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animatedScale = 0.1
                    animatedOpacity = 0.0
                }
            }
        }
    }

    private func menuButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(ModernColorPalette.vibrantBlue)

                Text(title)
                    .font(ModernTypography.body)
                    .foregroundColor(ModernColorPalette.primaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(ModernColorPalette.surfaceBackground)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Onboarding Overlay

struct OnboardingOverlay: View {
    @Binding var isVisible: Bool
    @State private var currentPage = 0
    @State private var animatedOffset: CGFloat = 0

    private let pages = [
        OnboardingPage(title: "Welcome to Odyssée", description: "Your personal travel companion for discovering and saving your favorite places around the world.", image: "globe.americas.fill"),
        OnboardingPage(title: "Save Your Spots", description: "Automatically add places from your photos or manually save your favorite restaurants, hotels, and destinations.", image: "heart.fill"),
        OnboardingPage(title: "Plan Your Adventures", description: "Organize your trips, discover new places, and never forget a favorite spot again.", image: "map.fill"),
        OnboardingPage(title: "Smart Discovery", description: "Get personalized recommendations for restaurants, hotels, and attractions based on your preferences.", image: "star.fill")
    ]

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.8)
                .onTapGesture {
                    // Dismiss on background tap (only on last page)
                    if currentPage == pages.count - 1 {
                        isVisible = false
                    }
                }

            // Content
            VStack(spacing: 32) {
                Spacer()

                // Page content
                VStack(spacing: 24) {
                    Image(systemName: pages[currentPage].image)
                        .font(.system(size: 64))
                        .foregroundColor(ModernColorPalette.vibrantBlue)

                    Text(pages[currentPage].title)
                        .font(ModernTypography.title2)
                        .foregroundColor(ModernColorPalette.primaryText)
                        .multilineTextAlignment(.center)

                    Text(pages[currentPage].description)
                        .font(ModernTypography.body)
                        .foregroundColor(ModernColorPalette.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                Spacer()

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? ModernColorPalette.vibrantBlue : ModernColorPalette.tertiaryText)
                            .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }

                // Buttons
                VStack(spacing: 12) {
                    Button(currentPage == pages.count - 1 ? "Get Started" : "Continue") {
                        if currentPage == pages.count - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isVisible = false
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                                animatedOffset = -CGFloat(currentPage) * 50
                            }
                        }
                    }
                    .font(ModernTypography.buttonPrimary)
                    .foregroundColor(ModernColorPalette.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(ModernColorPalette.vibrantBlue)
                    .cornerRadius(12)

                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isVisible = false
                            }
                        }
                        .font(ModernTypography.buttonTertiary)
                        .foregroundColor(ModernColorPalette.vibrantBlue)
                    }
                }
            }
            .padding(24)
            .background(ModernColorPalette.cardBackground)
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .scaleEffect(1.0 - CGFloat(currentPage) * 0.05)
            .opacity(1.0 - Double(currentPage) * 0.1)
            .animation(.easeInOut(duration: 0.3), value: currentPage)
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let image: String
}

// MARK: - Helper Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct SearchResult {
    let title: String
    let subtitle: String
    let type: SearchResultType
    let coordinate: CLLocationCoordinate2D?
}

enum SearchResultType {
    case place
    case restaurant
    case hotel
    case city
}

// MARK: - Preview

struct MainDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MainDashboardView()
            .environment(\.managedObjectContext, CoreDataStack.preview.viewContext)
            .environmentObject(PrivacyManager())
            .preferredColorScheme(.dark)
            .previewDisplayName("Main Dashboard - Dark")
    }
}