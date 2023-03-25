//
//  PKNetworkingHelpers.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

import UIKit

public typealias NetworkHandler = (Result<Data, Error>) -> Void
public typealias NetworkPaginatedHandler = (Result<[Data], Error>) -> Void

public protocol NetworkManagingKind {
    var session: NetworkSession { get }
    
    var cache: NSCache<NSString, UIImage> { get set }
    
    func fetch(_ endpoint: Endpoint, completionHandler: @escaping NetworkHandler)

    func fetchPaginated(_ endpoint: Endpoint, completionHandler: @escaping NetworkPaginatedHandler)
    
    func getAvatarImage(
        urlString: String,
        completionHandler: @escaping (Result<UIImage, NetworkingError>) -> Void
    ) -> URLSessionDataTask?
}

public enum NetworkingError: String, Error {
    case invalidURL = "Invalid URL"
    case invalidServerResponse =
            "Invalid response from the server. Make sure the username requested is entered is correctly and try again."
    case serverError = "Unable to complete your request due to a server error. Please bear with us while we fix this."
    case clientError =
            "Unable to complete your request due to a client error. Please check your internet connection and try again."
    case dataError =
            "Invalid data recieved from the server. This should not have happened. Please bear with us while we fix this problem"
    case decodeError = "The JSON data could not be decoded correctly for its model type."
    case testingError = "Task failed successfully"
}

public protocol NetworkSession {
    @discardableResult
    func loadData(
        _ url: URL,
        then handler: @escaping NetworkHandler
    ) -> URLSessionDataTask?
}

// Inspired by https://www.swiftbysundell.com/articles/constructing-urls-in-swift/
public struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
}

public extension Endpoint {
    // Keep it backwards compatible
    init(from urlString: String) {
        if let url = URL(string: urlString) {
            path = url.path
            if let queryParams = URLComponents(string: urlString)?.queryItems {
                queryItems = queryParams
            }
        } else {
            path = ""
        }
    }
    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "pokeapi.co"
        components.path = path
        if !queryItems.isEmpty {
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

public extension Endpoint {
    static func getAllPokemon(with limit: Int? = nil, and offset: Int? = nil) -> Self {
        var queryItems: [URLQueryItem] = []
        if let limitValue = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limitValue)))
        }
        if let offsetValue = offset {
            queryItems.append(URLQueryItem(name: "offset", value: String(offsetValue)))
        }
        return Endpoint(path: "/api/v2" + "/pokemon", queryItems: queryItems)
    }
    
    static func getPokemon(with idOrName: String) -> Self {
        Endpoint(path: "/api/v2" + "/pokemon/\(idOrName)")
    }
    
    static func getPokemonSpecies(with idOrName: String) -> Self {
        Endpoint(path: "/api/v2" + "/pokemon-species/\(idOrName)")
    }
    
    static func getPokemonStats(with idOrName: String) -> Self {
        Endpoint(path: "/api/v2" + "/stat/\(idOrName)")
    }
}
