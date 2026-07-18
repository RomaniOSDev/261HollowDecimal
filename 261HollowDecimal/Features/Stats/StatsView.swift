import SwiftUI

struct StatsView: View {
    let bottomInset: CGFloat
    var embedInNavigation: Bool = true

    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Group {
            if embedInNavigation {
                NavigationStack { content }
            } else {
                content
            }
        }
    }

    private var content: some View {
        ZStack {
            if embedInNavigation {
                AppBackgroundView()
            } else {
                Color.clear
            }

            ScrollView {
                VStack(spacing: 18) {
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Travel Summary")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))

                            LazyVGrid(columns: columns, spacing: 10) {
                                summaryTile("Trips", "\(store.tripsCreated)", "airplane.departure")
                                summaryTile("Finished", "\(store.tripsFinished)", "flag.checkered")
                                summaryTile("Day plans", "\(store.dayPlansCreated)", "list.bullet.rectangle")
                                summaryTile("Templates", "\(store.packingTemplatesApplied)", "suitcase.fill")
                                summaryTile("Phrases", "\(store.phrasesCopied)", "text.bubble.fill")
                                summaryTile("Streak", "\(store.streakDays)d", "calendar.badge.checkmark")
                            }
                        }
                    }

                    AppSectionHeader(
                        title: "Achievements",
                        subtitle: "\(store.achievementsUnlocked.count)/\(AchievementCatalog.all.count) unlocked"
                    )

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(AchievementCatalog.all) { achievement in
                            AchievementCell(
                                achievement: achievement,
                                unlocked: store.achievementsUnlocked[achievement.id] != nil
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, bottomInset + 24)
            }
            .clearScrollBackground()
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func summaryTile(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(spacing: 8) {
            IconBadge(systemName: icon, size: 36)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(InsetPanelBackground(cornerRadius: 14))
    }
}
