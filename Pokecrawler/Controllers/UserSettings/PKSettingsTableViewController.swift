//
//  PKSettingsTableViewController.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 26/03/23.
//

import UIKit

struct PKSettingsTableViewData {
    
}

class PKSettingsTableViewController: UITableViewController {
    
    private var storageManager: PKStorageManager!
    
    init(with storageManager: PKStorageManager) {
        super.init(nibName: nil, bundle: nil)
        self.storageManager = storageManager
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Create a variable to store the state of the dark mode toggle
    var isDarkModeEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the title of the view controller
        title = "Settings"
        
        // Register a cell for the table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        if let darkModeToggle = storageManager.getFromDefaults(for: .darkModeToggle) as? Bool {
            isDarkModeEnabled = darkModeToggle
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Configure the cell
        cell.textLabel?.text = "Dark Mode"
        
        // Create a switch to toggle dark mode
        let darkModeSwitch = UISwitch()
        darkModeSwitch.isOn = isDarkModeEnabled
        darkModeSwitch.addTarget(self, action: #selector(darkModeSwitchChanged(_:)), for: .valueChanged)
        cell.accessoryView = darkModeSwitch
        
        return cell
    }
    
    @objc func darkModeSwitchChanged(_ sender: UISwitch) {
        // Update the state of the dark mode toggle
        isDarkModeEnabled = sender.isOn
        
        // Update the app's appearance based on the toggle
        if isDarkModeEnabled {
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .dark
        } else {
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .light
        }
        
        storageManager.updateDefaults(for: .darkModeToggle, with: isDarkModeEnabled)
    }
    
}
