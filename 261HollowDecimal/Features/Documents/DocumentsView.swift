import SwiftUI

struct DocumentsView: View {
    let bottomInset: CGFloat
    var embedInNavigation: Bool = true

    @EnvironmentObject private var store: AppDataStore
    @State private var showAdd = false
    @State private var customTitle = ""
    @State private var selectedKind: DocumentKind = .other
    @State private var remindDays = 7
    @State private var linkedTripID: UUID?
    @State private var statusFilter: DocumentStatus? = nil

    private var filteredDocuments: [TravelDocument] {
        guard let statusFilter else { return store.documents }
        return store.documents.filter { $0.status == statusFilter }
    }

    private var readyCount: Int {
        store.documents.filter { $0.status != .missing }.count
    }

    var body: some View {
        Group {
            if embedInNavigation {
                NavigationStack { content }
            } else {
                content
            }
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
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 10) {
                            AppSectionHeader(
                                title: "Document readiness",
                                subtitle: "\(readyCount)/\(store.documents.count) prepared",
                                actionTitle: "Add",
                                action: {
                                    showAdd = true
                                }
                            )
                            AppProgressBar(
                                progress: store.documents.isEmpty ? 0 : Double(readyCount) / Double(store.documents.count),
                                height: 10
                            )
                        }
                    }

                    if let reminder = store.documentReminderText {
                        HStack(alignment: .top, spacing: 10) {
                            IconBadge(systemName: "exclamationmark.triangle.fill", size: 36)
                            Text(reminder)
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Spacer(minLength: 0)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color("AppSurface"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color("AppAccent").opacity(0.4), lineWidth: 1)
                                )
                        )
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", selected: statusFilter == nil) {
                                FeedbackService.lightTap()
                                statusFilter = nil
                            }
                            ForEach(DocumentStatus.allCases) { status in
                                FilterChip(title: status.rawValue, selected: statusFilter == status) {
                                    FeedbackService.lightTap()
                                    statusFilter = status
                                }
                            }
                        }
                    }

                    LazyVStack(spacing: 12) {
                        ForEach(filteredDocuments) { document in
                            DocumentCell(
                                document: document,
                                linkedTripTitle: linkedTitle(for: document),
                                onStatusChange: { newStatus in
                                    FeedbackService.lightTap()
                                    var updated = document
                                    updated.status = newStatus
                                    store.updateDocument(updated)
                                    if newStatus != .missing {
                                        FeedbackService.success()
                                    }
                                },
                                onRemindChange: { value in
                                    var updated = document
                                    updated.remindDaysBefore = max(1, min(value, 60))
                                    store.updateDocument(updated)
                                },
                                onDelete: {
                                    FeedbackService.lightTap()
                                    store.deleteDocument(id: document.id)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, bottomInset + 24)
            }
            .clearScrollBackground()
        }
        .navigationTitle(embedInNavigation ? "Travel Documents" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if embedInNavigation {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        FeedbackService.lightTap()
                        showAdd = true
                    }
                    .foregroundStyle(Color("AppAccent"))
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
        .sheet(isPresented: $showAdd) { addSheet }
        .onAppear { store.refreshDocumentReminder() }
        .onReceive(NotificationCenter.default.publisher(for: .documentsAddRequested)) { _ in
            showAdd = true
        }
    }

    private func linkedTitle(for document: TravelDocument) -> String? {
        guard let tripID = document.tripID,
              let trip = store.trips.first(where: { $0.id == tripID }) else { return nil }
        return trip.title
    }

    private var addSheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        Picker("Type", selection: $selectedKind) {
                            ForEach(DocumentKind.allCases) { kind in
                                Text(kind.rawValue).tag(kind)
                            }
                        }
                        .tint(Color("AppAccent"))
                        TextField("Custom title (optional)", text: $customTitle)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Stepper("Remind \(remindDays) days before", value: $remindDays, in: 1...60)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Picker("Link trip", selection: $linkedTripID) {
                            Text("None").tag(nil as UUID?)
                            ForEach(store.trips) { trip in
                                Text(trip.title).tag(Optional(trip.id))
                            }
                        }
                        .tint(Color("AppAccent"))
                    }
                    .listRowBackground(Color("AppSurface"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        showAdd = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let doc = TravelDocument(
                            kind: selectedKind,
                            customTitle: customTitle,
                            status: .missing,
                            tripID: linkedTripID,
                            remindDaysBefore: remindDays
                        )
                        store.addDocument(doc)
                        FeedbackService.mediumTap()
                        FeedbackService.success()
                        store.flashSuccessCheckmark()
                        showAdd = false
                        customTitle = ""
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
}
