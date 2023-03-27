//
//  PKNetworkingHelpers.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

import UIKit

/// Return handler for all fetch requests
public typealias NetworkHandler = (Result<Data, Error>) -> Void

/// Return handler for paginated requests with multiple requests
public typealias NetworkPaginatedHandler = (Result<[Data], Error>) -> Void

/// Interface exposing required methods for a Network Layer Manager
public protocol NetworkManagingKind {
    
    /// The NetworkSession object used to interface with URLSession protocols
    var session: NetworkSession { get }
    
    /// Used to cache Images
    var cache: NSCache<NSString, UIImage> { get set }
    
    /**
     Make a Network Fetch Request.
     Uses URLSessionDataTask under the hood
     - Parameter endpoint: The Endpoint to be fetched
     - Parameter completionHandler: A Result<Data, Error> of the Fetch Task
     */
    func fetch(_ endpoint: Endpoint, completionHandler: @escaping NetworkHandler)

    /**
     Make a Network Fetch Request for paginated results.
     Automatically fetches nested data for each resulting URL
     Uses URLSessionDataTask under the hood with DispatchGroups for managing dependencies with Multiprocesses
     - Parameter endpoint: The Endpoint to be fetched
     - Parameter completionHandler: A Result<Data, Error> of the Fetch Task
     */
    func fetchPaginated(_ endpoint: Endpoint, completionHandler: @escaping NetworkPaginatedHandler)
    
    /**
     Fetches an image from the web with automatic caching.
     Uses URLSessionDataTask under the hood
     - Parameter urlString: Image URL
     - Parameter completionHandler: A Result<UIImage, Error> of the Fetch Task
     - Returns: The URLSessionDataTask for the fetch. Reference can be used to cancel ongoing requests
     */
    func getAvatarImage(
        urlString: String,
        completionHandler: @escaping (Result<UIImage, NetworkingError>) -> Void
    ) -> URLSessionDataTask?
}

// A list of commonly encountered Networking Errors
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

/// Separating URLSession and Network Manager instances
/// helps us acheive full mocking instead of partial mocking
public protocol NetworkSession {
    /**
     Make a Network Fetch Request.
     Uses URLSession under the hood
     - Parameter url: The URL to be fetched. Generally comes from the Endpoint
     - Parameter handler: A Result<Data, Error> of the Fetch Task
     - Returns: The URLSessionDataTask for the fetch. Reference can be used to cancel ongoing requests.
     */
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
    /**
     Create an endpoint from a string referencing an URL
     Useful for when API requests return URLs that need to be further fetched
     - Parameter urlString: The URL string of the endpoint
     **/
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

    /// Constructs an URL from the path and query items
    /// We still have to keep 'url' as an optional, since we're
    /// dealing with dynamic components that could be invalid.
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

// Define all endpoints here
public extension Endpoint {
    
    /**
     Fetches all available Pokemon. Note that this requires further requests to get full data
     By default, the limit is set to 20 with subsequent offsets of 20
     - Parameter limit: Number of Items to fetch every request
     - Parameter offset: Offset of items already fetched
    */
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
    
    /**
     Fetches a Single Pokemon. Must supply the Pokemon ID or it's Name
     - Parameter idOrName: String for Pokemon ID or Pokemon's Name
     */
    static func getPokemon(with idOrName: String) -> Self {
        Endpoint(path: "/api/v2" + "/pokemon/\(idOrName)")
    }
    
    /**
     Fetches a Pokemon's Species info. Must supply the Pokemon ID or it's Name
     - Parameter idOrName: String for Pokemon ID or Pokemon's Name
     */
    static func getPokemonSpecies(with idOrName: String) -> Self {
        Endpoint(path: "/api/v2" + "/pokemon-species/\(idOrName)")
    }
    
    /**
     Fetches Pokemon's Stats. Must supply the Pokemon ID or it's Name
     - Parameter idOrName: String for Pokemon ID or Pokemon's Name
     */
    static func getPokemonStats(with idOrName: String) -> Self {
        Endpoint(path: "/api/v2" + "/stat/\(idOrName)")
    }
}
