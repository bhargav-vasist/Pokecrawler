//
//  PKStorageManager.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

// Ideally I'd like to keep a persistence layer manager abstracted from UI libraries but alas I must cut corners.

import UIKit

/// Defines types of operations used with persistence layer
enum PKStorageUpdateOperationKind {
    case add
    case remove
}

/// The default class for managing persistence and storage items for the app
public class PKStorageManager {
    
    /// File Manager instance used to retrieve Local Storage documents
    private var fileManager: FileManager
    
    /// User Defaults instance used for User Preferences and other ephemeral persisting
    /// Uses the standard suite by default unless specified
    private var userDefaults: UserDefaults

    /**
     Manages persistence across the app
     - Parameter fileManager: File Manager dependency. Uses default instance unless specified
     - Parameter userDefaults: User Default dependency. Uses the standard suite by default unless specified
     */
    init(fileManager: FileManager = FileManager.default, and userDefaults: UserDefaults = UserDefaults()) {
        self.fileManager = fileManager
        self.userDefaults = userDefaults
    }
    
    /**
     Retrieves object from User Defaults for the key
     - Parameter key: Object's key of UserDefaultKeys instance
     - Returns: Any object. Nil if the object doesn't exist
     */
    func getFromDefaults(for key: UserDefaultKeys) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }
    
    /**
     Updates object from User Defaults for the key specified
     - Parameter key: Object's key of UserDefaultKeys instance
     - Parameter value: Updated value for the key. Can be set to nil implicitly
     */
    func updateDefaults(for key: UserDefaultKeys, with value: Any?) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    /**
     - Parameter pokemon: The Pokemon to be favourited of instance PokemonModel
     - Parameter type: One of the base operations defined by PKStorageUpdateOperationKind
     - Returns: Boolean indicating success or failure of the operation
     */
    func updateFavouritePokemon(with pokemon: PKPokemonModel, of type: PKStorageUpdateOperationKind) async throws -> Bool {
        do {
            var favourites = try await retrievefavourites()
            switch type {
            case .add:
                guard !favourites.contains(where: { $0 == pokemon }) else {
                    throw StorageError.dedupeError
                }
                favourites.append(pokemon)
                return try save(favPokemon: favourites)
            case .remove:
                guard favourites.contains(where: { $0 == pokemon }) else {
                    throw StorageError.dedupeError
                }
                favourites.removeAll { $0 == pokemon }
                return try save(favPokemon: favourites)
            }
        } catch {
            throw error
        }
    }
    
    /**
     - Returns: Array of pokemon that have been saved
     */
    func retrievefavourites() async throws -> [PKPokemonModel] {
        let favouritesURL = URL(
            fileURLWithPath: "favourites",
            relativeTo: fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        )
        guard FileManager.default.fileExists(atPath: favouritesURL.path) else {
            // We've never saved to favourites before.
            // So here is where we create the save file for the very first time in our app's document directory.
            let emptyfavourites = [PKPokemonModel]()
            let encoder = PKPokemonModel.encoder
            let emptyfavouritesData = try? encoder.encode(emptyfavourites)
            try? emptyfavouritesData?.write(to: favouritesURL, options: .atomicWrite)
            return emptyfavourites
        }
        do {
            let favouritesData = try Data(contentsOf: favouritesURL)
            let decoder = PKPokemonModel.decoder
            let favourites = try decoder.decode([PKPokemonModel].self, from: favouritesData)
            return favourites
        } catch {
            print(error.localizedDescription)
            throw StorageError.retrieveFavouritesError
        }
    }
    
    /**
     - Parameter favPokemon: The Array of Pokemon to be saved of instance PokemonModel
     - Returns: Boolean indicating success or failure of the operation
     */
    private func save(favPokemon: [PKPokemonModel]) throws -> Bool {
        let favouritesURL = URL(
            fileURLWithPath: "favourites",
            relativeTo: fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        )
        do {
            let encoder = PKPokemonModel.encoder
            let favouritesData = try encoder.encode(favPokemon)
            try favouritesData.write(to: favouritesURL, options: .atomicWrite)
            return true
        } catch {
            print(error.localizedDescription)
            throw StorageError.saveFavouritesError
        }
    }
}
