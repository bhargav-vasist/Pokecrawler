//
//  SceneDelegate.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Start loading the Pokemon search index in background
        PKPokemonIndex.shared.loadAndSync()
        
        window = UIWindow(windowScene: windowScene)
        
        // Use TabBarController as root
        let tabBarController = PKMainTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // Apply dark mode preference
        if let darkModeEnabled = PKStorageManager().getFromDefaults(for: .darkModeToggle) as? Bool {
            window?.overrideUserInterfaceStyle = darkModeEnabled ? .dark : .light
        } else {
            window?.overrideUserInterfaceStyle = .light
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
