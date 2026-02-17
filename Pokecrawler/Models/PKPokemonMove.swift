//
//  PKPokemonMove.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 08/12/25.
//

import UIKit

/// Pokemon Move slot from Pokemon response
class PKPokemonMove: Codable {
    /// The move the Pokémon can learn
    var move: PKMNamedAPIResource<String>
    
    /// The details of the version in which the Pokémon can learn the move
    var versionGroupDetails: [PKPokemonMoveVersion]?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

/// Version details for when a Pokemon learns a move
class PKPokemonMoveVersion: Codable {
    /// The method by which the move is learned
    var moveLearnMethod: PKMNamedAPIResource<String>?
    
    /// The version group in which the move is learned
    var versionGroup: PKMNamedAPIResource<String>?
    
    /// The minimum level to learn the move
    var levelLearnedAt: Int?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

/// Full Move details (fetched separately)
class PKMoveDetail: Codable {
    /// The identifier for this move resource
    var id: Int
    
    /// The name for this move resource
    var name: String
    
    /// The percent value of how likely this move is to be successful
    var accuracy: Int?
    
    /// The percent value of how likely it is this moves effect will take effect
    var effectChance: Int?
    
    /// Power points. The number of times this move can be used
    var pp: Int? // swiftlint:disable:this identifier_name
    
    /// A value between -8 and 8. Sets the order in which moves are executed during battle
    var priority: Int?
    
    /// The base power of this move with a value of 0 if it does not have a base power
    var power: Int?
    
    /// The type of damage the move inflicts on the target, e.g. physical
    var damageClass: PKMNamedAPIResource<String>?
    
    /// The elemental type of this move
    var type: PKMNamedAPIResource<PKPokemonBaseType>?
    
    /// The flavor text of this move listed in different languages
    var flavorTextEntries: [PKMoveFlavorText]?
    
    /// The effect of this move listed in different languages
    var effectEntries: [PKMoveEffectEntry]?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    /// Get English description
    var englishDescription: String? {
        flavorTextEntries?.first(where: { $0.language?.name == "en" })?.flavorText?
            .replacingOccurrences(of: "\n", with: " ")
    }
    
    /// Formatted display name
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    /// Color for the move type
    var typeColor: UIColor {
        type?.name.getColorForType() ?? .systemGray
    }
}

class PKMoveFlavorText: Codable {
    var flavorText: String?
    var language: PKMNamedAPIResource<String>?
    var versionGroup: PKMNamedAPIResource<String>?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

class PKMoveEffectEntry: Codable {
    var effect: String?
    var shortEffect: String?
    var language: PKMNamedAPIResource<String>?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
