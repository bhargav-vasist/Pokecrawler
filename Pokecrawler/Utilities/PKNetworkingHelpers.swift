//
//  PKNetworkingHelpers.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

import Foundation

typealias NetworkHandler = (Result<Data, Error>) -> Void

enum NetworkingError: Error {
    case invalidURL
    case serverError(String)
    case invalidServerResponse
}

protocol NetworkSession {
    @discardableResult
    func loadData(
        _ url: URL,
        then handler: @escaping NetworkHandler
    ) -> URLSessionDataTask?
}

// Inspired by https://www.swiftbysundell.com/articles/constructing-urls-in-swift/
struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem] = []
}

extension Endpoint {
    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "pokeapi.co"
        components.path = "/api/v2" + path
        if (!queryItems.isEmpty) {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }
        print("components", components)
        return url
    }
}

extension Endpoint {
    static var getAllPokemon: Self {
        Endpoint(path: "/pokemon")
    }
    
    static func getPokemon(with idOrName: String) -> Self {
        Endpoint(path: "/pokemon/\(idOrName)")
    }
}
