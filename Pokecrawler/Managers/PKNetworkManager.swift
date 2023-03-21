//
//  PKNetworkManager.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

// Ideally I'd like to keep a network layer manager abstracted from UI libraries but alas I must cut corners.
import UIKit

class PKNetworkManager {
    private let session: NetworkSession
    
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    func fetch(_ endpoint: Endpoint, completionHandler: @escaping NetworkHandler) {
        if let requestURL = endpoint.url {
            print("Url is", requestURL)
            let request = session.loadData(requestURL) { result in
                switch result {
                case .success(let data):
                    let jsonDecoder = PKPokemonModel.decoder
                    if let pokemon = try? jsonDecoder.decode(PKPokemonModel.self, from: data) {
                        print("Got data", pokemon)
                    }
                case .failure(let error):
                    print("Failed network request", error)
                }
            }
            request?.resume()
        } else {
            completionHandler(.failure(NetworkingError.invalidURL))
        }
    }
}
