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
    
    private var networkManager: PKNetworkManager!
    
    var pokemonData: [PKPokemonModel] = [] {
        didSet {
            updateDataSource(with: pokemonData)
        }
    }
    
    // Check the API returned value to see if paginated calls are to be made
    var hasMorePokemon = true
    
    // Offset of the items already fetched
    var currentFetchOffset = 0
    
    // No of items to fetch per call
    let fetchItemLimit = 10
    
    // Paginated Call in Progress
    var isFetchingNextPage = false
    
    init(
        with networkManager: PKNetworkManager,
        for collectionView: UICollectionView,
        and cellProvider: @escaping UICollectionViewDiffableDataSource<PokeSections, PKPokemonModel>.CellProvider
    ) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
        self.networkManager = networkManager
    }
    
    // Called the first time every load.
    func fetchPokeData() {
        networkManager.fetchPaginated(.getAllPokemon(with: fetchItemLimit)) { [weak self] result in
            switch result {
            case .success(let pokeData):
                let jsonDecoder = PKPokemonModel.decoder
                let pokemon = pokeData.compactMap({
                    try? jsonDecoder.decode(PKPokemonModel.self, from: $0
                    )}
                ).sorted(by: { $0.id < $1.id })
                guard let unwrappedSelf = self else {
                    return
                }
                unwrappedSelf.currentFetchOffset += unwrappedSelf.fetchItemLimit
                unwrappedSelf.pokemonData = pokemon
            case .failure(let error):
                print("Fetching all Pokemon failed with error", error)
            }
        }
    }
    
    // Paginated calls to fetch more pokemon.
    func fetchEvenMorePokeData() {
        guard !isFetchingNextPage else {
            return
        }
        isFetchingNextPage = true
        networkManager.fetchPaginated(
            .getAllPokemon(
                with: fetchItemLimit, and: currentFetchOffset
            )
        ) { [weak self] result in
            switch result {
            case .success(let pokeData):
                let jsonDecoder = PKPokemonModel.decoder
                let extraPokemon = pokeData.compactMap({
                    try? jsonDecoder.decode(PKPokemonModel.self, from: $0
                    )}).sorted(by: { $0.id < $1.id })
                guard let unwrappedSelf = self else {
                    return
                }
                unwrappedSelf.currentFetchOffset += unwrappedSelf.fetchItemLimit
                unwrappedSelf.pokemonData.append(contentsOf: extraPokemon)
            case .failure(let error):
                print("Fetching paginated pokemon failed with error", error)
            }
            self?.isFetchingNextPage = false
        }
    }
    
    // Apply the new snapshot which includes additional items or filtered items (in the future)
    func updateDataSource(with pokemonData: [PKPokemonModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<PokeSections, PKPokemonModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(pokemonData, toSection: .main)
        DispatchQueue.main.async {
            self.apply(snapshot, animatingDifferences: true)
        }
    }
}
