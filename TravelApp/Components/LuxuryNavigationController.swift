//
//  LuxuryNavigationController.swift
//  Odyssée
//
//  Created by Odyssée Team on 11/26/2025.
//  Copyright © 2025 Odyssée. All rights reserved.
//

import SwiftUI

struct LuxuryNavigationController<Content: View>: View {
    let content: Content
    let title: String?
    let titleView: AnyView?
    let leftButton: NavigationButton?
    let rightButton: NavigationButton?
    let backgroundColor: Color
    let foregroundColor: Color
    let hideNavigationBar: Bool
    let largeTitle: Bool

    init(
        title: String? = nil,
        titleView: AnyView? = nil,
        leftButton: NavigationButton? = nil,
        rightButton: NavigationButton? = nil,
        backgroundColor: Color = LuxuryColorPalette.pearlWhite,
        foregroundColor: Color = LuxuryColorPalette.textPrimary,
        hideNavigationBar: Bool = false,
        largeTitle: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.titleView = titleView
        self.leftButton = leftButton
        self.rightButton = rightButton
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.hideNavigationBar = hideNavigationBar
        self.largeTitle = largeTitle
        self.content = content()
    }

    var body: some View {
        NavigationView {
            content
                .background(backgroundColor)
                .navigationTitle(titleView != nil ? "" : (title ?? ""))
                .navigationBarTitleDisplayMode(largeTitle ? .large : .inline)
                .navigationBarItems(
                    leading: leftButton?.view,
                    trailing: rightButton?.view
                )
                .toolbar {
                    if let customTitleView = titleView {
                        ToolbarItem(placement: .principal) {
                            customTitleView
                        }
                    }
                }
                .navigationBarBackButtonHidden(true) // We'll add our own back button
                .navigationBarHidden(hideNavigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(foregroundColor)
    }
}

// MARK: - Navigation Button Structure

struct NavigationButton {
    let icon: String?
    let title: String?
    let style: NavigationButtonStyle
    let action: () -> Void

    enum NavigationButtonStyle {
        case icon
        case text
        case iconWithText
        case back
    }

    init(
        icon: String? = nil,
        title: String? = nil,
        style: NavigationButtonStyle = .icon,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.style = style
        self.action = action
    }

    @ViewBuilder
    var view: some View {
        switch style {
        case .icon:
            Button(action: action) {
                Image(systemName: icon ?? "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(LuxuryColorPalette.textPrimary)
            }
            .buttonStyle(PlainButtonStyle())

        case .text:
            Button(action: action) {
                Text(title ?? "")
                    .font(LuxuryTypography.buttonLabel)
                    .foregroundColor(LuxuryColorPalette.textPrimary)
            }
            .buttonStyle(PlainButtonStyle())

        case .iconWithText:
            Button(action: action) {
                HStack(spacing: LuxurySpacing.xs) {
                    Image(systemName: icon ?? "")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(LuxuryColorPalette.textPrimary)

                    Text(title ?? "")
                        .font(LuxuryTypography.buttonLabel)
                        .foregroundColor(LuxuryColorPalette.textPrimary)
                }
            }
            .buttonStyle(PlainButtonStyle())

        case .back:
            Button(action: action) {
                HStack(spacing: LuxurySpacing.xs) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LuxuryColorPalette.textPrimary)

                    Text("Back")
                        .font(LuxuryTypography.buttonLabel)
                        .foregroundColor(LuxuryColorPalette.textPrimary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Specialized Navigation Controllers

struct LuxuryStandardNavController<Content: View>: View {
    let title: String
    let showBackButton: Bool
    let rightButton: NavigationButton?
    let onBack: (() -> Void)?
    let content: Content

    init(
        title: String,
        showBackButton: Bool = true,
        rightButton: NavigationButton? = nil,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.rightButton = rightButton
        self.onBack = onBack
        self.content = content()
    }

    var body: some View {
        LuxuryNavigationController(
            title: title,
            leftButton: showBackButton ? NavigationButton(
                style: .back,
                action: onBack ?? {}
            ) : nil,
            rightButton: rightButton,
            largeTitle: true
        ) {
            content
        }
    }
}

struct LuxuryModalNavController<Content: View>: View {
    let title: String
    let onClose: () -> Void
    let showDoneButton: Bool
    let onDone: (() -> Void)?
    let content: Content

    init(
        title: String,
        onClose: @escaping () -> Void,
        showDoneButton: Bool = false,
        onDone: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.onClose = onClose
        self.showDoneButton = showDoneButton
        self.onDone = onDone
        self.content = content()
    }

    var body: some View {
        LuxuryNavigationController(
            title: title,
            leftButton: NavigationButton(
                icon: "xmark",
                style: .icon,
                action: onClose
            ),
            rightButton: showDoneButton ? NavigationButton(
                title: "Done",
                style: .text,
                action: onDone ?? {}
            ) : nil,
            largeTitle: false
        ) {
            content
        }
    }
}

struct LuxuryTabNavController: View {
    let content: AnyView

    init(@ViewBuilder content: () -> some View) {
        self.content = AnyView(content())
    }

    var body: some View {
        TabView {
            content
        }
        .accentColor(LuxuryColorPalette.softGold)
        .onAppear {
            setupTabBarAppearance()
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(LuxuryColorPalette.pearlWhite)
        appearance.shadowColor = UIColor(LuxuryColorPalette.softShadow)

        // Normal state
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: LuxuryTypography.UIFonts.caption,
            .foregroundColor: UIColor(LuxuryColorPalette.textSecondary)
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(LuxuryColorPalette.textSecondary)

        // Selected state
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: LuxuryTypography.UIFonts.caption,
            .foregroundColor: UIColor(LuxuryColorPalette.softGold)
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(LuxuryColorPalette.softGold)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Luxury Tab Bar Item

struct LuxuryTabBarItem: View {
    let title: String
    let icon: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? LuxuryColorPalette.softGold : LuxuryColorPalette.textSecondary)

            Text(title)
                .font(LuxuryTypography.caption)
                .foregroundColor(isSelected ? LuxuryColorPalette.softGold : LuxuryColorPalette.textSecondary)
        }
    }
}

// MARK: - Navigation Links with Luxury Styling

struct LuxuryNavigationLink<Destination: View>: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let value: String?
    let destination: Destination
    let showChevron: Bool

    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        value: String? = nil,
        showChevron: Bool = true,
        @ViewBuilder destination: () -> Destination
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.value = value
        self.destination = destination()
        self.showChevron = showChevron
    }

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: LuxurySpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(LuxuryColorPalette.softGold)
                        .frame(width: 24, height: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(LuxuryTypography.listItemTitle)
                        .foregroundColor(LuxuryColorPalette.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(LuxuryTypography.listItemSubtitle)
                            .foregroundColor(LuxuryColorPalette.textSecondary)
                    }
                }

                Spacer()

                if let value = value {
                    Text(value)
                        .font(LuxuryTypography.body)
                        .foregroundColor(LuxuryColorPalette.textSecondary)
                        .padding(.trailing, LuxurySpacing.xs)
                }

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(LuxuryColorPalette.textTertiary)
                }
            }
            .padding(LuxurySpacing.sm)
            .background(LuxuryColorPalette.pearlWhite)
            .cornerRadius(LuxurySpacing.cornerRadiusSmall)
            .shadow(color: LuxuryColorPalette.Shadow.subtle.color, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Floating Navigation Button

struct FloatingNavButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: LuxurySpacing.xs) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(LuxuryColorPalette.pearlWhite)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            colors: [LuxuryColorPalette.softGold, LuxuryColorPalette.softGold.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: LuxuryColorPalette.Shadow.heavy.color, radius: 16, x: 0, y: 8)
            }
            .buttonStyle(PlainButtonStyle())

            Text(title)
                .font(LuxuryTypography.caption)
                .foregroundColor(LuxuryColorPalette.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Preview

struct LuxuryNavigationController_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Standard Navigation
            LuxuryStandardNavController(
                title: "Luxury Travel",
                rightButton: NavigationButton(
                    icon: "plus",
                    style: .icon,
                    action: {}
                )
            ) {
                ScrollView {
                    LazyVStack(spacing: LuxurySpacing.md) {
                        Text("Navigation Example")
                            .font(LuxuryTypography.title)
                            .foregroundColor(LuxuryColorPalette.textPrimary)

                        Navigation Links
                        LuxuryNavigationLink(
                            title: "Destination Details",
                            subtitle: "Monaco Grand Prix",
                            icon: "diamond.fill",
                            value: "5-Star",
                            destination: Text("Destination Detail View")
                        )

                        LuxuryNavigationLink(
                            title: "Trip Planning",
                            subtitle: "Upcoming travels",
                            icon: "calendar.badge.plus",
                            destination: Text("Trip Planning View")
                        )
                    }
                    .padding(LuxurySpacing.md)
                }
                .background(LuxuryColorPalette.warmWhite)
            }
            .previewDisplayName("Standard Navigation")

            // Tab Navigation
            LuxuryTabNavController {
                Text("Tab Content")
                    .font(LuxuryTypography.title)
                    .foregroundColor(LuxuryColorPalette.textPrimary)
                    .padding()
            }
            .previewDisplayName("Tab Navigation")

            // Modal Navigation
            LuxuryModalNavController(
                title: "Edit Trip",
                onClose: {},
                showDoneButton: true
            ) {
                Text("Modal Content")
                    .padding()
            }
            .previewDisplayName("Modal Navigation")
        }
    }
}