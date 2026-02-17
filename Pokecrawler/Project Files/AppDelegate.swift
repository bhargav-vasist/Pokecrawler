//
//  AppDelegate.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        
        // Start loading the Pokemon search index in background
        // This fetches all Pokemon names for instant search
        PKPokemonIndex.shared.loadAndSync()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
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
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
