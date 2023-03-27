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
        configureCollectionView()
        configureDataSource()
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
        title = "Pokedex"
        
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(UIImage(systemName: "gear"), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        // Create a bar button item with the button as its custom view
        let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)

        // Add the button to the navigation bar
        navigationItem.rightBarButtonItem = settingsBarButtonItem
    }
    
    // Function to handle the settings button being tapped
    @objc func settingsButtonTapped() {
        navigationController?.pushViewController(PKSettingsTableViewController(with: PKStorageManager()), animated: true)
    }
    
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
        pokedexDataSource.fetchPokeData()
    }
}
