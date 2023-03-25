//
//  PKPokemonCollectionViewCell.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokemonCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: PKPokemonCollectionViewCell.self)

    var imageLoadingTask: URLSessionDataTask?
    
    lazy var pokeCardView: PKPokemonCard = {
       let card = PKPokemonCard()
        return card
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadingTask?.cancel()
    }
    
    func set(pokemon: PKPokemonModel) {
        pokeCardView.populateFields(with: pokemon)
        if let pokeSprite = pokemon.sprites.other?.home?.frontDefault {
            imageLoadingTask = PKNetworkManager().getAvatarImage(urlString: pokeSprite) { [weak self] result in
                switch result {
                case .failure:
                    break
                case .success(let image):
                    self?.pokeCardView.updateImage(with: image)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        contentView.addSubview(pokeCardView)
        NSLayoutConstraint.activate([
            pokeCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pokeCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pokeCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pokeCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
    }
}
