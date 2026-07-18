import Foundation
import Combine

final class DestinationsViewModel: ObservableObject {
    @Published var showEditor = false
    @Published var editingDestination: Destination?
    @Published var expandedID: UUID?
    @Published var nameInput = ""
    @Published var countryInput = ""
    @Published var noteInput = ""
    @Published var plannedDate = Date()
    @Published var usePlannedDate = false
    @Published var nameError = false
    @Published var shakeTrigger: CGFloat = 0
    @Published var pulsedID: UUID?

    private weak var store: AppDataStore?

    func bind(store: AppDataStore) {
        self.store = store
    }

    func openAdd() {
        FeedbackService.lightTap()
        editingDestination = nil
        nameInput = ""
        countryInput = ""
        noteInput = ""
        plannedDate = Date()
        usePlannedDate = false
        nameError = false
        showEditor = true
    }

    func openEdit(_ destination: Destination) {
        FeedbackService.lightTap()
        editingDestination = destination
        nameInput = destination.name
        countryInput = destination.country
        noteInput = destination.note
        if let date = destination.plannedDate {
            plannedDate = date
            usePlannedDate = true
        } else {
            plannedDate = Date()
            usePlannedDate = false
        }
        nameError = false
        showEditor = true
    }

    func save() {
        let trimmedName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            FeedbackService.warning()
            nameError = true
            shakeTrigger += 1
            return
        }
        guard let store else { return }

        let country = countryInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let flag = CountryFlags.flag(for: country.isEmpty ? trimmedName : country)
        let note = noteInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let date = usePlannedDate ? plannedDate : nil

        if var existing = editingDestination {
            existing.name = trimmedName
            existing.country = country.isEmpty ? "Worldwide" : country
            existing.flagEmoji = flag
            existing.note = note
            existing.plannedDate = date
            store.updateDestination(existing)
            FeedbackService.destinationSaved()
            FeedbackService.success()
            store.flashSuccessCheckmark()
        } else {
            let destination = Destination(
                name: trimmedName,
                country: country.isEmpty ? "Worldwide" : country,
                flagEmoji: flag,
                note: note,
                plannedDate: date
            )
            store.addDestination(destination)
            FeedbackService.destinationSaved()
            FeedbackService.success()
            store.flashSuccessCheckmark()
            pulse(destination.id)
        }

        showEditor = false
    }

    func toggleVisited(_ destination: Destination) {
        guard let store else { return }
        var updated = destination
        updated.visited.toggle()
        store.updateDestination(updated)
        if updated.visited {
            FeedbackService.success()
            pulse(destination.id)
        } else {
            FeedbackService.lightTap()
        }
    }

    func delete(_ destination: Destination) {
        FeedbackService.lightTap()
        store?.deleteDestination(id: destination.id)
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
