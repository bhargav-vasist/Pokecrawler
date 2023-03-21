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
    lazy var delegateFlowLayout = PKPokedexFlowLayout(self)
    
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
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func configureDataSource() {
        PKNetworkManager().fetch(.getPokemon(with: "1")) { result in
            switch result {
            case .success(let pokeData):
                print("Data received", pokeData)
            case .failure(let error):
                print("Fetching pokemon failed with error", error)
            }
        }
    }
}

