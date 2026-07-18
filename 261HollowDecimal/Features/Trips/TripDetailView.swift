import SwiftUI

struct TripDetailView: View {
    let tripID: UUID
    let bottomInset: CGFloat

    @EnvironmentObject private var store: AppDataStore
    @State private var showExpenseEditor = false
    @State private var expenseAmount = ""
    @State private var expenseNote = ""
    @State private var expenseCategory: ExpenseCategory = .food
    @State private var expenseError = false
    @State private var expenseShake: CGFloat = 0
    @State private var editingPlan: TripDayPlan?
    @State private var planTitle = ""
    @State private var planNote = ""
    @State private var planActivitiesText = ""

    private var trip: Trip? {
        store.trips.first { $0.id == tripID }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            if let trip {
                ScrollView {
                    VStack(spacing: 16) {
                        summaryCard(trip)
                        budgetCard(trip)
                        dayPlansCard(trip)
                        expensesCard(trip)
                        linkedActions(trip)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, bottomInset + 24)
                }
                .clearScrollBackground()
            } else {
                EmptyStateView(symbolName: "airplane", message: "This trip is no longer available.")
            }
        }
        .navigationTitle(trip?.title ?? "Trip")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showExpenseEditor) { expenseSheet }
        .sheet(item: $editingPlan) { plan in dayPlanSheet(plan) }
    }

    private func summaryCard(_ trip: Trip) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    IconBadge(systemName: "airplane")
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trip.title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        Text("\(dateFormatter.string(from: trip.startDate)) – \(dateFormatter.string(from: trip.endDate))")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    StatusChip(text: trip.status.rawValue)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(TripStatus.allCases) { status in
                            FilterChip(title: status.rawValue, selected: trip.status == status) {
                                FeedbackService.lightTap()
                                var updated = trip
                                updated.status = status
                                store.updateTrip(updated)
                                FeedbackService.success()
                                store.flashSuccessCheckmark()
                            }
                        }
                    }
                }

                if !trip.notes.isEmpty {
                    Text(trip.notes)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextPrimary"))
                }

                if !trip.destinationIDs.isEmpty {
                    let names = store.destinations
                        .filter { trip.destinationIDs.contains($0.id) }
                        .map { "\($0.flagEmoji) \($0.name)" }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(names, id: \.self) { name in
                                Text(name)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color("AppBackground").opacity(0.45))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
        }
    }

    private func budgetCard(_ trip: Trip) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Budget Tracker", subtitle: trip.budgetLimit > 0 ? "Track spend by category" : "Set a budget when editing the trip")

                if trip.budgetLimit <= 0 {
                    Text("No budget set for this trip yet.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Spent")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                            Text(String(format: "$%.0f", trip.totalSpent))
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Remaining")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                            Text(String(format: "$%.0f", trip.remainingBudget))
                                .font(.title3.weight(.bold))
                                .foregroundStyle(trip.remainingBudget >= 0 ? Color("AppAccent") : Color.red.opacity(0.9))
                        }
                    }
                    AppProgressBar(progress: trip.budgetProgress, height: 10)
                }

                Button {
                    FeedbackService.lightTap()
                    expenseAmount = ""
                    expenseNote = ""
                    expenseCategory = .food
                    expenseError = false
                    showExpenseEditor = true
                } label: {
                    Text("Add Expense")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    private func dayPlansCard(_ trip: Trip) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(
                    title: "Day Plan",
                    subtitle: "\(trip.dayPlans.count) days mapped",
                    actionTitle: "Rebuild",
                    action: {
                        store.regenerateDayPlans(for: trip.id)
                        FeedbackService.success()
                    }
                )

                LazyVStack(spacing: 8) {
                    ForEach(trip.dayPlans.sorted { $0.dayIndex < $1.dayIndex }) { plan in
                        DayPlanCell(plan: plan) {
                            FeedbackService.lightTap()
                            planTitle = plan.title
                            planNote = plan.note
                            planActivitiesText = plan.activities.joined(separator: "\n")
                            editingPlan = plan
                        }
                    }
                }
            }
        }
    }

    private func expensesCard(_ trip: Trip) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                AppSectionHeader(title: "Expenses", subtitle: trip.expenses.isEmpty ? "Nothing logged yet" : "\(trip.expenses.count) entries")

                if trip.expenses.isEmpty {
                    Text("Add flights, stays, food, and transport costs.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(trip.expenses.sorted { $0.date > $1.date }) { expense in
                        ExpenseCell(expense: expense) {
                            FeedbackService.lightTap()
                            store.deleteExpense(id: expense.id, from: trip.id)
                        }
                    }
                }
            }
        }
    }

    private func linkedActions(_ trip: Trip) -> some View {
        SurfaceCard {
            VStack(spacing: 10) {
                Button {
                    FeedbackService.lightTap()
                    store.selectedPrepTripID = trip.id
                    FeedbackService.success()
                } label: {
                    Label("Use Packing List for This Trip", systemImage: "suitcase.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                Text("Open Toolkit → Prep to manage the linked packing list and templates.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var expenseSheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        Picker("Category", selection: $expenseCategory) {
                            ForEach(ExpenseCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .tint(Color("AppAccent"))
                        TextField("Amount", text: $expenseAmount)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .modifier(ShakeEffect(animatableData: expenseShake))
                        if expenseError {
                            Text("Enter a valid amount.")
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.9))
                        }
                        TextField("Note", text: $expenseNote)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        showExpenseEditor = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveExpense() }
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func dayPlanSheet(_ plan: TripDayPlan) -> some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Day title", text: $planTitle)
                            .foregroundStyle(Color("AppTextPrimary"))
                        TextField("Activities (one per line)", text: $planActivitiesText, axis: .vertical)
                            .lineLimit(4...10)
                            .foregroundStyle(Color("AppTextPrimary"))
                        TextField("Notes", text: $planNote, axis: .vertical)
                            .lineLimit(2...5)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Day \(plan.dayIndex)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        editingPlan = nil
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = plan
                        updated.title = planTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        updated.note = planNote.trimmingCharacters(in: .whitespacesAndNewlines)
                        updated.activities = planActivitiesText
                            .split(separator: "\n")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        store.updateDayPlan(updated, in: tripID)
                        FeedbackService.mediumTap()
                        FeedbackService.success()
                        store.flashSuccessCheckmark()
                        editingPlan = nil
                    }
                    .foregroundStyle(Color("AppAccent"))
                }
            }
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func saveExpense() {
        let amount = Double(expenseAmount.replacingOccurrences(of: ",", with: ".")) ?? -1
        guard amount >= 0 else {
            FeedbackService.warning()
            expenseError = true
            expenseShake += 1
            return
        }
        let expense = TripExpense(
            category: expenseCategory,
            amount: amount,
            note: expenseNote.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        store.addExpense(expense, to: tripID)
        FeedbackService.mediumTap()
        FeedbackService.success()
        store.flashSuccessCheckmark()
        showExpenseEditor = false
    }
}
