//
//  PKPokemonIndex.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 16/02/26.
//

import Foundation

/// Lightweight Pokemon entry for search index (name + URL only)
struct PKIndexEntry: Codable, Hashable {
    let name: String
    let url: String
    
    /// Extract Pokemon ID from the URL
    var id: Int? {
        // URL format: https://pokeapi.co/api/v2/pokemon/{id}/
        let components = url.trimmingCharacters(in: CharacterSet(charactersIn: "/")).split(separator: "/")
        return components.last.flatMap { Int($0) }
    }
}

/// Manages a local index of all Pokemon names for instant search
/// Syncs in background on app launch, persists to disk
class PKPokemonIndex {
    
    // MARK: - Singleton
    static let shared = PKPokemonIndex()
    
    // MARK: - Properties
    private var entries: [PKIndexEntry] = []
    private let networkManager: PKNetworkManager
    private let fileManager: FileManager
    
    /// Whether the index has been loaded (from disk or network)
    private(set) var isLoaded = false
    
    /// Whether a sync is currently in progress
    private(set) var isSyncing = false
    
    /// Callback when index finishes loading
    var onIndexReady: (() -> Void)?
    
    /// Total Pokemon count in the index
    var count: Int { entries.count }
    
    // MARK: - File Paths
    private var indexFileURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pokemon_index.json")
    }
    
    private var metadataFileURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pokemon_index_meta.json")
    }
    
    // MARK: - Init
    private init(networkManager: PKNetworkManager = PKNetworkManager(), fileManager: FileManager = .default) {
        self.networkManager = networkManager
        self.fileManager = fileManager
    }
    
    // MARK: - Public API
    
    /// Load index from disk, then sync from network in background
    /// Call this on app launch
    func loadAndSync() {
        // First, try loading from disk for instant availability
        if loadFromDisk() {
            isLoaded = true
            onIndexReady?()
        }
        
        // Then sync from network if stale (> 24 hours old)
        if shouldSync() {
            syncFromNetwork()
        }
    }
    
    /// Force a fresh sync from the network
    func forceSync() {
        syncFromNetwork()
    }
    
    /// Search Pokemon by partial name match (case-insensitive)
    /// - Parameters:
    ///   - query: Search string
    ///   - limit: Max results to return (0 = unlimited)
    /// - Returns: Matching entries sorted by relevance
    func search(query: String, limit: Int = 0) -> [PKIndexEntry] {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !normalizedQuery.isEmpty else {
            return []
        }
        
        // Filter and sort by relevance:
        // 1. Exact match first
        // 2. Starts with query
        // 3. Contains query
        let matches = entries.filter { $0.name.lowercased().contains(normalizedQuery) }
        
        let sorted = matches.sorted { entry1, entry2 in
            let name1 = entry1.name.lowercased()
            let name2 = entry2.name.lowercased()
            
            // Exact match wins
            if name1 == normalizedQuery { return true }
            if name2 == normalizedQuery { return false }
            
            // Prefix match is next best
            let starts1 = name1.hasPrefix(normalizedQuery)
            let starts2 = name2.hasPrefix(normalizedQuery)
            if starts1 && !starts2 { return true }
            if starts2 && !starts1 { return false }
            
            // Otherwise sort alphabetically
            return name1 < name2
        }
        
        if limit > 0 && sorted.count > limit {
            return Array(sorted.prefix(limit))
        }
        return sorted
    }
    
    /// Load index and call completion when ready
    func loadIndex(completion: @escaping () -> Void) {
        if isLoaded {
            completion()
            return
        }
        
        onIndexReady = completion
        loadAndSync()
    }
    
    /// Get all entries (useful for browsing)
    func allEntries() -> [PKIndexEntry] {
        return entries.sorted { ($0.id ?? 0) < ($1.id ?? 0) }
    }
    
    // MARK: - Disk Persistence
    
    private func loadFromDisk() -> Bool {
        guard fileManager.fileExists(atPath: indexFileURL.path) else {
            return false
        }
        
        do {
            let data = try Data(contentsOf: indexFileURL)
            entries = try JSONDecoder().decode([PKIndexEntry].self, from: data)
            print("[PKPokemonIndex] Loaded \(entries.count) entries from disk")
            return true
        } catch {
            print("[PKPokemonIndex] Failed to load from disk: \(error)")
            return false
        }
    }
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: indexFileURL, options: .atomicWrite)
            
            // Save metadata with timestamp
            let metadata = IndexMetadata(lastSyncDate: Date(), entryCount: entries.count)
            let metaData = try JSONEncoder().encode(metadata)
            try metaData.write(to: metadataFileURL, options: .atomicWrite)
            
            print("[PKPokemonIndex] Saved \(entries.count) entries to disk")
        } catch {
            print("[PKPokemonIndex] Failed to save to disk: \(error)")
        }
    }
    
    private func shouldSync() -> Bool {
        guard fileManager.fileExists(atPath: metadataFileURL.path) else {
            return true // Never synced
        }
        
        do {
            let data = try Data(contentsOf: metadataFileURL)
            let metadata = try JSONDecoder().decode(IndexMetadata.self, from: data)
            
            // Sync if older than 24 hours
            let staleThreshold: TimeInterval = 24 * 60 * 60
            return Date().timeIntervalSince(metadata.lastSyncDate) > staleThreshold
        } catch {
            return true
        }
    }
    
    // MARK: - Network Sync
    
    private func syncFromNetwork() {
        guard !isSyncing else { return }
        isSyncing = true
        
        print("[PKPokemonIndex] Starting network sync...")
        
        // Fetch all Pokemon names (limit=2000 covers all current Pokemon)
        let endpoint = Endpoint.getAllPokemon(with: 2000, and: 0)
        
        networkManager.fetch(endpoint) { [weak self] result in
            guard let self = self else { return }
            
            defer { self.isSyncing = false }
            
            switch result {
            case .success(let data):
                self.parseAndSaveIndex(data: data)
                
            case .failure(let error):
                print("[PKPokemonIndex] Network sync failed: \(error)")
            }
        }
    }
    
    private func parseAndSaveIndex(data: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(PKIndexResponse.self, from: data)
            
            guard let results = response.results else {
                print("[PKPokemonIndex] No results in response")
                return
            }
            
            entries = results
            saveToDisk()
            
            DispatchQueue.main.async { [weak self] in
                self?.isLoaded = true
                self?.onIndexReady?()
            }
            
            print("[PKPokemonIndex] Synced \(entries.count) entries from network")
            
        } catch {
            print("[PKPokemonIndex] Failed to parse index: \(error)")
        }
    }
}

// MARK: - Supporting Types

private struct IndexMetadata: Codable {
    let lastSyncDate: Date
    let entryCount: Int
}

private struct PKIndexResponse: Codable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [PKIndexEntry]?
}
