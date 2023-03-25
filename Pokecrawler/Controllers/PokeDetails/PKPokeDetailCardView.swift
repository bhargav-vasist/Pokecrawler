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
    
    // If supplying with 
    init(with pokemonModel: PKPokemonModel) {
        infoTitleOne = "Height"
        infoTitleTwo = "Weight"
        infoDescriptionOne = "\(pokemonModel.height * 10) cm"
        infoDescriptionTwo = "\(Float(pokemonModel.weight) / 100) kg"
    }
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
        let stack = PKVertStackView(with: [titleLabelOne, descriptionLabelOne])
        stack.alignment = .leading
        stack.spacing = 4
        return stack
    }()
    
    lazy private var vertStackTwo: PKVertStackView = {
        let stack = PKVertStackView(with: [titleLabelTwo, descriptionLabelTwo])
        stack.alignment = .leading
        stack.spacing = 4
        return stack
    }()
    
    lazy private var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [vertStackOne, vertStackTwo])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fillEqually
        containerView.addSubview(stack)
        return stack
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
