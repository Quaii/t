//
//  PremiumButton.swift
//  Wanderlux
//
//  Created by Wanderlux Team on 11/26/2025.
//  Copyright © 2025 Wanderlux. All rights reserved.
//

import SwiftUI

enum PremiumButtonStyle {
    case primary    // Gold gradient with luxury styling
    case secondary  // Midnight black with luxury feel
    case tertiary   // Outline style with luxury accent
    case luxury     // Special luxury variant with gold text
}

struct PremiumButton: View {
    let title: String
    let style: PremiumButtonStyle
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    let height: CGFloat
    let icon: String?

    @State private var isPressed = false

    init(
        title: String,
        style: PremiumButtonStyle = .primary,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        height: CGFloat = LuxurySpacing.Dimensions.buttonHeight,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.height = height
        self.icon = icon
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: LuxurySpacing.xs) {
                if isLoading {
                    LuxuryLoadingView()
                        .scaleEffect(0.6)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(LuxuryTypography.buttonLabel)
                    .kerning(0.5)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(backgroundView)
            .overlay(
                borderOverlay
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isDisabled || isLoading ? 0.6 : (isPressed ? 0.9 : 1.0))
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            guard !isDisabled && !isLoading else { return }

            withAnimation(LuxuryAnimation.ButtonPress.press) {
                isPressed = true
                LuxuryAnimation.ButtonPress.perform()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(LuxuryAnimation.ButtonPress.release) {
                    isPressed = false
                }
            }
        }
    }

    private var textColor: Color {
        switch style {
        case .primary, .luxury:
            return LuxuryColorPalette.midnightBlack
        case .secondary, .tertiary:
            return LuxuryColorPalette.textPrimary
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(LuxuryColorPalette.primaryButton)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(LuxuryColorPalette.softGold.opacity(0.3), lineWidth: 1)
                )
        case .secondary:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(LuxuryColorPalette.secondaryButton)
        case .tertiary:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.clear)
        case .luxury:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(LuxuryColorPalette.midnightBlack)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(LuxuryColorPalette.luxuryGoldGradient)
                        .opacity(0.1)
                )
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        switch style {
        case .tertiary:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(LuxuryColorPalette.softGold, lineWidth: borderWidth)
        case .luxury:
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(LuxuryColorPalette.softGold.opacity(0.5), lineWidth: 1)
        default:
            EmptyView()
        }
    }

    private var cornerRadius: CGFloat {
        return LuxurySpacing.cornerRadiusSmall
    }

    private var borderWidth: CGFloat {
        return LuxurySpacing.borderWidthStandard
    }
}

// MARK: - Specialized Premium Buttons

struct CallToActionButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let subtitle: String?

    init(title: String, subtitle: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.isLoading = isLoading
    }

    var body: some View {
        VStack(spacing: LuxurySpacing.xs) {
            PremiumButton(
                title: title,
                style: .primary,
                isLoading: isLoading,
                action: action
            )

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(LuxuryTypography.caption)
                    .foregroundColor(LuxuryColorPalette.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct OutlinedActionView: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        PremiumButton(
            title: title,
            style: .tertiary,
            icon: icon,
            action: action
        )
    }
}

struct LuxuryActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        PremiumButton(
            title: title,
            style: .luxury,
            action: action
        )
    }
}

struct SecondaryActionButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        PremiumButton(
            title: title,
            style: .secondary,
            icon: icon,
            action: action
        )
    }
}

// MARK: - Button Group

struct PremiumButtonGroup: View {
    let primaryTitle: String
    let secondaryTitle: String?
    let tertiaryTitle: String?
    let primaryAction: () -> Void
    let secondaryAction: (() -> Void)?
    let tertiaryAction: (() -> Void)?
    let isLoading: Bool
    let spacing: CGFloat

    init(
        primaryTitle: String,
        secondaryTitle: String? = nil,
        tertiaryTitle: String? = nil,
        isLoading: Bool = false,
        spacing: CGFloat = LuxurySpacing.sm,
        primaryAction: @escaping () -> Void,
        secondaryAction: (() -> Void)? = nil,
        tertiaryAction: (() -> Void)? = nil
    ) {
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
        self.tertiaryTitle = tertiaryTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.tertiaryAction = tertiaryAction
        self.isLoading = isLoading
        self.spacing = spacing
    }

    var body: some View {
        VStack(spacing: spacing) {
            PremiumButton(
                title: primaryTitle,
                style: .primary,
                isLoading: isLoading,
                action: primaryAction
            )

            if let secondaryTitle = secondaryTitle {
                PremiumButton(
                    title: secondaryTitle,
                    style: .secondary,
                    action: secondaryAction ?? {}
                )
            }

            if let tertiaryTitle = tertiaryTitle {
                PremiumButton(
                    title: tertiaryTitle,
                    style: .tertiary,
                    action: tertiaryAction ?? {}
                )
            }
        }
    }
}

// MARK: - Icon Button

struct PremiumIconButton: View {
    let icon: String
    let style: PremiumButtonStyle
    let size: CGFloat
    let action: () -> Void
    @State private var isPressed = false

    init(
        icon: String,
        style: PremiumButtonStyle = .primary,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: size, height: size)
                .background(iconBackground)
                .overlay(iconBorder)
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(color: LuxuryColorPalette.Shadow.subtle.color, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
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
        }
    }

    private var iconColor: Color {
        switch style {
        case .primary:
            return LuxuryColorPalette.midnightBlack
        case .secondary:
            return LuxuryColorPalette.pearlWhite
        case .tertiary:
            return LuxuryColorPalette.softGold
        case .luxury:
            return LuxuryColorPalette.softGold
        }
    }

    @ViewBuilder
    private var iconBackground: some View {
        switch style {
        case .primary:
            Circle().fill(LuxuryColorPalette.primaryButton)
        case .secondary:
            Circle().fill(LuxuryColorPalette.secondaryButton)
        case .tertiary:
            Circle().fill(Color.clear)
        case .luxury:
            Circle().fill(LuxuryColorPalette.midnightBlack)
        }
    }

    @ViewBuilder
    private var iconBorder: some View {
        switch style {
        case .tertiary:
            Circle().stroke(LuxuryColorPalette.softGold, lineWidth: 2)
        case .luxury:
            Circle().stroke(LuxuryColorPalette.softGold.opacity(0.5), lineWidth: 1)
        default:
            EmptyView()
        }
    }
}

// MARK: - Floating Action Button

struct PremiumFloatingActionButton: View {
    let icon: String
    let action: () -> Void
    @State private var isExpanded = false

    var body: some View {
        ZStack {
            // Floating button
            PremiumIconButton(
                icon: icon,
                style: .primary,
                size: 56
            ) {
                withAnimation(LuxuryAnimation.gentleSpring) {
                    isExpanded.toggle()
                }
                action()
            }
            .shadow(color: LuxuryColorPalette.Shadow.heavy.color, radius: 16, x: 0, y: 8)
        }
    }
}

// MARK: - Preview

struct PremiumButton_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVStack(spacing: LuxurySpacing.lg) {
                VStack(spacing: LuxurySpacing.md) {
                    Text("Button Styles")
                        .font(LuxuryTypography.title)
                        .foregroundColor(LuxuryColorPalette.textPrimary)

                    PremiumButton(title: "Primary Button", style: .primary, action: {})
                    PremiumButton(title: "Secondary Button", style: .secondary, action: {})
                    PremiumButton(title: "Tertiary Button", style: .tertiary, action: {})
                    PremiumButton(title: "Luxury Button", style: .luxury, action: {})

                    HStack(spacing: LuxurySpacing.sm) {
                        PremiumIconButton(icon: "heart.fill", style: .primary, action: {})
                        PremiumIconButton(icon: "star.fill", style: .secondary, action: {})
                        PremiumIconButton(icon: "plus", style: .tertiary, action: {})
                    }
                }

                VStack(spacing: LuxurySpacing.md) {
                    Text("Loading States")
                        .font(LuxuryTypography.title)
                        .foregroundColor(LuxuryColorPalette.textPrimary)

                    PremiumButton(title: "Loading", style: .primary, isLoading: true, action: {})
                    PremiumButton(title: "Disabled", style: .secondary, isDisabled: true, action: {})
                }

                VStack(spacing: LuxurySpacing.md) {
                    Text("Button Groups")
                        .font(LuxuryTypography.title)
                        .foregroundColor(LuxuryColorPalette.textPrimary)

                    PremiumButtonGroup(
                        primaryTitle: "Book Now",
                        secondaryTitle: "Learn More",
                        tertiaryTitle: "Save for Later",
                        primaryAction: {},
                        secondaryAction: {},
                        tertiaryAction: {}
                    )
                }

                VStack(spacing: LuxurySpacing.md) {
                    Text("Specialized Buttons")
                        .font(LuxuryTypography.title)
                        .foregroundColor(LuxuryColorPalette.textPrimary)

                    CallToActionButton(
                        title: "Start Planning",
                        subtitle: "Begin your luxury journey today",
                        action: {}
                    )

                    OutlinedActionView(title: "View Details", icon: "info.circle", action: {})

                    LuxuryActionButton(title: "Premium Experience", action: {})
                }
            }
            .padding(LuxurySpacing.md)
        }
        .background(LuxuryColorPalette.warmWhite)
        .previewDisplayName("Premium Buttons")
    }
}