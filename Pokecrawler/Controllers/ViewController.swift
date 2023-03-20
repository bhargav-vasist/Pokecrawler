//
//  ViewController.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

import UIKit

class ViewController: UIViewController {

    let greetingLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(greetingLabel)
        view.backgroundColor = .white
        greetingLabel.text = "Gotta catch 'em all"
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        greetingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }


}

