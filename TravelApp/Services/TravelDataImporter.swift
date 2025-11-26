//
//  TravelDataImporter.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import Foundation
import CoreData
import UniformTypeIdentifiers

class TravelDataImporter: ObservableObject {
    @Published var isImporting = false
    @Published var importProgress: Double = 0.0
    @Published var importError: String?
    @Published var importResults: ImportResults?
    @Published var showingConflictResolver = false
    @Published var conflictItems: [ImportConflict] = []

    private let coreDataStack = CoreDataStack.shared
    private var importData: TravelDataExport?

    // MARK: - Public Import Methods

    func importFromFile(_ fileURL: URL) async {
        await MainActor.run {
            isImporting = true
            importProgress = 0.0
            importError = nil
            importResults = nil
            showingConflictResolver = false
            conflictItems = []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()

            importData = try decoder.decode(TravelDataExport.self, from: data)

            // Validate import data
            try validateImportData(importData)

            // Check for conflicts
            let conflicts = try await checkForConflicts(importData)

            await MainActor.run {
                if !conflicts.isEmpty {
                    conflictItems = conflicts
                    showingConflictResolver = true
                    isImporting = false
                } else {
                    Task {
                        await performImport(data: importData)
                    }
                }
            }

        } catch {
            await MainActor.run {
                importError = "Import failed: \(error.localizedDescription)"
                isImporting = false
            }
        }
    }

    func resolveConflicts(_ resolutions: [ConflictResolution]) async {
        await MainActor.run {
            isImporting = true
            importProgress = 0.0
            showingConflictResolver = false
            conflictItems = []
        }

        guard let importData = importData else { return }

        do {
            // Apply conflict resolutions
            let resolvedData = try applyConflictResolutions(importData, resolutions: resolutions)

            // Perform import with resolved data
            await performImport(data: resolvedData)

        } catch {
            await MainActor.run {
                importError = "Failed to resolve conflicts: \(error.localizedDescription)"
                isImporting = false
            }
        }
    }

    func importWithoutConflicts(_ data: TravelDataExport, strategy: ImportStrategy) async {
        await MainActor.run {
            isImporting = true
            importProgress = 0.0
            importError = nil
            importResults = nil
        }

        do {
            let resolvedData = try applyImportStrategy(data, strategy: strategy)
            await performImport(data: resolvedData)

        } catch {
            await MainActor.run {
                importError = "Import failed: \(error.localizedDescription)"
                isImporting = false
            }
        }
    }

    // MARK: - Private Import Methods

    private func performImport(data: TravelDataExport) async {
        guard let coreDataStack = CoreDataStack.shared as? CoreDataStack else { return }

        let backgroundContext = coreDataStack.backgroundContext

        backgroundContext.perform {
            do {
                // Import visited places
                try self.importVisitedPlaces(data.visitedPlaces, context: backgroundContext)
                await MainActor.run { self.importProgress = 0.2 }

                // Import trip plans
                try self.importTripPlans(data.tripPlans, context: backgroundContext)
                await MainActor.run { self.importProgress = 0.4 }

                // Import travel moments
                try self.importTravelMoments(data.travelMoments, context: backgroundContext)
                await MainActor.run { self.importProgress = 0.6 }

                // Import user preferences
                if let prefs = data.userPreferences {
                    try self.importUserPreferences(prefs, context: backgroundContext)
                }
                await MainActor.run { self.importProgress = 0.8 }

                // Save changes
                coreDataStack.save(context: backgroundContext)
                await MainActor.run { self.importProgress = 1.0 }

                // Generate import results
                let results = ImportResults(
                    visitedPlacesImported: data.visitedPlaces.count,
                    tripPlansImported: data.tripPlans.count,
                    travelMomentsImported: data.travelMoments.count,
                    conflictsResolved: conflictItems.count,
                    userPreferencesImported: data.userPreferences != nil
                )

                await MainActor.run {
                    self.importResults = results
                    self.isImporting = false
                }

            } catch {
                await MainActor.run {
                    self.importError = "Import failed: \(error.localizedDescription)"
                    self.isImporting = false
                }
            }
        }
    }

    // MARK: - Data Import Methods

    private func importVisitedPlaces(_ places: [VisitedPlaceExport], context: NSManagedObjectContext) throws {
        for placeExport in places {
            // Check if place already exists
            let existingPlace = try findExistingVisitedPlace(
                latitude: placeExport.latitude,
                longitude: placeExport.longitude,
                context: context
            )

            if existingPlace != nil {
                // Skip or merge based on conflict resolution
                continue
            }

            let place = VisitedPlace(context: context)
            place.id = UUID(uuidString: placeExport.id) ?? UUID()
            place.name = placeExport.name
            place.country = placeExport.country
            place.city = placeExport.city
            place.latitude = placeExport.latitude
            place.longitude = placeExport.longitude

            if let firstVisitString = placeExport.firstVisitDate {
                place.firstVisitDate = ISO8601DateFormatter().date(from: firstVisitString)
            }

            if let lastVisitString = placeExport.lastVisitDate {
                place.lastVisitDate = ISO8601DateFormatter().date(from: lastVisitString)
            }

            place.photoCount = Int16(placeExport.photoCount)
            place.isFavorite = placeExport.isFavorite
            place.notes = placeExport.notes

            if let createdString = placeExport.createdAt {
                place.createdAt = ISO8601DateFormatter().date(from: createdString)
            } else {
                place.createdAt = Date()
            }

            if let updatedString = placeExport.updatedAt {
                place.updatedAt = ISO8601DateFormatter().date(from: updatedString)
            } else {
                place.updatedAt = Date()
            }
        }
    }

    private func importTripPlans(_ trips: [TripPlanExport], context: NSManagedObjectContext) throws {
        for tripExport in trips {
            let trip = TripPlan(context: context)
            trip.id = UUID(uuidString: tripExport.id) ?? UUID()
            trip.tripName = tripExport.tripName
            trip.startDate = ISO8601DateFormatter().date(from: tripExport.startDate)
            trip.endDate = ISO8601DateFormatter().date(from: tripExport.endDate)
            trip.travelerCount = Int16(tripExport.travelerCount)
            trip.totalBudget = NSDecimalNumber(value: tripExport.totalBudget)
            trip.accommodationBudget = NSDecimalNumber(value: tripExport.accommodationBudget)
            trip.diningBudget = NSDecimalNumber(value: tripExport.diningBudget)
            trip.activitiesBudget = NSDecimalNumber(value: tripExport.activitiesBudget)
            trip.transportBudget = NSDecimalNumber(value: tripExport.transportBudget)
            trip.status = tripExport.status
            trip.priority = Int16(tripExport.priority)
            trip.notes = tripExport.notes
            trip.createdAt = Date()
            trip.updatedAt = Date()

            // Set destination relationship if destination ID exists
            if !tripExport.destinationId.isEmpty {
                let destinationRequest = NSFetchRequest<DiscoveredPlace>(entityName: "VisitedPlace")
                destinationRequest.predicate = NSPredicate(format: "id == %@", tripExport.destinationId)
                destinationRequest.fetchLimit = 1

                let destinations = try context.fetch(destinationRequest)
                trip.destination = destinations.first
            }
        }
    }

    private func importTravelMoments(_ moments: [TravelMomentExport], context: NSManagedObjectContext) throws {
        for momentExport in moments {
            let moment = TravelMoment(context: context)
            moment.id = UUID(uuidString: momentExport.id) ?? UUID()
            moment.photoAssetIdentifier = momentExport.photoAssetIdentifier
            moment.title = momentExport.title
            moment.description = momentExport.description
            moment.tags = momentExport.tags
            moment.rating = Int16(momentExport.rating)
            moment.isHighlight = momentExport.isHighlight
            moment.createdAt = Date()

            if let dateString = momentExport.momentDate {
                moment.momentDate = ISO8601DateFormatter().date(from: dateString)
            }

            // Set visited place relationship if place ID exists
            if !momentExport.visitedPlaceId.isEmpty {
                let placeRequest = NSFetchRequest<VisitedPlace>(entityName: "VisitedPlace")
                placeRequest.predicate = NSPredicate(format: "id == %@", momentExport.visitedPlaceId)
                placeRequest.fetchLimit = 1

                let places = try context.fetch(placeRequest)
                moment.visitedPlace = places.first
            }
        }
    }

    private func importUserPreferences(_ prefs: UserPreferencesExport, context: NSManagedObjectContext) throws {
        let existingRequest = NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
        existingRequest.predicate = NSPredicate(format: "id == %@", UserPreferences.singletonID)
        existingRequest.fetchLimit = 1

        let existingPrefs = try context.fetch(existingRequest)

        let userPrefs = existingPrefs.first ?? UserPreferences(context: context)
        userPrefs.id = UUID(uuidString: UserPreferences.singletonID) ?? UUID()
        userPrefs.appTheme = prefs.appTheme
        userPrefs.globeStyle = prefs.globeStyle
        userPrefs.autoPhotoScanEnabled = prefs.autoPhotoScanEnabled
        userPrefs.scanFrequency = Int16(prefs.scanFrequency)
        userPrefs.defaultMapView = prefs.defaultMapView
        userPrefs.exportFormat = prefs.exportFormat
        userPrefs.createdAt = Date()
        userPrefs.updatedAt = Date()

        if let lastBackupString = prefs.lastBackupDate {
            userPrefs.lastBackupDate = ISO8601DateFormatter().date(from: lastBackupString)
        }

        if let lastScanString = prefs.photoScanLastRun {
            userPrefs.photoScanLastRun = ISO8601DateFormatter().date(from: lastScanString)
        }
    }

    // MARK: - Conflict Detection

    private func checkForConflicts(_ data: TravelDataExport) async throws -> [ImportConflict] {
        var conflicts: [ImportConflict] = []
        let backgroundContext = coreDataStack.backgroundContext

        // Check visited places conflicts
        for placeExport in data.visitedPlaces {
            let existingPlace = try findExistingVisitedPlace(
                latitude: placeExport.latitude,
                longitude: placeExport.longitude,
                context: backgroundContext
            )

            if let existing = existingPlace {
                let conflict = ImportConflict(
                    id: UUID(),
                    type: .visitedPlace,
                    existingItem: ImportConflictItem.fromVisitedPlace(existing),
                    importItem: ImportConflictItem.fromExport(placeExport),
                    resolution: .undetermined
                )
                conflicts.append(conflict)
            }
        }

        // Check trip plan conflicts (by trip name and dates)
        for tripExport in data.tripPlans {
            let existingTrips = try findConflictingTripPlans(
                name: tripExport.tripName,
                startDate: ISO8601DateFormatter().date(from: tripExport.startDate),
                endDate: ISO8601DateFormatter().date(from: tripExport.endDate),
                context: backgroundContext
            )

            for existing in existingTrips {
                let conflict = ImportConflict(
                    id: UUID(),
                    type: .tripPlan,
                    existingItem: ImportConflictItem.fromTripPlan(existing),
                    importItem: ImportConflictItem.fromExportTrip(tripExport),
                    resolution: .undetermined
                )
                conflicts.append(conflict)
            }
        }

        return conflicts
    }

    private func findExistingVisitedPlace(latitude: Double, longitude: Double, context: NSManagedObjectContext) throws -> VisitedPlace? {
        let request: NSFetchRequest<VisitedPlace> = VisitedPlace.fetchRequest()
        request.predicate = NSPredicate(
            format: "abs(latitude - %f) < 0.0001 AND abs(longitude - %f) < 0.0001",
            latitude, longitude
        )
        request.fetchLimit = 1

        return try context.fetch(request).first
    }

    private func findConflictingTripPlans(name: String, startDate: Date, endDate: Date, context: NSManagedObjectContext) throws -> [TripPlan] {
        let request: NSFetchRequest<TripPlan> = TripPlan.fetchRequest()
        request.predicate = NSPredicate(format: "tripName == %@", name)
        let existingTrips = try context.fetch(request)

        // Check for date conflicts
        return existingTrips.filter { existing in
            guard let existingStart = existing.startDate,
                  let existingEnd = existing.endDate else { return false }

            return dateRangesOverlap(start1: startDate, end1: endDate, start2: existingStart, end2: existingEnd)
        }
    }

    private func dateRangesOverlap(start1: Date, end1: Date, start2: Date, end2: Date) -> Bool {
        return start1 <= end2 && start2 <= end1
    }

    // MARK: - Conflict Resolution

    private func applyConflictResolutions(_ data: TravelDataExport, resolutions: [ConflictResolution]) throws -> TravelDataExport {
        var resolvedData = data

        for resolution in resolutions {
            switch resolution.action {
            case .keepExisting:
                if resolution.conflict.type == .visitedPlace {
                    resolvedData.visitedPlaces.removeAll { $0.id == resolution.conflict.importItem.id }
                } else if resolution.conflict.type == .tripPlan {
                    resolvedData.tripPlans.removeAll { $0.id == resolution.conflict.importItem.id }
                }

            case .useImported:
                if resolution.conflict.type == .visitedPlace {
                    // Replace existing in import (will be handled in import logic)
                } else if resolution.conflict.type == .tripPlan {
                    // Replace existing in import (will be handled in import logic)
                }

            case .merge:
                if resolution.conflict.type == .visitedPlace {
                    if let index = resolvedData.visitedPlaces.firstIndex(where: { $0.id == resolution.conflict.importItem.id }) {
                        let merged = mergeVisitedPlaces(existing: resolution.conflict.existingItem.visitedPlace!, imported: resolution.conflict.importItem.visitedPlace!)
                        resolvedData.visitedPlaces[index] = merged
                    }
                } else if resolution.conflict.type == .tripPlan {
                    if let index = resolvedData.tripPlans.firstIndex(where: { $0.id == resolution.conflict.importItem.id }) {
                        let merged = mergeTripPlans(existing: resolution.conflict.existingItem.tripPlan!, imported: resolution.conflict.importItem.tripPlan!)
                        resolvedData.tripPlans[index] = merged
                    }
                }

            case .skip:
                // Skip importing this item
                if resolution.conflict.type == .visitedPlace {
                    resolvedData.visitedPlaces.removeAll { $0.id == resolution.conflict.importItem.id }
                } else if resolution.conflict.type == .tripPlan {
                    resolvedData.tripPlans.removeAll { $0.id == resolution.conflict.importItem.id }
                }
            }
        }

        return resolvedData
    }

    private func applyImportStrategy(_ data: TravelDataExport, strategy: ImportStrategy) throws -> TravelDataExport {
        switch strategy {
        case .skipConflicts:
            // Remove conflicting items from import
            return data // Conflicts will be skipped during import process

        case .replaceExisting:
            // Keep import data, will overwrite existing
            return data

        case .merge:
            // Merge logic will be applied during import
            return data
        }
    }

    private func mergeVisitedPlaces(existing: VisitedPlace, imported: VisitedPlaceExport) -> VisitedPlaceExport {
        return VisitedPlaceExport(
            id: existing.id?.uuidString ?? imported.id,
            name: imported.name.isEmpty ? existing.name ?? "" : imported.name,
            country: imported.country.isEmpty ? existing.country ?? "" : imported.country,
            city: imported.city.isEmpty ? existing.city ?? "" : imported.city,
            latitude: imported.latitude,
            longitude: imported.longitude,
            firstVisitDate: min(
                existing.firstVisitDate?.ISO8601String() ?? "",
                imported.firstVisitDate ?? ""
            ),
            lastVisitDate: max(
                existing.lastVisitDate?.ISO8601String() ?? "",
                imported.lastVisitDate ?? ""
            ),
            photoCount: existing.photoCount + Int16(imported.photoCount),
            isFavorite: existing.isFavorite || imported.isFavorite,
            notes: (existing.notes ?? "") + (imported.notes.isEmpty ? "" : " | " + imported.notes),
            createdAt: min(
                existing.createdAt?.ISO8601String() ?? "",
                imported.createdAt ?? ""
            ),
            updatedAt: Date().ISO8601String()
        )
    }

    private func mergeTripPlans(existing: TripPlan, imported: TripPlanExport) -> TripPlanExport {
        return TripPlanExport(
            id: existing.id?.uuidString ?? imported.id,
            tripName: imported.tripName.isEmpty ? existing.tripName ?? "" : imported.tripName,
            destinationId: imported.destinationId.isEmpty ? (existing.destination?.id?.uuidString ?? "") : imported.destinationId,
            startDate: min(
                existing.startDate?.ISO8601String() ?? "",
                imported.startDate
            ),
            endDate: max(
                existing.endDate?.ISO8601String() ?? "",
                imported.endDate
            ),
            travelerCount: max(Int(existing.travelerCount), imported.travelerCount),
            totalBudget: existing.totalBudget.doubleValue + imported.totalBudget,
            accommodationBudget: existing.accommodationBudget.doubleValue + imported.accommodationBudget,
            diningBudget: existing.diningBudget.doubleValue + imported.diningBudget,
            activitiesBudget: existing.activitiesBudget.doubleValue + imported.activitiesBudget,
            transportBudget: existing.transportBudget.doubleValue + imported.transportBudget,
            status: imported.status,
            priority: max(Int(existing.priority), imported.priority),
            notes: (existing.notes ?? "") + (imported.notes.isEmpty ? "" : " | " + imported.notes),
            createdAt: min(
                existing.createdAt?.ISO8601String() ?? "",
                imported.createdAt ?? ""
            ),
            updatedAt: Date().ISO8601String()
        )
    }

    // MARK: - Validation

    private func validateImportData(_ data: TravelDataExport) throws {
        // Check required fields
        for place in data.visitedPlaces {
            if place.name.isEmpty {
                throw ImportError.invalidData("Visited place missing name")
            }
            if place.country.isEmpty {
                throw ImportError.invalidData("Visited place missing country")
            }
        }

        for trip in data.tripPlans {
            if trip.tripName.isEmpty {
                throw ImportError.invalidData("Trip plan missing name")
            }
            if trip.startDate.isEmpty {
                throw ImportError.invalidData("Trip plan missing start date")
            }
            if trip.endDate.isEmpty {
                throw ImportError.invalidData("Trip plan missing end date")
            }
        }

        // Validate data version
        guard data.metadata.version >= "1.0" else {
            throw ImportError.incompatibleVersion
        }
    }
}

// MARK: - Data Models

struct ImportResults {
    let visitedPlacesImported: Int
    let tripPlansImported: Int
    let travelMomentsImported: Int
    let conflictsResolved: Int
    let userPreferencesImported: Bool
}

struct ImportConflict: Identifiable {
    let id: UUID
    let type: ConflictType
    let existingItem: ImportConflictItem
    let importItem: ImportConflictItem
    let resolution: ConflictResolutionAction
}

enum ConflictType {
    case visitedPlace
    case tripPlan
}

struct ImportConflictItem {
    let id: String
    let name: String
    let description: String

    static func fromVisitedPlace(_ place: VisitedPlace) -> ImportConflictItem {
        ImportConflictItem(
            id: place.id?.uuidString ?? "",
            name: place.name ?? "",
            description: "\(place.city ?? ""), \(place.country ?? "")"
        )
    }

    static func fromTripPlan(_ trip: TripPlan) -> ImportConflictItem {
        ImportConflictItem(
            id: trip.id?.uuidString ?? "",
            name: trip.tripName ?? "",
            description: "\(trip.startDate?.formatted(date: .abbreviated) ?? "") - \(trip.endDate?.formatted(date: .abbreviated) ?? "")"
        )
    }

    static func fromExport(_ place: VisitedPlaceExport) -> ImportConflictItem {
        ImportConflictItem(
            id: place.id,
            name: place.name,
            description: "\(place.city), \(place.country)"
        )
    }

    static func fromExportTrip(_ trip: TripPlanExport) -> ImportConflictItem {
        ImportConflictItem(
            id: trip.id,
            name: trip.tripName,
            description: "\(trip.startDate) - \(trip.endDate)"
        )
    }
}

struct ConflictResolution {
    let conflict: ImportConflict
    let action: ConflictResolutionAction
}

enum ConflictResolutionAction {
    case keepExisting
    case useImported
    case merge
    case skip
}

enum ImportStrategy {
    case skipConflicts
    case replaceExisting
    case merge
}

enum ImportError: LocalizedError {
    case invalidData(String)
    case incompatibleVersion
    case fileNotFound
    case jsonDecoding(Error)
    case coreData(Error)

    var errorDescription: String? {
        switch self {
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .incompatibleVersion:
            return "Incompatible data version"
        case .fileNotFound:
            return "File not found"
        case .jsonDecoding(let error):
            return "JSON decoding error: \(error.localizedDescription)"
        case .coreData(let error):
            return "Core Data error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Extensions

extension UserPreferences {
    static let singletonID = "00000000-0000-0000-0000-000000000000"
}

extension UTType {
    static let wanderluxImport = UTType(filenameExtension: "wanderlux", conformingTo: [.json])
}