//
//  ExchangeDataStorage.swift
//  CurrencyConverter
//
//  Created by Anmol Suneja on 06/05/24.
//

import Foundation

enum UserDefaultsKeysConstants {
    static let currencies = "user_defaults_currencies"
    static let currenciesUpdatedAt = "user_defaults_updated_time"
}

class ExchangeDataStorage {
    static let shared = ExchangeDataStorage()
    private init() {}
    
    private let refreshTime = 30
        
    private func getLastUpdatedTime() -> Date? {
        UserDefaults.standard.object(forKey: UserDefaultsKeysConstants.currenciesUpdatedAt) as? Date
    }
    
    func saveUpdatedTime(_ time: Date = Date()) {
        UserDefaults.standard.set(time, forKey: UserDefaultsKeysConstants.currenciesUpdatedAt)
    }
    
    var shouldRefreshCurrencies: Bool {
        guard let lastRefreshTime = getLastUpdatedTime() else {
            return true
        }
        
        let timeDifference = Date().timeIntervalSince(lastRefreshTime)
        let thirtyMinutesInSeconds: TimeInterval = TimeInterval(refreshTime * 60)
        return timeDifference >= thirtyMinutesInSeconds
    }
    
    func saveCurrencies(_ currencies: [Currency]) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(currencies)
            UserDefaults.standard.set(encodedData, forKey: UserDefaultsKeysConstants.currencies)
            UserDefaults.standard.synchronize()
        } catch {
            print("Error saving currencies:", error)
        }
    }
    
    func getCurrencies() -> [Currency] {
        var currencies: [Currency] = []
        if let savedData = UserDefaults.standard.data(forKey: UserDefaultsKeysConstants.currencies) {
            do {
                let decoder = JSONDecoder()
                let loadedCurrencies = try decoder.decode([Currency].self, from: savedData)
                currencies = loadedCurrencies
            } catch {
                print("Error decoding currencies:", error)
            }
        }
        return currencies
    }
}
