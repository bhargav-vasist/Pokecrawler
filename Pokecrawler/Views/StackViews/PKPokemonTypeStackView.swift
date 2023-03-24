//
//  PKPokemonTypeStackView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokemonTypeStackView: UIStackView {
    private var pokemonTypes: [PKPokemonSpeciesType]!
    
    init(with types: [PKPokemonSpeciesType]) {
        super.init(frame: .zero)
        pokemonTypes = types
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = 12
        pokemonTypes.forEach { addArrangedSubview(PKPokemonTypeChipLabel(type: $0)) }
    }
}
