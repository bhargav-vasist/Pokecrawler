//
//  PKPokeDetailView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 22/03/23.
//

import UIKit

class PKPokeDetailView: UIView {
    
    // MARK: - Models
    enum PKPokeDetailTabs: String, CaseIterable {
        case about
        case stats
    }
    
    private var pokemonModel: PKPokemonModel!
    
    // MARK: - Views
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
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        return containerView
    }()
    
    lazy private var aboutView: PKPokeDetailAboutView = {
        let abView = PKPokeDetailAboutView(with: pokemonModel)
        containerView.addSubview(abView)
        abView.isHidden = true
        return abView
    }()
    
    lazy private var statsView: PKPokeDetailsStatsView = {
        let statview = PKPokeDetailsStatsView(with: pokemonModel)
        containerView.addSubview(statview)
        statview.isHidden = true
        return statview
    }()
    
    // MARK: - Lifecyle Methods
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
    
    // MARK: - Layouts and Constraint
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
            statsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // Ideally, a ViewModel does this job for the view.
    // Loads the async fetched data to the right view.
    func loadViews(with speciesData: PKPokemonSpecies) {
        DispatchQueue.main.async { [weak self] in
            self?.populateViews(with: speciesData)
        }
    }
    
    // Set the appropriate data to the respective view
    private func populateViews(with speciesData: PKPokemonSpecies) {
        let allCases = PKPokeDetailTabs.allCases
        let selectedItem = allCases[segmentedDetails.selectedSegmentIndex]
        switch selectedItem {
        case .about:
            aboutView.loadView(with: speciesData)
        case .stats:
            break // No op because Stats already has all the data it needs
        }
        segmentTapped()
    }
    
    // Only changes the visual state of the segment selected
    // and also toggles the visibilty of the other views
    @objc private func segmentTapped() {
        let allCases = PKPokeDetailTabs.allCases
        let selectedItem = allCases[segmentedDetails.selectedSegmentIndex]
        let allViews = [aboutView, statsView]
        
        // Hide all and unhide only the selected view
        allViews.forEach {$0.isHidden = true}
        switch selectedItem {
        case .about:
            aboutView.isHidden = false
        case .stats:
            statsView.isHidden = false
        }
    }
}
