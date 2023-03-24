//
//  NetworkSessionMock.swift
//  PokecrawlerTests
//
//  Created by Bhargav Vasist on 24/03/23.
//

import XCTest
@testable import Pokecrawler

class NetworkManagerMock: NetworkManagingKind {
    var session: Pokecrawler.NetworkSession
    
    var cache: NSCache<NSString, UIImage>
    
    var fetchCallCount = 0
    var fetchPaginationCallCount = 0
    
    init(session: Pokecrawler.NetworkSession, cache: NSCache<NSString, UIImage>) {
        self.session = session
        self.cache = cache
    }
    
    func fetch(_ endpoint: Pokecrawler.Endpoint, completionHandler: @escaping Pokecrawler.NetworkHandler) {
        fetchCallCount += 1
        session.loadData(endpoint.url!) { result in
            switch result {
            case .success(let data):
                completionHandler(.success(data))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchPaginated(_ endpoint: Pokecrawler.Endpoint, completionHandler: @escaping Pokecrawler.NetworkPaginatedHandler) {
        fetchPaginationCallCount += 1
        let fakedResponse = PaginatedResponseFake()
        var totalResponses: [Data] = []
        fakedResponse.getResponseData().results?.forEach({ item in
            
            fetch(Endpoint(from: item.url!)) { result in
                switch result {
                case .success(let data):
                    totalResponses.append(data)
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        })
        completionHandler(.success(totalResponses))
    }
    
    
    func getAvatarImage(urlString: String, completionHandler: @escaping (Result<UIImage, Pokecrawler.NetworkingError>) -> Void) -> URLSessionDataTask? {
        // TODO: - check for corrrect caching
        return nil
    }
}
