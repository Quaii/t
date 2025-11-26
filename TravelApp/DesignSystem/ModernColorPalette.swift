//
//  ModernColorPalette.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import SwiftUI

struct ModernColorPalette {
    // MARK: - Dark Theme Primary Colors

    /// Deep charcoal - Primary dark background
    static let deepCharcoal = Color(hex: "#1C1C1E")

    /// Rich charcoal - Secondary backgrounds
    static let richCharcoal = Color(hex: "#2C2C2E")

    /// Medium charcoal - Elevated elements
    static let mediumCharcoal = Color(hex: "#3A3A3C")

    /// Light charcoal - Borders and dividers
    static let lightCharcoal = Color(hex: "#48484A")

    /// Off white - Primary text for dark backgrounds
    static let offWhite = Color(hex: "#F2F2F7")

    /// Light gray - Secondary text
    static let lightGray = Color(hex: "#AEAEB2")

    /// Medium gray - Tertiary text and disabled elements
    static let mediumGray = Color(hex: "#8E8E93")

    /// Dark gray - Hover states and subtle accents
    static let darkGray = Color(hex: "#636366")

    // MARK: - Accent Colors

    /// Vibrant blue - Primary actions and highlights
    static let vibrantBlue = Color(hex: "#007AFF")

    /// Soft blue - Secondary highlights
    static let softBlue = Color(hex: "#5AC8FA")

    /// Mint green - Success states and confirmations
    static let mintGreen = Color(hex: "#30D158")

    /// Warm orange - Warning states and attention
    static let warmOrange = Color(hex: "#FF9F0A")

    /// Soft red - Error states and critical actions
    static let softRed = Color(hex: "#FF453A")

    /// Purple accent - Special features and premium elements
    static let purpleAccent = Color(hex: "#BF5AF2")

    /// Gold accent - Premium features and highlights
    static let goldAccent = Color(hex: "#FFD700")

    // MARK: - Background Colors

    /// Primary dark background
    static let primaryBackground = deepCharcoal

    /// Secondary background for cards and elevated elements
    static let secondaryBackground = richCharcoal

    /// Tertiary background for grouped content
    static let tertiaryBackground = mediumCharcoal

    /// Surface background for inputs and forms
    static let surfaceBackground = Color(hex: "#48484A")

    // MARK: - Text Colors

    /// Primary text - High contrast for readability
    static let primaryText = offWhite

    /// Secondary text - Subtle information
    static let secondaryText = lightGray

    /// Tertiary text - Even more subtle
    static let tertiaryText = mediumGray

    /// Accent text - Links and important elements
    static let accentText = vibrantBlue

    /// Disabled text
    static let disabledText = darkGray

    // MARK: - Interactive Colors

    /// Primary button gradient
    static let primaryButton = LinearGradient(
        colors: [vibrantBlue, softBlue],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Secondary button
    static let secondaryButton = LinearGradient(
        colors: [mediumCharcoal, richCharcoal],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Tertiary button (outline style)
    static let tertiaryButton = Color.clear

    /// Success button
    static let successButton = LinearGradient(
        colors: [mintGreen, Color(hex: "#28C740")],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Card & UI Colors

    /// Card background
    static let cardBackground = secondaryBackground

    /// Card border
    static let cardBorder = lightCharcoal

    /// Input field background
    static let inputBackground = surfaceBackground

    /// Input field border (focused)
    static let inputBorderFocused = vibrantBlue

    /// Input field border (default)
    static let inputBorderDefault = lightCharcoal

    // MARK: - Map & Location Colors

    /// Visited places
    static let visitedPlace = vibrantBlue

    /// Favorite spots
    static let favoriteSpot = goldAccent

    /// Search results
    static let searchResult = softBlue

    /// Restaurant markers
    static let restaurantMarker = softRed

    /// Hotel markers
    static let hotelMarker = mintGreen

    /// Store markers
    static let storeMarker = purpleAccent

    /// Current location
    static let currentLocation = vibrantBlue

    // MARK: - Status Colors

    /// Active/traveling status
    static let activeStatus = mintGreen

    /// Planning status
    static let planningStatus = warmOrange

    /// Completed status
    static let completedStatus = mediumGray

    /// Cancelled status
    static let cancelledStatus = softRed

    // MARK: - Shadow Colors

    /// Subtle shadow for elevated elements
    static let subtleShadow = Color.black.opacity(0.1)

    /// Medium shadow
    static let mediumShadow = Color.black.opacity(0.2)

    /// Heavy shadow for floating elements
    static let heavyShadow = Color.black.opacity(0.3)

    // MARK: - Overlay Colors

    /// Modal overlay
    static let modalOverlay = Color.black.opacity(0.4)

    /// Loading overlay
    static let loadingOverlay = Color.black.opacity(0.6)

    /// Navigation bar overlay
    static let navigationOverlay = richCharcoal.opacity(0.9)

    // MARK: - Gradient Backgrounds

    /// Home screen gradient
    static let homeGradient = LinearGradient(
        colors: [deepCharcoal, richCharcoal],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Card gradient
    static let cardGradient = LinearGradient(
        colors: [richCharcoal, mediumCharcoal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Button pressed gradient
    static let buttonPressedGradient = LinearGradient(
        colors: [vibrantBlue.opacity(0.8), softBlue.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Light Mode Support (Optional)

    struct LightMode {
        /// Light background
        static let primaryBackground = Color(hex: "#FFFFFF")
        static let secondaryBackground = Color(hex: "#F8F8F8")
        static let tertiaryBackground = Color(hex: "#F0F0F0")

        /// Light text
        static let primaryText = Color(hex: "#1C1C1E")
        static let secondaryText = Color(hex: "#48484A")
        static let tertiaryText = Color(hex: "#8E8E93")

        /// Light card
        static let cardBackground = Color.white
        static let cardBorder = Color(hex: "#E5E5E5")
    }

    // MARK: - Accessibility Colors

    struct Accessibility {
        /// High contrast text
        static let highContrastText = Color.white

        /// High contrast background
        static let highContrastBackground = Color.black

        /// High contrast accent
        static let highContrastAccent = Color.blue

        /// Focus ring
        static let focusRing = vibrantBlue
    }

    // MARK: - Semantic Colors

    struct System {
        /// System blue (matches iOS)
        static let systemBlue = Color.blue

        /// System green
        static let systemGreen = Color.green

        /// System orange
        static let systemOrange = Color.orange

        /// System red
        static let systemRed = Color.red

        /// System background
        static let systemBackground = Color(UIColor.systemBackground)

        /// System grouped background
        static let systemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    }

    // MARK: - Color Extensions

    /// Get semantic color based on context
    static func semantic(_ context: ColorContext) -> Color {
        switch context {
        case .primaryText:
            return primaryText
        case .secondaryText:
            return secondaryText
        case .tertiaryText:
            return tertiaryText
        case .accent:
            return vibrantBlue
        case .success:
            return mintGreen
        case .warning:
            return warmOrange
        case .error:
            return softRed
        case .background:
            return primaryBackground
        case .card:
            return cardBackground
        case .border:
            return cardBorder
        }
    }

    /// Get status color
    static func status(_ type: StatusType) -> Color {
        switch type {
        case .active:
            return activeStatus
        case .planning:
            return planningStatus
        case .completed:
            return completedStatus
        case .cancelled:
            return cancelledStatus
        }
    }
}

enum ColorContext {
    case primaryText
    case secondaryText
    case tertiaryText
    case accent
    case success
    case warning
    case error
    case background
    case card
    case border
}

enum StatusType {
    case active
    case planning
    case completed
    case cancelled
}

// MARK: - UIColor Extensions for UIKit Integration

extension UIColor {
    static let deepCharcoal = UIColor(hex: "#1C1C1E")
    static let richCharcoal = UIColor(hex: "#2C2C2E")
    static let mediumCharcoal = UIColor(hex: "#3A3A3C")
    static let lightCharcoal = UIColor(hex: "#48484A")
    static let offWhite = UIColor(hex: "#F2F2F7")
    static let vibrantBlue = UIColor(hex: "#007AFF")
    static let softBlue = UIColor(hex: "#5AC8FA")
    static let mintGreen = UIColor(hex: "#30D158")
    static let warmOrange = UIColor(hex: "#FF9F0A")
    static let softRed = UIColor(hex: "#FF453A")
    static let purpleAccent = UIColor(hex: "#BF5AF2")
    static let goldAccent = UIColor(hex: "#FFD700")

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}