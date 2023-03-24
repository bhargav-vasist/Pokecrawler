//
//  EndpointTests.swift
//  PokecrawlerTests
//
//  Created by Bhargav Vasist on 24/03/23.
//

import XCTest
@testable import Pokecrawler

final class EndpointTests: XCTestCase {
    
    func testURLGeneration() throws {
        let endpoint = Endpoint(path: "/api/v2" + "/pokemon", queryItems: [])
        let generatedURL = try XCTUnwrap(endpoint.url)
        XCTAssertEqual(generatedURL, URL(string: "https://pokeapi.co/api/v2/pokemon"))
    }
    
    func testFailingURLGeneration() throws {
        let endpoint = Endpoint(path: "/pokemon", queryItems: [])
        let generatedURL = try XCTUnwrap(endpoint.url)
        XCTAssertNotEqual(generatedURL, URL(string: "https://pokeapi.co/api/v2/pokemon"))
    }
    
    func testURLGenerationWithParams() throws {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "limit", value: "10"))
        queryItems.append(URLQueryItem(name: "offset", value: "10"))
        let endpoint = Endpoint(path: "/api/v2" + "/pokemon", queryItems: queryItems)
        let generatedURL = try XCTUnwrap(endpoint.url)
        XCTAssertEqual(generatedURL, URL(string: "https://pokeapi.co/api/v2/pokemon?limit=10&offset=10"))
    }
    
    func testURLGenerationFromURLString() throws {
        let endpoint = Endpoint(from: "https://pokeapi.co/api/v2/pokemon-species/35")
        let generatedURL = try XCTUnwrap(endpoint.url)
        XCTAssertEqual(generatedURL, URL(string: "https://pokeapi.co/api/v2/pokemon-species/35"))
    }
}
