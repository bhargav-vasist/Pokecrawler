//
//  PKPokemonCollectionViewCell.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

class PKPokemonCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: PKPokemonCollectionViewCell.self)
    
    let avatarImageView = GFAvatarImageView()
    let usernameLabel = GFFollowerCellUsernameLabel()
    lazy var verticalStackView = GFFollowerCellStackView(with: [avatarImageView, usernameLabel])

    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    func set(follower: GFFollower) {
        usernameLabel.text = follower.login
        GFNetworkManager.shared.getAvatarImage(urlString: follower.avatarURL) { [weak self] result in
            switch result {
            case .failure:
                break
            case .success(let image):
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        contentView.addSubview(verticalStackView)
    
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

    }
}

