//
//  PKPokemonAbility.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 16/02/26.
//

import Foundation

/// Pokemon Ability slot
class PKPokemonAbility: Codable {
    /// Whether or not this is a hidden ability
    var isHidden: Bool
    
    /// The slot this ability occupies in this Pokémon species
    var slot: Int
    
    /// The ability the Pokémon may have
    var ability: PKMNamedAPIResource<String>
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

/// Full Ability details (fetched separately)
class PKAbilityDetail: Codable {
    /// The identifier for this ability resource
    var id: Int
    
    /// The name for this ability resource
    var name: String
    
    /// The generation this ability originated in
    var generation: PKMNamedAPIResource<String>?
    
    /// The flavor text of this ability listed in different languages
    var flavorTextEntries: [PKAbilityFlavorText]?
    
    /// The effect of this ability listed in different languages
    var effectEntries: [PKAbilityEffectEntry]?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    /// Get English description
    var englishDescription: String? {
        effectEntries?.first(where: { $0.language?.name == "en" })?.shortEffect
    }
    
    /// Get English flavor text
    var englishFlavorText: String? {
        flavorTextEntries?.first(where: { $0.language?.name == "en" })?.flavorText?
            .replacingOccurrences(of: "\n", with: " ")
    }
}

class PKAbilityFlavorText: Codable {
    var flavorText: String?
    var language: PKMNamedAPIResource<String>?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

class PKAbilityEffectEntry: Codable {
    var effect: String?
    var shortEffect: String?
    var language: PKMNamedAPIResource<String>?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
