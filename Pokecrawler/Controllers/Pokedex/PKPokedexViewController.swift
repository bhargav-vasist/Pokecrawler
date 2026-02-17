//
//  ViewController.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

import UIKit

class PKPokedexViewController: UIViewController {
    
    var pokedexDataSource: PKPokedexDataSource!
    
    var collectionView: UICollectionView!
    lazy var delegateFlowLayout = PKPokedexDelegateFlowLayout(self)
    
    private var networkManager: PKNetworkManager!
    
    // MARK: - Search
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Pokémon by name..."
        search.searchBar.delegate = self
        return search
    }()
    
    /// Debouncer for search input — waits 300ms after typing stops before searching
    private let searchDebouncer = PKDebouncer(delay: 0.3)
    
    // MARK: - State Views
    private lazy var loadingView: PKLoadingView = {
        let view = PKLoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var emptyStateView: PKEmptyStateView = {
        let view = PKEmptyStateView(
            image: UIImage(systemName: "magnifyingglass"),
            title: "No Pokémon Found",
            message: "Try searching for a different name"
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    init(with networkManager: PKNetworkManager) {
        super.init(nibName: nil, bundle: nil)
        self.networkManager = networkManager
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureNavigation()
        configureSearchController()
        configureCollectionView()
        configureStateViews()
        configureDataSource()
        observeSearchIndex()
    }
    
    /// Observe the Pokemon index loading state and update search placeholder
    private func observeSearchIndex() {
        updateSearchPlaceholder()
        
        // If index isn't loaded yet, wait for it
        if !PKPokemonIndex.shared.isLoaded {
            PKPokemonIndex.shared.onIndexReady = { [weak self] in
                DispatchQueue.main.async {
                    self?.updateSearchPlaceholder()
                }
            }
        }
    }
    
    private func updateSearchPlaceholder() {
        searchController.searchBar.placeholder = "Search"
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = delegateFlowLayout
        collectionView.register(
            PKPokemonCollectionViewCell.self,
            forCellWithReuseIdentifier: PKPokemonCollectionViewCell.reuseIdentifier
        )
        view.addSubview(collectionView)
    }
    
    private func configureNavigation() {
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.tintColor = .label
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Pokédex"
    }
    
    private func configureSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func configureStateViews() {
        view.addSubview(loadingView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - State Management
    private func showLoading() {
        emptyStateView.isHidden = true
        loadingView.startLoading(message: "Searching...")
    }
    
    private func hideLoading() {
        loadingView.stopLoading()
    }
    
    private func showEmptyState() {
        loadingView.stopLoading()
        emptyStateView.isHidden = false
    }
    
    private func hideEmptyState() {
        emptyStateView.isHidden = true
    }
    
    // Manages all the data manipulation operations like
    // Fetch, Load, Update for the CollectionView
    private func configureDataSource() {
        pokedexDataSource = PKPokedexDataSource(
            with: PKNetworkManager(),
            for: collectionView,
            and: { collectionView, indexPath, pokemon in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PKPokemonCollectionViewCell.reuseIdentifier,
                for: indexPath) as? PKPokemonCollectionViewCell else {
                fatalError("Failed to dequeue reusable PKPokemonCollectionViewCell")
            }
            cell.set(pokemon: pokemon)
            return cell
        })
        pokedexDataSource.delegate = self
        pokedexDataSource.fetchPokeData()
    }
}

// MARK: - PKPokedexDataSourceDelegate
extension PKPokedexViewController: PKPokedexDataSourceDelegate {
    func dataSourceDidStartAPISearch() {
        showLoading()
    }
    
    func dataSourceDidFinishSearch(resultsCount: Int) {
        hideLoading()
        if resultsCount == 0 && pokedexDataSource.isSearching {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
}

// MARK: - UISearchResultsUpdating
extension PKPokedexViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        
        // If query is empty, reset state
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            hideLoading()
            hideEmptyState()
        }
        
        // Debounce the search to avoid excessive API calls while typing
        searchDebouncer.debounce { [weak self] in
            guard let self = self else { return }
            
            self.pokedexDataSource.searchPokemon(query: query) { isAPISearch in
                DispatchQueue.main.async {
                    if isAPISearch {
                        self.showLoading()
                    }
                }
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension PKPokedexViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchDebouncer.cancel()
        hideLoading()
        hideEmptyState()
        pokedexDataSource.clearSearch()
    }
}
