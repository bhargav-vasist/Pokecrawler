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
    struct LayoutConstants {
        static let maxItemsPerRow = 2.0
        static let interItemSpacing = 5.0
        static let cellAspectRatio = 1.45
        static let horizontalMargin = 16.0
        static let interLineSpacing = 16.0
    }
    
    init(_ viewController: PKPokedexViewController) {
        self.pokedexViewController = viewController
    }
}

extension PKPokedexDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        
        // Weird math for getting widths fitting for most screensizes.
        let cellItemWidth = (screenWidth / LayoutConstants.maxItemsPerRow)
                            - ((LayoutConstants.maxItemsPerRow * LayoutConstants.interItemSpacing)
                            + LayoutConstants.horizontalMargin)
        let cellItemHeight = cellItemWidth * LayoutConstants.cellAspectRatio
        
        return CGSize(width: cellItemWidth, height: cellItemHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return LayoutConstants.interItemSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return LayoutConstants.interLineSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0.0,
            left: LayoutConstants.horizontalMargin,
            bottom: 0.0,
            right: LayoutConstants.horizontalMargin
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let pokemon = pokedexViewController?.pokedexDataSource.itemIdentifier(for: indexPath) else {
            fatalError("Critical data for Pokemon Cell not found! This should not have happenened")
        }
        let pokeDetailVC = PKPokeDetailViewController(with: pokemon, and: PKNetworkManager())
        pokedexViewController?.navigationController?.pushViewController(pokeDetailVC, animated: true)
    }
    
    // Detects when the end of the page is about to hit and calls for fetching paginated data.
    // Probably a better idea to use a combination of didEndDragging and DidEndDecelerating.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let hasMorePokemon = pokedexViewController?.pokedexDataSource.hasMorePokemon,
              hasMorePokemon else { return }
        
        let contentHeight = scrollView.contentSize.height
        let contentOffset = scrollView.contentOffset.y
        let scrollViewFrameHeight = scrollView.frame.size.height
        
        print("Scrollview", scrollViewFrameHeight + contentOffset, "Versus", contentHeight-400)
        if (scrollViewFrameHeight + contentOffset) > (contentHeight - 400) {
            pokedexViewController?.pokedexDataSource.fetchEvenMorePokeData()
        }
    }
}
