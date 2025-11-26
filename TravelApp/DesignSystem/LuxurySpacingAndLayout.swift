//
//  LuxurySpacingAndLayout.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import SwiftUI

struct LuxurySpacing {
    // MARK: - Base Unit System

    /// Base unit for all spacing (8pt)
    static let baseUnit: CGFloat = 8

    // MARK: - Spacing Constants

    /// Micro spacing (1x) - 8pt
    static let xs: CGFloat = baseUnit * 1

    /// Small spacing (2x) - 16pt
    static let sm: CGFloat = baseUnit * 2

    /// Medium spacing (3x) - 24pt
    static let md: CGFloat = baseUnit * 3

    /// Large spacing (4x) - 32pt
    static let lg: CGFloat = baseUnit * 4

    /// Extra large spacing (6x) - 48pt
    static let xl: CGFloat = baseUnit * 6

    /// XX Large spacing (8x) - 64pt
    static let xxl: CGFloat = baseUnit * 8

    // MARK: - Component Spacing

    /// Internal padding for components
    static let componentPadding: CGFloat = sm

    /// Section spacing between content blocks
    static let sectionSpacing: CGFloat = lg

    /// Card margins
    static let cardMargin: CGFloat = md

    /// List item spacing
    static let listItemSpacing: CGFloat = xs

    /// Button padding
    static let buttonPadding: EdgeInsets = EdgeInsets(top: sm, leading: md, bottom: sm, trailing: md)

    /// Input field padding
    static let inputPadding: EdgeInsets = EdgeInsets(top: sm, leading: sm, bottom: sm, trailing: sm)

    /// Container padding
    static let containerPadding: CGFloat = md

    /// Safe area offset
    static let safeAreaOffset: CGFloat = md

    // MARK: - Corner Radius

    /// Small corner radius for buttons and small elements
    static let cornerRadiusSmall: CGFloat = 8

    /// Medium corner radius for cards
    static let cornerRadiusMedium: CGFloat = 12

    /// Large corner radius for major components
    static let cornerRadiusLarge: CGFloat = 16

    /// Extra large corner radius for special elements
    static let cornerRadiusXLarge: CGFloat = 24

    // MARK: - Border Width

    /// Thin border for subtle definition
    static let borderWidthThin: CGFloat = 0.5

    /// Standard border
    static let borderWidthStandard: CGFloat = 1

    /// Thick border for emphasis
    static let borderWidthThick: CGFloat = 2

    // MARK: - Shadow Properties

    struct Shadow {
        /// Subtle shadow for luxury cards
        static let subtle = (color: Color.black.opacity(0.08), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))

        /// Medium shadow for elevated elements
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))

        /// Heavy shadow for floating elements
        static let heavy = (color: Color.black.opacity(0.25), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))

        /// Gold shadow for premium elements
        static let gold = (color: LuxuryColorPalette.softGold.opacity(0.3), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
    }

    // MARK: - Layout Dimensions

    struct Dimensions {
        /// Standard button height
        static let buttonHeight: CGFloat = 48

        /// Large button height
        static let buttonHeightLarge: CGFloat = 56

        /// Small button height
        static let buttonHeightSmall: CGFloat = 36

        /// Card minimum height
        static let cardMinHeight: CGFloat = 120

        /// List item height
        static let listItemHeight: CGFloat = 64

        /// List item height large
        static let listItemHeightLarge: CGFloat = 88

        /// Icon size small
        static let iconSizeSmall: CGFloat = 16

        /// Icon size medium
        static let iconSizeMedium: CGFloat = 24

        /// Icon size large
        static let iconSizeLarge: CGFloat = 32

        /// Image aspect ratios
        static let imageAspectWide: CGFloat = 16/9
        static let imageAspectSquare: CGFloat = 1
        static let imageAspectTall: CGFloat = 4/5

        /// Grid columns
        static let gridColumnsSmall: Int = 1
        static let gridColumnsMedium: Int = 2
        static let gridColumnsLarge: Int = 3

        /// Maximum content width for readability
        static let maxContentWidth: CGFloat = 600
    }

    // MARK: - Safe Area Margins

    struct SafeArea {
        static var top: CGFloat {
            return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        }

        static var bottom: CGFloat {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 34
        }

        static var leading: CGFloat {
            return UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0
        }

        static var trailing: CGFloat {
            return UIApplication.shared.windows.first?.safeAreaInsets.right ?? 0
        }

        static var all: EdgeInsets {
            return EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
        }
    }

    // MARK: - Responsive Breakpoints

    struct Breakpoint {
        static let compact: CGFloat = 375  // iPhone SE
        static let regular: CGFloat = 414   // iPhone Pro Max
        static let medium: CGFloat = 768    // iPad mini
        static let large: CGFloat = 1024    // iPad Pro
        static let xlarge: CGFloat = 1366   // iPad Pro 12.9"
    }

    // MARK: - Device Adaptation

    struct Adaptive {
        static var isCompactWidth: Bool {
            UIScreen.main.bounds.width <= Breakpoint.compact
        }

        static var isRegularWidth: Bool {
            UIScreen.main.bounds.width <= Breakpoint.regular
        }

        static var isTabletWidth: Bool {
            UIScreen.main.bounds.width >= Breakpoint.medium
        }

        static func padding(for size: CGSize) -> EdgeInsets {
            if size.width <= Breakpoint.compact {
                return EdgeInsets(top: sm, leading: sm, bottom: sm, trailing: sm)
            } else if size.width <= Breakpoint.regular {
                return EdgeInsets(top: md, leading: md, bottom: md, trailing: md)
            } else {
                return EdgeInsets(top: lg, leading: lg, bottom: lg, trailing: lg)
            }
        }

        static func columns(for width: CGFloat) -> Int {
            if width <= Breakpoint.compact {
                return 1
            } else if width <= Breakpoint.medium {
                return 2
            } else {
                return 3
            }
        }
    }
}

// MARK: - Layout Helpers

extension LuxurySpacing {
    /// HStack with luxury spacing
    struct HStack<Content: View>: View {
        let alignment: VerticalAlignment
        let spacing: CGFloat
        let content: Content

        init(alignment: VerticalAlignment = .center, spacing: CGFloat = sm, @ViewBuilder content: () -> Content) {
            self.alignment = alignment
            self.spacing = spacing
            self.content = content()
        }

        var body: some View {
            SwiftUI.HStack(alignment: alignment, spacing: spacing) {
                content
            }
        }
    }

    /// VStack with luxury spacing
    struct VStack<Content: View>: View {
        let alignment: HorizontalAlignment
        let spacing: CGFloat
        let content: Content

        init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = sm, @ViewBuilder content: () -> Content) {
            self.alignment = alignment
            self.spacing = spacing
            self.content = content()
        }

        var body: some View {
            SwiftUI.VStack(alignment: alignment, spacing: spacing) {
                content
            }
        }
    }

    /// Grid with adaptive columns
    struct AdaptiveGrid<Content: View>: View {
        let items: [Content]
        let spacing: CGFloat
        let padding: CGFloat

        init(items: [Content], spacing: CGFloat = sm, padding: CGFloat = md) {
            self.items = items
            self.spacing = spacing
            self.padding = padding
        }

        var body: some View {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 200), spacing: spacing)
            ], spacing: spacing) {
                ForEach(items.indices, id: \.self) { index in
                    items[index]
                }
            }
            .padding(padding)
        }
    }
}

// MARK: - Geometry Reader Helpers

extension LuxurySpacing {
    /// Container with maximum width constraint
    struct MaxWidthContainer<Content: View>: View {
        let maxWidth: CGFloat
        let alignment: HorizontalAlignment
        let content: Content

        init(maxWidth: CGFloat = Dimensions.maxContentWidth, alignment: HorizontalAlignment = .center, @ViewBuilder content: () -> Content) {
            self.maxWidth = maxWidth
            self.alignment = alignment
            self.content = content()
        }

        var body: some View {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity, alignment: .init(horizontal: alignment, vertical: .center))
        }
    }

    /// Responsive container that adapts to screen size
    struct ResponsiveContainer<Content: View>: View {
        let content: Content

        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }

        var body: some View {
            GeometryReader { geometry in
                MaxWidthContainer(alignment: .leading) {
                    content
                }
            }
        }
    }
}

// MARK: - View Modifiers

extension View {
    /// Apply luxury card styling
    func luxuryCard(
        padding: EdgeInsets = EdgeInsets(top: LuxurySpacing.md, leading: LuxurySpacing.md, bottom: LuxurySpacing.md, trailing: LuxurySpacing.md),
        margin: CGFloat = LuxurySpacing.sm,
        cornerRadius: CGFloat = LuxurySpacing.cornerRadiusMedium,
        shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = LuxurySpacing.Shadow.subtle
    ) -> some View {
        self
            .padding(padding)
            .background(LuxuryColorPalette.pearlWhite)
            .cornerRadius(cornerRadius)
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
            .padding(.horizontal, margin)
    }

    /// Apply luxury button styling
    func luxuryButton(
        height: CGFloat = LuxurySpacing.Dimensions.buttonHeight,
        cornerRadius: CGFloat = LuxurySpacing.cornerRadiusSmall
    ) -> some View {
        self
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .cornerRadius(cornerRadius)
    }

    /// Apply luxury section spacing
    func luxurySection() -> some View {
        self
            .padding(.horizontal, LuxurySpacing.containerPadding)
            .padding(.vertical, LuxurySpacing.sm)
    }

    /// Apply luxury container with max width
    func luxuryContainer() -> some View {
        LuxurySpacing.ResponsiveContainer {
            self
        }
    }
}