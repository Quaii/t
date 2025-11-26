//
//  PrivacyManager.swift
//  Wanderlux
//
//  Created by Wanderlux Team on 11/26/2025.
//  Copyright © 2025 Wanderlux. All rights reserved.
//

import SwiftUI
import Photos
import CoreLocation
import UserNotifications
import LocalAuthentication
import Foundation

class PrivacyManager: ObservableObject {
    @Published var photoLibraryAuthorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var biometricAvailability: LAContext.BiometryType = .none

    @Published var isFirstLaunch: Bool = true
    @Published var onboardingCompleted: Bool = false

    private let locationManager = CLLocationManager()
    private let userNotificationCenter = UNUserNotificationCenter.current()

    init() {
        locationManager.delegate = self
        checkCurrentPermissions()
        checkBiometricAvailability()
        loadOnboardingState()
    }

    // MARK: - Initial Permission Requests

    func requestInitialPermissions() {
        guard isFirstLaunch else { return }

        requestPermissionsWithOnboarding()
    }

    private func requestPermissionsWithOnboarding() {
        Task {
            // Request location permissions
            await requestLocationPermissions()

            // Request photo library permissions
            await requestPhotoLibraryPermissions()

            // Request notification permissions
            await requestNotificationPermissions()
        }
    }

    // MARK: - Photo Library Permissions

    func requestPhotoLibraryPermissions() async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                DispatchQueue.main.async {
                    self?.photoLibraryAuthorizationStatus = status
                    continuation.resume(returning: status == .authorized || status == .limited)
                }
            }
        }
    }

    func requestLimitedPhotoLibraryAccess() async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestLimitedLibraryAccessForContentTypes([.image]) { [weak self] status in
                DispatchQueue.main.async {
                    self?.photoLibraryAuthorizationStatus = status
                    continuation.resume(returning: status == .authorized || status == .limited)
                }
            }
        }
    }

    // MARK: - Location Permissions

    func requestLocationPermissions() async -> Bool {
        return await withCheckedContinuation { continuation in
            self.locationManager.requestWhenInUseAuthorization()

            // Delay to allow delegate callback
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let isAuthorized = self.locationAuthorizationStatus == .authorizedWhenInUse ||
                                 self.locationAuthorizationStatus == .authorizedAlways
                continuation.resume(returning: isAuthorized)
            }
        }
    }

    func requestAlwaysLocationPermissions() async -> Bool {
        return await withCheckedContinuation { continuation in
            self.locationManager.requestAlwaysAuthorization()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let isAuthorized = self.locationAuthorizationStatus == .authorizedAlways
                continuation.resume(returning: isAuthorized)
            }
        }
    }

    // MARK: - Notification Permissions

    func requestNotificationPermissions() async -> Bool {
        do {
            let granted = try await userNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            DispatchQueue.main.async {
                self.notificationAuthorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            print("Error requesting notification permissions: \(error)")
            return false
        }
    }

    // MARK: - Biometric Authentication

    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access your luxury travel data"
            ) { success, error in
                continuation.resume(returning: success)
            }
        }
    }

    func authenticateWithPasscode() async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return false
        }

        return await withCheckedContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Authenticate to access your luxury travel data"
            ) { success, error in
                continuation.resume(returning: success)
            }
        }
    }

    // MARK: - Permission Status Checks

    func canAccessPhotoLibrary() -> Bool {
        return photoLibraryAuthorizationStatus == .authorized || photoLibraryAuthorizationStatus == .limited
    }

    func canAccessLocation() -> Bool {
        return locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways
    }

    func canTrackLocation() -> Bool {
        return locationAuthorizationStatus == .authorizedAlways
    }

    func canSendNotifications() -> Bool {
        return notificationAuthorizationStatus == .authorized
    }

    func supportsBiometrics() -> Bool {
        return biometricAvailability != .none
    }

    // MARK: - Privacy Features

    func requestDataDeletion() async {
        // Delete all user data from Core Data
        let backgroundContext = CoreDataStack.shared.backgroundContext

        backgroundContext.perform {
            // Delete all entities
            let entities = [
                "VisitedPlace", "LuxuryDestination", "TripPlan",
                "TravelMoment", "LuxuryCollection", "LuxuryExperience",
                "UserPreferences"
            ]

            for entityName in entities {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                do {
                    try backgroundContext.execute(deleteRequest)
                } catch {
                    print("Error deleting \(entityName): \(error)")
                }
            }

            CoreDataStack.shared.save(context: backgroundContext)
        }

        // Send confirmation notification
        await sendPrivacyNotification(
            title: "Data Deleted",
            body: "All your travel data has been permanently deleted from Wanderlux."
        )
    }

    func exportUserData() async -> URL? {
        // Implementation for privacy-first data export
        let exporter = TravelDataExporter()
        return await exporter.exportAllData()
    }

    func getPrivacyReport() -> PrivacyReport {
        return PrivacyReport(
            hasPhotoAccess: canAccessPhotoLibrary(),
            hasLocationAccess: canAccessLocation(),
            hasNotificationAccess: canSendNotifications(),
            supportsBiometrics: supportsBiometrics(),
            photoScanLastRun: getLastPhotoScanDate(),
            dataExportDate: getLastExportDate(),
            locationsTracked: getTrackedLocationsCount(),
            totalTravelMoments: getTravelMomentsCount()
        )
    }

    // MARK: - Private Helpers

    private func checkCurrentPermissions() {
        photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        locationAuthorizationStatus = locationManager.authorizationStatus

        Task {
            let settings = await userNotificationCenter.notificationSettings()
            DispatchQueue.main.async {
                self.notificationAuthorizationStatus = settings.authorizationStatus
            }
        }
    }

    private func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricAvailability = context.biometryType
        }
    }

    private func loadOnboardingState() {
        let userDefaults = UserDefaults.standard
        isFirstLaunch = !userDefaults.bool(forKey: "HasLaunchedBefore")
        onboardingCompleted = userDefaults.bool(forKey: "OnboardingCompleted")

        if isFirstLaunch {
            userDefaults.set(true, forKey: "HasLaunchedBefore")
        }
    }

    private func sendPrivacyNotification(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await userNotificationCenter.add(request)
        } catch {
            print("Error sending privacy notification: \(error)")
        }
    }

    private func getLastPhotoScanDate() -> Date? {
        let request: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", UserPreferences.singletonID)

        do {
            let preferences = try CoreDataStack.shared.viewContext.fetch(request)
            return preferences.first?.photoScanLastRun
        } catch {
            return nil
        }
    }

    private func getLastExportDate() -> Date? {
        return UserDefaults.standard.object(forKey: "LastExportDate") as? Date
    }

    private func getTrackedLocationsCount() -> Int {
        let request: NSFetchRequest<VisitedPlace> = VisitedPlace.fetchRequest()

        do {
            return try CoreDataStack.shared.viewContext.count(for: request)
        } catch {
            return 0
        }
    }

    private func getTravelMomentsCount() -> Int {
        let request: NSFetchRequest<TravelMoment> = TravelMoment.fetchRequest()

        do {
            return try CoreDataStack.shared.viewContext.count(for: request)
        } catch {
            return 0
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension PrivacyManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.locationAuthorizationStatus = status
        }
    }
}

// MARK: - Privacy Report Structure

struct PrivacyReport {
    let hasPhotoAccess: Bool
    let hasLocationAccess: Bool
    let hasNotificationAccess: Bool
    let supportsBiometrics: Bool
    let photoScanLastRun: Date?
    let dataExportDate: Date?
    let locationsTracked: Int
    let totalTravelMoments: Int

    var photoScanDaysAgo: Int? {
        guard let lastRun = photoScanLastRun else { return nil }
        return Calendar.current.dateComponents([.day], from: lastRun, to: Date()).day
    }
}

// MARK: - Analytics (Privacy-First)

extension PrivacyManager {
    static func initializeAnalytics() {
        // Privacy-first analytics that run locally only
        UserDefaults.standard.set(true, forKey: "AnalyticsEnabled")

        // Track app launch anonymously
        let launchCount = UserDefaults.standard.integer(forKey: "LaunchCount") + 1
        UserDefaults.standard.set(launchCount, forKey: "LaunchCount")
    }

    func trackFeatureUsage(_ feature: String) {
        guard UserDefaults.standard.bool(forKey: "AnalyticsEnabled") else { return }

        // Local-only feature tracking
        let key = "Feature_\(feature)_Usage"
        let currentCount = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(currentCount, forKey: key)
    }

    func getLocalAnalytics() -> [String: Any] {
        guard UserDefaults.standard.bool(forKey: "AnalyticsEnabled") else { return [:] }

        return [
            "launchCount": UserDefaults.standard.integer(forKey: "LaunchCount"),
            "onboardingCompleted": onboardingCompleted,
            "permissionsGranted": [
                "photos": canAccessPhotoLibrary(),
                "location": canAccessLocation(),
                "notifications": canSendNotifications()
            ]
        ]
    }
}