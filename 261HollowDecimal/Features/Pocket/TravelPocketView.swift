import SwiftUI
import UIKit

struct TravelPocketView: View {
    let bottomInset: CGFloat
    var embedInNavigation: Bool = true

    @EnvironmentObject private var store: AppDataStore
    @State private var section: PocketSection = .phrases

    private enum PocketSection: String, CaseIterable, Identifiable {
        case phrases = "Phrases"
        case emergency = "Emergency"
        case currency = "Currency"

        var id: String { rawValue }
    }

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

            VStack(spacing: 0) {
                Picker("Section", selection: $section) {
                    ForEach(PocketSection.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .onChange(of: section) { _ in
                    FeedbackService.lightTap()
                }

                Group {
                    switch section {
                    case .phrases:
                        PhrasesPane(bottomInset: bottomInset)
                    case .emergency:
                        EmergencyCardPane(bottomInset: bottomInset)
                    case .currency:
                        CurrencyView(bottomInset: bottomInset, embedInNavigation: false)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(embedInNavigation ? "Travel Pocket" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

private struct PhrasesPane: View {
    let bottomInset: CGFloat
    @EnvironmentObject private var store: AppDataStore
    @State private var scenario = PhraseCatalog.scenarios[0]
    @State private var copiedID: String?

    private var phrases: [TravelPhrase] {
        PhraseCatalog.all.filter { $0.scenario == scenario }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                SurfaceCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick phrases")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Tap any card to copy. Useful at airports, hotels, restaurants, and emergencies.")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PhraseCatalog.scenarios, id: \.self) { item in
                            FilterChip(title: item, selected: scenario == item) {
                                FeedbackService.lightTap()
                                scenario = item
                            }
                        }
                    }
                }

                LazyVStack(spacing: 10) {
                    ForEach(phrases) { phrase in
                        PhraseCell(phrase: phrase, copied: copiedID == phrase.id) {
                            UIPasteboard.general.string = phrase.phrase
                            store.registerPhraseCopy()
                            FeedbackService.lightTap()
                            FeedbackService.success()
                            copiedID = phrase.id
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                if copiedID == phrase.id { copiedID = nil }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, bottomInset + 24)
        }
        .clearScrollBackground()
    }
}

private struct EmergencyCardPane: View {
    let bottomInset: CGFloat
    @EnvironmentObject private var store: AppDataStore
    @State private var bloodType = ""
    @State private var allergies = ""
    @State private var contactName = ""
    @State private var contactPhone = ""
    @State private var notes = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                SurfaceCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            IconBadge(systemName: "cross.case.fill")
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Emergency Card")
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text("Stored only on this device")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }

                        field("Blood type", text: $bloodType)
                        field("Allergies", text: $allergies)
                        field("Emergency contact name", text: $contactName)
                        field("Emergency contact phone", text: $contactPhone)
                        field("Notes", text: $notes, axis: true)

                        Button {
                            let card = EmergencyCard(
                                bloodType: bloodType,
                                allergies: allergies,
                                emergencyContactName: contactName,
                                emergencyContactPhone: contactPhone,
                                notes: notes
                            )
                            store.saveEmergencyCard(card)
                            FeedbackService.mediumTap()
                            FeedbackService.success()
                            store.flashSuccessCheckmark()
                        } label: {
                            Text("Save Emergency Card")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, bottomInset + 24)
        }
        .clearScrollBackground()
        .onAppear {
            bloodType = store.emergencyCard.bloodType
            allergies = store.emergencyCard.allergies
            contactName = store.emergencyCard.emergencyContactName
            contactPhone = store.emergencyCard.emergencyContactPhone
            notes = store.emergencyCard.notes
        }
    }

    private func field(_ title: String, text: Binding<String>, axis: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            Group {
                if axis {
                    TextField(title, text: text, axis: .vertical)
                        .lineLimit(3...6)
                } else {
                    TextField(title, text: text)
                }
            }
            .padding(12)
            .background(Color("AppBackground").opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .foregroundStyle(Color("AppTextPrimary"))
        }
    }
}
