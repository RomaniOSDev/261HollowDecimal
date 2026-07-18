import SwiftUI

struct CurrencyView: View {
    let bottomInset: CGFloat
    var embedInNavigation: Bool = true

    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = CurrencyViewModel()
    @State private var pickerContinent = CurrencyCatalog.continents[0]

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        Group {
            if embedInNavigation {
                NavigationStack { content }
            } else {
                content
            }
        }
        .onAppear {
            viewModel.bind(store: store)
            if !store.selectedContinent.isEmpty {
                pickerContinent = store.selectedContinent
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

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 14) {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Currency Quick Look")
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text("Reference rates versus USD for trip budgeting.")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(CurrencyCatalog.continents, id: \.self) { continent in
                                            FilterChip(
                                                title: continent,
                                                selected: pickerContinent == continent && !store.selectedContinent.isEmpty
                                            ) {
                                                pickerContinent = continent
                                                viewModel.selectContinent(continent)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        if store.selectedContinent.isEmpty || store.currencyRates.isEmpty {
                            EmptyStateView(
                                symbolName: "globe",
                                message: store.selectedContinent.isEmpty
                                    ? "Please select a continent to begin"
                                    : "No data available",
                                actionTitle: "Load \(pickerContinent)",
                                action: {
                                    viewModel.selectContinent(pickerContinent)
                                    viewModel.updateRates()
                                }
                            )
                        } else {
                            AppSectionHeader(
                                title: store.selectedContinent,
                                subtitle: "\(store.currencyRates.count) currencies"
                            )

                            LazyVStack(spacing: 10) {
                                ForEach(store.currencyRates) { rate in
                                    CurrencyCell(
                                        rate: rate,
                                        selected: viewModel.selectedCode == rate.code || viewModel.pulsedCode == rate.code,
                                        onTap: { viewModel.selectRow(rate) }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, bottomInset + 110)
                }
                .clearScrollBackground()
                .refreshable {
                    viewModel.updateRates()
                }

                VStack(spacing: 8) {
                    Button {
                        if store.selectedContinent.isEmpty {
                            viewModel.selectContinent(pickerContinent)
                        }
                        viewModel.updateRates()
                    } label: {
                        Text("Update Rates")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 16)

                    if let updated = store.ratesLastUpdated {
                        Text("Last updated: \(dateFormatter.string(from: updated))")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    } else {
                        Text("Last updated: —")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .padding(.bottom, 8)
                .background(Color("AppBackground").opacity(0.92))
            }
        }
        .navigationTitle(embedInNavigation ? "Currency Quick Look" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
