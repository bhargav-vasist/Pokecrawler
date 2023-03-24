//
//  NetworkSessionStub.swift
//  PokecrawlerTests
//
//  Created by Bhargav Vasist on 24/03/23.
//

import XCTest
@testable import Pokecrawler

class NetworkSessionStub: NetworkSession {
    var returnData = Data()
    func loadData(_ url: URL, then handler: @escaping Pokecrawler.NetworkHandler) -> URLSessionDataTask? {
        handler(.success(returnData))
        return nil
    }
}
