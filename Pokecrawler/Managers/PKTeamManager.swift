//
//  PKTeamManager.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 08/12/25.
//

import Foundation

/// Error types for team operations
enum PKTeamError: Error, LocalizedError {
    case teamFull
    case alreadyInTeam
    case notInTeam
    case saveFailed
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .teamFull:
            return "Your team is full! Remove a Pokémon first."
        case .alreadyInTeam:
            return "This Pokémon is already on your team."
        case .notInTeam:
            return "This Pokémon is not on your team."
        case .saveFailed:
            return "Failed to save your team."
        case .loadFailed:
            return "Failed to load your team."
        }
    }
}

/// Notification names for team changes
extension Notification.Name {
    static let teamDidChange = Notification.Name("PKTeamDidChange")
}

/// Manages the user's Pokemon team (up to 6 Pokemon)
class PKTeamManager {
    
    // MARK: - Singleton
    static let shared = PKTeamManager()
    
    // MARK: - Constants
    static let maxTeamSize = 6
    
    // MARK: - Properties
    private var team: [PKPokemonModel] = []
    private let fileManager: FileManager
    
    /// Current team (read-only)
    var currentTeam: [PKPokemonModel] {
        return team
    }
    
    /// Number of Pokemon in team
    var teamCount: Int {
        return team.count
    }
    
    /// Whether the team is full
    var isTeamFull: Bool {
        return team.count >= PKTeamManager.maxTeamSize
    }
    
    /// Available slots in team
    var availableSlots: Int {
        return PKTeamManager.maxTeamSize - team.count
    }
    
    // MARK: - File Path
    private var teamFileURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pokemon_team.json")
    }
    
    // MARK: - Init
    private init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        loadTeam()
    }
    
    // MARK: - Public API
    
    /// Check if a Pokemon is in the team
    func isInTeam(_ pokemon: PKPokemonModel) -> Bool {
        return team.contains(where: { $0.id == pokemon.id })
    }
    
    /// Add a Pokemon to the team
    /// - Throws: PKTeamError if team is full or Pokemon already exists
    @discardableResult
    func addToTeam(_ pokemon: PKPokemonModel) throws -> Bool {
        guard !isTeamFull else {
            throw PKTeamError.teamFull
        }
        
        guard !isInTeam(pokemon) else {
            throw PKTeamError.alreadyInTeam
        }
        
        team.append(pokemon)
        try saveTeam()
        notifyTeamChange()
        return true
    }
    
    /// Remove a Pokemon from the team
    /// - Throws: PKTeamError if Pokemon is not in team
    @discardableResult
    func removeFromTeam(_ pokemon: PKPokemonModel) throws -> Bool {
        guard let index = team.firstIndex(where: { $0.id == pokemon.id }) else {
            throw PKTeamError.notInTeam
        }
        
        team.remove(at: index)
        try saveTeam()
        notifyTeamChange()
        return true
    }
    
    /// Move a Pokemon within the team (reorder)
    func movePokemon(from sourceIndex: Int, to destinationIndex: Int) throws {
        guard sourceIndex >= 0, sourceIndex < team.count,
              destinationIndex >= 0, destinationIndex < team.count else {
            return
        }
        
        let pokemon = team.remove(at: sourceIndex)
        team.insert(pokemon, at: destinationIndex)
        try saveTeam()
        notifyTeamChange()
    }
    
    /// Clear the entire team
    func clearTeam() throws {
        team.removeAll()
        try saveTeam()
        notifyTeamChange()
    }
    
    /// Get Pokemon at specific slot (0-5)
    func pokemon(at slot: Int) -> PKPokemonModel? {
        guard slot >= 0, slot < team.count else {
            return nil
        }
        return team[slot]
    }
    
    // MARK: - Persistence
    
    private func saveTeam() throws {
        do {
            let encoder = PKPokemonModel.encoder
            let data = try encoder.encode(team)
            try data.write(to: teamFileURL, options: .atomicWrite)
        } catch {
            print("[PKTeamManager] Save failed: \(error)")
            throw PKTeamError.saveFailed
        }
    }
    
    private func loadTeam() {
        guard fileManager.fileExists(atPath: teamFileURL.path) else {
            team = []
            return
        }
        
        do {
            let data = try Data(contentsOf: teamFileURL)
            let decoder = PKPokemonModel.decoder
            team = try decoder.decode([PKPokemonModel].self, from: data)
        } catch {
            print("[PKTeamManager] Load failed: \(error)")
            team = []
        }
    }
    
    // MARK: - Notifications
    
    private func notifyTeamChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .teamDidChange, object: nil)
        }
    }
}
