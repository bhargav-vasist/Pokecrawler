//
//  PKPokeDetailView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 22/03/23.
//

import UIKit

class PKPokeDetailView: UIView {
    
    // MARK: - Models
    enum PKPokeDetailTabs: Int, CaseIterable {
        case about = 0
        case stats = 1
        case moves = 2
        
        var title: String {
            switch self {
            case .about: return "About"
            case .stats: return "Stats"
            case .moves: return "Moves"
            }
        }
    }
    
    private var pokemonModel: PKPokemonModel!
    
    /// Callback to present all moves modal
    var onShowAllMoves: ((_ moves: [(name: String, level: Int)], _ color: UIColor, _ pokemonName: String) -> Void)?
    
    // MARK: - Views
    lazy private var segmentedControl: UISegmentedControl = {
        let items = PKPokeDetailTabs.allCases.map { $0.title }
        let seg = UISegmentedControl(items: items)
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.selectedSegmentIndex = 0
        seg.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return seg
    }()
    
    lazy private var contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var aboutView: PKPokeDetailAboutView = {
        let view = PKPokeDetailAboutView(with: pokemonModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var statsView: PKPokeDetailsStatsView = {
        let view = PKPokeDetailsStatsView(with: pokemonModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    lazy private var movesView: PKPokeDetailMovesView = {
        let view = PKPokeDetailMovesView(with: pokemonModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // Bottom constraints for dynamic height based on selected tab
    private var aboutBottomConstraint: NSLayoutConstraint!
    private var statsBottomConstraint: NSLayoutConstraint!
    private var movesBottomConstraint: NSLayoutConstraint!
    
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
    }
    
    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.cornerRadius = 24
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubview(segmentedControl)
        addSubview(contentContainer)
        
        contentContainer.addSubview(aboutView)
        contentContainer.addSubview(statsView)
        contentContainer.addSubview(movesView)
        
        // Handle "Show All Moves" tap
        movesView.onShowAllTapped = { [weak self] moves, color in
            guard let self = self else { return }
            let pokemonName = self.pokemonModel.name.capitalized
            self.onShowAllMoves?(moves, color, pokemonName)
        }
    }
    
    private func setupLayout() {
        // Bottom constraints - determines content height based on visible tab
//        aboutBottomConstraint = contentContainer.bottomAnchor.constraint(greaterThanOrEqualTo: aboutView.bottomAnchor, constant: 100)
//        statsBottomConstraint = contentContainer.bottomAnchor.constraint(greaterThanOrEqualTo: statsView.bottomAnchor, constant: 100)
//        movesBottomConstraint = contentContainer.bottomAnchor.constraint(greaterThanOrEqualTo: movesView.bottomAnchor, constant: 100)
        
        // Start with about view active
//        aboutBottomConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            // Segmented control at top
            segmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Content container below segmented control
            contentContainer.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // About view - pinned to top
            aboutView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            aboutView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            aboutView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            
            // Stats view - pinned to top
            statsView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            statsView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            statsView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            
            // Moves view - pinned to top
            movesView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            movesView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            movesView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor)
        ])
    }
    
    // MARK: - Public
    func loadViews(with speciesData: PKPokemonSpecies) {
        DispatchQueue.main.async { [weak self] in
            self?.aboutView.loadView(with: speciesData)
        }
    }
    
    // MARK: - Segment
    @objc private func segmentChanged() {
        let index = segmentedControl.selectedSegmentIndex
        
        // Update visibility with fade animation
        UIView.animate(withDuration: 0.2) {
            self.aboutView.alpha = index == 0 ? 1 : 0
            self.statsView.alpha = index == 1 ? 1 : 0
            self.movesView.alpha = index == 2 ? 1 : 0
        }
        
        aboutView.isHidden = index != 0
        statsView.isHidden = index != 1
        movesView.isHidden = index != 2
        
        // Update bottom constraints for proper sizing
//        aboutBottomConstraint.isActive = index == 0
//        statsBottomConstraint.isActive = index == 1
//        movesBottomConstraint.isActive = index == 2
        
        setNeedsLayout()
    }
}
