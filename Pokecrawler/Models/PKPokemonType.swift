//
//  PKPokemonTypes.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

/// Pokemon Type
class PKPokemonSpeciesType: Codable {
    
    /// The order the Pokémon's types are listed in
    var slot: Int?
    
    /// The type the referenced Pokémon has
    var type: PKPokemonAPIType
}

struct PKPokemonAPIType: Codable {
    var name: PKPokemonBaseType
    var url: String
}

enum PKPokemonBaseType: String, Codable {
    case normal
    case fighting
    case flying
    case poison
    case ground
    case rock
    case bug
    case ghost
    case steel
    case fire
    case water
    case grass
    case electric
    case psychic
    case ice
    case dragon
    case dark
    case fairy
    case unknown
    
    func getColorForType() -> UIColor {
        switch self {
        case .grass:
            return .FlatUI.emerald
        case .bug:
            return .FlatUI.nephritis
        case .fire:
            return .FlatUI.pumpkin
        case .fighting:
            return .FlatUI.pomegranate
        case .electric:
            return .FlatUI.sunFlower
        case .ground:
            return .FlatUI.flatOrange
        case .water:
            return .FlatUI.belizeHole
        case .ice:
            return .FlatUI.turquoise
        case .dark:
            return .PokeColors.darkBrown
        case .rock:
            return .PokeColors.lightBrown
        case .normal:
            return .PokeColors.beigeRegret
        case .flying:
            return .FlatUI.amethyst
        case .poison:
            return .FlatUI.wisteria
        case .psychic:
            return .PokeColors.hotPink
        case .fairy:
            return .PokeColors.lightPink
        case .dragon:
            return .PokeColors.twitchPurple
        case .ghost:
            return .PokeColors.grapePurple
        case .steel:
            return .FlatUI.concrete
        case .unknown:
            return .FlatUI.midnightBlue
            
        }
    }
}
