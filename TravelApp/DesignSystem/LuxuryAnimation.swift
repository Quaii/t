//
//  LuxuryAnimation.swift
//  Wanderlux
//
//  Created by Wanderlux Team on 11/26/2025.
//  Copyright © 2025 Wanderlux. All rights reserved.
//

import SwiftUI

struct LuxuryAnimation {
    // MARK: - Animation Durations

    /// Quick micro-interactions
    static let quick: Double = 0.15

    /// Standard button press
    static let standard: Double = 0.3

    /// Smooth transitions
    static let smooth: Double = 0.5

    /// Delux luxury transitions
    static let deluxe: Double = 0.6

    /// Long graceful animations
    static let graceful: Double = 0.8

    // MARK: - Animation Curves

    /// Natural ease-in-out for most interactions
    static let easeInOut = Animation.easeInOut(duration: standard)

    /// Quick spring for buttons
    static let springy = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)

    /// Gentle spring for luxury feel
    static let gentleSpring = Animation.spring(response: 0.8, dampingFraction: 0.9, blendDuration: 0)

    /// Smooth slide transition
    static let smoothSlide = Animation.timingCurve(0.4, 0.0, 0.2, 1.0, duration: smooth)

    /// Elegantslow transition
    static let elegantSlow = Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: deluxe)

    /// Quick bounce for attention
    static let quickBounce = Animation.interpolatingSpring(stiffness: 300, damping: 20)

    /// Fluid entrance
    static let fluidEntrance = Animation.timingCurve(0.2, 0.0, 0.0, 1.0, duration: graceful)

    // MARK: - Transition Types

    /// Elegant fade in
    static let fadeTransition = AnyTransition.opacity.combined(with: .scale(scale: 0.95))

    /// Slide up from bottom
    static let slideUpTransition = AnyTransition.move(edge: .bottom).combined(with: .opacity)

    /// Slide down from top
    static let slideDownTransition = AnyTransition.move(edge: .top).combined(with: .opacity)

    /// Slide in from leading
    static let slideInLeadingTransition = AnyTransition.move(edge: .leading).combined(with: .opacity)

    /// Slide in from trailing
    static let slideInTrailingTransition = AnyTransition.move(edge: .trailing).combined(with: .opacity)

    /// Custom scale and fade
    static let scaleFadeTransition = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.8).combined(with: .opacity),
        removal: .scale(scale: 1.1).combined(with: .opacity)
    )

    /// Gentle rotation and fade
    static let rotateFadeTransition = AnyTransition.asymmetric(
        insertion: .rotation(.degrees(-5)).combined(with: .opacity),
        removal: .rotation(.degrees(5)).combined(with: .opacity)
    )

    // MARK: - State Animations

    /// Button press animation
    struct ButtonPress {
        static let press = Animation.easeInOut(duration: quick)
        static let release = Animation.spring(response: 0.4, dampingFraction: 0.6)
        static let haptic = "light" as String

        static func perform() {
            HapticFeedback.light()
        }

        static func strong() {
            HapticFeedback.medium()
        }
    }

    /// Card selection animation
    struct CardSelection {
        static let select = Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let deselect = Animation.easeInOut(duration: standard)
        static let haptic = "selection" as String

        static func select() {
            HapticFeedback.selectionChanged()
        }
    }

    /// Tab bar animation
    struct TabBar {
        static let switchTab = Animation.spring(response: 0.6, dampingFraction: 0.9)
        static let highlight = Animation.easeInOut(duration: quick)
        static let haptic = "selection" as String
    }

    /// Modal presentation
    struct Modal {
        static let present = Animation.timingCurve(0.2, 0.0, 0.2, 1.0, duration: smooth)
        static let dismiss = Animation.timingCurve(0.4, 0.0, 0.6, 1.0, duration: standard)
        static let background = Animation.easeInOut(duration: deluxe)
    }

    /// Navigation transitions
    struct Navigation {
        static let push = Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: smooth)
        static let pop = Animation.timingCurve(0.4, 0.0, 0.6, 1.0, duration: standard)
        static let bounceBack = Animation.spring(response: 0.6, dampingFraction: 0.75)
    }

    // MARK: - Loading Animations

    struct Loading {
        static let skeleton = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        static let shimmer = Animation.linear(duration: 2.0).repeatForever(autoreverses: false)
        static let pulse = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)

        static let shimmerGradient = LinearGradient(
            colors: [
                Color.clear,
                Color.white.opacity(0.3),
                Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Success/Error Animations

    struct Success {
        static let checkmark = Animation.spring(response: 0.8, dampingFraction: 0.5)
        static let fadeIn = Animation.easeInOut(duration: smooth)
        static let celebration = Animation.spring(response: 0.6, dampingFraction: 0.4)
        static let haptic = "success" as String

        static func show() {
            HapticFeedback.success()
        }
    }

    struct Error {
        static let shake = Animation.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)
        static let fadeIn = Animation.easeInOut(duration: standard)
        static let haptic = "error" as String

        static func show() {
            HapticFeedback.error()
        }
    }

    // MARK: - Gesture Animations

    struct Swipe {
        static let reveal = Animation.timingCurve(0.3, 0.0, 0.2, 1.0, duration: standard)
        static let dismiss = Animation.timingCurve(0.4, 0.0, 0.6, 1.0, duration: smooth)
        static let snapBack = Animation.spring(response: 0.6, dampingFraction: 0.8)
    }

    struct Pan {
        static let drag = Animation.interpolatingSpring(stiffness: 200, damping: 25)
        static let settle = Animation.spring(response: 0.7, dampingFraction: 0.9)
        static let throwaway = Animation.timingCurve(0.4, 0.0, 0.2, 1.0, duration: standard)
    }

    struct Pinch {
        static let zoom = Animation.interpolatingSpring(stiffness: 300, damping: 30)
        static let minZoom = Animation.spring(response: 0.8, dampingFraction: 0.9)
        static let maxZoom = Animation.spring(response: 0.6, dampingFraction: 0.85)
    }

    // MARK: - Haptic Feedback

    struct HapticFeedback {
        static func light() {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }

        static func medium() {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }

        static func heavy() {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }

        static func selectionChanged() {
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        }

        static func success() {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }

        static func warning() {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.warning)
        }

        static func error() {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
        }
    }
}

// MARK: - Custom Animation Modifiers

extension View {
    /// Luxury button press modifier
    func luxuryButtonPress() -> some View {
        self
            .scaleEffect(1.0)
            .animation(LuxuryAnimation.ButtonPress.press, value: UUID()) // Will animate on tap
            .onTapGesture {
                LuxuryAnimation.ButtonPress.perform()
            }
    }

    /// Card hover effect modifier
    func luxuryCardHover() -> some View {
        self
            .scaleEffect(1.0)
            .shadow(color: LuxuryColorPalette.Shadow.subtle.color, radius: 8, x: 0, y: 4)
            .animation(LuxuryAnimation.easeInOut, value: UUID())
    }

    /// Elegant appearance modifier
    func elegantAppear() -> some View {
        self
            .opacity(0)
            .scaleEffect(0.95)
            .animation(LuxuryAnimation.fluidEntrance, value: true)
            .onAppear {
                withAnimation(LuxuryAnimation.fluidEntrance) {
                    // Animation will trigger
                }
            }
    }

    /// Shimmer loading effect
    func shimmerLoading(isLoading: Bool) -> some View {
        self
            .overlay(
                Rectangle()
                    .fill(LuxuryAnimation.Loading.shimmerGradient)
                    .opacity(isLoading ? 1 : 0)
                    .animation(LuxuryAnimation.Loading.shimmer, value: isLoading)
            )
            .clipped()
    }

    /// Pulse animation for active states
    func pulseActive(isActive: Bool) -> some View {
        self
            .scaleEffect(isActive ? 1.05 : 1.0)
            .opacity(isActive ? 0.9 : 1.0)
            .animation(LuxuryAnimation.Loading.pulse, value: isActive)
    }

    /// Shake animation for errors
    func shakeError(trigger: Bool) -> some View {
        self
            .offset(x: trigger ? 10 : 0)
            .animation(LuxuryAnimation.Error.shake, value: trigger)
    }

    /// Success celebration animation
    func celebrateSuccess(trigger: Bool) -> some View {
        self
            .scaleEffect(trigger ? 1.1 : 1.0)
            .rotationEffect(.degrees(trigger ? 5 : 0))
            .animation(LuxuryAnimation.Success.celebration, value: trigger)
    }

    /// Slide up from bottom
    func slideUp(isPresented: Bool) -> some View {
        self
            .offset(y: isPresented ? 0 : 100)
            .opacity(isPresented ? 1 : 0)
            .animation(LuxuryAnimation.Modal.present, value: isPresented)
    }

    /// Elegant fade transition
    func elegantFade(isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.9)
            .animation(LuxuryAnimation.elegantSlow, value: isVisible)
    }
}

// MARK: - Custom Animation Views

struct LuxuryLoadingView: View {
    @State private var rotation: Double = 0
    @State private var scale: Double = 1.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(LuxuryColorPalette.softGold.opacity(0.3), lineWidth: 2)
                .frame(width: 40, height: 40)

            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(
                        colors: [LuxuryColorPalette.softGold, LuxuryColorPalette.midnightBlack],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(LuxuryAnimation.Loading.skeleton) {
                rotation = 360
            }
            withAnimation(LuxuryAnimation.Loading.pulse) {
                scale = 1.1
            }
        }
    }
}

struct SuccessCheckmark: View {
    @State private var progress: Double = 0
    @State private var scale: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(LuxuryColorPalette.forestGreen)
                .frame(width: 60, height: 60)
                .scaleEffect(scale)

            Path { path in
                path.move(to: CGPoint(x: 20, y: 30))
                path.addLine(to: CGPoint(x: 26, y: 36))
                path.addLine(to: CGPoint(x: 40, y: 22))
            }
            .trim(from: 0, to: progress)
            .stroke(LuxuryColorPalette.pearlWhite, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .frame(width: 60, height: 60)
        }
        .onAppear {
            LuxuryAnimation.Success.show()
            withAnimation(LuxuryAnimation.Success.checkmark) {
                scale = 1.0
                progress = 1.0
            }
        }
    }
}

struct ErrorIndicator: View {
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(LuxuryColorPalette.richRed)
                .frame(width: 60, height: 60)

            VStack(spacing: 0) {
                Rectangle()
                    .fill(LuxuryColorPalette.pearlWhite)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                    .rotationEffect(.degrees(45))

                Rectangle()
                    .fill(LuxuryColorPalette.pearlWhite)
                    .frame(width: 4, height: 24)
                    .cornerRadius(2)
                    .rotationEffect(.degrees(-45))
            }
        }
        .opacity(opacity)
        .onAppear {
            LuxuryAnimation.Error.show()
            withAnimation(LuxuryAnimation.Error.fadeIn) {
                opacity = 1.0
            }
        }
    }
}