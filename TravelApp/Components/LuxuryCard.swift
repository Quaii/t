//
//  LuxuryCard.swift
//  Wanderlux
//
//  Created by Wanderlux Team on 11/26/2025.
//  Copyright © 2025 Wanderlux. All rights reserved.
//

import SwiftUI

struct LuxuryCard<Content: View>: View {
    let content: Content
    let padding: EdgeInsets
    let cornerRadius: CGFloat
    let shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)
    let backgroundColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat
    let action: (() -> Void)?
    @State private var isPressed = false

    init(
        backgroundColor: Color = LuxuryColorPalette.pearlWhite,
        padding: EdgeInsets = EdgeInsets(top: LuxurySpacing.md, leading: LuxurySpacing.md, bottom: LuxurySpacing.md, trailing: LuxurySpacing.md),
        cornerRadius: CGFloat = LuxurySpacing.cornerRadiusMedium,
        shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = LuxurySpacing.Shadow.subtle,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action ?? {}) {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor ?? Color.clear, lineWidth: borderWidth)
            )
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
        }
        .buttonStyle(PlainButtonStyle()) // Disable default button styling
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .opacity(isPressed ? 0.9 : 1.0)
        .animation(LuxuryAnimation.ButtonPress.press, value: isPressed)
        .onTapGesture {
            withAnimation(LuxuryAnimation.ButtonPress.press) {
                isPressed = true
                LuxuryAnimation.ButtonPress.perform()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(LuxuryAnimation.ButtonPress.release) {
                    isPressed = false
                }
            }
            action?()
        }
    }
}

// MARK: - Specialized Luxury Cards

struct DestinationCard: View {
    let destination: LuxuryDestination
    let action: (() -> Void)?
    @State private var isFavorite = false

    var body: some View {
        LuxuryCard(
            backgroundColor: LuxuryColorPalette.pearlWhite,
            action: action
        ) {
            VStack(alignment: .leading, spacing: LuxurySpacing.sm) {
                // Image placeholder or actual image
                RoundedRectangle(cornerRadius: LuxurySpacing.cornerRadiusSmall)
                    .fill(LuxuryColorPalette.luxuryGoldGradient)
                    .frame(height: 120)
                    .overlay(
                        VStack {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 24))
                                .foregroundColor(LuxuryColorPalette.pearlWhite)
                            Text(destination.name ?? "Luxury Destination")
                                .font(LuxuryTypography.title)
                                .foregroundColor(LuxuryColorPalette.pearlWhite)
                                .multilineTextAlignment(.center)
                        }
                    )

                // Destination info
                VStack(alignment: .leading, spacing: LuxurySpacing.xs) {
                    Text(destination.name ?? "Unknown Destination")
                        .font(LuxuryTypography.title)
                        .foregroundColor(LuxuryColorPalette.textPrimary)

                    HStack(spacing: LuxurySpacing.xs) {
                        Text(destination.city ?? "")
                            .font(LuxuryTypography.caption)
                            .foregroundColor(LuxuryColorPalette.textSecondary)

                        Text("•")
                            .font(LuxuryTypography.caption)
                            .foregroundColor(LuxuryColorPalette.textTertiary)

                        Text(destination.country ?? "")
                            .font(LuxuryTypography.caption)
                            .foregroundColor(LuxuryColorPalette.textSecondary)
                    }

                    // Luxury rating
                    HStack(spacing: LuxurySpacing.xs) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < Int(destination.luxuryRating) ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(LuxuryColorPalette.softGold)
                        }

                        Spacer()

                        // Favorite button
                        Button(action: {
                            withAnimation(LuxuryAnimation.ButtonPress.select) {
                                isFavorite.toggle()
                                LuxuryAnimation.CardSelection.select()
                            }
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                                .foregroundColor(isFavorite ? LuxuryColorPalette.richRed : LuxuryColorPalette.textTertiary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct TripCard: View {
    let trip: TripPlan
    let action: (() -> Void)?

    var body: some View {
        LuxuryCard(
            backgroundColor: LuxuryColorPalette.pearlWhite,
            action: action
        ) {
            VStack(alignment: .leading, spacing: LuxurySpacing.sm) {
                // Status and destination
                HStack {
                    Text(trip.status?.capitalized ?? "Planning")
                        .font(LuxuryTypography.caption)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, LuxurySpacing.xs)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.1))
                        .cornerRadius(LuxurySpacing.cornerRadiusSmall)

                    Spacer()

                    Text(daysUntilTrip)
                        .font(LuxuryTypography.caption)
                        .foregroundColor(LuxuryColorPalette.textSecondary)
                }

                // Trip name
                Text(trip.tripName ?? "Untitled Trip")
                    .font(LuxuryTypography.title)
                    .foregroundColor(LuxuryColorPalette.textPrimary)

                // Dates
                LuxuryTypography.formatDateRange(start: trip.startDate ?? Date(), end: trip.endDate ?? Date())

                // Budget preview
                HStack {
                    Text("Total Budget")
                        .font(LuxuryTypography.caption)
                        .foregroundColor(LuxuryColorPalette.textSecondary)

                    Spacer()

                    LuxuryTypography.formatCurrency(trip.totalBudget?.doubleValue ?? 0)
                }

                // Destination preview
                if let destination = trip.destination {
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(LuxuryColorPalette.softGold)

                        Text(destination.name ?? "Unknown Destination")
                            .font(LuxuryTypography.body)
                            .foregroundColor(LuxuryColorPalette.textPrimary)
                            .lineLimit(1)

                        Spacer()
                    }
                }
            }
        }
    }

    private var statusColor: Color {
        switch trip.status {
        case "planning":
            return LuxuryColorPalette.amber
        case "booked":
            return LuxuryColorPalette.forestGreen
        case "active":
            return LuxuryColorPalette.premiumBlue
        case "completed":
            return LuxuryColorPalette.textSecondary
        default:
            return LuxuryColorPalette.textTertiary
        }
    }

    private var daysUntilTrip: String {
        guard let startDate = trip.startDate else { return "" }

        let days = Calendar.current.dateComponents([.day], from: Date(), to: startDate).day ?? 0

        if days > 0 {
            return "\(days) days"
        } else if days == 0 {
            return "Today"
        } else {
            return "Active"
        }
    }
}

struct VisitedPlaceCard: View {
    let place: VisitedPlace
    let action: (() -> Void)?

    var body: some View {
        LuxuryCard(
            backgroundColor: LuxuryColorPalette.pearlWhite,
            action: action
        ) {
            VStack(alignment: .leading, spacing: LuxurySpacing.sm) {
                // Header with name and favorite
                HStack {
                    VStack(alignment: .leading, spacing: LuxurySpacing.xs) {
                        Text(place.name ?? "Unknown Place")
                            .font(LuxuryTypography.title)
                            .foregroundColor(LuxuryColorPalette.textPrimary)

                        Text("\(place.city ?? ""), \(place.country ?? "")")
                            .font(LuxuryTypography.caption)
                            .foregroundColor(LuxuryColorPalette.textSecondary)
                    }

                    Spacer()

                    Button(action: {
                        // Toggle favorite
                    }) {
                        Image(systemName: place.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(place.isFavorite ? LuxuryColorPalette.richRed : LuxuryColorPalette.textTertiary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Photo count and last visit
                HStack {
                    Label("\(place.photoCount) Photos", systemImage: "photo.fill")
                        .font(LuxuryTypography.caption)
                        .foregroundColor(LuxuryColorPalette.textSecondary)

                    Spacer()

                    if let lastVisit = place.lastVisitDate {
                        Text("Last visited \(lastVisit, style: .relative) ago")
                            .font(LuxuryTypography.caption)
                            .foregroundColor(LuxuryColorPalette.textTertiary)
                    }
                }

                // Gold accent line
                Rectangle()
                    .fill(LuxuryColorPalette.luxuryGoldGradient)
                    .frame(height: 1)
                    .opacity(0.5)
            }
        }
    }
}

struct ExperienceCard: View {
    let experience: LuxuryExperience
    let action: (() -> Void)?

    var body: some View {
        LuxuryCard(
            backgroundColor: LuxuryColorPalette.pearlWhite,
            action: action
        ) {
            VStack(alignment: .leading, spacing: LuxurySpacing.sm) {
                // Header with luxury level
                HStack {
                    Text(experience.experienceName ?? "Luxury Experience")
                        .font(LuxuryTypography.title)
                        .foregroundColor(LuxuryColorPalette.textPrimary)
                        .lineLimit(2)

                    Spacer()

                    // Luxury level stars
                    HStack(spacing: 2) {
                        ForEach(0..<Int(experience.luxuryLevel), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(LuxuryColorPalette.softGold)
                        }
                    }
                }

                // Category and duration
                HStack {
                    Text(experience.category?.capitalized ?? "Experience")
                        .font(LuxuryTypography.caption)
                        .foregroundColor(LuxuryColorPalette.premiumBlue)
                        .padding(.horizontal, LuxurySpacing.xs)
                        .padding(.vertical, 2)
                        .background(LuxuryColorPalette.premiumBlue.opacity(0.1))
                        .cornerRadius(LuxurySpacing.cornerRadiusSmall)

                    if let duration = experience.duration {
                        Text(duration)
                            .font(LuxuryTypography.caption)
                            .foregroundColor(LuxuryColorPalette.textSecondary)

                        Spacer()
                    }
                }

                // Price
                if let cost = experience.estimatedCost {
                    LuxuryTypography.formatCurrency(cost.doubleValue)
                }

                // Booking required badge
                if experience.bookingRequired {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(LuxuryColorPalette.forestGreen)

                        Text("Booking Required")
                            .font(LuxuryTypography.caption)
                            .foregroundColor(LuxuryColorPalette.forestGreen)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct LuxuryCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVStack(spacing: LuxurySpacing.md) {
                LuxuryCard {
                    VStack(alignment: .leading, spacing: LuxurySpacing.sm) {
                        Text("Basic Card")
                            .font(LuxuryTypography.title)
                        Text("This is a basic luxury card with elegant styling.")
                            .font(LuxuryTypography.body)
                    }
                }

                DestinationCard(destination: LuxuryDestination.preview, action: {})

                TripCard(trip: TripPlan.preview, action: {})

                VisitedPlaceCard(place: VisitedPlace.preview, action: {})

                ExperienceCard(experience: LuxuryExperience.preview, action: {})
            }
            .padding(LuxurySpacing.md)
        }
        .background(LuxuryColorPalette.warmWhite)
        .previewDisplayName("Luxury Cards Collection")
    }
}

// MARK: - Preview Extensions

extension LuxuryDestination {
    static var preview: LuxuryDestination {
        let destination = LuxuryDestination()
        destination.name = "Monaco Grand Prix"
        destination.city = "Monte Carlo"
        destination.country = "Monaco"
        destination.luxuryRating = 5
        destination.destinationType = "cultural"
        return destination
    }
}

extension TripPlan {
    static var preview: TripPlan {
        let trip = TripPlan()
        trip.tripName = "Monaco Grand Prix 2025"
        trip.status = "planning"
        trip.startDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
        trip.endDate = Calendar.current.date(byAdding: .day, value: 35, to: Date())
        trip.totalBudget = 15000.0
        return trip
    }
}

extension VisitedPlace {
    static var preview: VisitedPlace {
        let place = VisitedPlace()
        place.name = "Monaco Harbor"
        place.city = "Monte Carlo"
        place.country = "Monaco"
        place.photoCount = 25
        place.isFavorite = true
        place.lastVisitDate = Date()
        return place
    }
}

extension LuxuryExperience {
    static var preview: LuxuryExperience {
        let experience = LuxuryExperience()
        experience.experienceName = "Helicopter Tour of French Riviera"
        experience.category = "transport"
        experience.luxuryLevel = 5
        experience.duration = "2 hours"
        experience.estimatedCost = 2500.0
        experience.bookingRequired = true
        return experience
    }
}