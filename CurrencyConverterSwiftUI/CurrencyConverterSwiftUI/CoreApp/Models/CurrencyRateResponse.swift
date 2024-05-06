//
//  CurrencyRateResponse.swift
//  CurrencyConverter
//
//  Created by Anmol Suneja on 05/05/24.
//

import Foundation

struct CurrencyRateResponse: Decodable {
    let rates: [String: Double]
}
