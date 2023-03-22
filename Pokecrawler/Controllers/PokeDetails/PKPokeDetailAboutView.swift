//
//  PKPokeDetailAboutView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 22/03/23.
//

import UIKit

class PKPokeDetailAboutView: UIView {
    
    lazy var pokeDescriptionLabel: PKSecondaryTitleLabel = {
        let label = PKSecondaryTitleLabel(fontSize: 18, text: "")
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(with pokemonModel: PKPokemonModel) {
        self.init(frame: .zero)
        //        self.pokemonModel = pokemonModel
        configureView()
        configureLayout()
    }
    
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 24
    }
    
    private func configureLayout() {
        //        NSLayoutConstraint.activate([
        //            typeStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
        //            typeStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
        //            typeStack.heightAnchor.constraint(equalToConstant: 35),
        //        ])
    }
}
