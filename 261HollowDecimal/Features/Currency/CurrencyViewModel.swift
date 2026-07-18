import Foundation
import Combine

final class CurrencyViewModel: ObservableObject {
    @Published var selectedContinent: String = ""
    @Published var selectedCode: String?
    @Published var pulsedCode: String?

    private weak var store: AppDataStore?

    func bind(store: AppDataStore) {
        self.store = store
        selectedContinent = store.selectedContinent
        if selectedContinent.isEmpty {
            // leave empty for empty state
        } else if store.currencyRates.isEmpty {
            store.loadRatesForSelectedContinent()
        }
    }

    func selectContinent(_ continent: String) {
        FeedbackService.lightTap()
        selectedContinent = continent
        store?.selectedContinent = continent
        store?.loadRatesForSelectedContinent()
    }

    func updateRates() {
        guard let store else { return }
        guard !selectedContinent.isEmpty else { return }
        store.updateRates()
        FeedbackService.ratesUpdated()
        FeedbackService.success()
        store.flashSuccessCheckmark()
    }

    func selectRow(_ rate: CurrencyRate) {
        FeedbackService.lightTap()
        selectedCode = rate.code
        pulsedCode = rate.code
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            if self?.pulsedCode == rate.code {
                self?.pulsedCode = nil
            }
        }
    }
}
