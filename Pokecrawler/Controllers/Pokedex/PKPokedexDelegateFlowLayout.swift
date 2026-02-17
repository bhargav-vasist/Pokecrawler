//
//  PKPokedexDelegateFlowLayout.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokedexDelegateFlowLayout: NSObject {
    var pokedexViewController: PKPokedexViewController?
    
    struct LayoutConstants {
        static let itemsPerRow: CGFloat = 2.0
        static let spacing: CGFloat = 16.0        // Same spacing everywhere (edges + between)
        static let cellAspectRatio: CGFloat = 1.35
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
        
        let screenWidth = collectionView.bounds.width
        let spacing = LayoutConstants.spacing
        let itemsPerRow = LayoutConstants.itemsPerRow
        
        // Total horizontal spacing: left edge + middle gaps + right edge
        // For 2 items: spacing + spacing + spacing = 3 * spacing
        let totalSpacing = spacing * (itemsPerRow + 1)
        let availableWidth = screenWidth - totalSpacing
        let cellWidth = availableWidth / itemsPerRow
        let cellHeight = cellWidth * LayoutConstants.cellAspectRatio
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return LayoutConstants.spacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return LayoutConstants.spacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0.0,
            left: LayoutConstants.spacing,
            bottom: LayoutConstants.spacing,
            right: LayoutConstants.spacing
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let pokemon = pokedexViewController?.pokedexDataSource.itemIdentifier(for: indexPath) else {
            fatalError("Critical data for Pokemon Cell not found! This should not have happenened")
        }
        let pokeDetailVC = PKPokeDetailViewController(with: pokemon, and: PKNetworkManager(), also: PKStorageManager())
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
        
        if (scrollViewFrameHeight + contentOffset) > (contentHeight - 250) {
            pokedexViewController?.pokedexDataSource.fetchEvenMorePokeData()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let hasMorePokemon = pokedexViewController?.pokedexDataSource.hasMorePokemon,
              hasMorePokemon else { return }
        
        let contentHeight = scrollView.contentSize.height
        let contentOffset = scrollView.contentOffset.y
        let scrollViewFrameHeight = scrollView.frame.size.height
        
        if (scrollViewFrameHeight + contentOffset) > (contentHeight - 400) {
            pokedexViewController?.pokedexDataSource.fetchEvenMorePokeData()
        }
    }
}
