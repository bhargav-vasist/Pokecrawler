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
    
    var pokemonData: [PKPokemonModel] = []
    var hasMorePokemon = true
    
    func updateDataSource(with pokemonData: [PKPokemonModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<PokeSections, PKPokemonModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(pokemonData, toSection: .main)
        DispatchQueue.main.async {
            self.apply(snapshot, animatingDifferences: true)
        }
    }

}
