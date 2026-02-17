//
//  PKMainTabBarController.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 16/02/26.
//

import UIKit

class PKMainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        configureViewControllers()
    }
    
    private func configureTabBar() {
        tabBar.tintColor = .systemRed
        
        // Configure tab bar appearance consistently
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = .secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = .systemRed
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemRed]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func configureViewControllers() {
        // Pokedex Tab
        let pokedexVC = PKPokedexViewController(with: PKNetworkManager())
        let pokedexNav = UINavigationController(rootViewController: pokedexVC)
        pokedexNav.tabBarItem = UITabBarItem(
            title: "Pokédex",
            image: UIImage(systemName: "book.closed"),
            selectedImage: UIImage(systemName: "book.closed.fill")
        )
        pokedexNav.tabBarItem.accessibilityLabel = "Pokédex"
        pokedexNav.tabBarItem.accessibilityHint = "Browse all Pokémon"
        
        // Team Tab
        let teamVC = PKTeamViewController()
        let teamNav = UINavigationController(rootViewController: teamVC)
        teamNav.tabBarItem = UITabBarItem(
            title: "My Team",
            image: UIImage(systemName: "person.3"),
            selectedImage: UIImage(systemName: "person.3.fill")
        )
        teamNav.tabBarItem.accessibilityLabel = "My Team"
        teamNav.tabBarItem.accessibilityHint = "View and manage your Pokémon team"
        
        // Settings Tab
        let settingsVC = PKSettingsTableViewController(with: PKStorageManager())
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear")
        )
        settingsNav.tabBarItem.accessibilityLabel = "Settings"
        settingsNav.tabBarItem.accessibilityHint = "App settings"
        
        viewControllers = [pokedexNav, teamNav, settingsNav]
    }
}
