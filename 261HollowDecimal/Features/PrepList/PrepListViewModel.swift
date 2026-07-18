import Foundation
import Combine

final class PrepListViewModel: ObservableObject {
    @Published var showEditor = false
    @Published var showTemplates = false
    @Published var editingItem: TravelItem?
    @Published var nameInput = ""
    @Published var selectedCategory: PrepCategory = .essentials
    @Published var collapsedCategories: Set<PrepCategory> = []
    @Published var nameError = false
    @Published var shakeTrigger: CGFloat = 0
    @Published var pulsedID: UUID?

    private weak var store: AppDataStore?

    var activeTripID: UUID? {
        store?.selectedPrepTripID
    }

    func bind(store: AppDataStore) {
        self.store = store
    }

    func openAdd() {
        FeedbackService.lightTap()
        editingItem = nil
        nameInput = ""
        selectedCategory = .essentials
        nameError = false
        showEditor = true
    }

    func openTemplates() {
        FeedbackService.lightTap()
        showTemplates = true
    }

    func openEdit(_ item: TravelItem) {
        FeedbackService.lightTap()
        editingItem = item
        nameInput = item.name
        selectedCategory = item.category
        nameError = false
        showEditor = true
    }

    func save() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            FeedbackService.warning()
            nameError = true
            shakeTrigger += 1
            return
        }
        guard let store else { return }

        if var existing = editingItem {
            existing.name = trimmed
            existing.category = selectedCategory
            store.updateTravelItem(existing)
            FeedbackService.mediumTap()
            FeedbackService.success()
            store.flashSuccessCheckmark()
        } else {
            let item = TravelItem(
                name: trimmed,
                category: selectedCategory,
                tripID: store.selectedPrepTripID
            )
            store.addTravelItem(item)
            FeedbackService.mediumTap()
            FeedbackService.success()
            store.flashSuccessCheckmark()
            pulse(item.id)
        }
        showEditor = false
    }

    func applyTemplate(_ template: PackingTemplate) {
        guard let store else { return }
        store.applyPackingTemplate(template, tripID: store.selectedPrepTripID)
        FeedbackService.mediumTap()
        FeedbackService.success()
        store.flashSuccessCheckmark()
        showTemplates = false
    }

    func toggleComplete(_ item: TravelItem) {
        guard let store else { return }
        var updated = item
        updated.completed.toggle()
        store.updateTravelItem(updated)
        if updated.completed {
            FeedbackService.itemCompleted()
            FeedbackService.success()
            pulse(item.id)
        } else {
            FeedbackService.lightTap()
        }
    }

    func delete(_ item: TravelItem) {
        FeedbackService.lightTap()
        store?.deleteTravelItem(id: item.id)
    }

    func toggleCollapse(_ category: PrepCategory) {
        FeedbackService.lightTap()
        if collapsedCategories.contains(category) {
            collapsedCategories.remove(category)
        } else {
            collapsedCategories.insert(category)
        }
    }

    func items(for category: PrepCategory) -> [TravelItem] {
        guard let store else { return [] }
        return store.items(for: store.selectedPrepTripID)
            .filter { $0.category == category }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private func pulse(_ id: UUID) {
        pulsedID = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            if self?.pulsedID == id {
                self?.pulsedID = nil
            }
        }
    }
}
