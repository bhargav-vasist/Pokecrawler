//
//  PKPokemonCard.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokemonCard: UIView {
    
    // MARK: - Views
    let pokeSpriteImageView = PKPokeSpriteImageView()
    
    /// Pokemon name with proper truncation for long names (e.g., "Charizard-Gmax")
    lazy var pokemonNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    /// Pokemon ID badge (e.g., "#025")
    lazy var pokemonIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.numberOfLines = 1
        return label
    }()
    
    /// Container for the labels with padding
    lazy var labelContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pokemonNameLabel)
        view.addSubview(pokemonIDLabel)
        return view
    }()
    
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pokeSpriteImageView, labelContainer])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    private var currentPokemon: PKPokemonModel?
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        configure()
        configureAccessibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configure() {
        addSubview(verticalStackView)
        translatesAutoresizingMaskIntoConstraints = false
        
        // Card styling
        layer.cornerRadius = 16.0
        clipsToBounds = false
        
        // Subtle shadow for depth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.15
        
        // Inner container clips content
        verticalStackView.layer.cornerRadius = 16.0
        verticalStackView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            // Stack fills the card
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Sprite is square
            pokeSpriteImageView.heightAnchor.constraint(equalTo: pokeSpriteImageView.widthAnchor),
            
            // Label container has fixed height
            labelContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            
            // Name label with horizontal padding
            pokemonNameLabel.topAnchor.constraint(equalTo: labelContainer.topAnchor, constant: 4),
            pokemonNameLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 8),
            pokemonNameLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -8),
            
            // ID label below name
            pokemonIDLabel.topAnchor.constraint(equalTo: pokemonNameLabel.bottomAnchor, constant: 2),
            pokemonIDLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 8),
            pokemonIDLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -8),
            pokemonIDLabel.bottomAnchor.constraint(lessThanOrEqualTo: labelContainer.bottomAnchor, constant: -8)
        ])
    }
    
    private func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
    
    // MARK: - Public Methods
    func populateFields(with pokemon: PKPokemonModel) {
        currentPokemon = pokemon
        
        // Format name: replace hyphens with spaces for readability, capitalize properly
        let displayName = pokemon.name
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
        
        pokemonNameLabel.text = displayName
        pokemonIDLabel.text = String(format: "#%03d", pokemon.id)
        
        // Set background color based on type
        let typeColor = pokemon.types.first?.type.name.getColorForType() ?? .systemGray
        verticalStackView.backgroundColor = typeColor
        
        // Update shadow color to match type for cohesive look
        layer.shadowColor = typeColor.cgColor
        
        // Accessibility
        accessibilityLabel = "\(displayName), number \(pokemon.id)"
        if let typeName = pokemon.types.first?.type.name {
            accessibilityLabel? += ", \(typeName.rawValue) type"
        }
        accessibilityHint = "Double tap to view details"
    }
    
    func updateImage(with image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.pokeSpriteImageView.image = image
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update shadow path for performance
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16.0).cgPath
    }
}
