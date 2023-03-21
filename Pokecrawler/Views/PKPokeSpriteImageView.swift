//
//  PKPokeSpriteImageView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//


import UIKit

class PKPokeSpriteImageView: UIImageView {

    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFit
//        layer.borderWidth = 1.0
//        layer.borderColor = UIColor.systemGray2.cgColor
        layer.cornerRadius = 16.0
        clipsToBounds = true
        image = UIImage(named: "pokeball")
    }
    
}
