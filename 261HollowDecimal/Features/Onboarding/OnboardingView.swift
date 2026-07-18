import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var page = 0

    private let pages: [OnboardingPageModel] = [
        OnboardingPageModel(
            headline: "Plan Your Trip",
            detail: "Organize your upcoming journeys efficiently.",
            symbol: "airplane.departure",
            imageName: "home_hero",
            accentLabel: "Trip Planner"
        ),
        OnboardingPageModel(
            headline: "Add Destinations",
            detail: "Easily add places to your wishlist to track future trips.",
            symbol: "mappin.and.ellipse",
            imageName: "home_map",
            accentLabel: "Wishlist"
        ),
        OnboardingPageModel(
            headline: "Get Started",
            detail: "Begin by adding your first destination now.",
            symbol: "flag.checkered",
            imageName: "home_pack",
            accentLabel: "Ready to go"
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPage(
                            model: pages[index],
                            isVisible: page == index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: page)

                bottomControls
            }
        }
        .preferredColorScheme(.dark)
    }

    private var bottomControls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == page
                            ? LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color("AppTextSecondary").opacity(0.35),
                                    Color("AppTextSecondary").opacity(0.2)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: index == page ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: page)
                }
            }

            Button {
                FeedbackService.lightTap()
                if page < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        page += 1
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        store.hasSeenOnboarding = true
                    }
                }
            } label: {
                Text(page < pages.count - 1 ? "Next" : "Get Started")
            }
            .buttonStyle(PrimaryButtonStyle())

            if page < pages.count - 1 {
                Button {
                    FeedbackService.lightTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        store.hasSeenOnboarding = true
                    }
                } label: {
                    Text("Skip for now")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(height: 44)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 28)
        .background(
            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.05),
                    Color("AppBackground").opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

private struct OnboardingPageModel {
    let headline: String
    let detail: String
    let symbol: String
    let imageName: String
    let accentLabel: String
}

private struct OnboardingPage: View {
    let model: OnboardingPageModel
    let isVisible: Bool

    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroCard
                    .scaleEffect(appeared ? 1 : 0.94)
                    .opacity(appeared ? 1 : 0)

                contentCard
                    .offset(y: appeared ? 0 : 18)
                    .opacity(appeared ? 1 : 0)

                featureHints
                    .opacity(appeared ? 1 : 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 12)
        }
        .clearScrollBackground()
        .onChange(of: isVisible) { visible in
            if visible {
                animateIn()
            } else {
                appeared = false
            }
        }
        .onAppear {
            if isVisible {
                animateIn()
            }
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image(model.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipped()

            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.05),
                    Color("AppBackground").opacity(0.55),
                    Color("AppBackground").opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    IconBadge(systemName: model.symbol, size: 42)
                    StatusChip(text: model.accentLabel)
                }

                Text(model.headline)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color("AppTextPrimary").opacity(0.18),
                            Color("AppTextSecondary").opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .appRaised()
    }

    private var contentCard: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(model.detail)
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    MetricChip(icon: model.symbol, text: "Guided setup")
                    MetricChip(icon: "checkmark.seal.fill", text: "Local only")
                }
            }
        }
    }

    private var featureHints: some View {
        HStack(spacing: 10) {
            hintTile(icon: "calendar", title: "Days")
            hintTile(icon: "dollarsign.circle", title: "Budget")
            hintTile(icon: "suitcase.fill", title: "Pack")
        }
    }

    private func hintTile(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            IconBadge(systemName: icon, size: 36)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(InsetPanelBackground(cornerRadius: 16))
    }

    private func animateIn() {
        appeared = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            appeared = true
        }
    }
}
