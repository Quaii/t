//
//  OdysséeApp.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import SwiftUI
import CoreData
import Photos
import CoreLocation

@main
struct OdysséeApp: App {
    let persistenceController = CoreDataStack.shared
    @StateObject private var privacyManager = PrivacyManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(privacyManager)
                .onAppear {
                    setupApp()
                }
                .preferredColorScheme(.dark)
        }
    }

    private func setupApp() {
        // Request initial permissions
        privacyManager.requestInitialPermissions()

        // Setup modern dark theme appearance
        setupModernAppearance()

        // Initialize app analytics (privacy-first)
        PrivacyManager.initializeAnalytics()
    }

    private func setupModernAppearance() {
        // Configure navigation bar for dark theme
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(ModernColorPalette.richCharcoal)
        navBarAppearance.titleTextAttributes = [
            .font: ModernTypography.UIFonts.displaySemibold,
            .foregroundColor: UIColor(ModernColorPalette.offWhite)
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .font: ModernTypography.UIFonts.displayBold,
            .foregroundColor: UIColor(ModernColorPalette.offWhite)
        ]
        navBarAppearance.shadowColor = UIColor.clear

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance

        // Configure tab bar for dark theme
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(ModernColorPalette.richCharcoal)
        tabBarAppearance.shadowImage = UIImage()
        tabBarAppearance.shadowColor = UIColor.clear

        // Tab bar item appearance
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: ModernTypography.UIFonts.caption1,
            .foregroundColor: UIColor(ModernColorPalette.tertiaryText)
        ]
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: ModernTypography.UIFonts.caption1,
            .foregroundColor: UIColor(ModernColorPalette.vibrantBlue)
        ]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // Configure window background for dark theme
        UIWindow.appearance().backgroundColor = UIColor(ModernColorPalette.deepCharcoal)

        // Configure status bar for dark theme
        UIApplication.shared.statusBarStyle = .lightContent
    }
}