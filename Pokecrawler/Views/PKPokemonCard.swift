//
//  PKPokemonCard.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokemonCard: UIView {
    let pokeSpriteImageView = PKPokeSpriteImageView()
    let pokemonNameLabel = PKPrimaryTitleLabel(text: "")
    let pokemonIDLabel = PKSecondaryTitleLabel(fontSize: 18, text: "")
    
    lazy var mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verticalStackView)
        return view
    }()
    
    lazy var verticalStackView: PKVertStackView = {
        let sv = PKVertStackView(with: [pokeSpriteImageView, pokemonNameLabel, pokemonIDLabel])
        return sv
    }()
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(mainView)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .FlatUI.emerald
        layer.cornerRadius = 16.0
        clipsToBounds = true
        
        NSLayoutConstraint.activate([
            pokeSpriteImageView.heightAnchor.constraint(equalTo: pokeSpriteImageView.widthAnchor),
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func populateFields(with pokemon: PKPokemonModel) {
        pokemonNameLabel.text = pokemon.name?.capitalized
        // If the pokemon has no ID, then it is not a pokemon
        pokemonIDLabel.text = "#" + String(pokemon.id)
    }
    
    func updateImage(with image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.pokeSpriteImageView.image = image
        }
    }
}
