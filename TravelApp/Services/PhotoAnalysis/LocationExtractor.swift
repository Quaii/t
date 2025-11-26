//
//  LocationExtractor.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import CoreLocation
import Foundation

class LocationExtractor: NSObject, ObservableObject {
    private let geocoder = CLGeocoder()
    private let geocodingQueue = DispatchQueue(label: "com.odyssee.geocoding", qos: .utility)

    // Cache for geocoding results to avoid API limits
    private var geocodingCache: [String: (placeName: String?, country: String?, city: String?)] = [:]
    private let cacheQueue = DispatchQueue(label: "com.odyssee.geocoding.cache", attributes: .concurrent)

    override init() {
        super.init()
    }

    /// Extract location name from coordinates using reverse geocoding
    func reverseGeocodeLocation(
        latitude: Double,
        longitude: Double,
        completion: @escaping (String?, String?, String?) -> Void
    ) {
        let coordinateKey = "\(latitude),\(longitude)"

        // Check cache first
        cacheQueue.async(flags: .read) {
            if let cachedResult = self.geocodingCache[coordinateKey] {
                DispatchQueue.main.async {
                    completion(cachedResult.placeName, cachedResult.country, cachedResult.city)
                }
                return
            }

            // Not in cache, perform geocoding
            self.performReverseGeocoding(
                latitude: latitude,
                longitude: longitude,
                coordinateKey: coordinateKey,
                completion: completion
            )
        }
    }

    private func performReverseGeocoding(
        latitude: Double,
        longitude: Double,
        coordinateKey: String,
        completion: @escaping (String?, String?, String?) -> Void
    ) {
        let location = CLLocation(latitude: latitude, longitude: longitude)

        geocodingQueue.async {
            self.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first else {
                    DispatchQueue.main.async {
                        completion(nil, nil, nil)
                    }
                    return
                }

                let placeName = self.extractPlaceName(from: placemark)
                let country = placemark.country
                let city = placemark.locality ?? placemark.subAdministrativeArea

                // Cache the result
                let result = (placeName, country, city)
                self.cacheQueue.async(flags: .barrier) {
                    self.geocodingCache[coordinateKey] = result
                }

                DispatchQueue.main.async {
                    completion(placeName, country, city)
                }
            }
        }
    }

    /// Extract meaningful place name from placemark hierarchy
    private func extractPlaceName(from placemark: CLPlacemark) -> String? {
        // Priority order for place name extraction
        if let name = placemark.name, !name.isEmpty {
            return name
        }

        if let thoroughfare = placemark.thoroughfare, !thoroughfare.isEmpty {
            return thoroughfare
        }

        if let subLocality = placemark.subLocality, !subLocality.isEmpty {
            return subLocality
        }

        if let locality = placemark.locality, !locality.isEmpty {
            return locality
        }

        if let administrativeArea = placemark.administrativeArea, !administrativeArea.isEmpty {
            return administrativeArea
        }

        if let country = placemark.country, !country.isEmpty {
            return country
        }

        return "Unknown Location"
    }

    /// Batch geocode multiple coordinates for efficiency
    func batchReverseGeocode(
        coordinates: [(Double, Double)],
        completion: @escaping ([String: (String?, String?, String?)]) -> Void
    ) {
        var results: [String: (String?, String?, String?)] = [:]
        let semaphore = DispatchSemaphore(value: 0)
        let group = DispatchGroup()

        for (latitude, longitude) in coordinates {
            group.enter()
            reverseGeocodeLocation(latitude: latitude, longitude: longitude) { placeName, country, city in
                let key = "\(latitude),\(longitude)"
                results[key] = (placeName, country, city)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }

    /// Extract coordinates from CLLocation
    func extractCoordinates(from location: CLLocation) -> (latitude: Double, longitude: Double)? {
        guard location.horizontalAccuracy <= 50 else { return nil }
        return (location.coordinate.latitude, location.coordinate.longitude)
    }

    /// Calculate distance between two coordinates in meters
    func calculateDistance(
        from coord1: (latitude: Double, longitude: Double),
        to coord2: (latitude: Double, longitude: Double)
    ) -> CLLocationDistance {
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        return location1.distance(from: location2)
    }

    /// Check if coordinates are within a specified radius
    func areCoordinatesWithinRadius(
        coord1: (latitude: Double, longitude: Double),
        coord2: (latitude: Double, longitude: Double),
        radiusMeters: CLLocationDistance
    ) -> Bool {
        return calculateDistance(from: coord1, to: coord2) <= radiusMeters
    }

    /// Format coordinates for display
    func formatCoordinates(latitude: Double, longitude: Double) -> String {
        let latDirection = latitude >= 0 ? "N" : "S"
        let lonDirection = longitude >= 0 ? "E" : "W"

        return String(format: "%.4f°%@, %.4f°%@",
                     abs(latitude), latDirection,
                     abs(longitude), lonDirection)
    }

    /// Get timezone information for coordinates
    func getTimezoneForLocation(latitude: Double, longitude: Double) -> TimeZone? {
        return TimeZone.current // Simplified - in production, you'd use a timezone lookup service
    }

    /// Clear geocoding cache to free memory
    func clearCache() {
        cacheQueue.async(flags: .barrier) {
            self.geocodingCache.removeAll()
        }
    }

    /// Get cache statistics
    func getCacheStats() -> Int {
        return cacheQueue.sync {
            return geocodingCache.count
        }
    }
}