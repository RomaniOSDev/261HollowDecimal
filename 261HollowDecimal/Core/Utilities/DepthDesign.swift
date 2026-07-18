import SwiftUI

/// Lightweight depth tokens — one soft shadow max, no blur, no animated backgrounds.
enum AppDepth {
    static let cardRadius: CGFloat = 18
    static let chipRadius: CGFloat = 12

    static let raisedShadow = ShadowSpec(colorOpacity: 0.30, radius: 8, y: 4)
    static let floatingShadow = ShadowSpec(colorOpacity: 0.38, radius: 12, y: 6)
    static let buttonShadow = ShadowSpec(colorOpacity: 0.28, radius: 6, y: 3)

    struct ShadowSpec {
        let colorOpacity: Double
        let radius: CGFloat
        let y: CGFloat
    }
}

struct ElevatedPanelBackground: View {
    var cornerRadius: CGFloat = AppDepth.cardRadius
    var elevated: Bool = true

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color("AppSurface"),
                        Color("AppSurface").opacity(0.92),
                        Color("AppBackground").opacity(0.55)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color("AppTextPrimary").opacity(0.14),
                                Color("AppTextSecondary").opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .modifier(OptionalElevation(enabled: elevated, spec: AppDepth.raisedShadow))
    }
}

private struct OptionalElevation: ViewModifier {
    let enabled: Bool
    let spec: AppDepth.ShadowSpec

    func body(content: Content) -> some View {
        if enabled {
            content.shadow(
                color: Color("AppBackground").opacity(spec.colorOpacity),
                radius: spec.radius,
                x: 0,
                y: spec.y
            )
        } else {
            content
        }
    }
}

extension View {
    func clearScrollBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.clear)
    }

    func transparentScreenChrome() -> some View {
        background(Color.clear)
    }

    /// Single soft elevation — prefer this over stacking multiple shadows.
    func appRaised(_ enabled: Bool = true) -> some View {
        modifier(OptionalElevation(enabled: enabled, spec: AppDepth.raisedShadow))
    }

    func appFloating(_ enabled: Bool = true) -> some View {
        modifier(OptionalElevation(enabled: enabled, spec: AppDepth.floatingShadow))
    }

    func appButtonDepth() -> some View {
        modifier(OptionalElevation(enabled: true, spec: AppDepth.buttonShadow))
    }
}
