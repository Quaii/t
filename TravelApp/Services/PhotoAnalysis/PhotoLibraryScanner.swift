//
//  PhotoLibraryScanner.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import Photos
import CoreLocation
import CoreData
import Foundation
import UserNotifications

class PhotoLibraryScanner: ObservableObject {
    private let photoLibrary = PHPhotoLibrary.shared()
    private let imageManager = PHImageManager.default()
    private let locationExtractor = LocationExtractor()
    private let persistenceController = CoreDataStack.shared

    @Published var scanningProgress: Double = 0.0
    @Published var isScanning: Bool = false
    @Published var totalPhotosToScan: Int = 0
    @Published var photosProcessed: Int = 0
    @Published var lastScanDate: Date?

    var authorizationStatus: PHAuthorizationStatus {
        return photoLibrary.authorizationStatus(for: .readWrite)
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        photoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }

    func startScan() async {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            print("Photo library access not authorized")
            return
        }

        await withCheckedContinuation { continuation in
            startScanningPhotos {
                continuation.resume()
            }
        }
    }

    private func startScanningPhotos(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.isScanning = true
            self.scanningProgress = 0.0
            self.photosProcessed = 0
        }

        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared]
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)

        let allPhotos = PHAsset.fetchAssets(with: fetchOptions)
        DispatchQueue.main.async {
            self.totalPhotosToScan = allPhotos.count
        }

        // Get last scan date to only process new photos
        let lastScanDate = getLastScanDate()

        let backgroundQueue = DispatchQueue(label: "com.odyssee.photoScanning", qos: .userInitiated)

        backgroundQueue.async {
            self.processPhotosBatch(assets: allPhotos, lastScanDate: lastScanDate) {
                DispatchQueue.main.async {
                    self.isScanning = false
                    self.scanningProgress = 1.0
                    self.saveLastScanDate()
                    self.sendScanCompletionNotification()
                    completion()
                }
            }
        }
    }

    private func processPhotosBatch(assets: PHFetchResult<PHAsset>, lastScanDate: Date?, completion: @escaping () -> Void) {
        let batchSize = 100
        let totalBatches = max(1, assets.count / batchSize)
        var completedBatches = 0

        for batchStart in stride(from: 0, to: assets.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, assets.count)
            let batchRange = batchStart..<batchEnd

            autoreleasepool {
                var batchLocations: [(CLLocation, Date, String)] = []

                for index in batchRange {
                    let asset = assets.object(at: index)

                    // Skip photos older than last scan date
                    if let lastScan = lastScanDate, asset.creationDate ?? Date.distantPast <= lastScan {
                        continue
                    }

                    // Only process photos with location data
                    if let location = asset.location {
                        // Only include photos with decent GPS accuracy (within 50 meters)
                        if location.horizontalAccuracy <= 50 {
                            batchLocations.append((location, asset.creationDate ?? Date(), asset.localIdentifier))
                        }
                    }
                }

                // Process the batch of locations
                processLocationBatch(locations: batchLocations)

                // Update progress
                DispatchQueue.main.async {
                    self.photosProcessed += batchRange.count
                    completedBatches += 1
                    self.scanningProgress = Double(completedBatches) / Double(totalBatches)
                }
            }
        }

        completion()
    }

    private func processLocationBatch(locations: [(CLLocation, Date, String)]) {
        let backgroundContext = persistenceController.backgroundContext

        backgroundContext.perform {
            // Group locations by geographical clustering (within 100m)
            let clusteredLocations = self.clusterLocations(locations)

            for (clusterCoordinate, dateRange, photoIdentifiers) in clusteredLocations {
                // Get place name using reverse geocoding
                self.locationExtractor.reverseGeocodeLocation(
                    latitude: clusterCoordinate.latitude,
                    longitude: clusterCoordinate.longitude
                ) { placeName, country, city in
                    let context = self.persistenceController.backgroundContext

                    context.perform {
                        // Check if this place already exists
                        let existingPlace = self.findExistingPlace(
                            coordinate: clusterCoordinate,
                            in: context
                        )

                        if let place = existingPlace {
                            // Update existing place
                            place.lastVisitDate = dateRange.end
                            place.photoCount += photoIdentifiers.count
                            place.updatedAt = Date()

                            // Create travel moments for this batch
                            self.createTravelMoments(
                                for: place,
                                photoIdentifiers: photoIdentifiers,
                                dateRange: dateRange,
                                in: context
                            )
                        } else {
                            // Create new visited place
                            let newPlace = VisitedPlace(context: context)
                            newPlace.id = UUID()
                            newPlace.name = placeName ?? "Unknown Location"
                            newPlace.country = country
                            newPlace.city = city
                            newPlace.latitude = clusterCoordinate.latitude
                            newPlace.longitude = clusterCoordinate.longitude
                            newPlace.firstVisitDate = dateRange.start
                            newPlace.lastVisitDate = dateRange.end
                            newPlace.photoCount = photoIdentifiers.count
                            newPlace.isFavorite = false
                            newPlace.createdAt = Date()
                            newPlace.updatedAt = Date()

                            // Create travel moments
                            self.createTravelMoments(
                                for: newPlace,
                                photoIdentifiers: photoIdentifiers,
                                dateRange: dateRange,
                                in: context
                            )
                        }

                        self.persistenceController.save(context: context)
                    }
                }
            }
        }
    }

    private func clusterLocations(_ locations: [(CLLocation, Date, String)]) -> [(CLLocation, DateRange, [String])] {
        var clusters: [(CLLocation, DateRange, [String])] = []
        let clusterRadius: CLLocationDistance = 100 // 100 meters

        for (location, date, identifier) in locations {
            var placedInCluster = false

            for i in clusters.indices {
                let clusterDistance = location.distance(from: clusters[i].0)
                if clusterDistance <= clusterRadius {
                    // Add to existing cluster
                    clusters[i].1.start = min(clusters[i].1.start, date)
                    clusters[i].1.end = max(clusters[i].1.end, date)
                    clusters[i].2.append(identifier)
                    placedInCluster = true
                    break
                }
            }

            if !placedInCluster {
                // Create new cluster
                clusters.append((location, DateRange(start: date, end: date), [identifier]))
            }
        }

        return clusters
    }

    private func findExistingPlace(coordinate: CLLocationCoordinate2D, in context: NSManagedObjectContext) -> VisitedPlace? {
        let request: NSFetchRequest<VisitedPlace> = VisitedPlace.fetchRequest()

        // Find places within 50 meters
        let latDelta = 0.0005 // approximately 50 meters
        let lonDelta = 0.0005

        request.predicate = NSPredicate(
            format: "latitude BETWEEN {%f, %f} AND longitude BETWEEN {%f, %f}",
            coordinate.latitude - latDelta,
            coordinate.latitude + latDelta,
            coordinate.longitude - lonDelta,
            coordinate.longitude + lonDelta
        )

        do {
            return try context.fetch(request).first
        } catch {
            print("Error finding existing place: \(error)")
            return nil
        }
    }

    private func createTravelMoments(
        for place: VisitedPlace,
        photoIdentifiers: [String],
        dateRange: DateRange,
        in context: NSManagedObjectContext
    ) {
        // Group photos by date for moment creation
        let groupedPhotos = Dictionary(grouping: photoIdentifiers) { identifier in
            // For simplicity, group by the date range start
            // In a real implementation, you'd fetch actual photo dates
            Calendar.current.startOfDay(for: dateRange.start)
        }

        for (date, identifiers) in groupedPhotos {
            for identifier in identifiers {
                let moment = TravelMoment(context: context)
                moment.id = UUID()
                moment.visitedPlace = place
                moment.photoAssetIdentifier = identifier
                moment.momentDate = date
                moment.title = nil // Will be auto-generated
                moment.description = nil
                moment.tags = nil
                moment.rating = 0
                moment.isHighlight = false
                moment.createdAt = Date()
            }
        }
    }

    private func getLastScanDate() -> Date? {
        let request: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", UserPreferences.singletonID)

        do {
            let preferences = try CoreDataStack.shared.viewContext.fetch(request)
            return preferences.first?.photoScanLastRun
        } catch {
            print("Error getting last scan date: \(error)")
            return nil
        }
    }

    private func saveLastScanDate() {
        let backgroundContext = persistenceController.backgroundContext
        backgroundContext.perform {
            let request: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", UserPreferences.singletonID)

            do {
                let preferences = try backgroundContext.fetch(request)
                let userPrefs = preferences.first ?? UserPreferences(context: backgroundContext)

                userPrefs.id = UUID(uuidString: UserPreferences.singletonID) ?? UUID()
                userPrefs.photoScanLastRun = Date()
                userPrefs.updatedAt = Date()

                self.persistenceController.save(context: backgroundContext)
            } catch {
                print("Error saving last scan date: \(error)")
            }
        }
    }

    private func sendScanCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Photo Scan Complete"
        content.body = "Odyssée has discovered new travel locations from your photos."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

private struct DateRange {
    var start: Date
    var end: Date
}

extension UserPreferences {
    static let singletonID = "00000000-0000-0000-0000-000000000000"
}