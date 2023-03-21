//
//  PKPokedexDataSource.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

enum PokeSections {
    case main
}

class PKPokedexDataSource: UICollectionViewDiffableDataSource<PokeSections, PKPokemonModel> {
    
    var pokemonData: [PKPokemonModel] = [] {
        didSet {
            updateDataSource(with: pokemonData)
        }
    }
    var hasMorePokemon = true
    
    func fetchPokeData() {
        PKNetworkManager().fetchPaginated(.getAllPokemon()) { [weak self] result in
            switch result {
            case .success(let pokeData):
                let jsonDecoder = PKPokemonModel.decoder
                let pokemon = pokeData.compactMap({ try? jsonDecoder.decode(PKPokemonModel.self, from: $0)}).sorted(by: { $0.id < $1.id })
                self?.pokemonData = pokemon
            case .failure(let error):
                print("Fetching pokemon failed with error", error)
            }
        }
        PKNetworkManager().fetch(.getPokemon(with: "1")) { [weak self] result in
            switch result {
            case .success(let pokeData):
                let jsonDecoder = PKPokemonModel.decoder
                if let pokemon = try? jsonDecoder.decode(PKPokemonModel.self, from: pokeData) {
                    self?.pokemonData = [pokemon]
                }
            case .failure(let error):
                print("Fetching pokemon failed with error", error)
            }
        }
    }
    
    func updateDataSource(with pokemonData: [PKPokemonModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<PokeSections, PKPokemonModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(pokemonData, toSection: .main)
        DispatchQueue.main.async {
            self.apply(snapshot, animatingDifferences: true)
        }
    }
}
