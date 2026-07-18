import SwiftUI
import UIKit
import StoreKit

struct SettingsView: View {
    let bottomInset: CGFloat

    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 18) {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Your Activity")
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))

                                LazyVGrid(
                                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                                    spacing: 10
                                ) {
                                    settingsTile("Trips", "\(store.tripsCreated)", "airplane")
                                    settingsTile("Finished", "\(store.tripsFinished)", "flag.checkered")
                                    settingsTile("Entries", "\(store.destinationsAdded + store.travelItems.count)", "square.stack.3d.up")
                                    settingsTile("Minutes", "\(store.totalMinutesUsed)", "clock.fill")
                                    settingsTile("Streak", "\(store.streakDays)d", "flame.fill")
                                    settingsTile("Sessions", "\(store.totalSessionsCompleted)", "bolt.fill")
                                }
                            }
                        }

                        NavigationLink {
                            StatsView(bottomInset: bottomInset, embedInNavigation: false)
                        } label: {
                            HStack(spacing: 12) {
                                IconBadge(systemName: "trophy.fill", size: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Achievements")
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Text("Travel milestones and badges")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                                Spacer()
                                Text("\(store.achievementsUnlocked.count)/\(AchievementCatalog.all.count)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("AppAccent"))
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                            .padding(14)
                            .background(ElevatedPanelBackground())
                        }
                        .buttonStyle(SoftPressStyle())

                        VStack(spacing: 0) {
                            SettingsRowCell(title: "Rate Us", systemImage: "star.fill") {
                                FeedbackService.lightTap()
                                rateApp()
                            }
                            Divider().background(Color("AppTextSecondary").opacity(0.2)).padding(.leading, 62)
                            SettingsRowCell(title: "Privacy", systemImage: "hand.raised.fill") {
                                FeedbackService.lightTap()
                                openLink(.privacyPolicy)
                            }
                            Divider().background(Color("AppTextSecondary").opacity(0.2)).padding(.leading, 62)
                            SettingsRowCell(title: "Terms", systemImage: "doc.plaintext") {
                                FeedbackService.lightTap()
                                openLink(.termsOfUse)
                            }
                            Divider().background(Color("AppTextSecondary").opacity(0.2)).padding(.leading, 62)
                            SettingsRowCell(title: "Reset All Data", systemImage: "trash", destructive: true) {
                                FeedbackService.lightTap()
                                showResetAlert = true
                            }
                        }
                        .background(ElevatedPanelBackground())

                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, bottomInset + 24)
                }
                .clearScrollBackground()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {
                    FeedbackService.lightTap()
                }
                Button("Reset", role: .destructive) {
                    FeedbackService.warning()
                    store.resetAllData()
                }
            } message: {
                Text("This will permanently delete trips, destinations, packing lists, documents, pocket data, and achievements on this device.")
            }
        }
        .background(Color.clear)
    }

    private func settingsTile(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack(spacing: 10) {
            IconBadge(systemName: icon, size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(InsetPanelBackground(cornerRadius: 12))
    }

    private func openLink(_ link: AppLinks) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
