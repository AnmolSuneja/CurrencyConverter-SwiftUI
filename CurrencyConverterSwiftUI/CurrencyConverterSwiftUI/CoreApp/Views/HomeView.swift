//
//  HomeView.swift
//  CurrencyConverter
//
//  Created by Anmol Suneja on 04/05/24.
//

import SwiftUI

struct HomeView: View {
    @FocusState private var amountFocusState: Bool
    @StateObject private var viewModel = CurrencyViewModel()
    @State private var popOverCurrency: Currency?
    @State private var selectedDetent: PresentationDetent = .medium
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, pinnedViews: [.sectionHeaders],  content: {
                    Section(header: currencyView) {
                        if viewModel.isInputFieldFunctional {
                            currencyOutputGridView
                        } else {
                            emptyKeyboardDismissView
                        }
                    }
                })
                .padding()
            }
            .popover(item: $popOverCurrency, content: { currency in
                DetailView(currency: currency, viewModel: viewModel)
                .presentationDetents([.medium], selection: $selectedDetent)
                
            })
            .alert(Constants.errorTitle, isPresented: $viewModel.showErrorAlert) {
                Button(Constants.btnOkTitle, role: .none) {}
            } message: {
                Text("\(viewModel.errorText)")
            }
            .refreshable {
                try? await viewModel.fetchExchangeInfo(isRefreshNeeded: true)
            }
            .task {
                try? await viewModel.fetchExchangeInfo()
            }
            .navigationTitle(Constants.navigationTitle)
            .navigationDestination(for: String.self) { currency in
                CurrencyPicker(selection: $viewModel.selectedCurrency, currencies: viewModel.currencies)
            }
        }
    }
    
    var currencyView: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center) {
                
                NavigationLink(value: viewModel.selectedCurrency) {
                    VStack(alignment: .leading) {
                        HStack() {
                            Text(Constants.selectCurrencyTitle)
                                .font(.title3)
                            Image(systemName: "arrow.right")
                        }
                        
                        if viewModel.isCurrencyLoaded {
                            Text("\(viewModel.selectedCurrency)")
                                .font(.title)
                                .bold()
                        } else if viewModel.errorText.isEmpty {
                            ProgressView()
                        }
                    }
                }
                .disabled(!viewModel.isCurrencyLoaded)
                .tint(Color.black)
                
                Spacer(minLength: 30)
                
                TextField(Constants.enterAmount, text: $viewModel.inputAmountValue)
                    .focused($amountFocusState)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .disabled(!viewModel.isCurrencyLoaded)
            }
            Divider()
        }
        .background(
            Color.white
        )
    }
    
    var currencyOutputGridView: some View {
        ForEach(viewModel.currencies, id: \.symbol) { currency in
            VStack {
                Text("\(currency.symbol)")
                    .font(.title3)
                    .minimumScaleFactor(0.5)

                
                Text("\(viewModel.getAmount(currencyRate: currency.rate))")
                    .font(.title3)
                    .bold()
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .onTapGesture {
                amountFocusState = false
                popOverCurrency = currency
            }
            .padding()
            .background(Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
    
    var emptyKeyboardDismissView: some View {
        VStack {}
        .frame(width: 700)
        .frame(height: 700)
        .background(Color.white)
        .onTapGesture {
            amountFocusState = false
        }
    }
}

#Preview {
    HomeView()
}
