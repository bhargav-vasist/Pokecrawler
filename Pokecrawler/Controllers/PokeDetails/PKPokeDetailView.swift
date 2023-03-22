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
        case forms
    }
    
    private var pokemonModel: PKPokemonModel! {
        didSet {
            populateViewsWithData()
        }
    }
    
    lazy private var typeStack: PKPokemonTypeStackView = {
        let sv = PKPokemonTypeStackView(with: pokemonModel.types)
        addSubview(sv)
        return sv
    }()
    
    lazy private var segmentedDetails: UISegmentedControl = {
        let segCtrl = UISegmentedControl(items: PKPokeDetailTabs.allCases)
        return segCtrl
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
        backgroundColor = .white
        layer.cornerRadius = 24
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            typeStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            typeStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            typeStack.heightAnchor.constraint(equalToConstant: 35),
        ])
    }
    
    private func populateViewsWithData() {
        
    }
    
    private func segmentTapped(_ segmentedControl: UISegmentedControl) {
        let allCases = PKPokeDetailTabs.allCases
        let selectedItem = allCases[segmentedDetails.selectedSegmentIndex]
        switch (selectedItem) {
        case .about:
            print("About tapped")
        case .stats:
            print("Stats tapped")
        case .forms:
            print("Forms tapped")
        }
    }
}
