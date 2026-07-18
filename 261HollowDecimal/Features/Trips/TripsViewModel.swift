import Foundation
import Combine

final class TripsViewModel: ObservableObject {
    @Published var showEditor = false
    @Published var editingTrip: Trip?
    @Published var titleInput = ""
    @Published var startDate = Date()
    @Published var endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @Published var budgetInput = ""
    @Published var notesInput = ""
    @Published var selectedDestinationIDs: Set<UUID> = []
    @Published var titleError = false
    @Published var shakeTrigger: CGFloat = 0

    private weak var store: AppDataStore?

    func bind(store: AppDataStore) {
        self.store = store
    }

    func openAdd() {
        FeedbackService.lightTap()
        editingTrip = nil
        titleInput = ""
        startDate = Date()
        endDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        budgetInput = ""
        notesInput = ""
        selectedDestinationIDs = []
        titleError = false
        showEditor = true
    }

    func openEdit(_ trip: Trip) {
        FeedbackService.lightTap()
        editingTrip = trip
        titleInput = trip.title
        startDate = trip.startDate
        endDate = trip.endDate
        budgetInput = trip.budgetLimit > 0 ? String(format: "%.0f", trip.budgetLimit) : ""
        notesInput = trip.notes
        selectedDestinationIDs = Set(trip.destinationIDs)
        titleError = false
        showEditor = true
    }

    func save() {
        let title = titleInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            FeedbackService.warning()
            titleError = true
            shakeTrigger += 1
            return
        }
        guard let store else { return }

        let budget = Double(budgetInput.replacingOccurrences(of: ",", with: ".")) ?? 0
        let safeEnd = max(endDate, startDate)

        if var existing = editingTrip {
            let dateChanged = existing.startDate != startDate || existing.endDate != safeEnd
            existing.title = title
            existing.startDate = startDate
            existing.endDate = safeEnd
            existing.budgetLimit = max(budget, 0)
            existing.notes = notesInput.trimmingCharacters(in: .whitespacesAndNewlines)
            existing.destinationIDs = Array(selectedDestinationIDs)
            store.updateTrip(existing)
            if dateChanged {
                store.regenerateDayPlans(for: existing.id)
            }
        } else {
            let trip = Trip(
                title: title,
                startDate: startDate,
                endDate: safeEnd,
                budgetLimit: max(budget, 0),
                notes: notesInput.trimmingCharacters(in: .whitespacesAndNewlines),
                destinationIDs: Array(selectedDestinationIDs)
            )
            store.addTrip(trip)
        }

        FeedbackService.mediumTap()
        FeedbackService.success()
        store.flashSuccessCheckmark()
        showEditor = false
    }
}
