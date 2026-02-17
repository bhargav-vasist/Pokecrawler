//
//  PKPokeDetailAboutView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 22/03/23.
//

import UIKit

class PKPokeDetailAboutView: UIView {

    // MARK: - Properties
    private var pokemonModel: PKPokemonModel!

    // MARK: - Views
    lazy private var typeStack: PKPokemonTypeStackView = {
        let stack = PKPokemonTypeStackView(with: pokemonModel.types)
        return stack
    }()

    lazy private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "Loading..."
        return label
    }()

    lazy private var statsCard: PKPokeDetailCardView = {
        let viewModel = PKPokeDetailCardViewModel(with: pokemonModel)
        let card = PKPokeDetailCardView(with: viewModel)
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()
    
    lazy private var abilitiesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Abilities"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()
    
    lazy private var abilitiesStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    convenience init(with pokemonModel: PKPokemonModel) {
        self.init(frame: .zero)
        self.pokemonModel = pokemonModel
        setupView()
        setupLayout()
        populateAbilities()
    }

    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(typeStack)
        addSubview(descriptionLabel)
        addSubview(statsCard)
        addSubview(abilitiesLabel)
        addSubview(abilitiesStack)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            typeStack.topAnchor.constraint(equalTo: topAnchor),
            typeStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            typeStack.heightAnchor.constraint(equalToConstant: 30),
        
            descriptionLabel.topAnchor.constraint(equalTo: typeStack.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        
            statsCard.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            statsCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            statsCard.trailingAnchor.constraint(equalTo: trailingAnchor),
            statsCard.heightAnchor.constraint(equalToConstant: 70),
            
            abilitiesLabel.topAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: 24),
            abilitiesLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            abilitiesStack.topAnchor.constraint(equalTo: abilitiesLabel.bottomAnchor, constant: 12),
            abilitiesStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            abilitiesStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func populateAbilities() {
        guard let abilities = pokemonModel.abilities else { return }
        
        let typeColor = pokemonModel.types.first?.type.name.getColorForType() ?? .systemGray
        
        for ability in abilities {
            let chip = makeAbilityChip(ability, color: typeColor)
            abilitiesStack.addArrangedSubview(chip)
        }
    }
    
    private func makeAbilityChip(_ ability: PKPokemonAbility, color: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 10
        
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.text = ability.ability.name.replacingOccurrences(of: "-", with: " ").capitalized
        name.font = .preferredFont(forTextStyle: .body)
        
        container.addSubview(name)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 44),
            name.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            name.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        if ability.isHidden {
            let badge = UILabel()
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.text = "Hidden"
            badge.font = .systemFont(ofSize: 11, weight: .semibold)
            badge.textColor = .white
            badge.backgroundColor = color
            badge.textAlignment = .center
            badge.layer.cornerRadius = 6
            badge.clipsToBounds = true
            container.addSubview(badge)
            
            NSLayoutConstraint.activate([
                badge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
                badge.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                badge.widthAnchor.constraint(equalToConstant: 55),
                badge.heightAnchor.constraint(equalToConstant: 22)
            ])
        }
        
        return container
    }

    // MARK: - Public
    func loadView(with species: PKPokemonSpecies) {
        DispatchQueue.main.async { [weak self] in
            let text = species.flavorTextEntries?.first { $0.language?.name == "en" }?.flavorText?
                .replacingOccurrences(of: "\n", with: " ")
                .replacingOccurrences(of: "\u{0C}", with: " ")
            self?.descriptionLabel.text = text ?? "No description available."
        }
    }
}
