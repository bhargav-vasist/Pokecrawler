//
//  PKPokeDetailStatsView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 23/03/23.
//

import UIKit

class PKPokeDetailsStatsView: UIView {
    
    private var pokemonModel: PKPokemonModel!
    
    lazy private var mainStackView: UIStackView = {
        let sv = PKVertStackView(with: [])
        sv.alignment = .leading
        sv.distribution = .fill
        addSubview(sv)
        return sv
    }()
    
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
                let statRow = PKPokeDetailsStatsRowView(with: baseStat, of: stat.baseStat, and: pokemonModel.types.first?.type.name)
                mainStackView.addArrangedSubview(statRow)
            }
        }
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
}

class PKPokeDetailsStatsRowView: UIView {
    
    private var statName: PKPokemonBaseStat!
    private var statValue: Int!
    private var pokeType: PKPokemonBaseType?
    
    private var scaledBaseStatValue: Float {
        (Float(statValue)) / Float(statName.getMaxValue())
    }
    
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
        let pv = UIProgressView(progressViewStyle: .bar)
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.trackTintColor = .systemGray
        pv.progressTintColor = pokeType?.getColorForType()
        pv.layer.cornerRadius = 7
        pv.clipsToBounds = true
        addSubview(pv)
        return pv
    }()
    
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
