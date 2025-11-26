//
//  TravelDataExporter.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import Foundation
import CoreData
import UniformTypeIdentifiers

class TravelDataExporter: ObservableObject {
    @Published var isExporting = false
    @Published var exportProgress: Double = 0.0
    @Published var exportedFileURL: URL?
    @Published var exportError: String?

    private let coreDataStack = CoreDataStack.shared

    // MARK: - Public Export Methods

    func exportAllData() async -> URL? {
        await MainActor.run {
            isExporting = true
            exportProgress = 0.0
            exportError = nil
            exportedFileURL = nil
        }

        do {
            let exportData = try await prepareCompleteExportData()
            let fileURL = try await writeExportToFile(data: exportData, fileName: "wanderlux_backup")

            await MainActor.run {
                exportedFileURL = fileURL
                isExporting = false
                exportProgress = 1.0
            }

            return fileURL
        } catch {
            await MainActor.run {
                exportError = "Export failed: \(error.localizedDescription)"
                isExporting = false
            }
            return nil
        }
    }

    func exportDateRange(startDate: Date, endDate: Date) async -> URL? {
        await MainActor.run {
            isExporting = true
            exportProgress = 0.0
            exportError = nil
        }

        do {
            let exportData = try await prepareDateRangeExportData(startDate: startDate, endDate: endDate)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: startDate)
            let fileURL = try await writeExportToFile(data: exportData, fileName: "wanderlux_export_\(dateString)")

            await MainActor.run {
                exportedFileURL = fileURL
                isExporting = false
                exportProgress = 1.0
            }

            return fileURL
        } catch {
            await MainActor.run {
                exportError = "Export failed: \(error.localizedDescription)"
                isExporting = false
            }
            return nil
        }
    }

    func exportFavoritesOnly() async -> URL? {
        await MainActor.run {
            isExporting = true
            exportProgress = 0.0
            exportError = nil
        }

        do {
            let exportData = try await prepareFavoritesExportData()
            let fileURL = try await writeExportToFile(data: exportData, fileName: "wanderlux_favorites")

            await MainActor.run {
                exportedFileURL = fileURL
                isExporting = false
                exportProgress = 1.0
            }

            return fileURL
        } catch {
            await MainActor.run {
                exportError = "Export failed: \(error.localizedDescription)"
                isExporting = false
            }
            return nil
        }
    }

    func exportSelectedCollections(_ collectionIds: [UUID]) async -> URL? {
        await MainActor.run {
            isExporting = true
            exportProgress = 0.0
            exportError = nil
        }

        do {
            let exportData = try await prepareCollectionsExportData(collectionIds: collectionIds)
            let fileURL = try await writeExportToFile(data: exportData, fileName: "wanderlux_collections")

            await MainActor.run {
                exportedFileURL = fileURL
                isExporting = false
                exportProgress = 1.0
            }

            return fileURL
        } catch {
            await MainActor.run {
                exportError = "Export failed: \(error.localizedDescription)"
                isExporting = false
            }
            return nil
        }
    }

    // MARK: - Data Preparation Methods

    private func prepareCompleteExportData() async throws -> TravelDataExport {
        await MainActor.run {
            exportProgress = 0.1
        }

        let backgroundContext = coreDataStack.backgroundContext
        let exportData = TravelDataExport()

        // Export visited places
        let visitedPlaces = try await fetchVisitedPlaces(context: backgroundContext)
        exportData.visitedPlaces = visitedPlaces.compactMap { place in
            guard let id = place.id else { return nil }
            return VisitedPlaceExport(
                id: id.uuidString,
                name: place.name ?? "",
                country: place.country ?? "",
                city: place.city ?? "",
                latitude: place.latitude,
                longitude: place.longitude,
                firstVisitDate: place.firstVisitDate?.ISO8601String(),
                lastVisitDate: place.lastVisitDate?.ISO8601String(),
                photoCount: Int(place.photoCount),
                isFavorite: place.isFavorite,
                notes: place.notes ?? "",
                createdAt: place.createdAt?.ISO8601String() ?? "",
                updatedAt: place.updatedAt?.ISO8601String() ?? ""
            )
        }

        await MainActor.run {
            exportProgress = 0.3
        }

        // Export trip plans
        let tripPlans = try await fetchTripPlans(context: backgroundContext)
        exportData.tripPlans = tripPlans.compactMap { trip in
            guard let id = trip.id else { return nil }
            return TripPlanExport(
                id: id.uuidString,
                tripName: trip.tripName ?? "",
                destinationId: trip.destination?.id?.uuidString ?? "",
                startDate: trip.startDate?.ISO8601String() ?? "",
                endDate: trip.endDate?.ISO8601String() ?? "",
                travelerCount: Int(trip.travelerCount),
                totalBudget: trip.totalBudget?.doubleValue ?? 0,
                accommodationBudget: trip.accommodationBudget?.doubleValue ?? 0,
                diningBudget: trip.diningBudget?.doubleValue ?? 0,
                activitiesBudget: trip.activitiesBudget?.doubleValue ?? 0,
                transportBudget: trip.transportBudget?.doubleValue ?? 0,
                status: trip.status ?? "",
                priority: Int(trip.priority),
                notes: trip.notes ?? "",
                createdAt: trip.createdAt?.ISO8601String() ?? "",
                updatedAt: trip.updatedAt?.ISO8601String() ?? ""
            )
        }

        await MainActor.run {
            exportProgress = 0.5
        }

        // Export travel moments
        let travelMoments = try await fetchTravelMoments(context: backgroundContext)
        exportData.travelMoments = travelMoments.compactMap { moment in
            guard let id = moment.id else { return nil }
            return TravelMomentExport(
                id: id.uuidString,
                visitedPlaceId: moment.visitedPlace?.id?.uuidString ?? "",
                photoAssetIdentifier: moment.photoAssetIdentifier ?? "",
                momentDate: moment.momentDate?.ISO8601String() ?? "",
                title: moment.title ?? "",
                description: moment.description ?? "",
                tags: moment.tags ?? "",
                rating: Int(moment.rating),
                isHighlight: moment.isHighlight,
                createdAt: moment.createdAt?.ISO8601String() ?? ""
            )
        }

        await MainActor.run {
            exportProgress = 0.7
        }

        // Export user preferences
        let userPreferences = try await fetchUserPreferences(context: backgroundContext)
        if let prefs = userPreferences.first {
            exportData.userPreferences = UserPreferencesExport(
                appTheme: prefs.appTheme ?? "",
                globeStyle: prefs.globeStyle ?? "",
                autoPhotoScanEnabled: prefs.autoPhotoScanEnabled,
                scanFrequency: Int(prefs.scanFrequency),
                defaultMapView: prefs.defaultMapView ?? "",
                exportFormat: prefs.exportFormat ?? "",
                lastBackupDate: prefs.lastBackupDate?.ISO8601String(),
                photoScanLastRun: prefs.photoScanLastRun?.ISO8601String(),
                createdAt: prefs.createdAt?.ISO8601String() ?? "",
                updatedAt: prefs.updatedAt?.ISO8601String() ?? ""
            )
        }

        await MainActor.run {
            exportProgress = 0.9
        }

        // Set metadata
        exportData.metadata = ExportMetadata(
            version: "1.0",
            exportDate: ISO8601DateFormatter().string(from: Date()),
            exportType: "full",
            deviceInfo: await getDeviceInfo(),
            appVersion: await getAppVersion()
        )

        await MainActor.run {
            exportProgress = 1.0
        }

        return exportData
    }

    private func prepareDateRangeExportData(startDate: Date, endDate: Date) async throws -> TravelDataExport {
        // Similar to complete export but filtered by date range
        let exportData = try await prepareCompleteExportData()

        // Filter visited places by date range
        exportData.visitedPlaces = exportData.visitedPlaces.filter { place in
            guard let lastVisitString = place.lastVisitDate,
                  let lastVisitDate = ISO8601DateFormatter().date(from: lastVisitString) else {
                return false
            }
            return (lastVisitDate >= startDate) && (lastVisitDate <= endDate)
        }

        // Filter trip plans by date range
        exportData.tripPlans = exportData.tripPlans.filter { trip in
            guard let tripStartString = trip.startDate,
                  let tripStartDate = ISO8601DateFormatter().date(from: tripStartString),
                  let tripEndString = trip.endDate,
                  let tripEndDate = ISO8601DateFormatter().date(from: tripEndString) else {
                return false
            }
            return (tripStartDate <= endDate) && (tripEndDate >= startDate)
        }

        // Filter travel moments by date range
        exportData.travelMoments = exportData.travelMoments.filter { moment in
            guard let momentDateString = moment.momentDate,
                  let momentDate = ISO8601DateFormatter().date(from: momentDateString) else {
                return false
            }
            return (momentDate >= startDate) && (momentDate <= endDate)
        }

        // Update metadata
        exportData.metadata.exportType = "daterange"
        exportData.metadata.dateRange = DateRangeExport(
            startDate: ISO8601DateFormatter().string(from: startDate),
            endDate: ISO8601DateFormatter().string(from: endDate)
        )

        return exportData
    }

    private func prepareFavoritesExportData() async throws -> TravelDataExport {
        // Get all favorite items from FavoritesManager
        let favoritesManager = FavoritesManager()

        return TravelDataExport(
            visitedPlaces: favoritesManager.favoritePlaces.compactMap { favorite in
                guard let id = favorite.id,
                      let place = favorite.place else { return nil }
                return VisitedPlaceExport(
                    id: id.uuidString,
                    name: place.name ?? "",
                    country: place.country ?? "",
                    city: place.city ?? "",
                    latitude: place.latitude,
                    longitude: place.longitude,
                    firstVisitDate: place.firstVisitDate?.ISO8601String(),
                    lastVisitDate: place.lastVisitDate?.ISO8601String(),
                    photoCount: Int(place.photoCount),
                    isFavorite: true, // All exported places are favorites
                    notes: favorite.notes,
                    tags: favorite.tags.joined(separator: ","),
                    createdAt: place.createdAt?.ISO8601String() ?? "",
                    updatedAt: place.updatedAt?.ISO8601String() ?? ""
                )
            },
            tripPlans: [],
            travelMoments: [],
            userPreferences: nil,
            metadata: ExportMetadata(
                version: "1.0",
                exportDate: ISO8601DateFormatter().string(from: Date()),
                exportType: "favorites",
                deviceInfo: await getDeviceInfo(),
                appVersion: await getAppVersion()
            )
        )
    }

    private func prepareCollectionsExportData(collectionIds: [UUID]) async throws -> TravelDataExport {
        // Implementation for specific collections
        return try await prepareCompleteExportData()
    }

    // MARK: - File Writing Methods

    private func writeExportToFile(data: TravelDataExport, fileName: String) async throws -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let jsonData = try encoder.encode(data)

        // Get documents directory
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ExportError.documentsDirectoryNotFound
        }

        // Create Odyssée export directory
        let exportDirectory = documentsURL.appendingPathComponent("Odyssée Exports")
        try FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true)

        // Write file
        let fileURL = exportDirectory.appendingPathComponent("\(fileName).json")
        try jsonData.write(to: fileURL)

        return fileURL
    }

    // MARK: - Core Data Fetch Methods

    private func fetchVisitedPlaces(context: NSManagedObjectContext) async throws -> [VisitedPlace] {
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<VisitedPlace> = VisitedPlace.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \VisitedPlace.lastVisitDate, ascending: false)]

                do {
                    let places = try context.fetch(request)
                    continuation.resume(returning: places)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func fetchTripPlans(context: NSManagedObjectContext) async throws -> [TripPlan] {
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<TripPlan> = TripPlan.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \TripPlan.startDate, ascending: true)]

                do {
                    let trips = try context.fetch(request)
                    continuation.resume(returning: trips)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func fetchTravelMoments(context: NSManagedObjectContext) async throws -> [TravelMoment] {
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<TravelMoment> = TravelMoment.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \TravelMoment.momentDate, ascending: false)]

                do {
                    let moments = try context.fetch(request)
                    continuation.resume(returning: moments)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func fetchUserPreferences(context: NSManagedObjectContext) async throws -> [UserPreferences] {
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()

                do {
                    let prefs = try context.fetch(request)
                    continuation.resume(returning: prefs)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Device and App Info

    private func getDeviceInfo() async -> DeviceInfo {
        let device = UIDevice.current
        return DeviceInfo(
            model: device.model,
            systemVersion: device.systemVersion,
            name: device.name,
            systemName: device.systemName
        )
    }

    private func getAppVersion() async -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Data Models

struct TravelDataExport: Codable {
    let visitedPlaces: [VisitedPlaceExport]
    let tripPlans: [TripPlanExport]
    let travelMoments: [TravelMomentExport]
    let userPreferences: UserPreferencesExport?
    let metadata: ExportMetadata
}

struct VisitedPlaceExport: Codable {
    let id: String
    let name: String
    let country: String
    let city: String
    let latitude: Double
    let longitude: Double
    let firstVisitDate: String?
    let lastVisitDate: String?
    let photoCount: Int
    let isFavorite: Bool
    let notes: String
    let tags: String
    let createdAt: String
    let updatedAt: String
}

struct TripPlanExport: Codable {
    let id: String
    let tripName: String
    let destinationId: String
    let startDate: String
    let endDate: String
    let travelerCount: Int
    let totalBudget: Double
    let accommodationBudget: Double
    let diningBudget: Double
    let activitiesBudget: Double
    let transportBudget: Double
    let status: String
    let priority: Int
    let notes: String
    let createdAt: String
    let updatedAt: String
}

struct TravelMomentExport: Codable {
    let id: String
    let visitedPlaceId: String
    let photoAssetIdentifier: String
    let momentDate: String
    let title: String?
    let description: String?
    let tags: String
    let rating: Int
    let isHighlight: Bool
    let createdAt: String
}

struct UserPreferencesExport: Codable {
    let appTheme: String
    let globeStyle: String
    let autoPhotoScanEnabled: Bool
    let scanFrequency: Int
    let defaultMapView: String
    let exportFormat: String
    let lastBackupDate: String?
    let photoScanLastRun: String?
    let createdAt: String
    let updatedAt: String
}

struct ExportMetadata: Codable {
    let version: String
    let exportDate: String
    let exportType: String
    let dateRange: DateRangeExport?
    let deviceInfo: DeviceInfo
    let appVersion: String
}

struct DateRangeExport: Codable {
    let startDate: String
    let endDate: String
}

struct DeviceInfo: Codable {
    let model: String
    let systemVersion: String
    let name: String
    let systemName: String
}

// MARK: - Error Types

enum ExportError: LocalizedError {
    case documentsDirectoryNotFound
    case writeFailed(Error)
    case encodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .documentsDirectoryNotFound:
            return "Documents directory not found"
        case .writeFailed(let error):
            return "Failed to write file: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        }
    }
}

// MARK: - UTType Extensions

extension UTType {
    static let wanderluxExport = UTType(filenameExtension: "wanderlux", conformingTo: [.json])
}