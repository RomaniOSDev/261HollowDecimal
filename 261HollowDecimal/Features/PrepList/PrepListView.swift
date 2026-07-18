import SwiftUI

struct PrepListView: View {
    let bottomInset: CGFloat
    var embedInNavigation: Bool = true

    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = PrepListViewModel()

    private var scopedItems: [TravelItem] {
        store.items(for: store.selectedPrepTripID)
    }

    private var linkedTripTitle: String {
        if let id = store.selectedPrepTripID,
           let trip = store.trips.first(where: { $0.id == id }) {
            return trip.title
        }
        return "General list"
    }

    private var completedCount: Int {
        scopedItems.filter(\.completed).count
    }

    var body: some View {
        Group {
            if embedInNavigation {
                NavigationStack { content }
            } else {
                content
            }
        }
        .onAppear { viewModel.bind(store: store) }
        .onReceive(NotificationCenter.default.publisher(for: .prepListAddRequested)) { _ in
            viewModel.openAdd()
        }
        .onReceive(NotificationCenter.default.publisher(for: .prepListTemplateRequested)) { _ in
            viewModel.openTemplates()
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
                VStack(spacing: 14) {
                    tripFilterBar

                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Packing progress")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Spacer()
                                Text("\(completedCount)/\(scopedItems.count)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color("AppAccent"))
                            }
                            AppProgressBar(
                                progress: scopedItems.isEmpty ? 0 : Double(completedCount) / Double(scopedItems.count),
                                height: 10
                            )
                            HStack(spacing: 8) {
                                Button("Templates") { viewModel.openTemplates() }
                                    .buttonStyle(SecondaryButtonStyle())
                                Button("Add Item") { viewModel.openAdd() }
                                    .buttonStyle(PrimaryButtonStyle())
                            }
                        }
                    }

                    if scopedItems.isEmpty {
                        EmptyStateView(
                            symbolName: "suitcase.fill",
                            message: "No items yet! Start packing by adding your first essential or generate a template.",
                            actionTitle: "Browse Templates",
                            action: { viewModel.openTemplates() }
                        )
                    } else {
                        ForEach(PrepCategory.allCases) { category in
                            let items = viewModel.items(for: category)
                            if !items.isEmpty || !viewModel.collapsedCategories.contains(category) {
                                categorySection(category, items: items)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, bottomInset + 24)
            }
            .clearScrollBackground()
        }
        .navigationTitle(embedInNavigation ? "Travel Prep List" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if embedInNavigation {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Templates") { viewModel.openTemplates() }
                        .foregroundStyle(Color("AppAccent"))
                        .frame(minHeight: 44)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Item") { viewModel.openAdd() }
                        .foregroundStyle(Color("AppAccent"))
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $viewModel.showEditor) {
            PrepItemEditorSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showTemplates) {
            PackingTemplatesSheet(viewModel: viewModel)
        }
    }

    private var tripFilterBar: some View {
        Menu {
            Button("General list") {
                FeedbackService.lightTap()
                store.selectedPrepTripID = nil
            }
            ForEach(store.trips) { trip in
                Button(trip.title) {
                    FeedbackService.lightTap()
                    store.selectedPrepTripID = trip.id
                }
            }
        } label: {
            HStack {
                IconBadge(systemName: "link", size: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Packing for")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(linkedTripTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(12)
            .background(cellSurface)
        }
    }

    private func categorySection(_ category: PrepCategory, items: [TravelItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.toggleCollapse(category)
                }
            } label: {
                HStack {
                    IconBadge(systemName: category.symbolName, size: 34)
                    Text(category.rawValue)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Text("\(items.filter(\.completed).count)/\(items.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Image(systemName: viewModel.collapsedCategories.contains(category) ? "chevron.right" : "chevron.down")
                        .foregroundStyle(Color("AppTextSecondary"))
                        .font(.caption)
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if !viewModel.collapsedCategories.contains(category) {
                LazyVStack(spacing: 8) {
                    ForEach(items) { item in
                        PrepItemCell(
                            item: item,
                            pulsed: viewModel.pulsedID == item.id,
                            onToggle: { viewModel.toggleComplete(item) },
                            onEdit: { viewModel.openEdit(item) },
                            onDelete: { viewModel.delete(item) }
                        )
                    }
                }
            }
        }
        .padding(12)
        .background(cellSurface)
    }
}

private var cellSurface: some View {
    ElevatedPanelBackground(elevated: false)
}

private struct PrepItemEditorSheet: View {
    @ObservedObject var viewModel: PrepListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Item name", text: $viewModel.nameInput)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .modifier(ShakeEffect(animatableData: viewModel.shakeTrigger))
                        if viewModel.nameError {
                            Text("Please enter an item name.")
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.9))
                        }
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            ForEach(PrepCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .tint(Color("AppAccent"))
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(viewModel.editingItem == nil ? "Add Item" : "Edit Item")
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

private struct PackingTemplatesSheet: View {
    @ObservedObject var viewModel: PrepListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 12) {
                        Text("Generate a starter packing list, then edit it for your trip.")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(PackingTemplate.allCases) { template in
                            TemplateCell(template: template) {
                                viewModel.applyTemplate(template)
                            }
                        }
                    }
                    .padding(16)
                }
                .clearScrollBackground()
            }
            .navigationTitle("Packing Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}
