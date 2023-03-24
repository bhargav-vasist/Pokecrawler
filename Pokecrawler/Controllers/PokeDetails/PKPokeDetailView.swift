//
//  PKPokeDetailView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 22/03/23.
//

import UIKit

class PKPokeDetailView: UIView {
    
    enum PKPokeDetailTabs: String, CaseIterable {
        case about
        case stats
        // TODO: Add this tab in the next cycle
        //        case forms
    }
    
    private var pokemonModel: PKPokemonModel! {
        didSet {
            DispatchQueue.main.async {
                self.populateViewsWithData()
            }
        }
    }
    
    private var pokemonSpecies: PKPokemonSpecies? {
        didSet {
            if pokemonSpecies != nil {
                DispatchQueue.main.async {
                    self.populateViewsWithData()
                }
            }
        }
    }
    
    lazy private var segmentedDetails: UISegmentedControl = {
        let segmentNames = PKPokeDetailTabs.allCases.map {$0.rawValue.capitalized}
        let segCtrl = UISegmentedControl(items: segmentNames)
        segCtrl.translatesAutoresizingMaskIntoConstraints = false
        segCtrl.addTarget(self, action: #selector(segmentTapped), for: .valueChanged)
        segCtrl.selectedSegmentIndex = 0
        addSubview(segCtrl)
        return segCtrl
    }()
    
    lazy private var containerView: UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cv)
        return cv
    }()
    
    lazy private var aboutView: PKPokeDetailAboutView = {
        let av = PKPokeDetailAboutView(with: pokemonModel)
        containerView.addSubview(av)
        av.isHidden = true
        return av
    }()
    
    lazy private var statsView: PKPokeDetailsStatsView = {
        let statview = PKPokeDetailsStatsView(with: pokemonModel)
        containerView.addSubview(statview)
        statview.isHidden = true
        return statview
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
        backgroundColor = .systemBackground
        layer.cornerRadius = 24
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            segmentedDetails.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            segmentedDetails.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            segmentedDetails.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            containerView.topAnchor.constraint(equalTo: segmentedDetails.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: segmentedDetails.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: segmentedDetails.trailingAnchor),
            
            aboutView.topAnchor.constraint(equalTo: containerView.topAnchor),
            aboutView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            aboutView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            aboutView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            statsView.topAnchor.constraint(equalTo: containerView.topAnchor),
            statsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            statsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            statsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
    
    func loadViews(with speciesData: PKPokemonSpecies) {
        pokemonSpecies = speciesData
    }
    
    private func populateViewsWithData() {
        let allCases = PKPokeDetailTabs.allCases
        let selectedItem = allCases[segmentedDetails.selectedSegmentIndex]
        switch (selectedItem) {
        case .about:
            guard let species = pokemonSpecies else {
                return
            }
            aboutView.loadView(with: species)
        case .stats:
            break // No op because Stats already has all the data it needs

        }
        segmentTapped()
    }
    
    @objc private func segmentTapped() {
        let allCases = PKPokeDetailTabs.allCases
        let selectedItem = allCases[segmentedDetails.selectedSegmentIndex]
        let allViews = [aboutView, statsView]
        
        // Hide all and unhide only the right view
        allViews.forEach {$0.isHidden = true}
        switch (selectedItem) {
        case .about:
            aboutView.isHidden = false
        case .stats:
            statsView.isHidden = false
        }
    }
}
