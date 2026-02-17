//
//  PKAddPokemonSheetController.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 08/12/25.
//

import UIKit

protocol PKAddPokemonSheetDelegate: AnyObject {
    func didAddPokemon(_ pokemon: PKPokemonModel)
}

final class PKAddPokemonSheetController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: PKAddPokemonSheetDelegate?
    
    private let networkManager = PKNetworkManager()
    private let teamManager = PKTeamManager.shared
    private let pokemonIndex = PKPokemonIndex.shared
    
    private var searchResults: [PKIndexEntry] = []
    private var isSearching = false
    private var searchTask: DispatchWorkItem?
    
    // MARK: - Views
    private lazy var handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiaryLabel
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Add Pokémon"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.placeholder = "Search Pokémon..."
        search.searchBarStyle = .minimal
        search.delegate = self
        return search
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(PKPokemonSearchCell.self, forCellReuseIdentifier: PKPokemonSearchCell.reuseIdentifier)
        table.backgroundColor = .clear
        table.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        table.keyboardDismissMode = .onDrag
        return table
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Search for a Pokémon to add to your team"
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadIndex()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(handleView)
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 36),
            handleView.heightAnchor.constraint(equalToConstant: 5),
            
            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: -40),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 40)
        ])
        
        updateEmptyState()
    }
    
    private func loadIndex() {
        loadingIndicator.startAnimating()
        emptyLabel.text = "Loading Pokémon..."
        
        pokemonIndex.loadIndex { [weak self] in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.emptyLabel.text = "Search for a Pokémon to add to your team"
            }
        }
    }
    
    private func updateEmptyState() {
        emptyLabel.isHidden = !searchResults.isEmpty
        tableView.isHidden = searchResults.isEmpty
    }
    
    // MARK: - Search
    private func performSearch(_ query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            searchResults = []
            tableView.reloadData()
            updateEmptyState()
            emptyLabel.text = "Search for a Pokémon to add to your team"
            return
        }
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            let results = self.pokemonIndex.search(query: query, limit: 50)
            
            DispatchQueue.main.async {
                self.searchResults = results
                self.tableView.reloadData()
                self.updateEmptyState()
                
                if results.isEmpty {
                    self.emptyLabel.text = "No Pokémon found for \"\(query)\""
                }
            }
        }
        
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: task)
    }
    
    // MARK: - Add Pokemon
    private func addPokemon(entry: PKIndexEntry) {
        loadingIndicator.startAnimating()
        
        networkManager.fetch(Endpoint(from: entry.url)) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
            
            switch result {
            case .success(let data):
                do {
                    let pokemon = try PKPokemonModel.decoder.decode(PKPokemonModel.self, from: data)
                    
                    DispatchQueue.main.async {
                        do {
                            try self.teamManager.addToTeam(pokemon)
                            self.delegate?.didAddPokemon(pokemon)
                            self.dismiss(animated: true)
                        } catch let error as PKTeamError {
                            self.showError(error.localizedDescription)
                        } catch {
                            self.showError("Failed to add Pokémon")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showError("Failed to load Pokémon data")
                    }
                }
                
            case .failure:
                DispatchQueue.main.async {
                    self.showError("Network error. Please try again.")
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension PKAddPokemonSheetController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(searchText.lowercased())
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource
extension PKAddPokemonSheetController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = PKPokemonSearchCell.reuseIdentifier
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier,
            for: indexPath
        ) as? PKPokemonSearchCell else {
            return UITableViewCell()
        }
        
        let entry = searchResults[indexPath.row]
        let isInTeam = teamManager.currentTeam.contains { $0.name.lowercased() == entry.name.lowercased() }
        cell.configure(with: entry, isInTeam: isInTeam, networkManager: networkManager)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PKAddPokemonSheetController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let entry = searchResults[indexPath.row]
        
        // Check if already in team
        if teamManager.currentTeam.contains(where: { $0.name.lowercased() == entry.name.lowercased() }) {
            showError("This Pokémon is already on your team!")
            return
        }
        
        if teamManager.isTeamFull {
            showError("Your team is full! Remove a Pokémon first.")
            return
        }
        
        addPokemon(entry: entry)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Search Result Cell
final class PKPokemonSearchCell: UITableViewCell {
    static let reuseIdentifier = "PKPokemonSearchCell"
    
    private var imageTask: URLSessionDataTask?
    
    private lazy var spriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var inTeamBadge: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "In Team"
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = .systemGreen
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        spriteImageView.image = nil
        inTeamBadge.isHidden = true
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        contentView.addSubview(spriteImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(inTeamBadge)
        
        NSLayoutConstraint.activate([
            spriteImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            spriteImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            spriteImageView.widthAnchor.constraint(equalToConstant: 44),
            spriteImageView.heightAnchor.constraint(equalToConstant: 44),
            
            nameLabel.leadingAnchor.constraint(equalTo: spriteImageView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            inTeamBadge.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            inTeamBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            inTeamBadge.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            inTeamBadge.widthAnchor.constraint(equalToConstant: 56),
            inTeamBadge.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with entry: PKIndexEntry, isInTeam: Bool, networkManager: PKNetworkManager) {
        let displayName = entry.name.replacingOccurrences(of: "-", with: " ").capitalized
        nameLabel.text = displayName
        
        inTeamBadge.isHidden = !isInTeam
        nameLabel.textColor = isInTeam ? .secondaryLabel : .label
        
        // Use the ID from the index entry for the sprite URL
        guard let pokemonId = entry.id else { return }
        let baseURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites"
        let spriteURL = "\(baseURL)/pokemon/other/official-artwork/\(pokemonId).png"
        
        imageTask = networkManager.getAvatarImage(urlString: spriteURL) { [weak self] result in
            if case .success(let image) = result {
                DispatchQueue.main.async {
                    self?.spriteImageView.image = image
                }
            }
        }
    }
}
