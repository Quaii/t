//
//  ModernTypography.swift
//  Wanderlux
//
//  Created by Wanderlux Team on 11/26/2025.
//  Copyright © 2025 Wanderlux. All rights reserved.
//

import SwiftUI
import UIKit

struct ModernTypography {
    // MARK: - Font System (San Francisco)

    /// Display Bold - Large headings and titles
    static let displayBold = Font.system(size: 28, weight: .bold, design: .default)

    /// Display Semibold - Section headers
    static let displaySemibold = Font.system(size: 22, weight: .semibold, design: .default)

    /// Display Medium - Subheadings
    static let displayMedium = Font.system(size: 20, weight: .medium, design: .default)

    /// Text Regular - Body content
    static let textRegular = Font.system(size: 17, weight: .regular, design: .default)

    /// Text Medium - Emphasized body text
    static let textMedium = Font.system(size: 17, weight: .medium, design: .default)

    /// Text Semibold - Important body text
    static let textSemibold = Font.system(size: 17, weight: .semibold, design: .default)

    /// Caption Regular - Secondary information
    static let captionRegular = Font.system(size: 15, weight: .regular, design: .default)

    /// Caption Medium - Emphasized captions
    static let captionMedium = Font.system(size: 15, weight: .medium, design: .default)

    /// Footnote Regular - Helper text
    static let footnoteRegular = Font.system(size: 13, weight: .regular, design: .default)

    /// Footnote Medium - Emphasized footnote text
    static let footnoteMedium = Font.system(size: 13, weight: .medium, design: .default)

    /// Large Title - Special headings
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)

    /// Title 1 - Main titles
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)

    /// Title 2 - Secondary titles
    static let title2 = Font.system(size: 22, weight: .bold, design: .default)

    /// Title 3 - Tertiary titles
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)

    /// Headline - Section headers
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)

    /// Body - Regular content
    static let body = Font.system(size: 17, weight: .regular, design: .default)

    /// Callout - Emphasized content
    static let callout = Font.system(size: 16, weight: .medium, design: .default)

    /// Subhead - Secondary content
    static let subhead = Font.system(size: 15, weight: .regular, design: .default)

    /// Footnote - Small text
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)

    /// Caption 1 - Label text
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)

    /// Caption 2 - Smallest text
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: - UI Font Equivalents

    struct UIFonts {
        static let displayBold = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let displaySemibold = UIFont.systemFont(ofSize: 22, weight: .semibold)
        static let displayMedium = UIFont.systemFont(ofSize: 20, weight: .medium)
        static let textRegular = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let textMedium = UIFont.systemFont(ofSize: 17, weight: .medium)
        static let textSemibold = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let captionRegular = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let captionMedium = UIFont.systemFont(ofSize: 15, weight: .medium)
        static let footnoteRegular = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let footnoteMedium = UIFont.systemFont(ofSize: 13, weight: .medium)
        static let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)
        static let title1 = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title2 = UIFont.systemFont(ofSize: 22, weight: .bold)
        static let title3 = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let callout = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let subhead = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let caption1 = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let caption2 = UIFont.systemFont(ofSize: 11, weight: .regular)
    }

    // MARK: - Dynamic Type Support

    struct Scaled {
        static let largeTitle = ModernTypography.largeTitle.scaled(minimum: 28, maximum: 40)
        static let title1 = ModernTypography.title1.scaled(minimum: 22, maximum: 34)
        static let title2 = ModernTypography.title2.scaled(minimum: 18, maximum: 28)
        static let title3 = ModernTypography.title3.scaled(minimum: 16, maximum: 26)
        static let headline = ModernTypography.headline.scaled(minimum: 15, maximum: 24)
        static let body = ModernTypography.body.scaled(minimum: 14, maximum: 22)
        static let callout = ModernTypography.callout.scaled(minimum: 14, maximum: 20)
        static let subhead = ModernTypography.subhead.scaled(minimum: 13, maximum: 18)
        static let footnote = ModernTypography.footnote.scaled(minimum: 12, maximum: 16)
        static let caption1 = ModernTypography.caption1.scaled(minimum: 11, maximum: 14)
        static let caption2 = ModernTypography.caption2.scaled(minimum: 10, maximum: 12)
    }

    // MARK: - Typography Styles for Specific Use Cases

    /// App bar titles
    static let appBarTitle = title2

    /// Destination names
    static let destinationName = title3

    /// Restaurant names
    static let restaurantName = headline

    /// Hotel names
    static let hotelName = headline

    /// Store names
    static let storeName = headline

    /// Section headers
    static let sectionHeader = headline

    /// Card titles
    static let cardTitle = textMedium

    /// Card subtitles
    static let cardSubtitle = captionRegular

    /// Navigation links
    static let navigationLink = textMedium

    /// Button labels
    static let buttonLabel = textMedium

    /// Tab bar labels
    static let tabBarLabel = caption1

    /// List item titles
    static let listItemTitle = textMedium

    /// List item subtitles
    static let listItemSubtitle = captionRegular

    /// Form labels
    static let formLabel = textRegular

    /// Form values
    static let formValue = textRegular

    /// Input placeholder
    static let inputPlaceholder = textRegular

    /// Error text
    static let errorText = captionMedium

    /// Success text
    static let successText = captionMedium

    /// Status labels
    static let statusLabel = footnoteMedium

    /// Timestamp text
    static let timestamp = footnoteRegular

    /// Price text
    static let priceText = textSemibold

    /// Rating text
    static let ratingText = captionRegular

    /// Badge text
    static let badgeText = footnoteMedium

    /// Search field text
    static let searchText = textRegular

    /// Address text
    static let addressText = captionRegular

    /// Distance text
    static let distanceText = captionRegular

    /// Tag text
    static let tagText = caption1

    /// Alert title
    static let alertTitle = headline

    /// Alert message
    static let alertMessage = textRegular

    /// Alert button
    static let alertButton = textMedium
}

// MARK: - Text Styles with Colors

extension ModernTypography {
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

    /// Large heading with high contrast
    static let largeHeading = StyledText(
        font: largeTitle,
        color: ModernColorPalette.primaryText,
        lineHeight: 1.2,
        letterSpacing: 0.5
    )

    /// Primary body text
    static let primaryBody = StyledText(
        font: body,
        color: ModernColorPalette.primaryText,
        lineHeight: 1.4
    )

    /// Secondary text
    static let secondaryText = StyledText(
        font: body,
        color: ModernColorPalette.secondaryText,
        lineHeight: 1.4
    )

    /// Tertiary text
    static let tertiaryText = StyledText(
        font: captionRegular,
        color: ModernColorPalette.tertiaryText,
        lineHeight: 1.3
    )

    /// Primary button text
    static let buttonPrimary = StyledText(
        font: buttonLabel,
        color: ModernColorPalette.primaryText
    )

    /// Secondary button text
    static let buttonSecondary = StyledText(
        font: buttonLabel,
        color: ModernColorPalette.primaryText
    )

    /// Tertiary button text
    static let buttonTertiary = StyledText(
        font: buttonLabel,
        color: ModernColorPalette.vibrantBlue
    )

    /// Destination title
    static let destinationTitle = StyledText(
        font: destinationName,
        color: ModernColorPalette.primaryText,
        lineHeight: 1.2
    )

    /// Restaurant name
    static let restaurantNameText = StyledText(
        font: restaurantName,
        color: ModernColorPalette.primaryText,
        lineHeight: 1.3
    )

    /// Hotel name
    static let hotelNameText = StyledText(
        font: hotelName,
        color: ModernColorPalette.primaryText,
        lineHeight: 1.3
    )

    /// Price display
    static let priceDisplay = StyledText(
        font: priceText,
        color: ModernColorPalette.vibrantBlue,
        letterSpacing: 0.2
    )

    /// Status active
    static let statusActive = StyledText(
        font: statusLabel,
        color: ModernColorPalette.mintGreen,
        letterSpacing: 0.3
    )

    /// Status planning
    static let statusPlanning = StyledText(
        font: statusLabel,
        color: ModernColorPalette.warmOrange,
        letterSpacing: 0.3
    )

    /// Status completed
    static let statusCompleted = StyledText(
        font: statusLabel,
        color: ModernColorPalette.secondaryText,
        letterSpacing: 0.3
    )

    /// Search field text
    static let searchField = StyledText(
        font: searchText,
        color: ModernColorPalette.primaryText
    )

    /// Tag text
    static let tagText = StyledText(
        font: tagText,
        color: ModernColorPalette.vibrantBlue
    )

    /// Alert title
    static let alertTitleText = StyledText(
        font: alertTitle,
        color: ModernColorPalette.primaryText,
        lineHeight: 1.2
    )

    /// Alert message
    static let alertMessageText = StyledText(
        font: alertMessage,
        color: ModernColorPalette.secondaryText,
        lineHeight: 1.4
    )
}

// MARK: - Text Formatting Utilities

extension ModernTypography {
    /// Format currency with modern styling
    static func formatCurrency(_ amount: Double, currency: String = "USD") -> Text {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0

        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
        return Text(formatted)
            .font(priceText)
            .foregroundColor(ModernColorPalette.vibrantBlue)
    }

    /// Format date with modern styling
    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> Text {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none

        return Text(formatter.string(from: date))
            .font(textRegular)
            .foregroundColor(ModernColorPalette.primaryText)
    }

    /// Format relative date
    static func formatRelativeDate(_ date: Date) -> Text {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated

        return Text(formatter.localizedString(for: date, relativeTo: Date()))
            .font(captionRegular)
            .foregroundColor(ModernColorPalette.secondaryText)
    }

    /// Format time
    static func formatTime(_ date: Date) -> Text {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        return Text(formatter.string(from: date))
            .font(captionRegular)
            .foregroundColor(ModernColorPalette.secondaryText)
    }

    /// Format date range for trips
    static func formatDateRange(start: Date, end: Date) -> Text {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)

        return Text("\(startString) - \(endString)")
            .font(textRegular)
            .foregroundColor(ModernColorPalette.secondaryText)
    }

    /// Format distance
    static func formatDistance(_ meters: Double) -> Text {
        let formatter = LengthFormatter()
        formatter.unitStyle = .abbreviated
        let formatted = formatter.string(fromMeters: meters)

        return Text(formatted)
            .font(captionRegular)
            .foregroundColor(ModernColorPalette.secondaryText)
    }

    /// Create heading with accent color
    static func modernHeading(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(title2)
                .foregroundColor(ModernColorPalette.primaryText)
                .tracking(0.5)

            Rectangle()
                .fill(ModernColorPalette.vibrantBlue)
                .frame(height: 2)
        }
    }

    /// Create section header
    static func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(headline)
            .foregroundColor(ModernColorPalette.primaryText)
            .tracking(0.3)
            .padding(.bottom, 8)
    }

    /// Create destination name with modern styling
    static func destinationNameWithLocation(_ name: String, location: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(destinationName)
                .foregroundColor(ModernColorPalette.primaryText)

            Text(location)
                .font(captionRegular)
                .foregroundColor(ModernColorPalette.secondaryText)
        }
    }
}

// MARK: - Accessibility Support

extension ModernTypography {
    struct Accessible {
        static let largeTitle = ModernTypography.largeTitle.accessibility()
        static let title1 = ModernTypography.title1.accessibility()
        static let headline = ModernTypography.headline.accessibility()
        static let body = ModernTypography.body.accessibility()
        static let caption1 = ModernTypography.caption1.accessibility()

        private static func accessibility(font: Font) -> Font {
            // Ensure minimum readable sizes for accessibility
            if UIFont.preferredFont(forTextStyle: .body).pointSize >= 18 {
                return font.size(font.size.value * 1.2)
            }
            return font
        }
    }
}