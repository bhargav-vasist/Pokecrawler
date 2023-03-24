//
//  NetworkRequestTests.swift
//  PokecrawlerTests
//
//  Created by Bhargav Vasist on 24/03/23.
//

import XCTest
@testable import Pokecrawler

final class NetworkRequestTests: XCTestCase {
    
    func testPaginatedCall() throws {
        let stubbedSession = NetworkSessionStub()
        let fakedCache = ImageCacheFake()
        let networkManager = NetworkManagerMock(session: stubbedSession, cache: fakedCache.getCachedData())
        let fakedResponse = PaginatedResponseFake()
        networkManager.fetchPaginated(fakedResponse.fakedEndpoint) { result in
            switch result {
            case .success(let dataArray):
                XCTAssertEqual(dataArray.count, fakedResponse.getResponseData().count)
                XCTAssertEqual(networkManager.fetchPaginationCallCount, 1)
                XCTAssertEqual(networkManager.fetchCallCount, fakedResponse.getResponseData().count)
            case .failure(let error):
                XCTAssertEqual(networkManager.fetchPaginationCallCount, 1)
                XCTAssertEqual(networkManager.fetchCallCount, 0)
                XCTAssertEqual(error.localizedDescription, NetworkingError.testingError.localizedDescription)
            }
        }
    }
}
