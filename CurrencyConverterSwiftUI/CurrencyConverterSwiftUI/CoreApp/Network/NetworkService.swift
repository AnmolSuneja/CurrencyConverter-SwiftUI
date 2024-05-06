//
//  NetworkService.swift
//  CurrencyConverter
//
//  Created by Anmol Suneja on 04/05/24.
//

import Foundation

enum NetworkServiceError: Error {
    case invalidStatusCode
    case invalidURL
}

enum HTTPMethodType: String {
    case get
}

actor NetworkService {
    func executeRequest<T: Decodable>(for api: Endpoint) async throws -> T {
        guard var urlComponents = URLComponents(string: api.fullPath) else {
            throw NetworkServiceError.invalidURL
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "app_id", value: ApiConstants.exchangeAppId)]
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = api.method
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300
        else {
            throw NetworkServiceError.invalidStatusCode
        }
        let parsedData = try JSONDecoder().decode(T.self, from: data)
        return parsedData
    }
}
