//
//  PKPokeDetailViewController.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokeDetailViewController: UIViewController {
    
    private var pokemonModel: PKPokemonModel!
    private var pokemonSpecies: PKPokemonSpecies? {
        didSet {
            if let species = pokemonSpecies {
                detailView.loadViews(with: species)
            }
        }
    }
    
    lazy private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        return scrollView
    }()
    
    lazy private var headerContainerView: UIView = {
       let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        return containerView
    }()
    
    lazy private var pokeSpriteImageView: PKPokeSpriteImageView = {
        let iv = PKPokeSpriteImageView()
        headerContainerView.addSubview(iv)
        return iv
    }()
    
    lazy private var detailView: PKPokeDetailView = {
        let view = PKPokeDetailView(with: pokemonModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }()
    
    private var imageLoadingTask: URLSessionDataTask?
    private var networkManager: PKNetworkManager!
    
    private var headerTopConstraint: NSLayoutConstraint!
    private var headerHeightConstraint: NSLayoutConstraint!
    fileprivate let headerHeight: CGFloat = 250
    
    init(with pokemonData: PKPokemonModel, and networkManager: PKNetworkManager) {
        super.init(nibName: nil, bundle: nil)
        self.pokemonModel = pokemonData
        self.networkManager = networkManager
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var isFavorited = false {
        didSet {
            navigationItem.rightBarButtonItem?.image = favoriteImage
        }
    }
    private var favoriteImage: UIImage? {
        return isFavorited ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureLayout()
        configureViews()
    }
    
    private func configureNavigation() {
        title = pokemonModel.name.capitalized
        
//        navigationItem.standardAppearance
        navigationItem.standardAppearance?.backgroundColor = .clear
        navigationItem.standardAppearance?.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance?.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        navigationItem.titleView?.tintColor = .white
        
        navigationController?.navigationItem.titleView?.tintColor = .white
        
//        navigationController?.navigationBar.standardAppearance.backgroundColor = .clear
//        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: favoriteImage, style: .plain, target: self, action: #selector(favoriteTapped))
    }
    
    private func configureLayout() {
        view.backgroundColor = pokemonModel.types.first?.type.name.getColorForType()
        
        headerTopConstraint = headerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        headerHeightConstraint = headerContainerView.heightAnchor.constraint(equalToConstant: headerHeight)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            headerTopConstraint,
            headerHeightConstraint,
            headerContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0),
            
            pokeSpriteImageView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            pokeSpriteImageView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            pokeSpriteImageView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            pokeSpriteImageView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -32),
            
            detailView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            detailView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0),
            detailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 600),
        ])
    }
    
    private func configureViews() {
        fetchAndUpdatePokemonImage()
        fetchPokeSpeciesData()
        fetchPokeStatsData()
    }
    
    private func fetchAndUpdatePokemonImage() {
        if let pokeSprite = pokemonModel.sprites.other?.home?.frontDefault {
            imageLoadingTask = networkManager.getAvatarImage(urlString: pokeSprite) { [weak self] result in
                switch result {
                case .failure:
                    break
                case .success(let image):
                    DispatchQueue.main.async { [weak self] in
                        self?.pokeSpriteImageView.image = image
                    }
                }
            }
        }
        
    }
    
    private func fetchPokeSpeciesData() {
        guard let speciesURL = pokemonModel.species.url else {
            print("Pokemon \(pokemonModel.name) does not have Species URL listed")
            return
        }
        networkManager.fetch(Endpoint(from: speciesURL)) { [weak self] result in
            switch (result) {
            case .success(let speciesData):
                let decoder = PKPokemonSpecies.decoder
                if let species = try? decoder.decode(PKPokemonSpecies.self, from: speciesData) {
                    print("Species found", species)
                    self?.pokemonSpecies = species
                }
            case .failure(let error):
                print("Errored fetching Species Data", error)
            }
        }
    }
    
    private func fetchPokeStatsData() {
        guard let speciesURL = pokemonModel.species.url else {
            print("Pokemon \(pokemonModel.name) does not have Species URL listed")
            return
        }
    }
    
    @objc private func favoriteTapped() {
        isFavorited.toggle()
        // TODO: - Add to persistence layer
    }
}

extension PKPokeDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0.0 {
            // Scrolling down: Scale
            headerHeightConstraint?.constant =
                headerHeight - scrollView.contentOffset.y
        }
        else {
            // Scrolling up: Parallax
            let parallaxFactor: CGFloat = 0.15
            let offsetY = scrollView.contentOffset.y * parallaxFactor
            let minOffsetY: CGFloat = 8.0
            let availableOffset = min(offsetY, minOffsetY)
            let contentRectOffsetY = availableOffset / headerHeight
            headerTopConstraint?.constant = view.frame.origin.y
            headerHeightConstraint?.constant =
                headerHeight - scrollView.contentOffset.y
            pokeSpriteImageView.layer.contentsRect =
                CGRect(x: 0, y: -contentRectOffsetY, width: 1, height: 1)
        }
    }
}
