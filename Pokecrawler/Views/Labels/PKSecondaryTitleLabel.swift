//
//  PKSecondaryTitleLabel.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKSecondaryTitleLabel: UILabel {

    init(fontSize: CGFloat, text: String) {
        super.init(frame: .zero)
        configure(fontSize: fontSize, text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(fontSize: CGFloat, text: String) {
        self.text = text
        font = UIFont.preferredFont(forTextStyle: .title2)
        textColor = .secondaryLabel
        textAlignment = .left
        lineBreakMode = .byTruncatingTail
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.9
        translatesAutoresizingMaskIntoConstraints = false
    }
}
