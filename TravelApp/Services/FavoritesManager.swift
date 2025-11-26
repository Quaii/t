//
//  FavoritesManager.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import SwiftUI
import CoreData
import Foundation

class FavoritesManager: ObservableObject {
    @Published var favoritePlaces: [FavoritePlace] = []
    @Published var favoriteRestaurants: [FavoriteRestaurant] = []
    @Published var favoriteHotels: [FavoriteHotel] = []
    @Published var favoriteStores: [FavoriteStore] = []
    @Published var favoriteCollections: [FavoriteCollection] = []
    @Published var isLoading = false

    private let coreDataStack = CoreDataStack.shared

    init() {
        loadFavorites()
    }

    // MARK: - Public Methods

    func addToFavorites<T: FavoriteItem>(_ item: T) {
        if let place = item as? VisitedPlace {
            addFavoritePlace(place)
        } else if let restaurant = item as? Restaurant {
            addFavoriteRestaurant(restaurant)
        } else if let hotel = item as? Hotel {
            addFavoriteHotel(hotel)
        } else if let store = item as? Store {
            addFavoriteStore(store)
        } else if let collection = item as? FavoriteCollection {
            addFavoriteCollection(collection)
        }
    }

    func removeFromFavorites<T: FavoriteItem>(_ item: T) {
        if let place = item as? VisitedPlace {
            removeFavoritePlace(place)
        } else if let restaurant = item as? Restaurant {
            removeFavoriteRestaurant(restaurant)
        } else if let hotel = item as? Hotel {
            removeFavoriteHotel(hotel)
        } else if let store = item as? Store {
            removeFavoriteStore(store)
        } else if let collection = item as? FavoriteCollection {
            removeFavoriteCollection(collection)
        }
    }

    func isFavorite<T: FavoriteItem>(_ item: T) -> Bool {
        if let place = item as? VisitedPlace {
            return isFavoritePlace(place)
        } else if let restaurant = item as? Restaurant {
            return isFavoriteRestaurant(restaurant)
        } else if let hotel = item as? Hotel {
            return isFavoriteHotel(hotel)
        } else if let store = item as? Store {
            return isFavoriteStore(store)
        } else if let collection = item as? FavoriteCollection {
            return isFavoriteCollection(collection)
        }
        return false
    }

    func createCollection(name: String, description: String? = nil, color: String = "#007AFF", icon: String = "star.fill") -> FavoriteCollection {
        let collection = FavoriteCollection(
            id: UUID(),
            name: name,
            description: description,
            color: color,
            icon: icon,
            createdAt: Date(),
            items: []
        )

        addFavoriteCollection(collection)
        return collection
    }

    func addToCollection(_ item: any FavoriteItem, collectionId: UUID) {
        // Implementation to add item to specific collection
    }

    func toggleFavorite<T: FavoriteItem>(_ item: T) {
        if isFavorite(item) {
            removeFromFavorites(item)
        } else {
            addToFavorites(item)
        }
    }

    // MARK: - Private Methods - Places

    private func addFavoritePlace(_ place: VisitedPlace) {
        guard !isFavoritePlace(place) else { return }

        let favoritePlace = FavoritePlace(
            id: UUID(),
            place: place,
            createdAt: Date(),
            notes: "",
            tags: []
        )

        favoritePlaces.append(favoritePlace)
        saveFavoritePlace(favoritePlace)

        // Update the original place
        place.isFavorite = true
        coreDataStack.save()
    }

    private func removeFavoritePlace(_ place: VisitedPlace) {
        favoritePlaces.removeAll { $0.place?.objectID == place.objectID }

        // Update the original place
        place.isFavorite = false
        coreDataStack.save()

        // Remove from Core Data
        deleteFavoritePlace(place)
    }

    private func isFavoritePlace(_ place: VisitedPlace) -> Bool {
        return favoritePlaces.contains { $0.place?.objectID == place.objectID }
    }

    private func saveFavoritePlace(_ favoritePlace: FavoritePlace) {
        // Save to Core Data
        let backgroundContext = coreDataStack.backgroundContext
        backgroundContext.perform {
            let entity = FavoritePlaceEntity(context: backgroundContext)
            entity.id = favoritePlace.id
            entity.createdAt = favoritePlace.createdAt
            entity.notes = favoritePlace.notes
            entity.tags = favoritePlace.tags.joined(separator: ",")

            // Set relationship to place
            if let place = favoritePlace.place as? NSManagedObject {
                entity.place = place
            }

            self.coreDataStack.save(context: backgroundContext)
        }
    }

    private func deleteFavoritePlace(_ place: VisitedPlace) {
        let backgroundContext = coreDataStack.backgroundContext
        backgroundContext.perform {
            let request: NSFetchRequest<FavoritePlaceEntity> = FavoritePlaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "place == %@", place)

            do {
                let favorites = try backgroundContext.fetch(request)
                for favorite in favorites {
                    backgroundContext.delete(favorite)
                }
                self.coreDataStack.save(context: backgroundContext)
            } catch {
                print("Error deleting favorite place: \(error)")
            }
        }
    }

    // MARK: - Private Methods - Restaurants

    private func addFavoriteRestaurant(_ restaurant: Restaurant) {
        guard !isFavoriteRestaurant(restaurant) else { return }

        let favoriteRestaurant = FavoriteRestaurant(
            id: UUID(),
            restaurant: restaurant,
            createdAt: Date(),
            lastVisited: nil,
            visitCount: 0,
            notes: "",
            tags: []
        )

        favoriteRestaurants.append(favoriteRestaurant)
        saveFavoriteRestaurant(favoriteRestaurant)
    }

    private func removeFavoriteRestaurant(_ restaurant: Restaurant) {
        favoriteRestaurants.removeAll { $0.restaurant?.name == restaurant.name }
        deleteFavoriteRestaurant(restaurant)
    }

    private func isFavoriteRestaurant(_ restaurant: Restaurant) -> Bool {
        return favoriteRestaurants.contains { $0.restaurant?.name == restaurant.name }
    }

    private func saveFavoriteRestaurant(_ favoriteRestaurant: FavoriteRestaurant) {
        // Save to Core Data
    }

    private func deleteFavoriteRestaurant(_ restaurant: Restaurant) {
        // Delete from Core Data
    }

    // MARK: - Private Methods - Hotels

    private func addFavoriteHotel(_ hotel: Hotel) {
        guard !isFavoriteHotel(hotel) else { return }

        let favoriteHotel = FavoriteHotel(
            id: UUID(),
            hotel: hotel,
            createdAt: Date(),
            lastStayed: nil,
            totalStays: 0,
            notes: "",
            tags: []
        )

        favoriteHotels.append(favoriteHotel)
        saveFavoriteHotel(favoriteHotel)
    }

    private func removeFavoriteHotel(_ hotel: Hotel) {
        favoriteHotels.removeAll { $0.hotel?.name == hotel.name }
        deleteFavoriteHotel(hotel)
    }

    private func isFavoriteHotel(_ hotel: Hotel) -> Bool {
        return favoriteHotels.contains { $0.hotel?.name == hotel.name }
    }

    private func saveFavoriteHotel(_ favoriteHotel: FavoriteHotel) {
        // Save to Core Data
    }

    private func deleteFavoriteHotel(_ hotel: Hotel) {
        // Delete from Core Data
    }

    // MARK: - Private Methods - Stores

    private func addFavoriteStore(_ store: Store) {
        guard !isFavoriteStore(store) else { return }

        let favoriteStore = FavoriteStore(
            id: UUID(),
            store: store,
            createdAt: Date(),
            lastVisited: nil,
            visitCount: 0,
            notes: "",
            tags: []
        )

        favoriteStores.append(favoriteStore)
        saveFavoriteStore(favoriteStore)
    }

    private func removeFavoriteStore(_ store: Store) {
        favoriteStores.removeAll { $0.store?.name == store.name }
        deleteFavoriteStore(store)
    }

    private func isFavoriteStore(_ store: Store) -> Bool {
        return favoriteStores.contains { $0.store?.name == store.name }
    }

    private func saveFavoriteStore(_ favoriteStore: FavoriteStore) {
        // Save to Core Data
    }

    private func deleteFavoriteStore(_ store: Store) {
        // Delete from Core Data
    }

    // MARK: - Private Methods - Collections

    private func addFavoriteCollection(_ collection: FavoriteCollection) {
        guard !isFavoriteCollection(collection) else { return }

        favoriteCollections.append(collection)
        saveFavoriteCollection(collection)
    }

    private func removeFavoriteCollection(_ collection: FavoriteCollection) {
        favoriteCollections.removeAll { $0.id == collection.id }
        deleteFavoriteCollection(collection)
    }

    private func isFavoriteCollection(_ collection: FavoriteCollection) -> Bool {
        return favoriteCollections.contains { $0.id == collection.id }
    }

    private func saveFavoriteCollection(_ collection: FavoriteCollection) {
        // Save to Core Data
    }

    private func deleteFavoriteCollection(_ collection: FavoriteCollection) {
        // Delete from Core Data
    }

    // MARK: - Loading

    private func loadFavorites() {
        isLoading = true

        // Load from Core Data
        let backgroundContext = coreDataStack.backgroundContext
        backgroundContext.perform {
            self.loadFavoritePlaces(context: backgroundContext)
            self.loadFavoriteRestaurants(context: backgroundContext)
            self.loadFavoriteHotels(context: backgroundContext)
            self.loadFavoriteStores(context: backgroundContext)
            self.loadFavoriteCollections(context: backgroundContext)

            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    private func loadFavoritePlaces(context: NSManagedObjectContext) {
        let request: NSFetchRequest<FavoritePlaceEntity> = FavoritePlaceEntity.fetchRequest()

        do {
            let entities = try context.fetch(request)
            favoritePlaces = entities.compactMap { entity in
                guard let place = entity.place as? VisitedPlace else { return nil }

                return FavoritePlace(
                    id: entity.id ?? UUID(),
                    place: place,
                    createdAt: entity.createdAt ?? Date(),
                    notes: entity.notes ?? "",
                    tags: entity.tags?.components(separatedBy: ",") ?? []
                )
            }
        } catch {
            print("Error loading favorite places: \(error)")
        }
    }

    private func loadFavoriteRestaurants(context: NSManagedObjectContext) {
        // Implementation to load favorite restaurants
    }

    private func loadFavoriteHotels(context: NSManagedObjectContext) {
        // Implementation to load favorite hotels
    }

    private func loadFavoriteStores(context: NSManagedObjectContext) {
        // Implementation to load favorite stores
    }

    private func loadFavoriteCollections(context: NSManagedObjectContext) {
        // Implementation to load favorite collections
    }

    // MARK: - Search and Filter

    func searchFavorites(query: String) -> [any FavoriteItem] {
        let lowercaseQuery = query.lowercased()

        var results: [any FavoriteItem] = []

        // Search in places
        results.append(contentsOf: favoritePlaces.filter {
            $0.place?.name?.lowercased().contains(lowercaseQuery) == true ||
            $0.place?.city?.lowercased().contains(lowercaseQuery) == true ||
            $0.place?.country?.lowercased().contains(lowercaseQuery) == true
        })

        // Search in restaurants
        results.append(contentsOf: favoriteRestaurants.filter {
            $0.restaurant?.name?.lowercased().contains(lowercaseQuery) == true ||
            $0.restaurant?.cuisine?.lowercased().contains(lowercaseQuery) == true
        })

        // Search in hotels
        results.append(contentsOf: favoriteHotels.filter {
            $0.hotel?.name?.lowercased().contains(lowercaseQuery) == true
        })

        // Search in stores
        results.append(contentsOf: favoriteStores.filter {
            $0.store?.name?.lowercased().contains(lowercaseQuery) == true ||
            $0.store?.category?.lowercased().contains(lowercaseQuery) == true
        })

        return results
    }

    func getFavoritesByCategory(_ category: FavoritesCategory) -> [any FavoriteItem] {
        switch category {
        case .all:
            return favoritePlaces + favoriteRestaurants + favoriteHotels + favoriteStores
        case .places:
            return favoritePlaces
        case .restaurants:
            return favoriteRestaurants
        case .hotels:
            return favoriteHotels
        case .stores:
            return favoriteStores
        case .collections:
            return favoriteCollections
        }
    }

    func getFavoritesCount() -> (places: Int, restaurants: Int, hotels: Int, stores: Int, collections: Int) {
        return (
            places: favoritePlaces.count,
            restaurants: favoriteRestaurants.count,
            hotels: favoriteHotels.count,
            stores: favoriteStores.count,
            collections: favoriteCollections.count
        )
    }
}

// MARK: - Data Models

protocol FavoriteItem {
    var id: UUID { get }
    var name: String { get }
    var createdAt: Date { get }
    var notes: String { get set }
    var tags: [String] { get set }
}

struct FavoritePlace: FavoriteItem {
    let id: UUID
    let place: VisitedPlace?
    let createdAt: Date
    var notes: String
    var tags: [String]

    var name: String {
        return place?.name ?? "Unknown Place"
    }
}

struct FavoriteRestaurant: FavoriteItem {
    let id: UUID
    let restaurant: Restaurant?
    let createdAt: Date
    var lastVisited: Date?
    var visitCount: Int
    var notes: String
    var tags: [String]

    var name: String {
        return restaurant?.name ?? "Unknown Restaurant"
    }
}

struct FavoriteHotel: FavoriteItem {
    let id: UUID
    let hotel: Hotel?
    let createdAt: Date
    var lastStayed: Date?
    var totalStays: Int
    var notes: String
    var tags: [String]

    var name: String {
        return hotel?.name ?? "Unknown Hotel"
    }
}

struct FavoriteStore: FavoriteItem {
    let id: UUID
    let store: Store?
    let createdAt: Date
    var lastVisited: Date?
    var visitCount: Int
    var notes: String
    var tags: [String]

    var name: String {
        return store?.name ?? "Unknown Store"
    }
}

struct FavoriteCollection: FavoriteItem {
    let id: UUID
    let name: String
    let description: String?
    let color: String
    let icon: String
    let createdAt: Date
    var items: [any FavoriteItem]

    var notes: String {
        get { description ?? "" }
        set { /* Collection notes stored in description */ }
    }

    var tags: [String] {
        get { [] }
        set { /* Collections don't have tags */ }
    }
}

enum FavoritesCategory: String, CaseIterable {
    case all = "All"
    case places = "Places"
    case restaurants = "Restaurants"
    case hotels = "Hotels"
    case stores = "Stores"
    case collections = "Collections"

    var displayName: String {
        return rawValue
    }

    var iconName: String {
        switch self {
        case .all:
            return "heart.fill"
        case .places:
            return "location.fill"
        case .restaurants:
            return "fork.knife"
        case .hotels:
            return "bed.double.fill"
        case .stores:
            return "bag.fill"
        case .collections:
            return "folder.fill"
        }
    }
}

// MARK: - Core Data Entities (placeholder)

class FavoritePlaceEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var createdAt: Date?
    @NSManaged var notes: String?
    @NSManaged var tags: String?
    @NSManaged var place: VisitedPlace?
}

// Note: Similar entities would be created for FavoriteRestaurantEntity, FavoriteHotelEntity, etc.