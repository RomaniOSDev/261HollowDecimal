import SwiftUI

struct DestinationsView: View {
    let bottomInset: CGFloat

    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = DestinationsViewModel()
    @State private var showVisitedOnly = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private var visibleDestinations: [Destination] {
        showVisitedOnly ? store.destinations.filter(\.visited) : store.destinations
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 16) {
                        SurfaceCard {
                            HStack(spacing: 12) {
                                overviewTile("Wishlist", "\(store.destinations.filter { !$0.visited }.count)", "heart.fill")
                                overviewTile("Visited", "\(store.destinations.filter(\.visited).count)", "checkmark.seal.fill")
                                overviewTile("Total", "\(store.destinations.count)", "globe.americas.fill")
                            }
                        }

                        HStack(spacing: 8) {
                            FilterChip(title: "All places", selected: !showVisitedOnly) {
                                FeedbackService.lightTap()
                                showVisitedOnly = false
                            }
                            FilterChip(title: "Visited", selected: showVisitedOnly) {
                                FeedbackService.lightTap()
                                showVisitedOnly = true
                            }
                            Spacer()
                        }

                        if visibleDestinations.isEmpty {
                            EmptyStateView(
                                symbolName: "map.fill",
                                message: "Your dream destinations await... Start planning now!",
                                actionTitle: "Add Destination",
                                action: { viewModel.openAdd() }
                            )
                        } else {
                            AppSectionHeader(
                                title: "Destinations",
                                subtitle: "Tap a card for details · long-press to edit",
                                actionTitle: "Add",
                                action: { viewModel.openAdd() }
                            )

                            LazyVStack(spacing: 12) {
                                ForEach(visibleDestinations) { destination in
                                    DestinationCell(
                                        destination: destination,
                                        plannedText: destination.plannedDate.map { "Planned: \(dateFormatter.string(from: $0))" },
                                        expanded: viewModel.expandedID == destination.id,
                                        pulsed: viewModel.pulsedID == destination.id,
                                        onToggleVisited: { viewModel.toggleVisited(destination) },
                                        onTap: {
                                            FeedbackService.lightTap()
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                if viewModel.expandedID == destination.id {
                                                    viewModel.expandedID = nil
                                                } else {
                                                    viewModel.expandedID = destination.id
                                                }
                                            }
                                        },
                                        onEdit: { viewModel.openEdit(destination) },
                                        onDelete: { viewModel.delete(destination) }
                                    )
                                    .swipeActionsCompat {
                                        viewModel.delete(destination)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, bottomInset + 80)
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
            .navigationTitle("Destinations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $viewModel.showEditor) {
                DestinationEditorSheet(viewModel: viewModel)
            }
            .onAppear { viewModel.bind(store: store) }
        }
        .background(Color.clear)
    }

    private func overviewTile(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(spacing: 8) {
            IconBadge(systemName: icon, size: 34)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(InsetPanelBackground(cornerRadius: 14))
    }
}

private extension View {
    func swipeActionsCompat(delete: @escaping () -> Void) -> some View {
        self.contextMenu {
            Button("Delete", role: .destructive, action: delete)
        }
    }
}

private struct DestinationEditorSheet: View {
    @ObservedObject var viewModel: DestinationsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Destination name", text: $viewModel.nameInput)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .modifier(ShakeEffect(animatableData: viewModel.shakeTrigger))
                        if viewModel.nameError {
                            Text("Please enter a destination name.")
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.9))
                        }
                        TextField("Country", text: $viewModel.countryInput)
                            .foregroundStyle(Color("AppTextPrimary"))
                        TextField("Note (optional)", text: $viewModel.noteInput, axis: .vertical)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(3...6)
                    }
                    .listRowBackground(Color("AppSurface"))

                    Section {
                        Toggle("Set planned date", isOn: $viewModel.usePlannedDate)
                            .tint(Color("AppAccent"))
                            .foregroundStyle(Color("AppTextPrimary"))
                        if viewModel.usePlannedDate {
                            DatePicker(
                                "Planned date",
                                selection: $viewModel.plannedDate,
                                displayedComponents: .date
                            )
                            .tint(Color("AppAccent"))
                            .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(viewModel.editingDestination == nil ? "Add Destination" : "Edit Destination")
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
