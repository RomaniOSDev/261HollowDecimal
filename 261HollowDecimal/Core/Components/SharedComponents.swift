import SwiftUI

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color("AppTextPrimary"))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(
                LinearGradient(
                    colors: [Color("AppPrimary"), Color("AppAccent").opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color("AppAccent"))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(minHeight: 44)
            .background(
                LinearGradient(
                    colors: [Color("AppSurface"), Color("AppBackground").opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color("AppAccent").opacity(0.55), Color("AppAccent").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct SoftPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.94 : 1)
    }
}

// MARK: - Shell

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("AppBackground"),
                    Color("AppSurface").opacity(0.38),
                    Color("AppBackground")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color("AppPrimary").opacity(0.16), Color.clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 320
            )
            .allowsHitTesting(false)

            RadialGradient(
                colors: [Color("AppAccent").opacity(0.10), Color.clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 280
            )
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

struct SurfaceCard<Content: View>: View {
    var padding: CGFloat = 16
    var elevated: Bool = true
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ElevatedPanelBackground(elevated: elevated))
    }
}

struct InsetPanelBackground: View {
    var cornerRadius: CGFloat = 14

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color("AppBackground").opacity(0.72),
                        Color("AppBackground").opacity(0.42)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color("AppTextSecondary").opacity(0.08), lineWidth: 1)
            )
    }
}

struct AppSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer(minLength: 8)
            if let actionTitle, let action {
                Button(action: {
                    FeedbackService.lightTap()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct IconBadge: View {
    let systemName: String
    var size: CGFloat = 44
    var tint: Color = Color("AppAccent")

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.28), tint.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .stroke(Color("AppTextPrimary").opacity(0.10), lineWidth: 1)
                )
            Image(systemName: systemName)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
    }
}

struct StatusChip: View {
    let text: String
    var emphasized: Bool = true

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(emphasized ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(
                    emphasized
                    ? LinearGradient(colors: [Color("AppPrimary").opacity(0.55), Color("AppAccent").opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Color("AppBackground").opacity(0.65), Color("AppBackground").opacity(0.4)], startPoint: .top, endPoint: .bottom)
                )
            )
    }
}

struct MetricChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
            Text(text)
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(Color("AppTextSecondary"))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(
                LinearGradient(
                    colors: [Color("AppBackground").opacity(0.7), Color("AppBackground").opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        )
    }
}

struct AppProgressBar: View {
    let progress: Double
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(
                    LinearGradient(
                        colors: [Color("AppBackground").opacity(0.75), Color("AppBackground").opacity(0.45)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geo.size.width * min(max(progress, 0), 1), progress > 0 ? 6 : 0))
            }
        }
        .frame(height: height)
    }
}

struct EmptyStateView: View {
    let symbolName: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("AppSurface"), Color("AppBackground").opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .appRaised()
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color("AppAccent").opacity(0.45), Color("AppPrimary").opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 110, height: 110)
                Image(systemName: symbolName)
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(Color("AppAccent"))
            }
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 28)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

struct SuccessCheckmarkOverlay: View {
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 64))
            .foregroundStyle(Color("AppAccent"))
            .padding(20)
            .background(ElevatedPanelBackground(cornerRadius: 20, elevated: true))
    }
}

struct AchievementBannerView: View {
    let achievement: AchievementDefinition

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: achievement.symbolName, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(ElevatedPanelBackground(cornerRadius: 14, elevated: true))
        .padding(.horizontal, 16)
    }
}

struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 58, height: 58)
                .background(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(Circle().stroke(Color("AppTextPrimary").opacity(0.14), lineWidth: 1))
                .clipShape(Circle())
                .appFloating()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Cells

struct TripCell: View {
    let trip: Trip
    var dateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                IconBadge(systemName: "airplane.departure")
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer(minLength: 8)
                StatusChip(text: trip.status.rawValue)
            }

            if trip.budgetLimit > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Budget")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        Spacer()
                        Text(String(format: "$%.0f / $%.0f", trip.totalSpent, trip.budgetLimit))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    AppProgressBar(progress: trip.budgetProgress)
                }
            }

            HStack(spacing: 8) {
                MetricChip(icon: "calendar", text: "\(trip.dayPlans.count) days")
                MetricChip(icon: "mappin.and.ellipse", text: "\(trip.destinationIDs.count) places")
                MetricChip(icon: "cart", text: "\(trip.expenses.count) spends")
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(16)
        .background(ElevatedPanelBackground())
    }
}

struct DestinationCell: View {
    let destination: Destination
    let plannedText: String?
    let expanded: Bool
    let pulsed: Bool
    var onToggleVisited: () -> Void
    var onTap: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("AppBackground").opacity(0.5))
                        .frame(width: 52, height: 52)
                    Text(destination.flagEmoji)
                        .font(.largeTitle)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(destination.name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(destination.country)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                    if let plannedText {
                        Label(plannedText, systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }

                Spacer(minLength: 0)

                Button(action: onToggleVisited) {
                    VStack(spacing: 4) {
                        Image(systemName: destination.visited ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(destination.visited ? Color("AppAccent") : Color("AppTextSecondary"))
                        Text(destination.visited ? "Visited" : "Wish")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(minWidth: 52, minHeight: 44)
                }
                .buttonStyle(.plain)
            }

            if !destination.note.isEmpty {
                Text(destination.note)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(expanded ? nil : 2)
            }

            if expanded {
                HStack(spacing: 10) {
                    Button("Edit", action: onEdit)
                        .buttonStyle(SecondaryButtonStyle())
                    Button("Delete", role: .destructive, action: onDelete)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.red.opacity(0.9))
                        .frame(minHeight: 44)
                        .padding(.horizontal, 14)
                        .background(Color("AppBackground").opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(16)
        .background(
            ElevatedPanelBackground()
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(pulsed ? Color("AppAccent") : Color.clear, lineWidth: 1.5)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .onLongPressGesture(perform: onEdit)
        .contextMenu {
            Button("Edit", action: onEdit)
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
}

struct PrepItemCell: View {
    let item: TravelItem
    let pulsed: Bool
    var onToggle: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.completed ? Color("AppAccent") : Color("AppTextSecondary"))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(item.completed ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                    .strikethrough(item.completed, color: Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(item.category.rawValue)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer(minLength: 0)

            Image(systemName: "line.3.horizontal")
                .foregroundStyle(Color("AppTextSecondary").opacity(0.7))
                .frame(width: 28, height: 44)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            ElevatedPanelBackground(cornerRadius: 14, elevated: false)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(pulsed ? Color("AppAccent") : Color.clear, lineWidth: 1.5)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
        .contextMenu {
            Button("Edit", action: onEdit)
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
}

struct DocumentCell: View {
    let document: TravelDocument
    let linkedTripTitle: String?
    var onStatusChange: (DocumentStatus) -> Void
    var onRemindChange: (Int) -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                IconBadge(systemName: document.kind.symbolName)
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.displayTitle)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(document.kind.rawValue)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                StatusChip(text: document.status.rawValue, emphasized: document.status != .missing)
            }

            HStack(spacing: 8) {
                ForEach(DocumentStatus.allCases) { status in
                    Button {
                        onStatusChange(status)
                    } label: {
                        Text(shortStatus(status))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(document.status == status ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 36)
                            .background(
                                Capsule().fill(document.status == status ? Color("AppPrimary") : Color("AppBackground").opacity(0.45))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Label("Remind \(document.remindDaysBefore)d before", systemImage: "bell")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Spacer()
                Stepper("", value: Binding(
                    get: { document.remindDaysBefore },
                    set: onRemindChange
                ), in: 1...60)
                .labelsHidden()
            }

            if let linkedTripTitle {
                Label(linkedTripTitle, systemImage: "link")
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
            }
        }
        .padding(16)
        .background(ElevatedPanelBackground())
        .contextMenu {
            Button("Delete", role: .destructive, action: onDelete)
        }
    }

    private func shortStatus(_ status: DocumentStatus) -> String {
        switch status {
        case .missing: return "Missing"
        case .ready: return "Ready"
        case .packed: return "Packed"
        }
    }
}

struct PhraseCell: View {
    let phrase: TravelPhrase
    let copied: Bool
    var onCopy: () -> Void

    var body: some View {
        Button(action: onCopy) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: "text.bubble.fill", size: 40)
                VStack(alignment: .leading, spacing: 6) {
                    Text(phrase.phrase)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .multilineTextAlignment(.leading)
                    Text(phrase.meaning)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(copied ? "Copied" : "Tap to copy")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                }
                Spacer(minLength: 0)
                Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundStyle(Color("AppAccent"))
                    .frame(width: 28, height: 28)
            }
            .padding(14)
            .background(ElevatedPanelBackground())
        }
        .buttonStyle(SoftPressStyle())
    }
}

struct CurrencyCell: View {
    let rate: CurrencyRate
    let selected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.22))
                        .frame(width: 44, height: 44)
                    Text(String(rate.code.prefix(1)))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(rate.name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(rate.code)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(String(format: "%.2f", rate.rateToUSD))
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(Color("AppAccent"))
                    Text("per USD")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(14)
            .background(
                ElevatedPanelBackground()
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(selected ? Color("AppAccent") : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(SoftPressStyle())
    }
}

struct ExpenseCell: View {
    let expense: TripExpense
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: expense.category.symbolName, size: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(expense.category.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
            }
            Spacer()
            Text(String(format: "$%.0f", expense.amount))
                .font(.headline.monospacedDigit())
                .foregroundStyle(Color("AppTextPrimary"))
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(Color.red.opacity(0.85))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(InsetPanelBackground())
    }
}

struct DayPlanCell: View {
    let plan: TripDayPlan
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.28))
                        .frame(width: 40, height: 40)
                    Text("\(plan.dayIndex)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(plan.title.isEmpty ? "Day \(plan.dayIndex)" : plan.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    if plan.activities.isEmpty && plan.note.isEmpty {
                        Text("Tap to plan this day")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    } else {
                        ForEach(plan.activities.prefix(3), id: \.self) { activity in
                            Text("• \(activity)")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(1)
                        }
                        if plan.activities.count > 3 {
                            Text("+\(plan.activities.count - 3) more")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color("AppAccent"))
                        }
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(Color("AppAccent"))
            }
            .padding(14)
            .background(InsetPanelBackground())
        }
        .buttonStyle(SoftPressStyle())
    }
}

struct AchievementCell: View {
    let achievement: AchievementDefinition
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(unlocked ? Color("AppPrimary").opacity(0.28) : Color("AppBackground").opacity(0.45))
                    .frame(width: 54, height: 54)
                Image(systemName: achievement.symbolName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(unlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.45))
            }
            Text(achievement.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(unlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(achievement.detail)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
            if unlocked {
                StatusChip(text: "Unlocked")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 168)
        .background(
            ElevatedPanelBackground(elevated: unlocked)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(unlocked ? Color("AppAccent").opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
        )
        .opacity(unlocked ? 1 : 0.72)
    }
}

struct TemplateCell: View {
    let template: PackingTemplate
    var onApply: () -> Void

    var body: some View {
        Button(action: onApply) {
            HStack(spacing: 12) {
                IconBadge(systemName: template.symbolName)
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.rawValue)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("\(template.items.count) curated items")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color("AppAccent"))
            }
            .padding(14)
            .background(ElevatedPanelBackground())
        }
        .buttonStyle(SoftPressStyle())
    }
}

struct SettingsRowCell: View {
    let title: String
    let systemImage: String
    var destructive: Bool = false
    var trailing: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                IconBadge(
                    systemName: systemImage,
                    size: 36,
                    tint: destructive ? Color.red.opacity(0.9) : Color("AppAccent")
                )
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(destructive ? Color.red.opacity(0.9) : Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                if let trailing {
                    Text(trailing)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                if !destructive {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(SoftPressStyle())
    }
}

struct FilterChip: View {
    let title: String
    let selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(selected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minHeight: 34)
                .background(
                    Capsule().fill(
                        selected
                        ? LinearGradient(colors: [Color("AppPrimary"), Color("AppAccent").opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color("AppSurface"), Color("AppBackground").opacity(0.55)], startPoint: .top, endPoint: .bottom)
                    )
                )
                .overlay(
                    Capsule().stroke(Color("AppTextPrimary").opacity(selected ? 0.14 : 0.06), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

