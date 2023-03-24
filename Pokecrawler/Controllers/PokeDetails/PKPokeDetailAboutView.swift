//
//  PKPokeDetailAboutView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 22/03/23.
//

import UIKit

class PKPokeDetailAboutView: UIView {
    
    lazy private var typeStack: PKPokemonTypeStackView = {
        let sv = PKPokemonTypeStackView(with: pokemonModel.types)
        addSubview(sv)
        return sv
    }()
    
    lazy var pokeDescriptionLabel: PKSecondaryTitleLabel = {
        let label = PKSecondaryTitleLabel(fontSize: 18, text: "")
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .natural
        addSubview(label)
        return label
    }()
    
    lazy var pokeBodyStatView: PKPokeDetailCardView = {
        let vm = PKPokeDetailCardViewModel(with: pokemonModel)
        let bsView = PKPokeDetailCardView(with: vm)
        bsView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bsView)
        return bsView
    }()
    
    private var pokemonModel: PKPokemonModel!
    private var pokemonSpecies: PKPokemonSpecies?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(with pokemonModel: PKPokemonModel) {
        self.init(frame: .zero)
        self.pokemonModel = pokemonModel
        configureView()
        configureLayout()
    }
    
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            typeStack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            typeStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            typeStack.heightAnchor.constraint(equalToConstant: 35),
            
            pokeDescriptionLabel.topAnchor.constraint(equalTo: typeStack.bottomAnchor, constant: 16),
            pokeDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            pokeDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            pokeBodyStatView.topAnchor.constraint(equalTo: pokeDescriptionLabel.bottomAnchor, constant: 16),
            pokeBodyStatView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pokeBodyStatView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            pokeBodyStatView.heightAnchor.constraint(equalToConstant: 65)
        ])
    }
    
    func loadView(with pokeSpecies: PKPokemonSpecies) {
        pokemonSpecies = pokeSpecies
        DispatchQueue.main.async {
            // Filters out UTF characters used in old Nintendo systems flavortext
            self.pokeDescriptionLabel.text = self.pokemonSpecies?.flavorTextEntries?.first(where: { $0.language?.name == "en"})?.flavorText?.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\u{0C}", with: " ")
        }
    }
    
}
