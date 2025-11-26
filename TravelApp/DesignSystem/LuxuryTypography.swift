//
//  LuxuryTypography.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import SwiftUI
import UIKit

struct LuxuryTypography {
    // MARK: - Font System (San Francisco + Didot)

    /// Headline - San Francisco Display Bold, 28pt
    static let headline = Font.system(size: 28, weight: .bold, design: .default)

    /// Title - San Francisco Display Semibold, 22pt
    static let title = Font.system(size: 22, weight: .semibold, design: .default)

    /// Subtitle - San Francisco Display Medium, 18pt
    static let subtitle = Font.system(size: 18, weight: .medium, design: .default)

    /// Body - San Francisco Text Regular, 17pt
    static let body = Font.system(size: 17, weight: .regular, design: .default)

    /// Caption - San Francisco Text Light, 15pt
    static let caption = Font.system(size: 15, weight: .light, design: .default)

    /// Footnote - San Francisco Text Regular, 13pt
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)

    /// Luxury Accent - Didot Display, 32pt (for special headings)
    static let luxuryAccent = Font.custom("Didot", size: 32)

    /// Didot Large - Premium headings
    static let didotLarge = Font.custom("Didot", size: 28)

    /// Didot Medium - Luxury text
    static let didotMedium = Font.custom("Didot", size: 22)

    /// Didot Small - Elegant accents
    static let didotSmall = Font.custom("Didot", size: 18)

    // MARK: - UI Font Equivalents

    struct UIFonts {
        static let headline = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title = UIFont.systemFont(ofSize: 22, weight: .semibold)
        static let subtitle = UIFont.systemFont(ofSize: 18, weight: .medium)
        static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let caption = UIFont.systemFont(ofSize: 15, weight: .light)
        static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let didotLarge = UIFont(name: "Didot", size: 28) ?? UIFont.boldSystemFont(ofSize: 28)
        static let didotMedium = UIFont(name: "Didot", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
        static let didotSmall = UIFont(name: "Didot", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
    }

    // MARK: - Dynamic Type Support

    struct Scaled {
        static let headline = headline.scaled(minimum: 20, maximum: 36)
        static let title = title.scaled(minimum: 16, maximum: 28)
        static let subtitle = subtitle.scaled(minimum: 14, maximum: 24)
        static let body = body.scaled(minimum: 14, maximum: 20)
        static let caption = caption.scaled(minimum: 12, maximum: 18)
        static let footnote = footnote.scaled(minimum: 11, maximum: 16)

        static let didotLarge = didotLarge.scaled(minimum: 20, maximum: 36)
        static let didotMedium = didotMedium.scaled(minimum: 16, maximum: 28)
        static let didotSmall = didotSmall.scaled(minimum: 14, maximum: 24)
    }

    // MARK: - Typography Styles for Specific Use Cases

    /// App Bar Titles
    static let appTitle = title

    /// Destination Names
    static let destinationName = luxuryAccent

    /// Trip Titles
    static let tripTitle = title

    /// Section Headers
    static let sectionHeader = subtitle

    /// Experience Names
    static let experienceName = body.weight(.medium)

    /// Price Text
    static let priceText = body.weight(.semibold)

    /// Tab Bar Labels
    static let tabBarLabel = caption.weight(.medium)

    /// Button Labels
    static let buttonLabel = body.weight(.semibold)

    /// Navigation Links
    static let navigationLink = body.weight(.medium)

    /// Card Headings
    static let cardHeading = title

    /// Card Subheadings
    static let cardSubheading = body

    /// List Item Titles
    static let listItemTitle = body.weight(.medium)

    /// List Item Subtitles
    static let listItemSubtitle = caption

    /// Form Labels
    static let formLabel = body.weight(.medium)

    /// Form Values
    static let formValue = body

    /// Error Text
    static let errorText = caption.weight(.medium)

    /// Success Text
    static let successText = caption.weight(.medium)

    /// Status Labels
    static let statusLabel = footnote.weight(.medium)

    /// Timestamp Text
    static let timestamp = footnote

    /// Badge Text
    static let badgeText = footnote.weight(.bold)

    /// Collection Names
    static let collectionName = didotMedium

    /// Luxury Brand Names
    static let brandName = didotSmall

    /// User Quotes/Reviews
    static let userQuote = body.italic()
}

// MARK: - Text Styles with Colors

extension LuxuryTypography {
    struct StyledText {
        let font: Font
        let color: Color
        let lineHeight: CGFloat?
        let letterSpacing: CGFloat?

        init(font: Font, color: Color, lineHeight: CGFloat? = nil, letterSpacing: CGFloat? = nil) {
            self.font = font
            self.color = color
            self.lineHeight = lineHeight
            self.letterSpacing = letterSpacing
        }

        func apply(to text: String) -> Text {
            var textComponent = Text(text)
                .font(font)
                .foregroundColor(color)

            if let lineHeight = lineHeight {
                textComponent = textComponent.lineSpacing(lineHeight)
            }

            if let letterSpacing = letterSpacing {
                textComponent = textComponent.kerning(letterSpacing)
            }

            return textComponent
        }
    }

    // MARK: - Predefined Styles

    /// Luxury heading with gold accent
    static let luxuryHeading = StyledText(
        font: luxuryAccent,
        color: LuxuryColorPalette.softGold,
        lineHeight: 2
    )

    /// Primary body text
    static let primaryBody = StyledText(
        font: body,
        color: LuxuryColorPalette.textPrimary,
        lineHeight: 1.4
    )

    /// Secondary text
    static let secondaryText = StyledText(
        font: body,
        color: LuxuryColorPalette.textSecondary,
        lineHeight: 1.4
    )

    /// Caption text
    static let captionText = StyledText(
        font: caption,
        color: LuxuryColorPalette.textTertiary,
        lineHeight: 1.3
    )

    /// Button primary
    static let buttonPrimary = StyledText(
        font: buttonLabel,
        color: LuxuryColorPalette.midnightBlack
    )

    /// Button secondary
    static let buttonSecondary = StyledText(
        font: buttonLabel,
        color: LuxuryColorPalette.textPrimary
    )

    /// Destination title
    static let destinationTitle = StyledText(
        font: destinationName,
        color: LuxuryColorPalette.midnightBlack,
        lineHeight: 2,
        letterSpacing: 1.0
    )

    /// Price display
    static let priceDisplay = StyledText(
        font: priceText,
        color: LuxuryColorPalette.softGold,
        letterSpacing: 0.5
    )

    /// Status active
    static let statusActive = StyledText(
        font: statusLabel,
        color: LuxuryColorPalette.forestGreen,
        letterSpacing: 0.5
    )

    /// Status pending
    static let statusPending = StyledText(
        font: statusLabel,
        color: LuxuryColorPalette.amber,
        letterSpacing: 0.5
    )

    /// Status error
    static let statusError = StyledText(
        font: statusLabel,
        color: LuxuryColorPalette.richRed,
        letterSpacing: 0.5
    )
}

// MARK: - Text Formatting Utilities

extension LuxuryTypography {
    /// Format currency with luxury styling
    static func formatCurrency(_ amount: Double, currency: String = "USD") -> Text {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0

        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
        return Text(formatted)
            .font(priceText)
            .foregroundColor(LuxuryColorPalette.softGold)
    }

    /// Format date with luxury styling
    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> Text {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none

        return Text(formatter.string(from: date))
            .font(body)
            .foregroundColor(LuxuryColorPalette.textPrimary)
    }

    /// Format date range for trips
    static func formatDateRange(start: Date, end: Date) -> Text {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)

        return Text("\(startString) - \(endString)")
            .font(body)
            .foregroundColor(LuxuryColorPalette.textSecondary)
    }

    /// Create elegant heading with Didot and underline
    static func luxuryHeading(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(luxuryAccent)
                .foregroundColor(LuxuryColorPalette.midnightBlack)
                .kerning(1.0)

            Rectangle()
                .fill(LuxuryColorPalette.luxuryGoldGradient)
                .frame(height: 2)
        }
    }

    /// Create destination name with location styling
    static func destinationNameWithLocation(_ name: String, location: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(destinationName)
                .foregroundColor(LuxuryColorPalette.midnightBlack)
                .kerning(0.5)

            Text(location)
                .font(caption)
                .foregroundColor(LuxuryColorPalette.textSecondary)
        }
    }
}

// MARK: - Accessible Typography

extension LuxuryTypography {
    struct Accessible {
        static let headline = headline.accessibility()
        static let title = title.accessibility()
        static let body = body.accessibility()
        static let caption = caption.accessibility()

        private static func accessibility(font: Font) -> Font {
            // Ensure minimum readable sizes for accessibility
            if UIFont.preferredFont(forTextStyle: .body).pointSize >= 18 {
                return font.size(font.size.value * 1.2)
            }
            return font
        }
    }
}