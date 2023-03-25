//
//  PKNetworkManager.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

// Ideally I'd like to keep a network layer manager abstracted from UI libraries but alas I must cut corners.
import UIKit

class PKNetworkManager: NetworkManagingKind {
    internal let session: NetworkSession
    
    internal var cache = NSCache<NSString, UIImage>()
    
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    func fetch(_ endpoint: Endpoint, completionHandler: @escaping NetworkHandler) {
        if let requestURL = endpoint.url {
            let request = session.loadData(requestURL) { result in
                switch result {
                case .success(let data):
                    completionHandler(.success(data))
                case .failure(let error):
                    print("Failed network request with error - ", error)
                }
            }
            request?.resume()
        } else {
            completionHandler(.failure(NetworkingError.invalidURL))
        }
    }
    
    func fetchPaginated(_ endpoint: Endpoint, completionHandler: @escaping NetworkPaginatedHandler) {
        let dispatchGroup = DispatchGroup()
        var paginatedArray: [Data] = []
        
        if let requestURL = endpoint.url {
            let request = session.loadData(requestURL) {  result in
                switch result {
                case .success(let data):
                    let decoder = PKPaginatedResponseModel.decoder
                    if let response = try? decoder.decode(PKPaginatedResponseModel.self, from: data),
                       let results = response.results {
                        for item in results {
                            if let itemURL = item.url {
                                dispatchGroup.enter()
                                let endpoint = Endpoint(from: itemURL)
                                self.fetch(endpoint) { result in
                                    switch result {
                                    case .success(let itemDetailData):
                                        paginatedArray.append(itemDetailData)
                                    case .failure:
                                        break
                                    }
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("Failed network request with error -", error)
                }
                
                dispatchGroup.notify(queue: .main) {
                    completionHandler(.success(paginatedArray))
                }
            }
            request?.resume()
        } else {
            completionHandler(.failure(NetworkingError.invalidURL))
        }
    }
    
    func getAvatarImage(
        urlString: String,
        completionHandler: @escaping (Result<UIImage, NetworkingError>) -> Void
    ) -> URLSessionDataTask? {
        // check cache first
        if let image = cache.object(forKey: NSString(string: urlString)) {
            completionHandler(.success(image))
            return nil
        }
        
        // if it doesn't exist then go ahead and create datatask to download the image
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(.invalidURL))
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if error != nil {
                completionHandler(.failure(.invalidServerResponse))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completionHandler(.failure(.serverError))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.dataError))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completionHandler(.failure(.dataError))
                return
            }
            self?.cache.setObject(image, forKey: NSString(string: urlString))
            completionHandler(.success(image))
        }
        task.resume()
        return task
    }
}
