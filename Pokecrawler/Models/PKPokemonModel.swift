//
//  PokemonModel.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 20/03/23.
//

import Foundation

class PKPokemonModel: Codable, Hashable {
    static func == (lhs: PKPokemonModel, rhs: PKPokemonModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    /// The identifier for this Pokémon resource
    var id: Int
    
    /// The name for this Pokémon resource
    var name: String
    
    /// The base experience gained for defeating this Pokémon
    var baseExperience: Int
    
    /// The height of this Pokémon
    var height: Int
    
    /// Set for exactly one Pokémon used as the default for each species
    var isDefault: Bool?
    
    /// Order for sorting. Almost national order, except families are grouped together.
    var order: Int?
    
    /// The weight of this Pokémon
    var weight: Int
    
    /// A list of location areas as well as encounter details pertaining to specific versions
    var locationAreaEncounters: String?
    
    /// A set of sprites used to depict this Pokémon in the game
    var sprites: PKPokemonSprite
    
    /// The species this Pokémon belongs to
    var species: PKMNamedAPIResource<String>
    
    /// A list of base stat values for this Pokémon
    var stats: [PKPokemonStat]?
    
    /// A list of details showing types this Pokémon has
    var types: [PKPokemonSpeciesType]
    
    static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

class PKPokemonSprite: Codable {
    
    /// The default depiction of this Pokémon from the front in battle
    var frontDefault: String?
    
    /// The shiny depiction of this Pokémon from the front in battle
    var frontShiny: String?
    
    /// The female depiction of this Pokémon from the front in battle
    var frontFemale: String?
    
    /// The shiny female depiction of this Pokémon from the front
    var frontShinyFemale: String?
    
    /// The default depiction of this Pokémon from the back in battle
    var backDefault: String?
    
    /// The shiny depiction of this Pokémon from the back in battle
    var backShiny: String?
    
    /// The female depiction of this Pokémon from the back in battle
    var backFemale: String?
    
    /// The shiny female depiction of this Pokémon from the back in battle
    var backShinyFemale: String?
    
    /// Misc data
    var other: PKPokemonOther?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

class PKPokemonOther: Codable {
    /// Art for dream world sequences
    var dreamWorld: PKPokemonDreamWorld?
    
    /// Art for Home Screen viewing
    var home: PKPokemonHome?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

class PKPokemonHome: Codable {
    /// The default depiction of this Pokémon from the front in battle
    var frontDefault: String?
    
    /// The shiny depiction of this Pokémon from the front in battle
    var frontShiny: String?
    
    /// The female depiction of this Pokémon from the front in battle
    var frontFemale: String?
    
    /// The shiny female depiction of this Pokémon from the front
    var frontShinyFemale: String?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

class PKPokemonDreamWorld: Codable {
    /// The default depiction of this Pokémon from the front in battle
    var frontDefault: String?
    
    /// The female depiction of this Pokémon from the front in battle
    var frontFemale: String?
    
    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
