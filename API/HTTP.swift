//
//  HTTP.swift
//
//  Created by Tim Roesner on 4/3/19.
//  Copyright © 2019 Tim Roesner. All rights reserved.
//

import Foundation
import Combine

struct HTTP {
    static func request<DecodableType: Decodable>(_ decodableType: DecodableType.Type, url: URL?, params: [URLQueryItem] = [], headers: [String: String] = [:]) async throws -> DecodableType {
        guard let url = url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = params
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(decodableType, from: data)
    }
}
