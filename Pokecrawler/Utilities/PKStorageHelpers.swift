//
//  PKStorageHelpers.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 26/03/23.
//

import Foundation

/// Static Key Structure for User Preferences
enum UserDefaultKeys: String {
    case darkModeToggle = "DarkModeToggle"
    case systemDefault = "SystemDefault"
}

/// A list of errors we might encounter trying to persist data in our app
public enum StorageError: String, Error {
    case invalidURL = "Invalid URL"
    case decodeError = "The JSON data could not be decoded correctly for its model type."
    case testingError = "Task failed successfully"
    case saveFavouritesError = "Saving to favourite Pokemon failed"
    case retrieveFavouritesError = "Retrieving favourite Pokemon failed"
    case dedupeError = "This Pokemon already exists in storage. Cannot save!"
}
