//
//  PKPaginatedResponseModel.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import Foundation

struct PKPaginatedResponseModel: Codable {
    
    struct PKPaginatedResults: Codable {
        var name: String?
        var url: String?
    }
    
    var count: Int?
    var next: String?
    var previous: String?
    var results: [PKPaginatedResults]?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
