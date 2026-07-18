import SwiftUI

struct HomeView: View {
    let bottomInset: CGFloat

    @EnvironmentObject private var store: AppDataStore
    @StateObject private var tripsVM = TripsViewModel()
    @State private var showAllTrips = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private var upcomingTrip: Trip? {
        store.trips
            .filter { $0.status != .completed }
            .sorted { $0.startDate < $1.startDate }
            .first
    }

    private var recentDestinations: [Destination] {
        Array(store.destinations.prefix(4))
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        heroSection
                        quickActionsSection
                        if let trip = upcomingTrip {
                            upcomingSection(trip)
                        }
                        wishlistPreviewSection
                        tripsPreviewSection
                    }
                    .padding(.bottom, bottomInset + 28)
                }
                .clearScrollBackground()
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: TripsListScreen(bottomInset: bottomInset), isActive: $showAllTrips) {
                    EmptyView()
                }
                .hidden()
            )
            .sheet(isPresented: $tripsVM.showEditor) {
                HomeTripEditorBridge(viewModel: tripsVM)
                    .environmentObject(store)
            }
            .onAppear { tripsVM.bind(store: store) }
        }
        .background(Color.clear)
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image("home_hero")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipped()

            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.15),
                    Color("AppBackground").opacity(0.55),
                    Color("AppBackground").opacity(0.96)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                Text(greeting)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))

                Text("Ready for your\nnext journey?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)

                Text("Plan trips, pack smart, and keep documents ready — all in one place.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    Button {
                        FeedbackService.lightTap()
                        tripsVM.openAdd()
                    } label: {
                        Text("Plan a Trip")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button {
                        FeedbackService.lightTap()
                        showAllTrips = true
                    } label: {
                        Text("My Trips")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.top, 4)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    // MARK: - Quick actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Quick Actions", subtitle: "Jump into what you need")
                .padding(.horizontal, 16)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                HomeImageActionCard(
                    title: "Plan Trip",
                    subtitle: "Dates & budget",
                    imageName: "home_hero",
                    symbol: "airplane.departure"
                ) {
                    FeedbackService.lightTap()
                    tripsVM.openAdd()
                }

                HomeImageActionCard(
                    title: "Places",
                    subtitle: "Wishlist map",
                    imageName: "home_map",
                    symbol: "mappin.and.ellipse"
                ) {
                    FeedbackService.lightTap()
                    NotificationCenter.default.post(name: .switchToTab, object: AppTab.destinations)
                }

                HomeImageActionCard(
                    title: "Pack",
                    subtitle: "Checklists",
                    imageName: "home_pack",
                    symbol: "suitcase.fill"
                ) {
                    FeedbackService.lightTap()
                    NotificationCenter.default.post(name: .openToolsSection, object: "prep")
                    NotificationCenter.default.post(name: .switchToTab, object: AppTab.tools)
                }

                HomeImageActionCard(
                    title: "Documents",
                    subtitle: "Travel docs",
                    imageName: "home_docs",
                    symbol: "doc.text.fill"
                ) {
                    FeedbackService.lightTap()
                    NotificationCenter.default.post(name: .openToolsSection, object: "docs")
                    NotificationCenter.default.post(name: .switchToTab, object: AppTab.tools)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Upcoming

    private func upcomingSection(_ trip: Trip) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(
                title: "Up Next",
                subtitle: "Your nearest planned trip",
                actionTitle: "Open",
                action: { showAllTrips = true }
            )
            .padding(.horizontal, 16)

            NavigationLink {
                TripDetailView(tripID: trip.id, bottomInset: bottomInset)
            } label: {
                ZStack(alignment: .bottomLeading) {
                    Image("home_map")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 168)
                        .clipped()

                    LinearGradient(
                        colors: [Color.clear, Color("AppBackground").opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        StatusChip(text: trip.status.rawValue)
                        Text(trip.title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("\(dateFormatter.string(from: trip.startDate)) – \(dateFormatter.string(from: trip.endDate))")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))

                        if trip.budgetLimit > 0 {
                            AppProgressBar(progress: trip.budgetProgress, height: 8)
                            Text(String(format: "$%.0f of $%.0f spent", trip.totalSpent, trip.budgetLimit))
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color("AppAccent"))
                        }

                        HStack(spacing: 8) {
                            MetricChip(icon: "calendar", text: "\(trip.dayPlans.count) days")
                            MetricChip(icon: "cart", text: "\(trip.expenses.count) spends")
                        }
                    }
                    .padding(16)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color("AppTextPrimary").opacity(0.16), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .appRaised()
            }
            .buttonStyle(SoftPressStyle())
            .padding(.horizontal, 16)
            .simultaneousGesture(TapGesture().onEnded { FeedbackService.lightTap() })
        }
    }

    // MARK: - Wishlist preview

    private var wishlistPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(
                title: "Dream Places",
                subtitle: store.destinations.isEmpty ? "Add your first destination" : "\(store.destinations.count) saved",
                actionTitle: "See all",
                action: {
                    NotificationCenter.default.post(name: .switchToTab, object: AppTab.destinations)
                }
            )
            .padding(.horizontal, 16)

            if recentDestinations.isEmpty {
                EmptyStateView(
                    symbolName: "map.fill",
                    message: "Your dream destinations await... Start planning now!",
                    actionTitle: "Browse Places",
                    action: {
                        NotificationCenter.default.post(name: .switchToTab, object: AppTab.destinations)
                    }
                )
                .padding(.horizontal, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(recentDestinations) { destination in
                            HomeDestinationChip(destination: destination)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    // MARK: - Trips preview

    private var tripsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(
                title: "Recent Trips",
                subtitle: store.trips.isEmpty ? "No trips yet" : "\(store.trips.count) total",
                actionTitle: store.trips.isEmpty ? "Create" : "All",
                action: {
                    if store.trips.isEmpty {
                        tripsVM.openAdd()
                    } else {
                        showAllTrips = true
                    }
                }
            )
            .padding(.horizontal, 16)

            if store.trips.isEmpty {
                ZStack(alignment: .bottomLeading) {
                    Image("home_hero")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipped()
                        .opacity(0.55)

                    LinearGradient(
                        colors: [Color.clear, Color("AppBackground").opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create your first itinerary")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Set dates, budget, and a day-by-day plan.")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        Button("Start Planning") {
                            FeedbackService.lightTap()
                            tripsVM.openAdd()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(16)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color("AppTextPrimary").opacity(0.12), lineWidth: 1)
                )
                .appRaised()
                .padding(.horizontal, 16)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(Array(store.trips.prefix(3))) { trip in
                        NavigationLink {
                            TripDetailView(tripID: trip.id, bottomInset: bottomInset)
                        } label: {
                            TripCell(
                                trip: trip,
                                dateText: "\(dateFormatter.string(from: trip.startDate)) – \(dateFormatter.string(from: trip.endDate))"
                            )
                        }
                        .buttonStyle(SoftPressStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Supporting views

struct HomeImageActionCard: View {
    let title: String
    let subtitle: String
    let imageName: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 128)
                    .clipped()

                LinearGradient(
                    colors: [
                        Color("AppBackground").opacity(0.05),
                        Color("AppBackground").opacity(0.88)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: symbol)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                        .frame(width: 36, height: 36)
                        .background(Color("AppSurface").opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color("AppTextPrimary").opacity(0.16), Color("AppTextSecondary").opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .appRaised()
        }
        .buttonStyle(SoftPressStyle())
    }
}

struct HomeDestinationChip: View {
    let destination: Destination

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("AppBackground").opacity(0.55))
                    .frame(width: 64, height: 64)
                Text(destination.flagEmoji)
                    .font(.system(size: 34))
            }
            Text(destination.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(destination.country)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
            StatusChip(text: destination.visited ? "Visited" : "Wish", emphasized: destination.visited)
        }
        .padding(12)
        .frame(width: 132)
        .background(ElevatedPanelBackground(cornerRadius: 18, elevated: true))
    }
}

/// Bridges TripsViewModel editor sheet without exposing private TripEditorSheet.
private struct HomeTripEditorBridge: View {
    @ObservedObject var viewModel: TripsViewModel
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Trip title", text: $viewModel.titleInput)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .modifier(ShakeEffect(animatableData: viewModel.shakeTrigger))
                        if viewModel.titleError {
                            Text("Please enter a trip title.")
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.9))
                        }
                        DatePicker("Start", selection: $viewModel.startDate, displayedComponents: .date)
                            .tint(Color("AppAccent"))
                        DatePicker("End", selection: $viewModel.endDate, displayedComponents: .date)
                            .tint(Color("AppAccent"))
                        TextField("Budget (USD)", text: $viewModel.budgetInput)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(Color("AppTextPrimary"))
                        TextField("Notes", text: $viewModel.notesInput, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                    }
                    .foregroundStyle(Color("AppAccent"))
                }
            }
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .onAppear { viewModel.bind(store: store) }
    }
}

struct TripsListScreen: View {
    let bottomInset: CGFloat

    var body: some View {
        TripsView(bottomInset: bottomInset, embedInParentNavigation: true)
    }
}
