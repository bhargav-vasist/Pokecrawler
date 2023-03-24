//
//  ImageCacheFake.swift
//  PokecrawlerTests
//
//  Created by Bhargav Vasist on 24/03/23.
//

import UIKit

struct ImageCacheFake {
    var fakedCache = NSCache<NSString, UIImage>()
    
    var fakeImage = UIImage(systemName: "figure.fall")!
    var fakeImageKey = "https://fake.com"
    
    func getCachedData() -> NSCache<NSString, UIImage> {
        fakedCache.setObject(fakeImage, forKey: NSString(string: fakeImageKey))
        return fakedCache
    }
}

