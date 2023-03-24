//
//  PKVertStackView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKVertStackView: UIStackView {
    
    init(with arrangedSubviews: [UIView]) {
        super.init(frame: .zero)
        configure(with: arrangedSubviews)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(with arrangedSubviews: [UIView]) {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .center
        distribution = .fill
        arrangedSubviews.forEach { addArrangedSubview($0) }
    }

}
