//
//  CurrencyViewModel.swift
//  CurrencyConverter
//
//  Created by Anmol Suneja on 04/05/24.
//

import Foundation

class CurrencyViewModel: ObservableObject {
    @Published var currencies: [Currency] = []
    @Published var showErrorAlert: Bool = false
    @Published var errorText: String = ""
    
    @Published var selectedCurrency: String = ""
    @Published var inputAmountValue: String = ""
    
    init() {
        currencies = ExchangeDataStorage.shared.getCurrencies()
        selectedCurrency = self.currencies.first?.symbol ?? ""
    }
        
    var isCurrencyLoaded: Bool {
        !selectedCurrency.isEmpty
    }
    
    var isInputFieldFunctional: Bool {
        !inputAmountValue.isEmpty && isCurrencyLoaded
    }
    
    var selectedCurrencyRate: Double? {
        let result = currencies.filter { currency in
            currency.symbol == selectedCurrency
        }.first?.rate
        return result
    }
    
    func getAmount(currencyRate: Double?) -> String {
        let fallbackAmount = Constants.notANumber
        var result = fallbackAmount
        if let inputAmount = Double(inputAmountValue) {
            let fromCurrencyRate = selectedCurrencyRate
            let toCurrencyRate = currencyRate
            
            if let fromCurrencyRate = fromCurrencyRate, let toCurrencyRate = toCurrencyRate {
                let amount = (toCurrencyRate * inputAmount/fromCurrencyRate)
                result = formatCurrency(value: amount) ?? fallbackAmount
            } else {
                result = Constants.errorCurrencyConversion
            }
            
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func formatCurrency(value: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.currencySymbol = ""
        return formatter.string(from: NSNumber(value: value))
    }

    
    private let service = NetworkService()
    
    func fetchExchangeInfo(isRefreshNeeded: Bool = false) async throws {
        if ExchangeDataStorage.shared.shouldRefreshCurrencies || isRefreshNeeded || self.currencies.isEmpty {
            async let fetchSymbols = fetchCurrencySymbols()
            async let fetchRates = fetchCurrencyRates()
            
            let (symbols, rates) = await (try fetchSymbols, try fetchRates)
            let currencies = mergeCurrencies(symbols: symbols, rates: rates)
            await MainActor.run {
                self.showErrorAlert = false
                self.errorText = ""
                self.currencies = currencies.sorted { $0.symbol < $1.symbol }
                
                if self.selectedCurrency.isEmpty {
                    self.selectedCurrency = self.currencies.first?.symbol ?? ""
                } else {
                    self.selectedCurrency = self.currencies.filter { currency in
                        currency.symbol == self.selectedCurrency
                    }.first?.symbol ?? (self.currencies.first?.symbol ?? "")
                }
                
                if self.currencies.isEmpty {
                    self.errorText = Constants.exchangeDataEmpty
                    self.showErrorAlert = true
                }
                ExchangeDataStorage.shared.saveCurrencies(self.currencies)
                ExchangeDataStorage.shared.saveUpdatedTime()
                print("Data refreshed from open exchange server")
            }
        }
    }
    
    private func mergeCurrencies(symbols: [String: String], rates: [String: Double]) -> [Currency] {
        var result: [Currency] = []
        let symbolKeys = symbols.keys
        let ratesKeys = rates.keys
        
        if symbolKeys.count > ratesKeys.count {
            for (sym, value) in symbols {
                result.append(Currency(symbol: sym, name: value, rate: rates[sym]))
            }
        } else {
            for (sym, rate) in rates {
                result.append(Currency(symbol: sym, name: symbols[sym], rate: rate))
            }
        }
        return result
    }
    
    private func fetchCurrencySymbols() async throws -> [String: String] {
        do  {
            let symbols: [String: String] = try await service.executeRequest(for: .symbols)
            return symbols
        } catch {
            await MainActor.run {
                self.errorText = "\(Constants.exchangeDataFetchError) \(error.localizedDescription)"
                self.showErrorAlert = true
            }
            throw error
        }
    }
    
    private func fetchCurrencyRates() async throws -> [String: Double] {
        do  {
            let rates: CurrencyRateResponse = try await service.executeRequest(for: .rates)
            return rates.rates
        } catch {
            await MainActor.run {
                self.errorText = "\(Constants.exchangeDataFetchError) \(error.localizedDescription)"
                self.showErrorAlert = true
            }
            throw error
        }
    }
}
