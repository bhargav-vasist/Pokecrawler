//
//  PKPokedexDelegateFlowLayout.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokedexDelegateFlowLayout: NSObject {
    var pokedexViewController: PKPokedexViewController?
    
    // TODO: Introduce items per row as a filter option
    let MAX_ITEMS_PER_ROW = 2.0
    let INTER_ITEM_SPACING = 5.0
    let CELL_ASPECT_RATIO = 1.45
    let HORIZONTAL_MARGIN = 16.0
    let INTER_LINE_SPACING = 16.0
    
    init(_ viewController: PKPokedexViewController) {
        self.pokedexViewController = viewController
    }
}

extension PKPokedexDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        
        // Weird math for getting widths fitting for most screensizes.
        let cellItemWidth = (screenWidth / MAX_ITEMS_PER_ROW) - ((MAX_ITEMS_PER_ROW * INTER_ITEM_SPACING) + HORIZONTAL_MARGIN)
        let cellItemHeight = cellItemWidth * CELL_ASPECT_RATIO
        
        return CGSize(width: cellItemWidth, height: cellItemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return INTER_ITEM_SPACING
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return INTER_LINE_SPACING
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: HORIZONTAL_MARGIN, bottom: 0.0, right: HORIZONTAL_MARGIN)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pokemon = pokedexViewController?.pokedexDataSource.itemIdentifier(for: indexPath) else {
            fatalError("Critical data for Pokemon Cell not found! This should not have happenened")
        }
        let pokeDetailVC = PKPokeDetailViewController(with: pokemon, and: PKNetworkManager())
        pokedexViewController?.navigationController?.pushViewController(pokeDetailVC, animated: true)
    }
    
    // Detects when the end of the page is about to hit and calls for fetching paginated data.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let hasMorePokemon = pokedexViewController?.pokedexDataSource.hasMorePokemon, hasMorePokemon else { return }
        
        let contentHeight = scrollView.contentSize.height
        let contentOffset = scrollView.contentOffset.y
        let scrollViewFrameHeight = scrollView.frame.size.height
        
        if (scrollViewFrameHeight + contentOffset) > (contentHeight - 300)  {
            print("Fetching more for you m'lord")
            pokedexViewController?.pokedexDataSource.fetchEvenMorePokeData()
        }
    }
}
