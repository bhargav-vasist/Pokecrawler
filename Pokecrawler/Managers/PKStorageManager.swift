//
//  PKStorageManager.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

// Ideally I'd like to keep a persistence layer manager abstracted from UI libraries but alas I must cut corners.

import UIKit

enum FavouriteUpdateOp {
    case add
    case remove
}

public class PKStorageManager {
    
    internal var fileManager: FileManager
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    func updateFavouritePokemon(with pokemon: PKPokemonModel, typeOfUpdate: FavouriteUpdateOp) async throws -> Bool {
        do {
            var favourites = try await retrievefavourites()
            switch typeOfUpdate {
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
