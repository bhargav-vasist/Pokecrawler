//
//  PKPokedexDataSource.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

enum PokeSections {
    case main
}

/// Delegate protocol for search state updates
protocol PKPokedexDataSourceDelegate: AnyObject {
    func dataSourceDidStartAPISearch()
    func dataSourceDidFinishSearch(resultsCount: Int)
}

class PKPokedexDataSource: UICollectionViewDiffableDataSource<PokeSections, PKPokemonModel> {
    
    private var networkManager: PKNetworkManager!
    
    /// Delegate for search state callbacks
    weak var delegate: PKPokedexDataSourceDelegate?
    
    /// All pokemon loaded so far (unfiltered)
    private var allPokemonData: [PKPokemonModel] = []
    
    /// Currently displayed pokemon (may be filtered)
    var pokemonData: [PKPokemonModel] = [] {
        didSet {
            updateDataSource(with: pokemonData)
        }
    }
    
    /// Current search query (empty = show all)
    private(set) var currentSearchQuery: String = ""
    
    /// Whether we're currently showing search results
    var isSearching: Bool {
        !currentSearchQuery.isEmpty
    }
    
    // Check the API returned value to see if paginated calls are to be made
    var hasMorePokemon = true
    
    // Offset of the items already fetched
    var currentFetchOffset = 0
    
    // No of items to fetch per call
    let fetchItemLimit = 10
    
    // Paginated Call in Progress
    var isFetchingNextPage = false
    
    init(
        with networkManager: PKNetworkManager,
        for collectionView: UICollectionView,
        and cellProvider: @escaping UICollectionViewDiffableDataSource<PokeSections, PKPokemonModel>.CellProvider
    ) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
        self.networkManager = networkManager
    }
    
    // Called the first time every load.
    func fetchPokeData() {
        networkManager.fetchPaginated(.getAllPokemon(with: fetchItemLimit)) { [weak self] result in
            switch result {
            case .success(let pokeData):
                let jsonDecoder = PKPokemonModel.decoder
                let pokemon = pokeData.compactMap({
                    try? jsonDecoder.decode(PKPokemonModel.self, from: $0
                    )}
                ).sorted(by: { $0.id < $1.id })
                guard let unwrappedSelf = self else {
                    return
                }
                unwrappedSelf.currentFetchOffset += unwrappedSelf.fetchItemLimit
                unwrappedSelf.allPokemonData = pokemon
                unwrappedSelf.pokemonData = pokemon
            case .failure(let error):
                print("Fetching all Pokemon failed with error", error)
            }
        }
    }
    
    // Paginated calls to fetch more pokemon.
    func fetchEvenMorePokeData() {
        // There's another call going on. Do not fetch more.
        // Don't fetch more while searching
        guard !isFetchingNextPage, !isSearching else {
            return
        }
        isFetchingNextPage = true
        networkManager.fetchPaginated(
            .getAllPokemon(
                with: fetchItemLimit, and: currentFetchOffset
            )
        ) { [weak self] result in
            switch result {
            case .success(let pokeData):
                let jsonDecoder = PKPokemonModel.decoder
                let extraPokemon = pokeData.compactMap({
                    try? jsonDecoder.decode(PKPokemonModel.self, from: $0
                    )}).sorted(by: { $0.id < $1.id })
                guard let unwrappedSelf = self else {
                    return
                }
                unwrappedSelf.currentFetchOffset += unwrappedSelf.fetchItemLimit
                unwrappedSelf.allPokemonData.append(contentsOf: extraPokemon)
                unwrappedSelf.pokemonData.append(contentsOf: extraPokemon)
            case .failure(let error):
                print("Fetching paginated pokemon failed with error", error)
            }
            self?.isFetchingNextPage = false
        }
    }
    
    // MARK: - Search
    
    /// Pending search results from index (names to fetch)
    private var pendingSearchResults: [PKIndexEntry] = []
    
    /// Search Pokemon using the global index for partial matching
    /// - Parameters:
    ///   - query: Search string (case-insensitive, supports partial match)
    ///   - completion: Called with true if API fetch was triggered
    func searchPokemon(query: String, completion: ((Bool) -> Void)? = nil) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        currentSearchQuery = trimmedQuery
        
        // Empty query = show all loaded pokemon
        guard !trimmedQuery.isEmpty else {
            pokemonData = allPokemonData
            delegate?.dataSourceDidFinishSearch(resultsCount: allPokemonData.count)
            completion?(false)
            return
        }
        
        // Search the global index (contains ALL Pokemon names)
        let indexResults = PKPokemonIndex.shared.search(query: trimmedQuery)
        
        guard !indexResults.isEmpty else {
            // No matches in index
            pokemonData = []
            delegate?.dataSourceDidFinishSearch(resultsCount: 0)
            completion?(false)
            return
        }
        
        // Check which results we already have loaded
        var cachedResults: [PKPokemonModel] = []
        var toFetch: [PKIndexEntry] = []
        
        for entry in indexResults {
            if let cached = allPokemonData.first(where: { $0.name.lowercased() == entry.name.lowercased() }) {
                cachedResults.append(cached)
            } else {
                toFetch.append(entry)
            }
        }
        
        // Show cached results immediately
        if !cachedResults.isEmpty {
            pokemonData = cachedResults
            delegate?.dataSourceDidFinishSearch(resultsCount: cachedResults.count)
        }
        
        // Fetch missing results (limit to first 20 to avoid hammering API)
        if !toFetch.isEmpty {
            pendingSearchResults = toFetch
            delegate?.dataSourceDidStartAPISearch()
            completion?(true)
            fetchSearchResults(entries: Array(toFetch.prefix(20)), existingResults: cachedResults)
        } else {
            completion?(false)
        }
    }
    
    /// Fetch full Pokemon data for search results
    private func fetchSearchResults(entries: [PKIndexEntry], existingResults: [PKPokemonModel]) {
        let dispatchGroup = DispatchGroup()
        var fetchedPokemon: [PKPokemonModel] = []
        let currentQuery = currentSearchQuery
        
        for entry in entries {
            dispatchGroup.enter()
            networkManager.fetch(.getPokemon(with: entry.name)) { [weak self] result in
                defer { dispatchGroup.leave() }
                
                // Check if search query changed
                guard self?.currentSearchQuery == currentQuery else { return }
                
                if case .success(let data) = result,
                   let pokemon = try? PKPokemonModel.decoder.decode(PKPokemonModel.self, from: data) {
                    fetchedPokemon.append(pokemon)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self, self.currentSearchQuery == currentQuery else { return }
            
            // Combine existing + fetched, sort by ID
            var allResults = existingResults + fetchedPokemon
            allResults.sort { $0.id < $1.id }
            
            self.pokemonData = allResults
            self.delegate?.dataSourceDidFinishSearch(resultsCount: allResults.count)
            
            // Cache newly fetched Pokemon
            for pokemon in fetchedPokemon where !self.allPokemonData.contains(where: { $0.id == pokemon.id }) {
                self.allPokemonData.append(pokemon)
            }
            self.allPokemonData.sort { $0.id < $1.id }
        }
    }
    
    /// Clear search and restore full pokemon list
    func clearSearch() {
        currentSearchQuery = ""
        pokemonData = allPokemonData
    }
    
    // Apply the new snapshot which includes additional items or filtered items (in the future)
    func updateDataSource(with pokemonData: [PKPokemonModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<PokeSections, PKPokemonModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(pokemonData, toSection: .main)
        DispatchQueue.main.async {
            self.apply(snapshot, animatingDifferences: true)
        }
    }
}
