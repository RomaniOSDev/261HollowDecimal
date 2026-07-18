import SwiftUI

struct TripsView: View {
    let bottomInset: CGFloat
    var embedInParentNavigation: Bool = false

    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = TripsViewModel()
    @State private var statusFilter: TripStatus? = nil

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private var filteredTrips: [Trip] {
        guard let statusFilter else { return store.trips }
        return store.trips.filter { $0.status == statusFilter }
    }

    var body: some View {
        Group {
            if embedInParentNavigation {
                tripsContent
            } else {
                NavigationStack { tripsContent }
            }
        }
        .background(Color.clear)
    }

    private var tripsContent: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 16) {
                    if !embedInParentNavigation {
                        overviewCard
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", selected: statusFilter == nil) {
                                FeedbackService.lightTap()
                                statusFilter = nil
                            }
                            ForEach(TripStatus.allCases) { status in
                                FilterChip(title: status.rawValue, selected: statusFilter == status) {
                                    FeedbackService.lightTap()
                                    statusFilter = status
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }

                    if filteredTrips.isEmpty {
                        EmptyStateView(
                            symbolName: "airplane.departure",
                            message: store.trips.isEmpty
                                ? "Plan your first trip — set dates, budget, and a day-by-day itinerary."
                                : "No trips match this filter.",
                            actionTitle: store.trips.isEmpty ? "Create Trip" : nil,
                            action: store.trips.isEmpty ? { viewModel.openAdd() } : nil
                        )
                    } else {
                        AppSectionHeader(
                            title: "Your Trips",
                            subtitle: "\(filteredTrips.count) shown",
                            actionTitle: "Add",
                            action: { viewModel.openAdd() }
                        )

                        LazyVStack(spacing: 12) {
                            ForEach(filteredTrips) { trip in
                                NavigationLink {
                                    TripDetailView(tripID: trip.id, bottomInset: bottomInset)
                                } label: {
                                    TripCell(
                                        trip: trip,
                                        dateText: "\(dateFormatter.string(from: trip.startDate)) – \(dateFormatter.string(from: trip.endDate))"
                                    )
                                }
                                .buttonStyle(SoftPressStyle())
                                .simultaneousGesture(TapGesture().onEnded {
                                    FeedbackService.lightTap()
                                })
                                .contextMenu {
                                    Button("Edit") { viewModel.openEdit(trip) }
                                    Button("Delete", role: .destructive) {
                                        FeedbackService.lightTap()
                                        store.deleteTrip(id: trip.id)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, bottomInset + 24)
            }
            .clearScrollBackground()

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton { viewModel.openAdd() }
                        .padding(.trailing, 20)
                        .padding(.bottom, bottomInset + 8)
                }
            }
        }
        .navigationTitle("Trips")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $viewModel.showEditor) {
            TripEditorSheet(viewModel: viewModel)
                .environmentObject(store)
        }
        .onAppear { viewModel.bind(store: store) }
    }

    private var overviewCard: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Trip Hub")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 10) {
                    overviewMetric("Planned", "\(store.trips.filter { $0.status == .planned }.count)", "calendar")
                    overviewMetric("Active", "\(store.trips.filter { $0.status == .active }.count)", "airplane")
                    overviewMetric("Done", "\(store.trips.filter { $0.status == .completed }.count)", "flag.checkered")
                }
            }
        }
    }

    private func overviewMetric(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(spacing: 8) {
            IconBadge(systemName: icon, size: 36)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(InsetPanelBackground(cornerRadius: 14))
    }
}

private struct TripEditorSheet: View {
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
                            .foregroundStyle(Color("AppTextPrimary"))
                        DatePicker("End", selection: $viewModel.endDate, displayedComponents: .date)
                            .tint(Color("AppAccent"))
                            .foregroundStyle(Color("AppTextPrimary"))
                        TextField("Budget (USD)", text: $viewModel.budgetInput)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(Color("AppTextPrimary"))
                        TextField("Notes", text: $viewModel.notesInput, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .listRowBackground(Color("AppSurface"))

                    if !store.destinations.isEmpty {
                        Section("Link destinations") {
                            ForEach(store.destinations) { destination in
                                Button {
                                    FeedbackService.lightTap()
                                    if viewModel.selectedDestinationIDs.contains(destination.id) {
                                        viewModel.selectedDestinationIDs.remove(destination.id)
                                    } else {
                                        viewModel.selectedDestinationIDs.insert(destination.id)
                                    }
                                } label: {
                                    HStack {
                                        Text("\(destination.flagEmoji) \(destination.name)")
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Spacer()
                                        if viewModel.selectedDestinationIDs.contains(destination.id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color("AppAccent"))
                                        }
                                    }
                                    .frame(minHeight: 44)
                                }
                            }
                        }
                        .listRowBackground(Color("AppSurface"))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(viewModel.editingTrip == nil ? "New Trip" : "Edit Trip")
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
                    Button("Save") { viewModel.save() }
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}
