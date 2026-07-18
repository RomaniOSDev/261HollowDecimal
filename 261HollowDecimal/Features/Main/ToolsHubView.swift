import SwiftUI

struct ToolsHubView: View {
    let bottomInset: CGFloat

    @State private var section: ToolsSection = .prep

    private enum ToolsSection: String, CaseIterable, Identifiable {
        case prep = "Prep"
        case docs = "Docs"
        case pocket = "Pocket"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    Picker("Section", selection: $section) {
                        ForEach(ToolsSection.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .onChange(of: section) { _ in
                        FeedbackService.lightTap()
                    }

                    Group {
                        switch section {
                        case .prep:
                            PrepListView(bottomInset: bottomInset, embedInNavigation: false)
                        case .docs:
                            DocumentsView(bottomInset: bottomInset, embedInNavigation: false)
                        case .pocket:
                            TravelPocketView(bottomInset: bottomInset, embedInNavigation: false)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(title(for: section))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if section == .prep {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Templates") {
                            FeedbackService.lightTap()
                            NotificationCenter.default.post(name: .prepListTemplateRequested, object: nil)
                        }
                        .foregroundStyle(Color("AppAccent"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(minHeight: 44)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add Item") {
                            FeedbackService.lightTap()
                            NotificationCenter.default.post(name: .prepListAddRequested, object: nil)
                        }
                        .foregroundStyle(Color("AppAccent"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(minWidth: 44, minHeight: 44)
                    }
                }
                if section == .docs {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add") {
                            FeedbackService.lightTap()
                            NotificationCenter.default.post(name: .documentsAddRequested, object: nil)
                        }
                        .foregroundStyle(Color("AppAccent"))
                        .frame(minWidth: 44, minHeight: 44)
                    }
                }
            }
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onReceive(NotificationCenter.default.publisher(for: .openToolsSection)) { note in
                guard let raw = note.object as? String else { return }
                switch raw {
                case "docs": section = .docs
                case "pocket": section = .pocket
                default: section = .prep
                }
            }
        }
        .background(Color.clear)
    }

    private func title(for section: ToolsSection) -> String {
        switch section {
        case .prep: return "Travel Prep List"
        case .docs: return "Travel Documents"
        case .pocket: return "Travel Pocket"
        }
    }
}
