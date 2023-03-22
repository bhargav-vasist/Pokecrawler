//
//  PKPokemonStats.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 22/03/23.
//

import Foundation

/// Stats determine certain aspects of battles. Each Pokémon has a value for each stat which grows as they gain levels and can be altered momentarily by effects in battles.
class PKPokeStat: Codable {
    
    /// The identifier for this stat resource
    var id: Int
    
    /// The name for this stat resource
    var name: PKPokemonBaseStat
    
    /// ID the games use for this stat
    var gameIndex: Int?
    
    /// Whether this stat only exists within a battle
    var isBattleOnly: Bool?
    
    /// A detail of moves which affect this stat positively or negatively
//    var affectingMoves: PKMMoveStatAffectSets?
//
//    //// A detail of natures which affect this stat positively or negatively
//    var affectingNatures: PKMNatureStatAffectSets?
//
//    /// A list of characteristics that are set on a Pokémon when its highest base stat is this stat
//    var characteristics: [PKMAPIResource<PKMCharacteristic>]?
//
//    /// The class of damage this stat is directly related to
//    var moveDamageClass: PKMNamedAPIResource<PKMMoveDamageClass>?
    
    /// The name of this region listed in different languages
//    var names: [PKMName]?
    
    public static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

enum PKPokemonBaseStat: String, Codable {
    case hp
    case attack
    case defense
    case specialAttack
    case specialDefense
    case speed
    case accuracy
    case evasion
    
    enum CodingKeys: String, CodingKey {
        case hp
        case attack
        case defense
        case specialAttack = "special-attack"
        case specialDefense = "special-defense"
        case speed
        case accuracy
        case evasion
    }
    
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

