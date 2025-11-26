//
//  LuxuryColorPalette.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import SwiftUI

struct LuxuryColorPalette {
    // MARK: - Primary Colors (Rolls-Royce Inspired)

    /// Midnight Black - Signature Rolls-Royce black
    static let midnightBlack = Color(hex: "#1A1A1A")

    /// Soft Gold - Luxury accent color
    static let softGold = Color(hex: "#D4AF37")

    /// Pearl White - Clean contrast for luxury
    static let pearlWhite = Color(hex: "#F5F5F5")

    /// Burl Wood - Warm sophistication
    static let burlWood = Color(hex: "#8B7355")

    /// Warm White - Premium background
    static let warmWhite = Color(hex: "#FAFAFA")

    // MARK: - Text Colors

    /// Primary text - High contrast readability
    static let textPrimary = Color(hex: "#1A1A1A")

    /// Secondary text - Subtle information
    static let textSecondary = Color(hex: "#666666")

    /// Tertiary text - Even more subtle
    static let textTertiary = Color(hex: "#999999")

    /// White text for dark backgrounds
    static let textWhite = Color.white

    // MARK: - Status Colors

    /// Forest Green - Positive actions and success states
    static let forestGreen = Color(hex: "#2E7D32")

    /// Amber - Attention states and warnings
    static let amber = Color(hex: "#F57C00")

    /// Rich Red - Critical states and errors
    static let richRed = Color(hex: "#C62828")

    // MARK: - Interactive States

    /// Primary button with luxury gold
    static let primaryButton = LinearGradient(
        colors: [softGold, softGold.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Secondary button with midnight black
    static let secondaryButton = LinearGradient(
        colors: [midnightBlack, midnightBlack.opacity(0.8)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Tertiary button with outline
    static let tertiaryButton = Color.clear

    // MARK: - Background Colors

    /// Primary background with warm white
    static let primaryBackground = warmWhite

    /// Secondary background for cards
    static let secondaryBackground = pearlWhite

    /// Tertiary background for grouped content
    static let tertiaryBackground = Color.white

    /// Dark background for luxury contrast
    static let darkBackground = midnightBlack

    // MARK: - Accent Colors

    /// Luxury gold accent
    static let goldAccent = softGold

    /// Premium blue accent
    static let premiumBlue = Color(hex: "#1E3A8A")

    /// Exclusive purple accent
    static let exclusivePurple = Color(hex: "#6B21A8")

    /// Elite silver accent
    static let eliteSilver = Color(hex: "#9CA3AF")

    // MARK: - Map & Visualization Colors

    /// Visited places - Gold pins
    static let visitedPlaceGold = softGold

    /// Wanted destinations - Silver pins
    static let wantedPlaceSilver = eliteSilver

    /// Current location - Blue pins
    static let currentLocationBlue = premiumBlue

    /// Collection themes
    static let collectionColors: [Color] = [
        softGold, eliteSilver, premiumBlue, exclusivePurple,
        Color(hex: "#DC2626"), // Ruby
        Color(hex: "#059669"), // Emerald
        Color(hex: "#7C3AED"), // Amethyst
        Color(hex: "#EA580C")  // Amber
    ]

    // MARK: - Luxury Gradients

    /// Signature gold gradient
    static let luxuryGoldGradient = LinearGradient(
        colors: [
            Color(hex: "#D4AF37"),
            Color(hex: "#F4E4C1"),
            Color(hex: "#D4AF37")
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Sophisticated dark gradient
    static let darkLuxuryGradient = LinearGradient(
        colors: [
            Color(hex: "#1A1A1A"),
            Color(hex: "#2D2D2D"),
            Color(hex: "#1A1A1A")
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Pearl white gradient
    static let pearlGradient = LinearGradient(
        colors: [
            Color(hex: "#F5F5F5"),
            Color.white,
            Color(hex: "#F5F5F5")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Shadow Colors

    /// Soft shadow for luxury cards
    static let softShadow = Color.black.opacity(0.08)

    /// Medium shadow for elevated elements
    static let mediumShadow = Color.black.opacity(0.15)

    /// Heavy shadow for floating elements
    static let heavyShadow = Color.black.opacity(0.25)

    // MARK: - Accessibility Support

    /// High contrast version for accessibility
    struct HighContrast {
        static let primaryText = Color.black
        static let secondaryText = Color.black.opacity(0.8)
        static let background = Color.white
        static let accent = Color.blue
        static let buttonBackground = Color.black
        static let buttonText = Color.white
    }

    /// Dark mode version
    struct DarkMode {
        static let primaryText = Color.white
        static let secondaryText = Color.white.opacity(0.8)
        static let background = Color.black
        static let accent = softGold
        static let cardBackground = Color.gray.opacity(0.2)
    }
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
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
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Get hex string from Color
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count > 3 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(a * 255), lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

// MARK: - UIColor Extensions for UIKit Integration

extension UIColor {
    static let luxuryMidnightBlack = UIColor(hex: "#1A1A1A")
    static let luxurySoftGold = UIColor(hex: "#D4AF37")
    static let luxuryPearlWhite = UIColor(hex: "#F5F5F5")
    static let luxuryBurlWood = UIColor(hex: "#8B7355")
    static let luxuryWarmWhite = UIColor(hex: "#FAFAFA")

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