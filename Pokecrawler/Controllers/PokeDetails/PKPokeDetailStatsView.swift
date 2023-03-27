//
//  PKPokeDetailStatsView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 23/03/23.
//

import UIKit

class PKPokeDetailsStatsView: UIView {
    
    // MARK: - Models
    private var pokemonModel: PKPokemonModel!
    
    // MARK: - View
    lazy private var mainStackView: UIStackView = {
        let stack = PKVertStackView(with: [])
        stack.alignment = .leading
        stack.distribution = .fill
        addSubview(stack)
        return stack
    }()
    
    // MARK: - Lifecycle Methods
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
        if let stats = pokemonModel.stats {
            stats.forEach { stat in
                guard let baseStat = PKPokemonBaseStat(rawValue: stat.stat.name) else {
                    return
                }
                let statRow = PKPokeDetailsStatsRowView(
                    with: baseStat,
                    of: stat.baseStat,
                    and: pokemonModel.types.first?.type.name
                )
                mainStackView.addArrangedSubview(statRow)
            }
        }
    }
    
    // MARK: - Layouts and Constraints
    private func configureLayout() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
}

class PKPokeDetailsStatsRowView: UIView {
    
    // MARK: - Models
    private var statName: PKPokemonBaseStat!
    private var statValue: Int!
    private var pokeType: PKPokemonBaseType?
    
    // MARK: - Computed properties
    private var scaledBaseStatValue: Float {
        (Float(statValue)) / Float(statName.getMaxValue())
    }
    
    // MARK: - Views
    lazy private var statNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    }()
    
    lazy private var statValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    }()
    
    lazy private var statProgressbar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .systemGray
        progressView.progressTintColor = pokeType?.getColorForType()
        progressView.layer.cornerRadius = 7
        progressView.clipsToBounds = true
        addSubview(progressView)
        return progressView
    }()
    
    // MARK: - Lifecycle Methods
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(with baseStat: PKPokemonBaseStat, of statValue: Int, and pokeType: PKPokemonBaseType?) {
        self.init(frame: .zero)
        self.statName = baseStat
        self.statValue = statValue
        self.pokeType = pokeType
        configureView()
        configureLayout()
    }
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        statNameLabel.text = statName.getDisplayName()
        statValueLabel.text = String(statValue)

        statProgressbar.progress = scaledBaseStatValue
    }
    
    // MARK: - Layouts and Constraints
    private func configureLayout() {
        let screenWidth = UIScreen.main.bounds.width

        NSLayoutConstraint.activate([
            statNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            statNameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            statNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            statValueLabel.leadingAnchor.constraint(equalTo: statNameLabel.trailingAnchor, constant: 0),
            statValueLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1),
            statValueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            statProgressbar.leadingAnchor.constraint(equalTo: statValueLabel.trailingAnchor, constant: 12),
            statProgressbar.heightAnchor.constraint(equalToConstant: 15),
            statProgressbar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6, constant: -12),
            statProgressbar.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            heightAnchor.constraint(equalToConstant: 45),
            widthAnchor.constraint(equalToConstant: screenWidth - 32)
        ])
    }
}
