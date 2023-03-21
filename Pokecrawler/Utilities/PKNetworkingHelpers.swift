//
//  PKNetworkingHelpers.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

import Foundation

typealias NetworkHandler = (Result<Data, Error>) -> Void

enum NetworkingError: String, Error {
    case invalidURL = "Invalid URL"
    case invalidServerResponse = "Invalid response from the server. Make sure the username requested is entered is correctly and try again."
    case serverError = "Unable to complete your request due to a server error. Please bear with us while we fix this."
    case clientError = "Unable to complete your request due to a client error. Please check your internet connection and try again."
    case dataError = "Invalid data recieved from the server. This should not have happened. Please bear with us while we fix this problem"
    case decodeError = "The JSON data could not be decoded correctly for its model type."
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
