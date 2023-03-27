//
//  PKPaginatedResponseModel.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import Foundation

/// The default response from the API for fetch requests
/// Will contain named resources without data
/// Requires further API calls to get full data
public struct PKPaginatedResponseModel: Codable {
    
    /// Named resources. Needs to be fetched again to get full data
    struct PKPaginatedResults: Codable {
        var name: String?
        var url: String?
    }
    
    /// Total count of items in the path
    var count: Int?
    
    /// Next item in the API path. Can be used for pre-fetching
    var next: String?
    
    /// Previous item in the API path. Returns nil for the first call
    var previous: String?
    
    /// The named resources that need further fetching
    var results: [PKPaginatedResults]?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
