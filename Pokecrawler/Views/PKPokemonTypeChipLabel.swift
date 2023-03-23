//
//  PKPokemonTypeChipLabel.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokemonTypeChipLabel: UILabel {
    
    private var pokemonType: PKPokemonSpeciesType!
    
    var paddingInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    
    init(type: PKPokemonSpeciesType) {
        super.init(frame: .zero)
        pokemonType = type
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2.0
    }
    
    override func drawText(in rect: CGRect) {
        let insets = paddingInsets
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += paddingInsets.top + paddingInsets.bottom
            contentSize.width += paddingInsets.left + paddingInsets.right
            return contentSize
        }
    }
    
    private func configure() {
        text = pokemonType.type.name.rawValue.capitalized
        font = .preferredFont(forTextStyle: .callout)
        textAlignment = .center
        textColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        adjustsFontSizeToFitWidth = true
        backgroundColor = pokemonType.type.name.getColorForType()
        minimumScaleFactor = 0.75
        layer.masksToBounds = true
        
    }
}
