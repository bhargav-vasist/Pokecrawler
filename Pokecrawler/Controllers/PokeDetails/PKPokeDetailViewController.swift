//
//  PKPokeDetailViewController.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokeDetailViewController: UIViewController {
    
    private var pokemonModel: PKPokemonModel!
    
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
    
    lazy private var detailView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        scrollView.addSubview(view)
        return view
    }()
    
    lazy private var typeStack: PKPokemonTypeStackView = {
        let sv = PKPokemonTypeStackView(with: pokemonModel.types)
        detailView.addSubview(sv)
        return sv
    }()
    
    private var imageLoadingTask: URLSessionDataTask?
    
    private var headerTopConstraint: NSLayoutConstraint!
    private var headerHeightConstraint: NSLayoutConstraint!
    fileprivate let headerHeight: CGFloat = 250
    
    init(pokemonData: PKPokemonModel) {
        super.init(nibName: nil, bundle: nil)
        pokemonModel = pokemonData
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
        
        navigationController?.navigationBar.standardAppearance.backgroundColor = .clear
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: favoriteImage, style: .plain, target: self, action: #selector(favoriteTapped))
    }
    
    private func configureLayout() {
        view.backgroundColor = pokemonModel.types.first?.type.name.getColorForType()
        
        headerTopConstraint = headerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        headerHeightConstraint = headerContainerView.heightAnchor.constraint(equalToConstant: headerHeight)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
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
            detailView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor),
            
            typeStack.topAnchor.constraint(equalTo: detailView.safeAreaLayoutGuide.topAnchor, constant: 12),
            typeStack.leadingAnchor.constraint(equalTo: detailView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            typeStack.heightAnchor.constraint(equalToConstant: 35),
        ])
    }
    
    private func configureViews() {
        fetchAndUpdatePokemonImage()
    }
    
    private func fetchAndUpdatePokemonImage() {
        if let pokeSprite = pokemonModel.sprites.other?.home?.frontDefault {
            imageLoadingTask = PKNetworkManager().getAvatarImage(urlString: pokeSprite) { [weak self] result in
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
            let parallaxFactor: CGFloat = 0.35
            let offsetY = scrollView.contentOffset.y * parallaxFactor
            let minOffsetY: CGFloat = 8.0
            let availableOffset = min(offsetY, minOffsetY)
            let contentRectOffsetY = availableOffset / headerHeight
            headerTopConstraint?.constant = view.frame.origin.y
            headerHeightConstraint?.constant =
                headerHeight - scrollView.contentOffset.y
            pokeSpriteImageView.layer.contentsRect =
                CGRect(x: 0, y: -contentRectOffsetY, width: 1, height: 1)
            typeStack.layer.contentsRect = CGRect(x: 0, y: -contentRectOffsetY, width: 1, height: 1)
        }
    }
}
