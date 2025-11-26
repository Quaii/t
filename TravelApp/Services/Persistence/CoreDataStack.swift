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
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

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
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        backgroundContext.perform {
            do {
                let result = try self.backgroundContext.execute(deleteRequest) as? NSBatchDeleteResult
                let objectIDArray = result?.result as? [NSManagedObjectID]
                let changes = [NSDeletedObjectsKey: objectIDArray ?? []]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
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
        let request: NSFetchRequest<T> = T.fetchRequest()

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
        let request: NSFetchRequest<T> = T.fetchRequest()

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
    }
}