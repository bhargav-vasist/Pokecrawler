//
//  PaginatedResponseFake.swift
//  PokecrawlerTests
//
//  Created by Bhargav Vasist on 24/03/23.
//

import Foundation
@testable import Pokecrawler

struct PaginatedResponseFake {
    
    var fakedURL = "https://fake.com"
    var fakedEndpoint = Endpoint(from: "https://fake.com")
    
    func getResponseData() -> PKPaginatedResponseModel {
        let fakeArray = [
            PKPaginatedResponseModel.PKPaginatedResults(name: "Fake 1", url: fakedURL),
            PKPaginatedResponseModel.PKPaginatedResults(name: "Fake 2", url: fakedURL),
            PKPaginatedResponseModel.PKPaginatedResults(name: "Fake 3", url: fakedURL),
            PKPaginatedResponseModel.PKPaginatedResults(name: "Fake 4", url: fakedURL),
            PKPaginatedResponseModel.PKPaginatedResults(name: "Fake 5", url: fakedURL),
            PKPaginatedResponseModel.PKPaginatedResults(name: "Fake 6", url: fakedURL),
            PKPaginatedResponseModel.PKPaginatedResults(name: "Fake 7", url: fakedURL),
            PKPaginatedResponseModel.PKPaginatedResults(name: "Fake 8", url: fakedURL),
            PKPaginatedResponseModel.PKPaginatedResults(name: "Fake 9", url: fakedURL),
            PKPaginatedResponseModel.PKPaginatedResults(name: "Fake 10", url: fakedURL)
        ]
        var fakedData = PKPaginatedResponseModel(count: fakeArray.count, next: nil, previous: nil, results: fakeArray)
        return fakedData
    }
}
