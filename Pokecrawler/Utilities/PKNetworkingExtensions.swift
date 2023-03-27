//
//  PKNetworkingExtensions.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

import Foundation

// Inspired by https://www.swiftbysundell.com/articles/constructing-urls-in-swift/
extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        self = url
    }
}

// Inspired by https://www.swiftbysundell.com/articles/mocking-in-swift/
extension URLSession: NetworkSession {
    
    /**
     Interfaces URLSession to conform to our Partial Mocking Protocol
     - Parameter url: URL to be fetched. Generally comes from Endpoint
     - Parameter handler: A Result<Data, Error> of the Fetch Task
     */
    @discardableResult
    public func loadData(
        _ url: URL,
        then handler: @escaping NetworkHandler
    ) -> URLSessionDataTask? {
        
        let task = dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading data with error - ", error.localizedDescription)
                handler(.failure(NetworkingError.serverError))
            } else if let data = data {
                handler(.success(data))
            } else {
                handler(.failure(NetworkingError.invalidServerResponse))
            }
        }
        return task
        
    }
}
