//
//  CoreDataStack.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import CoreData
import Foundation

class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "TravelData")

        // Configure CloudKit integration (optional for users)
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(
            true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, handle this error gracefully with proper user messaging
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }

        // Configure automatic migration
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Background context for heavy operations
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    func save(context: NSManagedObjectContext? = nil) {
        let context = context ?? viewContext

        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            // In production, handle this error with proper user messaging
            print("Core Data save error: \(nsError), \(nsError.userInfo)")
        }
    }

    func batchDelete<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
            entityName: T.entity().name ?? String(describing: T.self))
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        backgroundContext.perform {
            do {
                let result =
                    try self.backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
                let objectIDArray = result?.result as? [NSManagedObjectID]
                let changes = [NSDeletedObjectsKey: objectIDArray ?? []]
                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: changes, into: [self.viewContext])
            } catch {
                print("Batch delete error: \(error)")
            }
        }
    }

    func fetch<T: NSManagedObject>(
        entity: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [],
        fetchLimit: Int? = nil
    ) -> [T] {
        let request = T.fetchRequest() as! NSFetchRequest<T>

        if let predicate = predicate {
            request.predicate = predicate
        }

        if !sortDescriptors.isEmpty {
            request.sortDescriptors = sortDescriptors
        }

        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    func count<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil) -> Int {
        let request = T.fetchRequest() as! NSFetchRequest<T>

        if let predicate = predicate {
            request.predicate = predicate
        }

        do {
            return try viewContext.count(for: request)
        } catch {
            print("Count error: \(error)")
            return 0
        }
    }
}

// MARK: - Preview Helper for SwiftUI Previews
extension CoreDataStack {
    static var preview: CoreDataStack = {
        let stack = CoreDataStack()
        let context = stack.persistentContainer.viewContext

        // Create sample data for previews
        let sampleVisitedPlace = VisitedPlace(context: context)
        sampleVisitedPlace.id = UUID()
        sampleVisitedPlace.name = "Monaco"
        sampleVisitedPlace.country = "Monaco"
        sampleVisitedPlace.city = "Monte Carlo"
        sampleVisitedPlace.latitude = 43.7333
        sampleVisitedPlace.longitude = 7.4167
        sampleVisitedPlace.firstVisitDate = Date()
        sampleVisitedPlace.lastVisitDate = Date()
        sampleVisitedPlace.photoCount = 25
        sampleVisitedPlace.isFavorite = true
        sampleVisitedPlace.createdAt = Date()
        sampleVisitedPlace.updatedAt = Date()

        let sampleLuxuryDestination = LuxuryDestination(context: context)
        sampleLuxuryDestination.id = UUID()
        sampleLuxuryDestination.name = "Monaco Grand Prix"
        sampleLuxuryDestination.country = "Monaco"
        sampleLuxuryDestination.city = "Monte Carlo"
        sampleLuxuryDestination.latitude = 43.7333
        sampleLuxuryDestination.longitude = 7.4167
        sampleLuxuryDestination.luxuryRating = 5
        sampleLuxuryDestination.destinationType = "cultural"
        sampleLuxuryDestination.averageLuxuryCost = 1500.0
        sampleLuxuryDestination.signatureExperiences = "Grand Prix, Casino, Yacht Club"
        sampleLuxuryDestination.createdAt = Date()
        sampleLuxuryDestination.updatedAt = Date()

        let sampleTripPlan = TripPlan(context: context)
        sampleTripPlan.id = UUID()
        sampleTripPlan.tripName = "Monaco Grand Prix 2025"
        sampleTripPlan.startDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
        sampleTripPlan.endDate = Calendar.current.date(byAdding: .day, value: 35, to: Date())
        sampleTripPlan.travelerCount = 2
        sampleTripPlan.totalBudget = 15000.0
        sampleTripPlan.accommodationBudget = 8000.0
        sampleTripPlan.diningBudget = 3000.0
        sampleTripPlan.activitiesBudget = 2500.0
        sampleTripPlan.transportBudget = 1500.0
        sampleTripPlan.status = "planning"
        sampleTripPlan.priority = 5
        sampleTripPlan.createdAt = Date()
        sampleTripPlan.updatedAt = Date()
        sampleTripPlan.destination = sampleLuxuryDestination

        try? context.save()

        return stack
    }()
}

// MARK: - TravelDataModels

// MARK: - VisitedPlace
@objc(VisitedPlace)
public class VisitedPlace: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var country: String?
    @NSManaged public var city: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var firstVisitDate: Date?
    @NSManaged public var lastVisitDate: Date?
    @NSManaged public var photoCount: Int32
    @NSManaged public var isFavorite: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var notes: String?
    @NSManaged public var travelMoments: NSSet?
}

extension VisitedPlace: Identifiable {}

// MARK: - LuxuryDestination
@objc(LuxuryDestination)
public class LuxuryDestination: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var country: String?
    @NSManaged public var city: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var luxuryRating: Int16
    @NSManaged public var destinationType: String?
    @NSManaged public var averageLuxuryCost: NSDecimalNumber?
    @NSManaged public var signatureExperiences: String?
    @NSManaged public var bestTravelSeasons: String?
    @NSManaged public var region: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var tripPlans: NSSet?
    @NSManaged public var experiences: NSSet?
}

extension LuxuryDestination: Identifiable {}

// MARK: - TripPlan
@objc(TripPlan)
public class TripPlan: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var tripName: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var travelerCount: Int16
    @NSManaged public var totalBudget: NSDecimalNumber?
    @NSManaged public var accommodationBudget: NSDecimalNumber?
    @NSManaged public var diningBudget: NSDecimalNumber?
    @NSManaged public var activitiesBudget: NSDecimalNumber?
    @NSManaged public var transportBudget: NSDecimalNumber?
    @NSManaged public var status: String?
    @NSManaged public var priority: Int16
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var destination: LuxuryDestination?
}

extension TripPlan: Identifiable {}

// MARK: - TravelMoment
@objc(TravelMoment)
public class TravelMoment: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var momentDate: Date?
    @NSManaged public var descriptionText: String?
    @NSManaged public var tags: String?
    @NSManaged public var rating: Int16
    @NSManaged public var isHighlight: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var visitedPlace: VisitedPlace?
    @NSManaged public var photoAssetIdentifier: String?
}

extension TravelMoment: Identifiable {}

// MARK: - LuxuryCollection
@objc(LuxuryCollection)
public class LuxuryCollection: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var descriptionText: String?  // XML 'description'
    @NSManaged public var color: String?
    @NSManaged public var icon: String?
    @NSManaged public var isPublic: Bool
    @NSManaged public var theme: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
}

extension LuxuryCollection: Identifiable {}

// MARK: - LuxuryExperience
@objc(LuxuryExperience)
public class LuxuryExperience: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var experienceName: String?
    @NSManaged public var estimatedCost: NSDecimalNumber?
    @NSManaged public var luxuryLevel: Int16
    @NSManaged public var bookingRequired: Bool
    @NSManaged public var category: String?
    @NSManaged public var duration: String?
    @NSManaged public var seasonalAvailability: String?
    @NSManaged public var descriptionText: String?  // XML 'description'
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var destination: LuxuryDestination?
}

extension LuxuryExperience: Identifiable {}

// MARK: - UserPreferences
@objc(UserPreferences)
public class UserPreferences: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var appTheme: String?
    @NSManaged public var autoPhotoScanEnabled: Bool
    @NSManaged public var defaultMapView: String?
    @NSManaged public var exportFormat: String?
    @NSManaged public var globeStyle: String?
    @NSManaged public var lastBackupDate: Date?
    @NSManaged public var photoScanLastRun: Date?
    @NSManaged public var scanFrequency: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

    static let singletonID = "00000000-0000-0000-0000-000000000000"
}

extension UserPreferences: Identifiable {}
