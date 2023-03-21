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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureNavigation()
        configureCollectionView()
        configureDataSource()
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = delegateFlowLayout
        collectionView.register(PKPokemonCollectionViewCell.self, forCellWithReuseIdentifier: PKPokemonCollectionViewCell.reuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func configureNavigation() {
        view.backgroundColor = .lightText
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "Pokedex"
    }
    
    private func configureDataSource() {
        pokedexDataSource = PKPokedexDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, pokemon in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PKPokemonCollectionViewCell.reuseIdentifier, for: indexPath) as? PKPokemonCollectionViewCell else {
                fatalError("Failed to dequeue reusable PKPokemonCollectionViewCell")
            }
            cell.set(pokemon: pokemon)
            return cell
        })
        pokedexDataSource.fetchPokeData()
    }
}

