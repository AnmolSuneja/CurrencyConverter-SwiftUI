//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Anmol Suneja on 05/05/24.
//

import Foundation

struct Currency: Codable, Identifiable {
    let symbol: String
    let name: String?
    let rate: Double?
    
    var id: String {
        return symbol
    }
}
