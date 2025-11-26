//
//  ContentView.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var privacyManager: PrivacyManager

    var body: some View {
        TabView {
            MainDashboardView()
                .tabItem {
                    Image(systemName: "globe.americas.fill")
                    Text("Odyssée")
                }

            LuxuryDestinationGuideView()
                .tabItem {
                    Image(systemName: "diamond.fill")
                    Text("Destinations")
                }

            TripPlanningSuiteView()
                .tabItem {
                    Image(systemName: "calendar.badge.plus")
                    Text("Plan Trip")
                }

            LuxuryExperiencesView()
                .tabItem {
                    Image(systemName: "star.circle.fill")
                    Text("Experiences")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(Color("LuxuryAccent"))
        .preferredColorScheme(.light) // Luxury aesthetic primarily light theme
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, CoreDataStack.shared.container.viewContext)
            .environmentObject(PrivacyManager())
            .previewDisplayName("Odyssée - Luxury Travel")
    }
}