//
//  ExchangeDataStorageTest.swift
//  CurrencyConverterTests
//
//  Created by Anmol Suneja on 06/05/24.
//

@testable import CurrencyConverterSwiftUI
import XCTest

final class ExchangeDataStorageTest: XCTestCase {

    override func setUpWithError() throws {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeysConstants.currenciesUpdatedAt)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeysConstants.currencies)
    }

    func testSaveCurrenciesWithEmptyArray() {
        let currencies: [Currency] = []
        ExchangeDataStorage.shared.saveCurrencies(currencies)
        
        let fetchCurrencies = ExchangeDataStorage.shared.getCurrencies()
        XCTAssertTrue(fetchCurrencies.isEmpty, "Currencies should be saved and fetched as per empty input data")
    }
    
    func testSaveCurrenciesWithNonEmptyArray() {
        let dummyCurrency = Currency(symbol: "Sym", name: "Currency", rate: 1.0)
        let dummyCurrency2 = Currency(symbol: "Sym2", name: "Currency2", rate: 2.0)
        let dummyCurrency3 = Currency(symbol: "Sym3", name: "Currency3", rate: 3.0)
        let currencies: [Currency] = [dummyCurrency, dummyCurrency2, dummyCurrency3]
        ExchangeDataStorage.shared.saveCurrencies(currencies)
        
        let fetchCurrencies = ExchangeDataStorage.shared.getCurrencies()
        XCTAssertEqual(fetchCurrencies.count, 3)
        XCTAssertEqual(fetchCurrencies[0].symbol, "Sym")
        XCTAssertEqual(fetchCurrencies[1].name, "Currency2")
        XCTAssertEqual(fetchCurrencies[2].rate, 3.0)
    }
    
    func testShouldRefreshCurrenciesIfNoTimeAviablae() {
        let result = ExchangeDataStorage.shared.shouldRefreshCurrencies
        XCTAssertTrue(result, "Currencies should refresh within 40 minutes")
    }
    
    func testShouldRefreshCurrenciesWithinThirtyMinutes() {
        var date = Date()
        date = date.addingTimeInterval(-30 * 60)
        ExchangeDataStorage.shared.saveUpdatedTime(date)
        let result = ExchangeDataStorage.shared.shouldRefreshCurrencies
        XCTAssertTrue(result, "Currencies should refresh within 10 minutes")
    }
    
    func testShouldRefreshCurrenciesWithinFortyMinutes() {
        var date = Date()
        date = date.addingTimeInterval(-40 * 60)
        ExchangeDataStorage.shared.saveUpdatedTime(date)
        let result = ExchangeDataStorage.shared.shouldRefreshCurrencies
        XCTAssertTrue(result, "Currencies should refresh within 40 minutes")
    }
    
    func testShouldNotRefreshCurrenciesWithinTenMinutes() {
        var date = Date()
        date = date.addingTimeInterval(-10 * 60)
        ExchangeDataStorage.shared.saveUpdatedTime(date)
        let result = ExchangeDataStorage.shared.shouldRefreshCurrencies
        XCTAssertFalse(result, "Currencies should not refresh within 10 minutes")
    }
}
