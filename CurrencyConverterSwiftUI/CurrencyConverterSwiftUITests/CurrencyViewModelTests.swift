//
//  CurrencyViewModelTests.swift
//  CurrencyConverterTests
//
//  Created by Anmol Suneja on 06/05/24.
//

@testable import CurrencyConverterSwiftUI
import XCTest

final class CurrencyViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeysConstants.currenciesUpdatedAt)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeysConstants.currencies)
    }


    func testCurrencyViewModelInitilizerWithNoPreviousData() {
        let model = CurrencyViewModel()
        XCTAssertTrue(model.currencies.isEmpty, "Currencies should be empty by default")
        XCTAssertTrue(model.selectedCurrency.isEmpty, "Selected currency should be empty by default")
        XCTAssertFalse(model.isCurrencyLoaded, "Initially no curriencies should be loaded")
        XCTAssertFalse(model.isInputFieldFunctional, "Initially text field should not be functional")
        XCTAssertNil(model.selectedCurrencyRate, "Selected currency rate should be nil by default")
    }
    
    func testCurrencyViewModelInitilizerWithSomePreviousData() {
        let dummyCurrency = Currency(symbol: "Sym", name: "Currency", rate: 1.0)
        let dummyCurrency2 = Currency(symbol: "Sym2", name: "Currency2", rate: 2.0)
        let dummyCurrency3 = Currency(symbol: "Sym3", name: "Currency3", rate: 3.0)
        let currencies: [Currency] = [dummyCurrency, dummyCurrency2, dummyCurrency3]
        ExchangeDataStorage.shared.saveCurrencies(currencies)
        
        let model = CurrencyViewModel()
        let fetchCurrencies = model.currencies
        XCTAssertEqual(fetchCurrencies.count, 3)
        XCTAssertEqual(fetchCurrencies[0].symbol, "Sym")
        XCTAssertEqual(fetchCurrencies[1].name, "Currency2")
        XCTAssertEqual(fetchCurrencies[2].rate, 3.0)
        
        XCTAssertEqual(model.selectedCurrency, "Sym")
        XCTAssertTrue(model.isCurrencyLoaded, "Currencies should be loaded")
        XCTAssertEqual(model.selectedCurrencyRate, 1.0)
    }
    
    func testCurrencyViewModelWithApiFetchingCurrencies() {
        let model = CurrencyViewModel()
        let expectation = XCTestExpectation(description: "Fetch exchange data")
        Task {
            do {
                try await model.fetchExchangeInfo()
                
                XCTAssertFalse(model.currencies.isEmpty, "Currencies should not be empty")
                XCTAssertFalse(model.selectedCurrency.isEmpty, "Selected currency should not be empty")
                XCTAssertEqual(model.currencies[0].symbol, model.selectedCurrency)
                XCTAssertTrue(model.isCurrencyLoaded, "Currencies should be loaded")
                XCTAssertEqual(model.currencies[0].rate, model.selectedCurrencyRate)
                
                expectation.fulfill()
            } catch {
                print(error)
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testConvertedAmountTextGeneration() {
        let dummyCurrency = Currency(symbol: "Sym", name: "Currency", rate: 3.0)
        ExchangeDataStorage.shared.saveCurrencies([dummyCurrency])
        
        let model = CurrencyViewModel()
        // without input amount
        var result = model.getAmount(currencyRate: 6.0)
        XCTAssertEqual(result, "NAN")
        
        // with invalid input amount
        model.inputAmountValue = "2e"
        result = model.getAmount(currencyRate: 6.0)
        XCTAssertEqual(result, "NAN")
        
        // with valid input amount
        model.inputAmountValue = "2"
        result = model.getAmount(currencyRate: 6.0)
        XCTAssertEqual(result, "4.00")
        XCTAssertTrue(model.isInputFieldFunctional, "Text field should be functional")
        
        // with invalid input currency rate
        result = model.getAmount(currencyRate: nil)
        XCTAssertEqual(result, "Err")
        
        // with invalid selected currency rate
        let dummyCurrencyModel = Currency(symbol: "Sym", name: "Currency", rate: nil)
        ExchangeDataStorage.shared.saveCurrencies([dummyCurrencyModel])
        
        let model2 = CurrencyViewModel()
        model2.inputAmountValue = "2"
        result = model2.getAmount(currencyRate: 6.0)
        XCTAssertEqual(result, "Err")
    }
}
