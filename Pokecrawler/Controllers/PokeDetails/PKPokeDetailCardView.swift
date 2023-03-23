//
//  PKPokeDetailCardView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 23/03/23.
//

import UIKit

struct PKPokeDetailCardViewModel {
    var infoTitleOne: String
    var infoTitleTwo: String
    
    var infoDescriptionOne: String
    var infoDescriptionTwo: String
}

class PKPokeDetailCardView: UIView {
    
    private var viewModel: PKPokeDetailCardViewModel!
    
    lazy private var titleLabelOne: PKSecondaryTitleLabel = {
        let label = PKSecondaryTitleLabel(fontSize: 16, text: viewModel.infoTitleOne)
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()
    
    lazy private var titleLabelTwo: PKSecondaryTitleLabel = {
        let label = PKSecondaryTitleLabel(fontSize: 16, text: viewModel.infoTitleTwo)
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()
    
    lazy private var descriptionLabelOne: PKPrimaryTitleLabel = {
        let label = PKPrimaryTitleLabel(text: viewModel.infoDescriptionOne)
        return label
    }()
    
    lazy private var descriptionLabelTwo: PKPrimaryTitleLabel = {
        let label = PKPrimaryTitleLabel(text: viewModel.infoDescriptionTwo)
        return label
    }()
    
    lazy private var vertStackOne: PKVertStackView = {
        let sv = PKVertStackView(with: [titleLabelOne, descriptionLabelOne])
        sv.alignment = .leading
        sv.spacing = 4
        return sv
    }()
    
    lazy private var vertStackTwo: PKVertStackView = {
        let sv = PKVertStackView(with: [titleLabelTwo, descriptionLabelTwo])
        sv.alignment = .leading
        sv.spacing = 4
        return sv
    }()
    
    lazy private var mainStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [vertStackOne, vertStackTwo])
        sv.axis = .horizontal
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 12
        sv.alignment = .center
        sv.distribution = .fillEqually
        containerView.addSubview(sv)
        return sv
    }()
    
    lazy private var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    let cornerRadius: CGFloat = 12.0
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(with viewModel: PKPokeDetailCardViewModel) {
        self.init(frame: .zero)
        self.viewModel = viewModel
        configureView()
        configureLayout()
    }
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        
        // set the shadow of the view's layer
        
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 4.0
        layer.masksToBounds = false
        
        // set the cornerRadius of the containerView's layer
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.masksToBounds = true
        containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.layer.borderWidth = 0.2
        
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
