import Foundation
import Combine
import SwiftUI

final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var destinations: [Destination] {
        didSet {
            saveCodable(destinations, key: Keys.destinations)
            hasVisitedAll = !destinations.isEmpty && destinations.allSatisfy(\.visited)
        }
    }

    @Published var hasVisitedAll: Bool {
        didSet { defaults.set(hasVisitedAll, forKey: Keys.hasVisitedAll) }
    }

    @Published var destinationsAdded: Int {
        didSet { defaults.set(destinationsAdded, forKey: Keys.destinationsAdded) }
    }

    @Published var trips: [Trip] {
        didSet { saveCodable(trips, key: Keys.trips) }
    }

    @Published var tripsCreated: Int {
        didSet { defaults.set(tripsCreated, forKey: Keys.tripsCreated) }
    }

    @Published var tripsFinished: Int {
        didSet { defaults.set(tripsFinished, forKey: Keys.tripsFinished) }
    }

    @Published var budgetKeptCount: Int {
        didSet { defaults.set(budgetKeptCount, forKey: Keys.budgetKeptCount) }
    }

    @Published var dayPlansCreated: Int {
        didSet { defaults.set(dayPlansCreated, forKey: Keys.dayPlansCreated) }
    }

    @Published var travelItems: [TravelItem] {
        didSet {
            saveCodable(travelItems, key: Keys.travelItems)
            lastUpdated = Date()
        }
    }

    @Published var lastUpdated: Date {
        didSet { defaults.set(lastUpdated, forKey: Keys.lastUpdated) }
    }

    @Published var checklistsCompleted: Int {
        didSet { defaults.set(checklistsCompleted, forKey: Keys.checklistsCompleted) }
    }

    @Published var packingTemplatesApplied: Int {
        didSet { defaults.set(packingTemplatesApplied, forKey: Keys.packingTemplatesApplied) }
    }

    @Published var selectedPrepTripID: UUID? {
        didSet {
            if let id = selectedPrepTripID {
                defaults.set(id.uuidString, forKey: Keys.selectedPrepTripID)
            } else {
                defaults.removeObject(forKey: Keys.selectedPrepTripID)
            }
        }
    }

    @Published var documents: [TravelDocument] {
        didSet { saveCodable(documents, key: Keys.documents) }
    }

    @Published var docsReadyUnlocked: Bool {
        didSet { defaults.set(docsReadyUnlocked, forKey: Keys.docsReadyUnlocked) }
    }

    @Published var emergencyCard: EmergencyCard {
        didSet { saveCodable(emergencyCard, key: Keys.emergencyCard) }
    }

    @Published var phrasesCopied: Int {
        didSet { defaults.set(phrasesCopied, forKey: Keys.phrasesCopied) }
    }

    @Published var pocketReadyUnlocked: Bool {
        didSet { defaults.set(pocketReadyUnlocked, forKey: Keys.pocketReadyUnlocked) }
    }

    @Published var selectedContinent: String {
        didSet { defaults.set(selectedContinent, forKey: Keys.selectedContinent) }
    }

    @Published var currencyRates: [CurrencyRate] {
        didSet { saveCodable(currencyRates, key: Keys.currencyRates) }
    }

    @Published var ratesLastUpdated: Date? {
        didSet { defaults.set(ratesLastUpdated, forKey: Keys.ratesLastUpdated) }
    }

    @Published var tripsCompleted: Int {
        didSet {
            defaults.set(tripsCompleted, forKey: Keys.tripsCompleted)
            totalSessionsCompleted = tripsCompleted
        }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet { defaults.set(lastActivityDate, forKey: Keys.lastActivityDate) }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveCodable(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }

    @Published var pendingAchievementBanner: AchievementDefinition?
    @Published var showSuccessCheckmark = false
    @Published var documentReminderText: String?

    private let defaults = UserDefaults.standard
    private var achievementQueue: [AchievementDefinition] = []
    private var isShowingBanner = false
    private var sessionAccumulatedSeconds: TimeInterval = 0
    private var sessionTickDate: Date?
    private var cancellables = Set<AnyCancellable>()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let destinations = "destinations"
        static let hasVisitedAll = "hasVisitedAll"
        static let destinationsAdded = "destinationsAdded"
        static let trips = "trips"
        static let tripsCreated = "tripsCreated"
        static let tripsFinished = "tripsFinished"
        static let budgetKeptCount = "budgetKeptCount"
        static let dayPlansCreated = "dayPlansCreated"
        static let travelItems = "travelItems"
        static let lastUpdated = "lastUpdated"
        static let checklistsCompleted = "checklistsCompleted"
        static let packingTemplatesApplied = "packingTemplatesApplied"
        static let selectedPrepTripID = "selectedPrepTripID"
        static let documents = "documents"
        static let docsReadyUnlocked = "docsReadyUnlocked"
        static let emergencyCard = "emergencyCard"
        static let phrasesCopied = "phrasesCopied"
        static let pocketReadyUnlocked = "pocketReadyUnlocked"
        static let selectedContinent = "selectedContinent"
        static let currencyRates = "currencyRates"
        static let ratesLastUpdated = "ratesLastUpdated"
        static let tripsCompleted = "tripsCompleted"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
    }

    private init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        destinations = Self.loadCodable([Destination].self, key: Keys.destinations) ?? []
        hasVisitedAll = defaults.bool(forKey: Keys.hasVisitedAll)
        destinationsAdded = defaults.integer(forKey: Keys.destinationsAdded)
        trips = Self.loadCodable([Trip].self, key: Keys.trips) ?? []
        tripsCreated = defaults.integer(forKey: Keys.tripsCreated)
        tripsFinished = defaults.integer(forKey: Keys.tripsFinished)
        budgetKeptCount = defaults.integer(forKey: Keys.budgetKeptCount)
        dayPlansCreated = defaults.integer(forKey: Keys.dayPlansCreated)
        travelItems = Self.loadCodable([TravelItem].self, key: Keys.travelItems) ?? []
        lastUpdated = defaults.object(forKey: Keys.lastUpdated) as? Date ?? Date()
        checklistsCompleted = defaults.integer(forKey: Keys.checklistsCompleted)
        packingTemplatesApplied = defaults.integer(forKey: Keys.packingTemplatesApplied)
        if let raw = defaults.string(forKey: Keys.selectedPrepTripID) {
            selectedPrepTripID = UUID(uuidString: raw)
        } else {
            selectedPrepTripID = nil
        }
        let loadedDocs = Self.loadCodable([TravelDocument].self, key: Keys.documents)
        documents = loadedDocs?.isEmpty == false ? (loadedDocs ?? []) : DocumentSeed.defaultDocuments()
        docsReadyUnlocked = defaults.bool(forKey: Keys.docsReadyUnlocked)
        emergencyCard = Self.loadCodable(EmergencyCard.self, key: Keys.emergencyCard) ?? .empty
        phrasesCopied = defaults.integer(forKey: Keys.phrasesCopied)
        pocketReadyUnlocked = defaults.bool(forKey: Keys.pocketReadyUnlocked)
        selectedContinent = defaults.string(forKey: Keys.selectedContinent) ?? ""
        currencyRates = Self.loadCodable([CurrencyRate].self, key: Keys.currencyRates) ?? []
        ratesLastUpdated = defaults.object(forKey: Keys.ratesLastUpdated) as? Date
        tripsCompleted = defaults.integer(forKey: Keys.tripsCompleted)
        totalSessionsCompleted = defaults.object(forKey: Keys.totalSessionsCompleted) as? Int
            ?? defaults.integer(forKey: Keys.tripsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadCodable([String: Date].self, key: Keys.achievementsUnlocked) ?? [:]

        NotificationCenter.default.publisher(for: .dataReset)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)

        refreshDocumentReminder()
    }

    // MARK: - Destinations

    func addDestination(_ destination: Destination) {
        destinations.append(destination)
        destinationsAdded += 1
        recordActivity()
        evaluateAchievements()
    }

    func updateDestination(_ destination: Destination) {
        guard let index = destinations.firstIndex(where: { $0.id == destination.id }) else { return }
        let wasVisited = destinations[index].visited
        destinations[index] = destination
        if destination.visited && !wasVisited {
            tripsCompleted += 1
        }
        recordActivity()
        evaluateAchievements()
    }

    func deleteDestination(id: UUID) {
        destinations.removeAll { $0.id == id }
        for index in trips.indices {
            trips[index].destinationIDs.removeAll { $0 == id }
        }
        recordActivity()
    }

    func reorderDestinations(from source: IndexSet, to destination: Int) {
        destinations.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Trips

    func addTrip(_ trip: Trip) {
        var next = trip
        if next.dayPlans.isEmpty {
            next.dayPlans = Self.makeDayPlans(for: next)
            dayPlansCreated += next.dayPlans.count
        }
        trips.insert(next, at: 0)
        tripsCreated += 1
        recordActivity()
        evaluateAchievements()
        refreshDocumentReminder()
    }

    func updateTrip(_ trip: Trip) {
        guard let index = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        let previous = trips[index]
        trips[index] = trip
        if previous.status != .completed && trip.status == .completed {
            tripsFinished += 1
            tripsCompleted += 1
            if trip.budgetLimit > 0 && trip.totalSpent <= trip.budgetLimit {
                budgetKeptCount += 1
            }
        }
        recordActivity()
        evaluateAchievements()
        refreshDocumentReminder()
    }

    func deleteTrip(id: UUID) {
        trips.removeAll { $0.id == id }
        travelItems.removeAll { $0.tripID == id }
        for index in documents.indices where documents[index].tripID == id {
            documents[index].tripID = nil
        }
        if selectedPrepTripID == id {
            selectedPrepTripID = nil
        }
        recordActivity()
        refreshDocumentReminder()
    }

    func regenerateDayPlans(for tripID: UUID) {
        guard let index = trips.firstIndex(where: { $0.id == tripID }) else { return }
        let plans = Self.makeDayPlans(for: trips[index])
        dayPlansCreated += max(plans.count - trips[index].dayPlans.count, 0)
        trips[index].dayPlans = plans
        recordActivity()
        evaluateAchievements()
    }

    func updateDayPlan(_ plan: TripDayPlan, in tripID: UUID) {
        guard let tripIndex = trips.firstIndex(where: { $0.id == tripID }) else { return }
        guard let planIndex = trips[tripIndex].dayPlans.firstIndex(where: { $0.id == plan.id }) else { return }
        trips[tripIndex].dayPlans[planIndex] = plan
        recordActivity()
        evaluateAchievements()
    }

    func addExpense(_ expense: TripExpense, to tripID: UUID) {
        guard let index = trips.firstIndex(where: { $0.id == tripID }) else { return }
        trips[index].expenses.append(expense)
        recordActivity()
        evaluateAchievements()
    }

    func deleteExpense(id: UUID, from tripID: UUID) {
        guard let index = trips.firstIndex(where: { $0.id == tripID }) else { return }
        trips[index].expenses.removeAll { $0.id == id }
        recordActivity()
    }

    private static func makeDayPlans(for trip: Trip) -> [TripDayPlan] {
        (1...trip.dayCount).map { day in
            TripDayPlan(dayIndex: day, title: "Day \(day)", activities: [], note: "")
        }
    }

    // MARK: - Prep list

    func addTravelItem(_ item: TravelItem) {
        var next = item
        let scoped = travelItems.filter { $0.tripID == item.tripID }
        next.sortOrder = (scoped.map(\.sortOrder).max() ?? -1) + 1
        travelItems.append(next)
        recordActivity()
    }

    func updateTravelItem(_ item: TravelItem) {
        guard let index = travelItems.firstIndex(where: { $0.id == item.id }) else { return }
        let wasCompleted = travelItems[index].completed
        travelItems[index] = item
        if item.completed && !wasCompleted {
            maybeCompleteChecklist(for: item.tripID)
        }
        recordActivity()
        evaluateAchievements()
    }

    func deleteTravelItem(id: UUID) {
        travelItems.removeAll { $0.id == id }
        recordActivity()
    }

    func reorderTravelItems(from source: IndexSet, to destination: Int, in category: PrepCategory, tripID: UUID?) {
        var categoryItems = travelItems
            .filter { $0.category == category && $0.tripID == tripID }
            .sorted { $0.sortOrder < $1.sortOrder }
        categoryItems.move(fromOffsets: source, toOffset: destination)
        for (offset, item) in categoryItems.enumerated() {
            if let index = travelItems.firstIndex(where: { $0.id == item.id }) {
                travelItems[index].sortOrder = offset
            }
        }
    }

    func applyPackingTemplate(_ template: PackingTemplate, tripID: UUID?) {
        let baseOrder = (travelItems.filter { $0.tripID == tripID }.map(\.sortOrder).max() ?? -1) + 1
        for (offset, entry) in template.items.enumerated() {
            let item = TravelItem(
                name: entry.name,
                category: entry.category,
                sortOrder: baseOrder + offset,
                tripID: tripID
            )
            travelItems.append(item)
        }
        packingTemplatesApplied += 1
        recordActivity()
        evaluateAchievements()
    }

    func items(for tripID: UUID?) -> [TravelItem] {
        travelItems.filter { $0.tripID == tripID }
    }

    private func maybeCompleteChecklist(for tripID: UUID?) {
        let scoped = items(for: tripID)
        guard !scoped.isEmpty, scoped.allSatisfy(\.completed) else { return }
        checklistsCompleted += 1
        tripsCompleted += 1
        evaluateAchievements()
    }

    // MARK: - Documents

    func updateDocument(_ document: TravelDocument) {
        guard let index = documents.firstIndex(where: { $0.id == document.id }) else { return }
        documents[index] = document
        refreshDocsReadyFlag()
        recordActivity()
        evaluateAchievements()
        refreshDocumentReminder()
    }

    func addDocument(_ document: TravelDocument) {
        documents.append(document)
        recordActivity()
        refreshDocumentReminder()
    }

    func deleteDocument(id: UUID) {
        documents.removeAll { $0.id == id }
        recordActivity()
        refreshDocumentReminder()
    }

    private func refreshDocsReadyFlag() {
        let core = documents.filter { $0.kind != .other }
        let ready = !core.isEmpty && core.allSatisfy { $0.status == .ready || $0.status == .packed }
        if ready {
            docsReadyUnlocked = true
        }
    }

    func refreshDocumentReminder() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let upcoming = trips
            .filter { $0.status != .completed }
            .sorted { $0.startDate < $1.startDate }

        for trip in upcoming {
            let start = calendar.startOfDay(for: trip.startDate)
            let days = calendar.dateComponents([.day], from: today, to: start).day ?? 0
            guard days >= 0 else { continue }

            let related = documents.filter { $0.tripID == trip.id || $0.tripID == nil }
            let missing = related.filter { $0.status == .missing }
            let threshold = related.map(\.remindDaysBefore).max() ?? 7
            if days <= threshold && !missing.isEmpty {
                documentReminderText = "\(trip.title): check \(missing.count) travel document\(missing.count == 1 ? "" : "s") (\(days) day\(days == 1 ? "" : "s") left)."
                return
            }
        }
        documentReminderText = nil
    }

    // MARK: - Pocket

    func saveEmergencyCard(_ card: EmergencyCard) {
        emergencyCard = card
        if card.isFilled {
            pocketReadyUnlocked = true
        }
        recordActivity()
        evaluateAchievements()
    }

    func registerPhraseCopy() {
        phrasesCopied += 1
        pocketReadyUnlocked = true
        recordActivity()
        evaluateAchievements()
    }

    // MARK: - Currency

    func loadRatesForSelectedContinent() {
        guard !selectedContinent.isEmpty else {
            currencyRates = []
            return
        }
        currencyRates = CurrencyCatalog.rates.filter { $0.continent == selectedContinent }
        ratesLastUpdated = Date()
        recordActivity()
    }

    func updateRates() {
        loadRatesForSelectedContinent()
        evaluateAchievements()
    }

    // MARK: - Activity

    func recordActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 1 {
                streakDays += 1
            } else if dayDiff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = max(streakDays, 1)
        }
        lastActivityDate = Date()
        evaluateAchievements()
    }

    func startUsageTracking() {
        sessionTickDate = Date()
    }

    func pauseUsageTracking() {
        flushUsageSeconds()
        sessionTickDate = nil
    }

    private func flushUsageSeconds() {
        guard let start = sessionTickDate else { return }
        sessionAccumulatedSeconds += Date().timeIntervalSince(start)
        let wholeMinutes = Int(sessionAccumulatedSeconds / 60)
        if wholeMinutes > 0 {
            totalMinutesUsed += wholeMinutes
            sessionAccumulatedSeconds -= Double(wholeMinutes) * 60
        }
        sessionTickDate = Date()
    }

    // MARK: - Achievements

    func evaluateAchievements() {
        var newly: [AchievementDefinition] = []
        for definition in AchievementCatalog.all {
            guard achievementsUnlocked[definition.id] == nil else { continue }
            if isUnlocked(definition.id) {
                achievementsUnlocked[definition.id] = Date()
                newly.append(definition)
            }
        }
        for item in newly {
            enqueueAchievementBanner(item)
        }
    }

    private func isUnlocked(_ id: String) -> Bool {
        switch id {
        case "first_trip_planned": return tripsCreated >= 1
        case "itinerary_builder": return dayPlansCreated >= 3
        case "budget_keeper": return budgetKeptCount >= 1
        case "docs_ready": return docsReadyUnlocked
        case "packed_smart": return packingTemplatesApplied >= 1
        case "phrase_ready": return pocketReadyUnlocked || phrasesCopied >= 1
        case "planning_streak": return streakDays >= 7
        case "trip_finisher": return tripsFinished >= 1
        default: return false
        }
    }

    func enqueueAchievementBanner(_ definition: AchievementDefinition) {
        achievementQueue.append(definition)
        presentNextBannerIfNeeded()
    }

    private func presentNextBannerIfNeeded() {
        guard !isShowingBanner, let next = achievementQueue.first else { return }
        achievementQueue.removeFirst()
        isShowingBanner = true
        FeedbackService.achievement()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            pendingAchievementBanner = next
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            withAnimation(.easeInOut(duration: 0.3)) {
                self?.pendingAchievementBanner = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self?.isShowingBanner = false
                self?.presentNextBannerIfNeeded()
            }
        }
    }

    func flashSuccessCheckmark() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccessCheckmark = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            withAnimation(.easeInOut(duration: 0.3)) {
                self?.showSuccessCheckmark = false
            }
        }
    }

    // MARK: - Reset

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier
        if let domain {
            defaults.removePersistentDomain(forName: domain)
        }
        defaults.synchronize()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = false
        destinations = []
        hasVisitedAll = false
        destinationsAdded = 0
        trips = []
        tripsCreated = 0
        tripsFinished = 0
        budgetKeptCount = 0
        dayPlansCreated = 0
        travelItems = []
        lastUpdated = Date()
        checklistsCompleted = 0
        packingTemplatesApplied = 0
        selectedPrepTripID = nil
        documents = DocumentSeed.defaultDocuments()
        docsReadyUnlocked = false
        emergencyCard = .empty
        phrasesCopied = 0
        pocketReadyUnlocked = false
        selectedContinent = ""
        currencyRates = []
        ratesLastUpdated = nil
        tripsCompleted = 0
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]
        pendingAchievementBanner = nil
        showSuccessCheckmark = false
        documentReminderText = nil
        achievementQueue = []
        isShowingBanner = false
        sessionAccumulatedSeconds = 0
        sessionTickDate = nil
    }

    private func saveCodable<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadCodable<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
