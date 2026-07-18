import Foundation

extension Notification.Name {
    static let dataReset = Notification.Name("dataReset")
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
    static let prepListAddRequested = Notification.Name("prepListAddRequested")
    static let prepListTemplateRequested = Notification.Name("prepListTemplateRequested")
    static let documentsAddRequested = Notification.Name("documentsAddRequested")
    static let switchToTab = Notification.Name("switchToTab")
    static let openToolsSection = Notification.Name("openToolsSection")
}

// MARK: - Destinations

struct Destination: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var country: String
    var flagEmoji: String
    var note: String
    var visited: Bool
    var plannedDate: Date?

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        flagEmoji: String = "🌍",
        note: String = "",
        visited: Bool = false,
        plannedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.flagEmoji = flagEmoji
        self.note = note
        self.visited = visited
        self.plannedDate = plannedDate
    }
}

// MARK: - Packing

enum PrepCategory: String, Codable, CaseIterable, Identifiable {
    case clothing = "Clothing"
    case toiletries = "Toiletries"
    case essentials = "Essentials"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .toiletries: return "drop.fill"
        case .essentials: return "checkmark.seal.fill"
        }
    }
}

struct TravelItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var category: PrepCategory
    var completed: Bool
    var sortOrder: Int
    var tripID: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        category: PrepCategory,
        completed: Bool = false,
        sortOrder: Int = 0,
        tripID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.completed = completed
        self.sortOrder = sortOrder
        self.tripID = tripID
    }
}

enum PackingTemplate: String, CaseIterable, Identifiable {
    case beach = "Beach"
    case business = "Business"
    case hiking = "Hiking"
    case cityWeekend = "City Weekend"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .beach: return "sun.max.fill"
        case .business: return "briefcase.fill"
        case .hiking: return "figure.hiking"
        case .cityWeekend: return "building.2.fill"
        }
    }

    var items: [(name: String, category: PrepCategory)] {
        switch self {
        case .beach:
            return [
                ("Swimsuit", .clothing), ("Sandals", .clothing), ("Sun hat", .clothing),
                ("Sunscreen", .toiletries), ("After-sun lotion", .toiletries),
                ("Beach towel", .essentials), ("Reusable water bottle", .essentials)
            ]
        case .business:
            return [
                ("Blazer", .clothing), ("Dress shirts", .clothing), ("Formal shoes", .clothing),
                ("Toiletry kit", .toiletries), ("Razor", .toiletries),
                ("Laptop charger", .essentials), ("Business cards", .essentials), ("Adapter plug", .essentials)
            ]
        case .hiking:
            return [
                ("Hiking boots", .clothing), ("Moisture-wicking layers", .clothing), ("Rain jacket", .clothing),
                ("Blister kit", .toiletries), ("Insect repellent", .toiletries),
                ("Trail map / offline notes", .essentials), ("Headlamp", .essentials), ("First-aid kit", .essentials)
            ]
        case .cityWeekend:
            return [
                ("Comfortable walking shoes", .clothing), ("Casual outfits", .clothing), ("Light jacket", .clothing),
                ("Travel toothbrush", .toiletries), ("Hand sanitizer", .toiletries),
                ("City transit card note", .essentials), ("Portable charger", .essentials), ("Day backpack", .essentials)
            ]
        }
    }
}

// MARK: - Trips / Budget

enum TripStatus: String, Codable, CaseIterable, Identifiable {
    case planned = "Planned"
    case active = "Active"
    case completed = "Completed"

    var id: String { rawValue }
}

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case flight = "Flight"
    case stay = "Stay"
    case food = "Food"
    case transport = "Transport"
    case other = "Other"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .flight: return "airplane"
        case .stay: return "bed.double.fill"
        case .food: return "fork.knife"
        case .transport: return "tram.fill"
        case .other: return "cart.fill"
        }
    }
}

struct TripExpense: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var category: ExpenseCategory
    var amount: Double
    var note: String
    var date: Date

    init(
        id: UUID = UUID(),
        category: ExpenseCategory,
        amount: Double,
        note: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.amount = amount
        self.note = note
        self.date = date
    }
}

struct TripDayPlan: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var dayIndex: Int
    var title: String
    var activities: [String]
    var note: String

    init(
        id: UUID = UUID(),
        dayIndex: Int,
        title: String = "",
        activities: [String] = [],
        note: String = ""
    ) {
        self.id = id
        self.dayIndex = dayIndex
        self.title = title
        self.activities = activities
        self.note = note
    }
}

struct Trip: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var budgetLimit: Double
    var notes: String
    var destinationIDs: [UUID]
    var dayPlans: [TripDayPlan]
    var expenses: [TripExpense]
    var status: TripStatus

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date = Date(),
        endDate: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
        budgetLimit: Double = 0,
        notes: String = "",
        destinationIDs: [UUID] = [],
        dayPlans: [TripDayPlan] = [],
        expenses: [TripExpense] = [],
        status: TripStatus = .planned
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.budgetLimit = budgetLimit
        self.notes = notes
        self.destinationIDs = destinationIDs
        self.dayPlans = dayPlans
        self.expenses = expenses
        self.status = status
    }

    var totalSpent: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var remainingBudget: Double {
        budgetLimit - totalSpent
    }

    var budgetProgress: Double {
        guard budgetLimit > 0 else { return 0 }
        return min(totalSpent / budgetLimit, 1)
    }

    var dayCount: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return max(days + 1, 1)
    }
}

// MARK: - Documents

enum DocumentKind: String, Codable, CaseIterable, Identifiable {
    case passport = "Passport"
    case visa = "Visa"
    case insurance = "Insurance"
    case tickets = "Tickets"
    case hotel = "Hotel confirmation"
    case other = "Other"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .passport: return "person.text.rectangle"
        case .visa: return "globe"
        case .insurance: return "cross.case.fill"
        case .tickets: return "airplane.ticket"
        case .hotel: return "building.2.fill"
        case .other: return "doc.fill"
        }
    }
}

enum DocumentStatus: String, Codable, CaseIterable, Identifiable {
    case missing = "Missing"
    case ready = "Ready"
    case packed = "Packed digitally"

    var id: String { rawValue }
}

struct TravelDocument: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var kind: DocumentKind
    var customTitle: String
    var status: DocumentStatus
    var tripID: UUID?
    var remindDaysBefore: Int

    init(
        id: UUID = UUID(),
        kind: DocumentKind,
        customTitle: String = "",
        status: DocumentStatus = .missing,
        tripID: UUID? = nil,
        remindDaysBefore: Int = 7
    ) {
        self.id = id
        self.kind = kind
        self.customTitle = customTitle
        self.status = status
        self.tripID = tripID
        self.remindDaysBefore = remindDaysBefore
    }

    var displayTitle: String {
        let trimmed = customTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? kind.rawValue : trimmed
    }
}

// MARK: - Pocket

struct EmergencyCard: Codable, Equatable {
    var bloodType: String
    var allergies: String
    var emergencyContactName: String
    var emergencyContactPhone: String
    var notes: String

    static let empty = EmergencyCard(
        bloodType: "",
        allergies: "",
        emergencyContactName: "",
        emergencyContactPhone: "",
        notes: ""
    )

    var isFilled: Bool {
        !bloodType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !allergies.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !emergencyContactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !emergencyContactPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct TravelPhrase: Identifiable, Hashable {
    let id: String
    let scenario: String
    let phrase: String
    let meaning: String
}

enum PhraseCatalog {
    static let scenarios = ["Airport", "Hotel", "Food", "Help"]

    static let all: [TravelPhrase] = [
        TravelPhrase(id: "a1", scenario: "Airport", phrase: "Where is the check-in counter?", meaning: "Find airline desk"),
        TravelPhrase(id: "a2", scenario: "Airport", phrase: "Is this the line for security?", meaning: "Confirm queue"),
        TravelPhrase(id: "a3", scenario: "Airport", phrase: "Which gate is for my flight?", meaning: "Ask for gate"),
        TravelPhrase(id: "a4", scenario: "Airport", phrase: "Has boarding started?", meaning: "Boarding status"),
        TravelPhrase(id: "a5", scenario: "Airport", phrase: "Where can I find baggage claim?", meaning: "Luggage area"),
        TravelPhrase(id: "a6", scenario: "Airport", phrase: "Do I need to declare anything?", meaning: "Customs question"),
        TravelPhrase(id: "a7", scenario: "Airport", phrase: "Is there free Wi‑Fi here?", meaning: "Airport internet"),
        TravelPhrase(id: "a8", scenario: "Airport", phrase: "How do I get to the city center?", meaning: "Ground transport"),
        TravelPhrase(id: "h1", scenario: "Hotel", phrase: "I have a reservation under this name.", meaning: "Check-in"),
        TravelPhrase(id: "h2", scenario: "Hotel", phrase: "What time is breakfast served?", meaning: "Meal hours"),
        TravelPhrase(id: "h3", scenario: "Hotel", phrase: "Could I have a late checkout?", meaning: "Extra time"),
        TravelPhrase(id: "h4", scenario: "Hotel", phrase: "Is breakfast included?", meaning: "Confirm inclusion"),
        TravelPhrase(id: "h5", scenario: "Hotel", phrase: "Where is the elevator?", meaning: "Find lift"),
        TravelPhrase(id: "h6", scenario: "Hotel", phrase: "The Wi‑Fi password, please.", meaning: "Internet access"),
        TravelPhrase(id: "h7", scenario: "Hotel", phrase: "Can I leave my luggage after checkout?", meaning: "Bag storage"),
        TravelPhrase(id: "h8", scenario: "Hotel", phrase: "Is there a quieter room available?", meaning: "Room change"),
        TravelPhrase(id: "f1", scenario: "Food", phrase: "A table for two, please.", meaning: "Request seating"),
        TravelPhrase(id: "f2", scenario: "Food", phrase: "What do you recommend?", meaning: "Ask suggestion"),
        TravelPhrase(id: "f3", scenario: "Food", phrase: "I am allergic to nuts.", meaning: "Allergy alert"),
        TravelPhrase(id: "f4", scenario: "Food", phrase: "No spicy food, please.", meaning: "Preference"),
        TravelPhrase(id: "f5", scenario: "Food", phrase: "Could we have the check?", meaning: "Ask for bill"),
        TravelPhrase(id: "f6", scenario: "Food", phrase: "Is service included?", meaning: "Tipping / fees"),
        TravelPhrase(id: "f7", scenario: "Food", phrase: "Water without ice, please.", meaning: "Drink request"),
        TravelPhrase(id: "f8", scenario: "Food", phrase: "Do you have vegetarian options?", meaning: "Diet options"),
        TravelPhrase(id: "p1", scenario: "Help", phrase: "Can you help me, please?", meaning: "General help"),
        TravelPhrase(id: "p2", scenario: "Help", phrase: "I am lost. Where is this address?", meaning: "Navigation help"),
        TravelPhrase(id: "p3", scenario: "Help", phrase: "Please call a doctor.", meaning: "Medical help"),
        TravelPhrase(id: "p4", scenario: "Help", phrase: "Where is the nearest pharmacy?", meaning: "Find pharmacy"),
        TravelPhrase(id: "p5", scenario: "Help", phrase: "I need the police.", meaning: "Emergency police"),
        TravelPhrase(id: "p6", scenario: "Help", phrase: "My phone is dead. May I charge it?", meaning: "Power help"),
        TravelPhrase(id: "p7", scenario: "Help", phrase: "Does anyone speak English?", meaning: "Language help"),
        TravelPhrase(id: "p8", scenario: "Help", phrase: "This is an emergency.", meaning: "Urgent alert")
    ]
}

struct CurrencyRate: Identifiable, Codable, Equatable, Hashable {
    var id: String { code }
    var name: String
    var code: String
    var continent: String
    var rateToUSD: Double
}

enum CurrencyCatalog {
    static let continents = ["Europe", "Asia", "Americas", "Africa", "Oceania"]

    static let rates: [CurrencyRate] = [
        CurrencyRate(name: "Euro", code: "EUR", continent: "Europe", rateToUSD: 0.92),
        CurrencyRate(name: "British Pound", code: "GBP", continent: "Europe", rateToUSD: 0.79),
        CurrencyRate(name: "Swiss Franc", code: "CHF", continent: "Europe", rateToUSD: 0.88),
        CurrencyRate(name: "Polish Zloty", code: "PLN", continent: "Europe", rateToUSD: 3.95),
        CurrencyRate(name: "Swedish Krona", code: "SEK", continent: "Europe", rateToUSD: 10.45),
        CurrencyRate(name: "Japanese Yen", code: "JPY", continent: "Asia", rateToUSD: 149.50),
        CurrencyRate(name: "Chinese Yuan", code: "CNY", continent: "Asia", rateToUSD: 7.24),
        CurrencyRate(name: "South Korean Won", code: "KRW", continent: "Asia", rateToUSD: 1320.00),
        CurrencyRate(name: "Indian Rupee", code: "INR", continent: "Asia", rateToUSD: 83.10),
        CurrencyRate(name: "Thai Baht", code: "THB", continent: "Asia", rateToUSD: 35.80),
        CurrencyRate(name: "Canadian Dollar", code: "CAD", continent: "Americas", rateToUSD: 1.36),
        CurrencyRate(name: "Mexican Peso", code: "MXN", continent: "Americas", rateToUSD: 17.15),
        CurrencyRate(name: "Brazilian Real", code: "BRL", continent: "Americas", rateToUSD: 4.97),
        CurrencyRate(name: "Argentine Peso", code: "ARS", continent: "Americas", rateToUSD: 870.00),
        CurrencyRate(name: "South African Rand", code: "ZAR", continent: "Africa", rateToUSD: 18.65),
        CurrencyRate(name: "Egyptian Pound", code: "EGP", continent: "Africa", rateToUSD: 30.90),
        CurrencyRate(name: "Moroccan Dirham", code: "MAD", continent: "Africa", rateToUSD: 10.05),
        CurrencyRate(name: "Kenyan Shilling", code: "KES", continent: "Africa", rateToUSD: 129.50),
        CurrencyRate(name: "Australian Dollar", code: "AUD", continent: "Oceania", rateToUSD: 1.52),
        CurrencyRate(name: "New Zealand Dollar", code: "NZD", continent: "Oceania", rateToUSD: 1.64),
        CurrencyRate(name: "Fijian Dollar", code: "FJD", continent: "Oceania", rateToUSD: 2.25)
    ]
}

// MARK: - Achievements (travel-focused)

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbolName: String
}

enum AchievementCatalog {
    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_trip_planned",
            title: "First Trip Planned",
            detail: "Created your first trip itinerary.",
            symbolName: "airplane.departure"
        ),
        AchievementDefinition(
            id: "itinerary_builder",
            title: "Itinerary Builder",
            detail: "Added day plans across your trips.",
            symbolName: "list.bullet.rectangle"
        ),
        AchievementDefinition(
            id: "budget_keeper",
            title: "Budget Keeper",
            detail: "Finished a trip within budget.",
            symbolName: "dollarsign.circle.fill"
        ),
        AchievementDefinition(
            id: "docs_ready",
            title: "Docs Ready",
            detail: "Prepared your core travel documents.",
            symbolName: "checkmark.shield.fill"
        ),
        AchievementDefinition(
            id: "packed_smart",
            title: "Packed Smart",
            detail: "Generated a packing list from a template.",
            symbolName: "suitcase.fill"
        ),
        AchievementDefinition(
            id: "phrase_ready",
            title: "Phrase Ready",
            detail: "Saved an emergency card or copied useful phrases.",
            symbolName: "text.bubble.fill"
        ),
        AchievementDefinition(
            id: "planning_streak",
            title: "7-Day Planning Streak",
            detail: "Planned travel on 7 days in a row.",
            symbolName: "calendar.badge.checkmark"
        ),
        AchievementDefinition(
            id: "trip_finisher",
            title: "Trip Finisher",
            detail: "Marked a trip as completed.",
            symbolName: "flag.checkered"
        )
    ]
}

enum CountryFlags {
    static let suggestions: [(country: String, flag: String)] = [
        ("France", "🇫🇷"), ("Italy", "🇮🇹"), ("Spain", "🇪🇸"), ("Germany", "🇩🇪"),
        ("Japan", "🇯🇵"), ("USA", "🇺🇸"), ("UK", "🇬🇧"), ("Canada", "🇨🇦"),
        ("Australia", "🇦🇺"), ("Brazil", "🇧🇷"), ("Mexico", "🇲🇽"), ("Thailand", "🇹🇭"),
        ("Greece", "🇬🇷"), ("Portugal", "🇵🇹"), ("Netherlands", "🇳🇱"), ("Switzerland", "🇨🇭"),
        ("Turkey", "🇹🇷"), ("Egypt", "🇪🇬"), ("India", "🇮🇳"), ("South Korea", "🇰🇷"),
        ("New Zealand", "🇳🇿"), ("Argentina", "🇦🇷"), ("Morocco", "🇲🇦"), ("Indonesia", "🇮🇩")
    ]

    static func flag(for country: String) -> String {
        let trimmed = country.trimmingCharacters(in: .whitespacesAndNewlines)
        if let match = suggestions.first(where: { $0.country.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            return match.flag
        }
        return "🌍"
    }
}

enum DocumentSeed {
    static func defaultDocuments() -> [TravelDocument] {
        [
            TravelDocument(kind: .passport),
            TravelDocument(kind: .visa),
            TravelDocument(kind: .insurance),
            TravelDocument(kind: .tickets),
            TravelDocument(kind: .hotel)
        ]
    }
}
