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
    var type: PKMNamedAPIResource<PKPokemonBaseType>
}

/// API Referenced Resource
class PKAPIResource: Codable {
    private enum CodingKeys: String, CodingKey {
        case url
    }
    
    /// The URL of the referenced resource
    var url: String?
    
    /// Decode with the correct key strategy from Parent Decoder
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
    }
}

/// Named API Resource
class PKMNamedAPIResource<T: Codable>: PKAPIResource {
    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    /// The name of the referenced resource
    var name: T
    
    /// Encode the Generic Type to the container
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        
        try super.encode(to: encoder)
    }
    /// Decode with the correct key strategy from Parent Decoder
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(T.self, forKey: .name)

        try super.init(from: decoder)
    }
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
    
    // Unfortunate colorcoding mapping since the API gives us very little context clues.
    // swiftlint:disable cyclomatic_complexity
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
        // swiftlint:enable cyclomatic_complexity
    }
}
