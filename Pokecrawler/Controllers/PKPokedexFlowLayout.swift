//
//  PKPokedexFlowLayout.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokedexFlowLayout: NSObject {
    var pokedexViewController: PKPokedexViewController?
    
    init(_ viewController: PKPokedexViewController) {
        self.pokedexViewController = viewController
    }
}

extension PKPokedexFlowLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        let cellItemWidth = (screenWidth / 3.0) - 20.0
        let cellItemHeight = cellItemWidth * 1.25
        
        return CGSize(width: cellItemWidth, height: cellItemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pokemon = pokedexViewController?.pokedexDataSource.itemIdentifier(for: indexPath) else {
            fatalError("Critical data for Pokemon Cell not found! This should not happen")
        }
        print("You have selected", pokemon)
    }
}
