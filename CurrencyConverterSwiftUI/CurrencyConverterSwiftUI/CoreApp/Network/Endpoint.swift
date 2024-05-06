//
//  Endpoint.swift
//  CurrencyConverter
//
//  Created by Anmol Suneja on 04/05/24.
//

import Foundation

enum Endpoint {
    case symbols
    case rates
}

extension Endpoint {
    var fullPath: String {
        ApiConstants.baseURL + path
    }
    
    var method: String {
        httpMethod.rawValue.uppercased()
    }
}

private extension Endpoint {
    var path: String {
        switch self {
        case .symbols:
            return "/api/currencies.json"
        case .rates:
            return "/api/latest.json"
        }
    }
    
    var httpMethod: HTTPMethodType {
        switch self {
        case .symbols:
            return .get
        case .rates:
            return .get
        }
    }
}
