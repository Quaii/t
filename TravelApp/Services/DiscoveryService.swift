//
//  DiscoveryService.swift
//  Wanderlux
//
//  Created by Wanderlux Team on 11/26/2025.
//  Copyright © 2025 Wanderlux. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class DiscoveryService: NSObject, ObservableObject {
    @Published var nearbyRestaurants: [Restaurant] = []
    @Published var nearbyHotels: [Hotel] = []
    @Published var nearbyStores: [Store] = []
    @Published var recommendedPlaces: [DiscoveredPlace] = []
    @Published var cityRecommendations: [CityRecommendation] = []
    @Published var isSearching = false
    @Published var searchError: String?

    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?

    override init() {
        super.init()
        setupLocationServices()
    }

    // MARK: - Location Setup

    private func setupLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100m
    }

    func requestLocationAccess() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Handle denied location access
            break
        @unknown default:
            break
        }
    }

    // MARK: - Public Discovery Methods

    func discoverNearbyPlaces(category: DiscoveryCategory) {
        guard let location = userLocation else {
            requestLocationAccess()
            return
        }

        isSearching = true
        searchError = nil

        Task {
            await performSearch(location: location, category: category)
        }
    }

    func searchPlaces(query: String) async {
        guard let location = userLocation else {
            searchError = "Location access required for search"
            return
        }

        isSearching = true
        searchError = nil

        do {
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = query
            searchRequest.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )

            let searchResponse = try await MKLocalSearch(request: searchRequest)

            await MainActor.run {
                processSearchResults(searchResponse.mapItems, query: query)
                isSearching = false
            }
        } catch {
            await MainActor.run {
                searchError = "Search failed: \(error.localizedDescription)"
                isSearching = false
            }
        }
    }

    func getCityRecommendations(for cityName: String) async {
        Task {
            do {
                let cityQuery = "\(cityName) restaurants hotels attractions"
                let searchRequest = MKLocalSearchRequest()
                searchRequest.naturalLanguageQuery = cityQuery
                searchRequest.resultTypes = [.pointOfInterest]

                let searchResponse = try await MKLocalSearch(request: searchRequest)

                await MainActor.run {
                    self.cityRecommendations = processCityRecommendations(searchResponse.mapItems, cityName: cityName)
                }
            } catch {
                await MainActor.run {
                    self.searchError = "Failed to get city recommendations: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Private Search Methods

    private func performSearch(location: CLLocation, category: DiscoveryCategory) async {
        do {
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = category.searchQuery
            searchRequest.resultTypes = category.resultTypes
            searchRequest.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // ~5km radius
            )

            let searchResponse = try await MKLocalSearch(request: searchRequest)

            await MainActor.run {
                switch category {
                case .restaurants:
                    nearbyRestaurants = processRestaurantResults(searchResponse.mapItems)
                case .hotels:
                    nearbyHotels = processHotelResults(searchResponse.mapItems)
                case .stores:
                    nearbyStores = processStoreResults(searchResponse.mapItems)
                case .all:
                    processMixedResults(searchResponse.mapItems)
                }
                isSearching = false
            }
        } catch {
            await MainActor.run {
                searchError = "Search failed: \(error.localizedDescription)"
                isSearching = false
            }
        }
    }

    private func processSearchResults(_ mapItems: [MKMapItem], query: String) {
        let searchTerms = query.lowercased().components(separatedBy: .whitespacesAndNewlines)

        var restaurants: [Restaurant] = []
        var hotels: [Hotel] = []
        var stores: [Store] = []
        var places: [DiscoveredPlace] = []

        for item in mapItems {
            if let name = item.name,
               let coordinate = item.placemark.coordinate?.toCLLocation() {

                // Determine category based on search terms and item categories
                if searchTerms.contains(where: { $0.contains("restaurant") || $0.contains("food") || $0.contains("dining") }) ||
                   item.pointOfInterestCategory?.contains(where: { $0.rawValue.contains("restaurant") || $0.rawValue.contains("food") }) == true {
                    let restaurant = Restaurant.fromMapItem(item, coordinate: coordinate)
                    restaurants.append(restaurant)
                } else if searchTerms.contains(where: { $0.contains("hotel") || $0.contains("stay") || $0.contains("accommod") }) ||
                             item.pointOfInterestCategory?.contains(where: { $0.rawValue.contains("hotel") || $0.rawValue.contains("lodging") }) == true {
                    let hotel = Hotel.fromMapItem(item, coordinate: coordinate)
                    hotels.append(hotel)
                } else if searchTerms.contains(where: { $0.contains("store") || $0.contains("shop") || $0.contains("market") }) ||
                             item.pointOfInterestCategory?.contains(where: { $0.rawValue.contains("store") || $0.rawValue.contains("shop") }) == true {
                    let store = Store.fromMapItem(item, coordinate: coordinate)
                    stores.append(store)
                } else {
                    let place = DiscoveredPlace.fromMapItem(item, coordinate: coordinate)
                    places.append(place)
                }
            }
        }

        // Update published arrays
        if !restaurants.isEmpty {
            nearbyRestaurants = restaurants
        }
        if !hotels.isEmpty {
            nearbyHotels = hotels
        }
        if !stores.isEmpty {
            nearbyStores = stores
        }
        if !places.isEmpty {
            recommendedPlaces = places
        }
    }

    private func processRestaurantResults(_ mapItems: [MKMapItem]) -> [Restaurant] {
        return mapItems.compactMap { item in
            guard let name = item.name,
                  let coordinate = item.placemark.coordinate?.toCLLocation() else { return nil }
            return Restaurant.fromMapItem(item, coordinate: coordinate)
        }
    }

    private func processHotelResults(_ mapItems: [MKMapItem]) -> [Hotel] {
        return mapItems.compactMap { item in
            guard let name = item.name,
                  let coordinate = item.placemark.coordinate?.toCLLocation() else { return nil }
            return Hotel.fromMapItem(item, coordinate: coordinate)
        }
    }

    private func processStoreResults(_ mapItems: [MKMapItem]) -> [Store] {
        return mapItems.compactMap { item in
            guard let name = item.name,
                  let coordinate = item.placemark.coordinate?.toCLLocation() else { return nil }
            return Store.fromMapItem(item, coordinate: coordinate)
        }
    }

    private func processMixedResults(_ mapItems: [MKMapItem]) {
        // Separate results by type
        let restaurants = processRestaurantResults(mapItems)
        let hotels = processHotelResults(mapItems)
        let stores = processStoreResults(mapItems)
        let places = mapItems.compactMap { item in
            guard let name = item.name,
                  let coordinate = item.placemark.coordinate?.toCLLocation() else { return nil }
            return DiscoveredPlace.fromMapItem(item, coordinate: coordinate)
        }

        nearbyRestaurants = restaurants
        nearbyHotels = hotels
        nearbyStores = stores
        recommendedPlaces = places
    }

    private func processCityRecommendations(_ mapItems: [MKMapItem], cityName: String) -> [CityRecommendation] {
        var restaurants: [Restaurant] = []
        var hotels: [Hotel] = []
        var attractions: [DiscoveredPlace] = []

        for item in mapItems {
            guard let coordinate = item.placemark.coordinate?.toCLLocation() else { continue }

            if item.pointOfInterestCategory?.contains(where: { $0.rawValue.contains("restaurant") }) == true {
                if let restaurant = Restaurant.fromMapItem(item, coordinate: coordinate) {
                    restaurants.append(restaurant)
                }
            } else if item.pointOfInterestCategory?.contains(where: { $0.rawValue.contains("hotel") }) == true {
                if let hotel = Hotel.fromMapItem(item, coordinate: coordinate) {
                    hotels.append(hotel)
                }
            } else {
                if let place = DiscoveredPlace.fromMapItem(item, coordinate: coordinate) {
                    attractions.append(place)
                }
            }
        }

        return [
            CityRecommendation(
                cityName: cityName,
                restaurants: restaurants.prefix(5).map { $0 },
                hotels: hotels.prefix(3).map { $0 },
                attractions: attractions.prefix(5).map { $0 }
            )
        ]
    }

    // MARK: - AirBnB Integration (Mock Service)

    func getAirbnbRecommendations(for location: CLLocation, checkIn: Date, checkOut: Date) async -> [AirbnbListing] {
        // Mock implementation - in production, this would integrate with Airbnb API
        await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay

        return [
            AirbnbListing(
                id: "mock_1",
                title: "Modern Downtown Apartment",
                location: location,
                price: 125,
                rating: 4.8,
                bedrooms: 2,
                bathrooms: 1,
                maxGuests: 4,
                images: ["mock_image_1"],
                amenities: ["WiFi", "Kitchen", "AC", "Heating"],
                hostName: "Sarah",
                instantBook: true
            ),
            AirbnbListing(
                id: "mock_2",
                title: "Cozy Studio Near City Center",
                location: location,
                price: 85,
                rating: 4.6,
                bedrooms: 1,
                bathrooms: 1,
                maxGuests: 2,
                images: ["mock_image_2"],
                amenities: ["WiFi", "AC", "Kitchenette"],
                hostName: "Mike",
                instantBook: false
            )
        ]
    }
}

// MARK: - Data Models

struct Restaurant {
    let id: UUID
    let name: String
    let cuisine: String
    let priceRange: String
    let rating: Double
    let location: CLLocation
    let address: String
    let phone: String?
    let website: String?
    let isOpenNow: Bool?
    let distance: String?

    static func fromMapItem(_ item: MKMapItem, coordinate: CLLocation) -> Restaurant? {
        guard let name = item.name else { return nil }

        let cuisine = extractCuisine(from: item)
        let priceRange = extractPriceRange(from: item)
        let rating = item.rating ?? 0.0
        let address = formatAddress(item.placemark)
        let phone = item.phoneNumber
        let website = item.url?.absoluteString

        return Restaurant(
            id: UUID(),
            name: name,
            cuisine: cuisine,
            priceRange: priceRange,
            rating: rating,
            location: coordinate,
            address: address,
            phone: phone,
            website: website,
            isOpenNow: nil, // Would need real-time data
            distance: nil // Would calculate from user location
        )
    }

    private static func extractCuisine(from item: MKMapItem) -> String {
        // Extract from categories or use generic "Restaurant"
        if let categories = item.pointOfInterestCategory {
            return categories.first?.localizedName ?? "Restaurant"
        }
        return "Restaurant"
    }

    private static func extractPriceRange(from item: MKMapItem) -> String {
        // In a real implementation, this would come from API data
        return "$$"
    }

    private static func formatAddress(_ placemark: CLPlacemark) -> String {
        let components = [
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea
        ].compactMap { $0 }

        return components.joined(separator: ", ")
    }
}

struct Hotel {
    let id: UUID
    let name: String
    let rating: Double
    let priceRange: String
    let location: CLLocation
    let address: String
    let phone: String?
    let website: String?
    let stars: Int?
    let amenities: [String]

    static func fromMapItem(_ item: MKMapItem, coordinate: CLLocation) -> Hotel? {
        guard let name = item.name else { return nil }

        let rating = item.rating ?? 0.0
        let priceRange = extractPriceRange(from: item)
        let address = Restaurant.formatAddress(item.placemark)
        let phone = item.phoneNumber
        let website = item.url?.absoluteString

        return Hotel(
            id: UUID(),
            name: name,
            rating: rating,
            priceRange: priceRange,
            location: coordinate,
            address: address,
            phone: phone,
            website: website,
            stars: nil, // Would come from API data
            amenities: [] // Would come from API data
        )
    }

    private static func extractPriceRange(from item: MKMapItem) -> String {
        return "$$$"
    }
}

struct Store {
    let id: UUID
    let name: String
    let category: String
    let location: CLLocation
    let address: String
    let phone: String?
    let website: String?
    let openingHours: String?

    static func fromMapItem(_ item: MKMapItem, coordinate: CLLocation) -> Store? {
        guard let name = item.name else { return nil }

        let category = extractCategory(from: item)
        let address = Restaurant.formatAddress(item.placemark)
        let phone = item.phoneNumber
        let website = item.url?.absoluteString

        return Store(
            id: UUID(),
            name: name,
            category: category,
            location: coordinate,
            address: address,
            phone: phone,
            website: website,
            openingHours: nil
        )
    }

    private static func extractCategory(from item: MKMapItem) -> String {
        return item.pointOfInterestCategory?.first?.localizedName ?? "Store"
    }
}

struct DiscoveredPlace {
    let id: UUID
    let name: String
    let category: String
    let location: CLLocation
    let address: String
    let description: String?
    let rating: Double

    static func fromMapItem(_ item: MKMapItem, coordinate: CLLocation) -> DiscoveredPlace? {
        guard let name = item.name else { return nil }

        let category = item.pointOfInterestCategory?.first?.localizedName ?? "Place of Interest"
        let address = Restaurant.formatAddress(item.placemark)
        let rating = item.rating ?? 0.0

        return DiscoveredPlace(
            id: UUID(),
            name: name,
            category: category,
            location: coordinate,
            address: address,
            description: nil,
            rating: rating
        )
    }
}

struct CityRecommendation {
    let cityName: String
    let restaurants: [Restaurant]
    let hotels: [Hotel]
    let attractions: [DiscoveredPlace]
}

struct AirbnbListing {
    let id: String
    let title: String
    let location: CLLocation
    let price: Double
    let rating: Double
    let bedrooms: Int
    let bathrooms: Int
    let maxGuests: Int
    let images: [String]
    let amenities: [String]
    let hostName: String
    let instantBook: Bool

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }

    var url: String {
        return "https://airbnb.com/rooms/\(id)"
    }
}

// MARK: - Discovery Categories

enum DiscoveryCategory {
    case restaurants
    case hotels
    case stores
    case all

    var searchQuery: String {
        switch self {
        case .restaurants:
            return "restaurants"
        case .hotels:
            return "hotels"
        case .stores:
            return "stores shopping"
        case .all:
            return "restaurants hotels stores attractions"
        }
    }

    var resultTypes: [MKPointOfInterestCategory] {
        switch self {
        case .restaurants:
            return [.restaurant]
        case .hotels:
            return [.hotel]
        case .stores:
            return [.store]
        case .all:
            return [.pointOfInterest]
        }
    }
}

// MARK: - CLLocation Extension

extension CLLocationCoordinate2D {
    func toCLLocation() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

// MARK: - DiscoveryService Extension

extension DiscoveryService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location

        // Auto-discover nearby places when location updates
        Task {
            await discoverNearbyPlaces(category: .all)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            userLocation = nil
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}