import SwiftUI

enum AppTab: Hashable {
    case home
    case destinations
    case tools
    case settings
}

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .home

    private let tabBarClearance: CGFloat = 92

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackgroundView()

            Group {
                switch selectedTab {
                case .home:
                    HomeView(bottomInset: tabBarClearance)
                case .destinations:
                    DestinationsView(bottomInset: tabBarClearance)
                case .tools:
                    ToolsHubView(bottomInset: tabBarClearance)
                case .settings:
                    SettingsView(bottomInset: tabBarClearance)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .overlay(alignment: .top) {
            VStack(spacing: 8) {
                if let reminder = store.documentReminderText, selectedTab != .tools {
                    DocumentReminderBanner(text: reminder) {
                        FeedbackService.lightTap()
                        NotificationCenter.default.post(name: .openToolsSection, object: "docs")
                        selectedTab = .tools
                    }
                }
                if let achievement = store.pendingAchievementBanner {
                    AchievementBannerView(achievement: achievement)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, 8)
            .zIndex(20)
        }
        .overlay {
            if store.showSuccessCheckmark {
                SuccessCheckmarkOverlay()
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(30)
            }
        }
        .onAppear {
            store.startUsageTracking()
            store.evaluateAchievements()
            store.refreshDocumentReminder()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                store.startUsageTracking()
                store.refreshDocumentReminder()
            case .inactive, .background:
                store.pauseUsageTracking()
            @unknown default:
                store.pauseUsageTracking()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToTab)) { note in
            if let tab = note.object as? AppTab {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = tab
                }
            }
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(.home, title: "Home", symbol: "house.fill")
            tabItem(.destinations, title: "Places", symbol: "map.fill")
            tabItem(.tools, title: "Toolkit", symbol: "suitcase.fill")
            tabItem(.settings, title: "Settings", symbol: "gearshape.fill")
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(
            Color("AppSurface")
                .overlay(
                    LinearGradient(
                        colors: [Color("AppTextPrimary").opacity(0.08), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color("AppBackground").opacity(0.45), radius: 10, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabItem(_ tab: AppTab, title: String, symbol: String) -> some View {
        let isActive = selectedTab == tab
        return Button {
            FeedbackService.lightTap()
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isActive ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .frame(width: 44, height: 28)
                    .background(
                        Capsule()
                            .fill(isActive ? Color("AppPrimary") : Color.clear)
                            .padding(.horizontal, 8)
                    )
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isActive ? Color("AppAccent") : Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(TabPressStyle())
    }
}

private struct DocumentReminderBanner: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(Color("AppAccent"))
                Text(text)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                Text("Docs")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppPrimary"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color("AppSurface"))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}

private struct TabPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
