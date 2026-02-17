//
//  PKPokeDetailMovesView.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 16/02/26.
//

import UIKit

class PKPokeDetailMovesView: UIView {
    
    // MARK: - Properties
    private var pokemonModel: PKPokemonModel!
    private var allMoves: [(name: String, level: Int)] = []
    private let maxDisplayedMoves = 5
    
    /// Callback when "Show All" is tapped - parent should present the modal
    var onShowAllTapped: ((_ moves: [(name: String, level: Int)], _ color: UIColor) -> Void)?
    
    // MARK: - Views
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)
        return stack
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Level-up Moves"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        addSubview(label)
        return label
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No moves data available"
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .body)
        label.isHidden = true
        addSubview(label)
        return label
    }()
    
    private lazy var showAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show All Moves", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(showAllTapped), for: .touchUpInside)
        button.isHidden = true
        addSubview(button)
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(with pokemonModel: PKPokemonModel) {
        self.init(frame: .zero)
        self.pokemonModel = pokemonModel
        configureView()
        configureLayout()
        processMoves()
    }
    
    // MARK: - Configuration
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            stackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            showAllButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12),
            showAllButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            showAllButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            showAllButton.heightAnchor.constraint(equalToConstant: 44),
            showAllButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            emptyLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            emptyLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    private func processMoves() {
        guard let moves = pokemonModel.moves, !moves.isEmpty else {
            emptyLabel.isHidden = false
            return
        }
        
        // Get level-up moves, sorted by level
        allMoves = moves.compactMap { move -> (name: String, level: Int)? in
            guard let details = move.versionGroupDetails?.last,
                  details.moveLearnMethod?.name == "level-up",
                  let level = details.levelLearnedAt,
                  level > 0 else { return nil }
            
            let name = move.move.name.replacingOccurrences(of: "-", with: " ").capitalized
            return (name: name, level: level)
        }
        .sorted { $0.level < $1.level }
        
        if allMoves.isEmpty {
            emptyLabel.isHidden = false
            return
        }
        
        let typeColor = pokemonModel.types.first?.type.name.getColorForType() ?? .systemBlue
        
        // Show only first few moves
        let movesToDisplay = Array(allMoves.prefix(maxDisplayedMoves))
        
        for move in movesToDisplay {
            let moveRow = createMoveRow(name: move.name, level: move.level, color: typeColor)
            stackView.addArrangedSubview(moveRow)
        }
        
        // Show "Show All" button if there are more moves
        if allMoves.count > maxDisplayedMoves {
            showAllButton.isHidden = false
            showAllButton.setTitle("Show All \(allMoves.count) Moves", for: .normal)
            showAllButton.tintColor = typeColor
        }
    }
    
    private func createMoveRow(name: String, level: Int, color: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 8
        
        let levelLabel = UILabel()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.text = "Lv\(level)"
        levelLabel.font = .systemFont(ofSize: 12, weight: .bold)
        levelLabel.textColor = .white
        levelLabel.textAlignment = .center
        levelLabel.backgroundColor = color
        levelLabel.layer.cornerRadius = 10
        levelLabel.clipsToBounds = true
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = name
        nameLabel.font = .preferredFont(forTextStyle: .body)
        
        container.addSubview(levelLabel)
        container.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 40),
            
            levelLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            levelLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            levelLabel.widthAnchor.constraint(equalToConstant: 40),
            levelLabel.heightAnchor.constraint(equalToConstant: 20),
            
            nameLabel.leadingAnchor.constraint(equalTo: levelLabel.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        
        return container
    }
    
    // MARK: - Actions
    @objc private func showAllTapped() {
        let typeColor = pokemonModel.types.first?.type.name.getColorForType() ?? .systemBlue
        onShowAllTapped?(allMoves, typeColor)
    }
}

// MARK: - All Moves Modal
class PKAllMovesViewController: UIViewController {
    
    private let moves: [(name: String, level: Int)]
    private let accentColor: UIColor
    private let pokemonName: String
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "MoveCell")
        return table
    }()
    
    init(moves: [(name: String, level: Int)], accentColor: UIColor, pokemonName: String) {
        self.moves = moves
        self.accentColor = accentColor
        self.pokemonName = pokemonName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        title = "\(pokemonName)'s Moves"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissModal)
        )
        navigationItem.rightBarButtonItem?.tintColor = accentColor
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
}

extension PKAllMovesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moves.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoveCell", for: indexPath)
        let move = moves[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = move.name
        
        // Level badge
        let levelBadge = UILabel()
        levelBadge.text = "Lv\(move.level)"
        levelBadge.font = .systemFont(ofSize: 12, weight: .bold)
        levelBadge.textColor = .white
        levelBadge.backgroundColor = accentColor
        levelBadge.textAlignment = .center
        levelBadge.layer.cornerRadius = 10
        levelBadge.clipsToBounds = true
        levelBadge.frame = CGRect(x: 0, y: 0, width: 44, height: 22)
        
        cell.accessoryView = levelBadge
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(moves.count) Level-up Moves"
    }
}
