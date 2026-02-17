//
//  PKPokeDetailViewController.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokeDetailViewController: UIViewController {
    
    // MARK: - Models
    private var pokemonModel: PKPokemonModel!
    private var pokemonSpecies: PKPokemonSpecies? {
        didSet {
            if let species = pokemonSpecies {
                detailView.loadViews(with: species)
            }
        }
    }
    
    // MARK: - Managers
    private var imageLoadingTask: URLSessionDataTask?
    private var networkManager: PKNetworkManager!
    private var storageManager: PKStorageManager!
    private let teamManager = PKTeamManager.shared
        
    // MARK: - Views
    lazy private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        scroll.delegate = self
        scroll.contentInsetAdjustmentBehavior = .never
        view.addSubview(scroll)
        return scroll
    }()
    
    lazy private var contentView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(container)
        return container
    }()
    
    lazy private var pokeSpriteImageView: PKPokeSpriteImageView = {
        let imageView = PKPokeSpriteImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        return imageView
    }()
    
    lazy private var detailView: PKPokeDetailView = {
        let detailView = PKPokeDetailView(with: pokemonModel)
        detailView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailView)
        return detailView
    }()
    
    // Store the minimum height for detail view
    private var detailViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - State
    private var isFavorited = false
    
    // MARK: - Lifecycle
    init(with pokemonData: PKPokemonModel, and networkManager: PKNetworkManager, also storageManager: PKStorageManager) {
        super.init(nibName: nil, bundle: nil)
        self.pokemonModel = pokemonData
        self.networkManager = networkManager
        self.storageManager = storageManager
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureLayout()
        configureViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(teamDidChange), name: .teamDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndUpdateFavouriteStatus()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Calculate the height needed for detail view to fill screen and extend behind tab bar
        let spriteBottom = view.safeAreaInsets.top + 20 + 200 + 20 // safe area + top padding + sprite height + spacing
        let availableHeight = view.bounds.height - spriteBottom + (tabBarController?.tabBar.frame.height ?? 0)
        
        if detailViewHeightConstraint == nil {
            detailViewHeightConstraint = detailView.heightAnchor.constraint(greaterThanOrEqualToConstant: availableHeight)
            detailViewHeightConstraint?.isActive = true
        } else {
            detailViewHeightConstraint?.constant = availableHeight
        }
        
        // Set scroll inset for tab bar
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        scrollView.contentInset.bottom = tabBarHeight
        scrollView.verticalScrollIndicatorInsets.bottom = tabBarHeight
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func teamDidChange() {
        // Update nav bar if needed
    }
    
    // MARK: - Navigation
    private func configureNavigation() {
        let displayName = pokemonModel.name
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
        
        title = displayName
        navigationController?.navigationBar.tintColor = .white
        
        // Action button in nav bar
        let actionButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(showActionSheet)
        )
        navigationItem.rightBarButtonItem = actionButton
    }
    
    // MARK: - Layout
    private func configureLayout() {
        NSLayoutConstraint.activate([
            // Scroll view fills the entire screen
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view inside scroll view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Sprite at top (with safe area offset)
            pokeSpriteImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100),
            pokeSpriteImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pokeSpriteImageView.widthAnchor.constraint(equalToConstant: 200),
            pokeSpriteImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Detail view below sprite, extends to fill remaining space
            detailView.topAnchor.constraint(equalTo: pokeSpriteImageView.bottomAnchor, constant: 20),
            detailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            detailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            detailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func configureViews() {
        view.backgroundColor = pokemonModel.types.first?.type.name.getColorForType()
        fetchAndUpdatePokemonImage()
        fetchPokeSpeciesData()
        fetchAndUpdateFavouriteStatus()
        
        // Handle "Show All Moves" tap
        detailView.onShowAllMoves = { [weak self] moves, color, pokemonName in
            self?.presentAllMovesModal(moves: moves, color: color, pokemonName: pokemonName)
        }
    }
    
    private func presentAllMovesModal(moves: [(name: String, level: Int)], color: UIColor, pokemonName: String) {
        let movesVC = PKAllMovesViewController(moves: moves, accentColor: color, pokemonName: pokemonName)
        let navController = UINavigationController(rootViewController: movesVC)
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        present(navController, animated: true)
    }
    
    // MARK: - Data Fetching
    private func fetchAndUpdatePokemonImage() {
        if let pokeSprite = pokemonModel.sprites.other?.home?.frontDefault {
            imageLoadingTask = networkManager.getAvatarImage(urlString: pokeSprite) { [weak self] result in
                if case .success(let image) = result {
                    DispatchQueue.main.async {
                        self?.pokeSpriteImageView.image = image
                    }
                }
            }
        }
    }
    
    private func fetchPokeSpeciesData() {
        guard let speciesURL = pokemonModel.species.url else { return }
        networkManager.fetch(Endpoint(from: speciesURL)) { [weak self] result in
            if case .success(let data) = result,
               let species = try? PKPokemonSpecies.decoder.decode(PKPokemonSpecies.self, from: data) {
                self?.pokemonSpecies = species
            }
        }
    }
    
    private func fetchAndUpdateFavouriteStatus() {
        Task { [weak self] in
            guard let self = self else { return }
            let favorites = (try? await self.storageManager.retrievefavourites()) ?? []
            self.isFavorited = favorites.contains { $0 == self.pokemonModel }
        }
    }
    
    // MARK: - Actions
    @objc private func showActionSheet() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Team action
        let isInTeam = teamManager.isInTeam(pokemonModel)
        let teamTitle = isInTeam ? "Remove from Team" : "Add to Team"
        let teamIcon = isInTeam ? "minus.circle" : "plus.circle"
        
        let teamAction = UIAlertAction(title: teamTitle, style: isInTeam ? .destructive : .default) { [weak self] _ in
            self?.toggleTeam()
        }
        teamAction.setValue(UIImage(systemName: teamIcon), forKey: "image")
        
        if !isInTeam && teamManager.isTeamFull {
            teamAction.isEnabled = false
        }
        sheet.addAction(teamAction)
        
        // Favorite action
        let favTitle = isFavorited ? "Remove from Favorites" : "Add to Favorites"
        let favIcon = isFavorited ? "heart.slash" : "heart"
        
        let favAction = UIAlertAction(title: favTitle, style: .default) { [weak self] _ in
            self?.toggleFavorite()
        }
        favAction.setValue(UIImage(systemName: favIcon), forKey: "image")
        sheet.addAction(favAction)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(sheet, animated: true)
    }
    
    private func toggleTeam() {
        do {
            if teamManager.isInTeam(pokemonModel) {
                try teamManager.removeFromTeam(pokemonModel)
                showToast("Removed from team")
            } else {
                try teamManager.addToTeam(pokemonModel)
                showToast("Added to team!")
            }
        } catch let error as PKTeamError {
            showToast(error.localizedDescription)
        } catch {
            showToast("Something went wrong")
        }
    }
    
    private func toggleFavorite() {
        Task {
            do {
                let operation: PKStorageUpdateOperationKind = isFavorited ? .remove : .add
                if try await storageManager.updateFavouritePokemon(with: pokemonModel, of: operation) {
                    isFavorited.toggle()
                    showToast(isFavorited ? "Added to favorites!" : "Removed from favorites")
                }
            } catch {
                showToast("Failed to update favorite")
            }
        }
    }
    
    private func showToast(_ message: String) {
        let toast = PKToastView(message: message)
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: 20)
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            toast.alpha = 1
            toast.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 1.8) {
                toast.alpha = 0
                toast.transform = CGAffineTransform(translationX: 0, y: 10)
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PKPokeDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // Parallax effect with smooth easing:
        // - Scrolling UP (positive offset): sprite gets SMALLER
        // - Pulling DOWN (negative offset): sprite gets BIGGER
        
        let scale: CGFloat
        if offsetY > 0 {
            // Scrolling up - shrink sprite (ease out curve for smoother feel)
            let progress = min(offsetY / 200, 1.0)
            let easedProgress = 1 - pow(1 - progress, 2) // Ease out quad
            scale = 1 - (easedProgress * 0.3) // Scale down to 0.7
        } else if offsetY < 0 {
            // Pulling down - grow sprite (ease out curve)
            let progress = min(-offsetY / 150, 1.0)
            let easedProgress = 1 - pow(1 - progress, 2) // Ease out quad
            scale = 1 + (easedProgress * 0.5) // Scale up to 1.5
        } else {
            scale = 1.0
        }
        
        pokeSpriteImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
