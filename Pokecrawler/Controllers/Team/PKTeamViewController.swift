//
//  PKTeamViewController.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 08/12/25.
//

import UIKit

class PKTeamViewController: UIViewController {
    
    // MARK: - Properties
    private let teamManager = PKTeamManager.shared
    private let networkManager = PKNetworkManager()
    
    // MARK: - Views
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .systemBackground
        collection.delegate = self
        collection.dataSource = self
        collection.register(PKTeamSlotCell.self, forCellWithReuseIdentifier: PKTeamSlotCell.reuseIdentifier)
        collection.register(PKTeamHeaderView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: PKTeamHeaderView.reuseIdentifier)
        return collection
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureViews()
        configureNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        updateNavigationItems()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Configuration
    private func configureNavigation() {
        title = "My Team"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Clear team button (only show if team has Pokemon)
        updateNavigationItems()
    }
    
    private func configureViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(teamDidChange),
            name: .teamDidChange,
            object: nil
        )
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalWidth(1/3 * 1.3)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8)
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Updates
    @objc private func teamDidChange() {
        collectionView.reloadData()
        updateNavigationItems()
    }
    
    private func updateNavigationItems() {
        if teamManager.teamCount > 0 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Clear",
                style: .plain,
                target: self,
                action: #selector(clearTeamTapped)
            )
            navigationItem.rightBarButtonItem?.tintColor = .systemRed
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - Actions
    @objc private func clearTeamTapped() {
        let alert = UIAlertController(
            title: "Clear Team?",
            message: "This will remove all Pokémon from your team.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            try? self?.teamManager.clearTeam()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension PKTeamViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Always show 6 slots
        return PKTeamManager.maxTeamSize
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PKTeamSlotCell.reuseIdentifier,
            for: indexPath
        ) as? PKTeamSlotCell else {
            fatalError("Failed to dequeue PKTeamSlotCell")
        }
        
        let pokemon = teamManager.pokemon(at: indexPath.item)
        cell.configure(with: pokemon, slot: indexPath.item + 1, networkManager: networkManager)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PKTeamHeaderView.reuseIdentifier,
            for: indexPath
        ) as? PKTeamHeaderView else {
            fatalError("Failed to dequeue PKTeamHeaderView")
        }
        
        header.configure(filledSlots: teamManager.teamCount, totalSlots: PKTeamManager.maxTeamSize)
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension PKTeamViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let pokemon = teamManager.pokemon(at: indexPath.item) {
            // Show detail view for existing Pokemon
            let detailVC = PKPokeDetailViewController(
                with: pokemon,
                and: networkManager,
                also: PKStorageManager()
            )
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            // Empty slot - show add Pokemon sheet
            presentAddPokemonSheet()
        }
    }
    
    private func presentAddPokemonSheet() {
        guard !teamManager.isTeamFull else {
            return
        }
        
        let addSheet = PKAddPokemonSheetController()
        addSheet.delegate = self
        
        if let sheet = addSheet.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.selectedDetentIdentifier = .medium
        }
        
        present(addSheet, animated: true)
    }
}

// MARK: - PKAddPokemonSheetDelegate
extension PKTeamViewController: PKAddPokemonSheetDelegate {
    func didAddPokemon(_ pokemon: PKPokemonModel) {
        // Collection view will update via notification
        showToast("Added \(pokemon.name.capitalized) to team!")
    }
    
    private func showToast(_ message: String) {
        let toast = PKToastView(message: message)
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: 20)
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            toast.alpha = 1
            toast.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 1.8) {
                toast.alpha = 0
                toast.transform = CGAffineTransform(translationX: 0, y: 10)
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

// MARK: - Team Slot Cell
class PKTeamSlotCell: UICollectionViewCell {
    static let reuseIdentifier = "PKTeamSlotCell"
    
    private var imageTask: URLSessionDataTask?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var spriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private lazy var slotLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white.withAlphaComponent(0.7)
        return label
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "plus.circle.dashed"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Empty"
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .tertiaryLabel
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        spriteImageView.image = nil
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(spriteImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(slotLabel)
        containerView.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            slotLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            slotLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            
            spriteImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            spriteImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            spriteImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.7),
            spriteImageView.heightAnchor.constraint(equalTo: spriteImageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: spriteImageView.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8),
            
            emptyStateView.topAnchor.constraint(equalTo: containerView.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    func configure(with pokemon: PKPokemonModel?, slot: Int, networkManager: PKNetworkManager) {
        slotLabel.text = "\(slot)"
        
        if let pokemon = pokemon {
            emptyStateView.isHidden = true
            spriteImageView.isHidden = false
            nameLabel.isHidden = false
            
            let displayName = pokemon.name.replacingOccurrences(of: "-", with: " ").capitalized
            nameLabel.text = displayName
            
            let typeColor = pokemon.types.first?.type.name.getColorForType() ?? .systemGray
            containerView.backgroundColor = typeColor
            
            // Load image
            if let spriteURL = pokemon.sprites.other?.home?.frontDefault {
                imageTask = networkManager.getAvatarImage(urlString: spriteURL) { [weak self] result in
                    if case .success(let image) = result {
                        DispatchQueue.main.async {
                            self?.spriteImageView.image = image
                        }
                    }
                }
            }
        } else {
            emptyStateView.isHidden = false
            spriteImageView.isHidden = true
            nameLabel.isHidden = true
            containerView.backgroundColor = .secondarySystemBackground
        }
    }
}

// MARK: - Team Header View
class PKTeamHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "PKTeamHeaderView"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(filledSlots: Int, totalSlots: Int) {
        titleLabel.text = "Team Roster"
        subtitleLabel.text = "\(filledSlots)/\(totalSlots) slots filled"
    }
}
