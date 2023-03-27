//
//  PKPokemonStats.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 22/03/23.
//

import Foundation

/// Pokemon Stat
class PKPokemonStat: Codable {
    
    /// The stat the Pokémon has
    var stat: PKMNamedAPIResource<String>
    
    /// The effort points (EV) the Pokémon has in the stat
    var effort: Int?
    
    /// The base value of the stat
    var baseStat: Int
    
    public static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

/// Stats determine certain aspects of battles.
/// Each Pokémon has a value for each stat which grows as they gain levels and can be altered momentarily by effects in battles.
class PKPokeFullStat: Codable {
    
    /// The identifier for this stat resource
    var id: Int
    
    /// The name for this stat resource
    var name: PKPokemonBaseStat
    
    /// ID the games use for this stat
    var gameIndex: Int?
    
    /// Whether this stat only exists within a battle
    var isBattleOnly: Bool?
    
    public static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

enum PKPokemonBaseStat: String, Codable {
    // Since we use the Codable Enum directly for encoding/decoding,
    // we keep the name to match the keys value 
    // swiftlint:disable identifier_name
    case hp
    // swiftlint:enable identifier_name
    case attack
    case defense
    case specialAttack
    case specialDefense
    case speed
    case accuracy
    case evasion
    
    func getDisplayName() -> String {
        switch self {
        case .hp:
            return "HP"
        case .attack:
            return "ATK"
        case .defense:
            return "DEF"
        case .specialAttack:
            return "SP ATK"
        case .specialDefense:
            return "SP DEF"
        case .speed:
            return "SPD"
        case .accuracy:
            return "ACC"
        case .evasion:
            return "EVS"
        }
    }
    
    // The maximum values thus far in all Pokemon Games
    // for each base stat. Used to determine the progress bar
    // percentage for base stats
    func getMaxValue() -> Int {
        switch self {
        case .hp:
            return 255
        case .attack:
            return 190
        case .defense:
            return 250
        case .specialAttack:
            return 194
        case .specialDefense:
            return 250
        case .speed:
            return 200
        case .accuracy:
            return 100
        case .evasion:
            return 100
        }
    }
}
