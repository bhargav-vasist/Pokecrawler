//
//  PKPokemonSpecies.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 23/03/23.
//

import Foundation

/// A Pokémon Species forms the basis for at least one Pokémon.
/// Attributes of a Pokémon species are shared across all varieties of Pokémon within the species.
/// A good example is Wormadam; Wormadam is the species which can be found in three different varieties,
/// Wormadam-Trash, Wormadam-Sandy and Wormadam-Plant.
class PKPokemonSpecies: Codable {
    
    /// The identifier for this Pokémon species resource
    var id: Int
    
    /// The name for this Pokémon species resource
    var name: String
    
    /// The order in which species should be sorted.
    /// Based on National Dex order, except families are grouped together and sorted by stage.
    var order: Int?
    
    /// The chance of this Pokémon being female, in eighths; or -1 for genderless
    var genderRate: Int?
    
    /// The base capture rate; up to 255. The higher the number, the easier the catch.
    var captureRate: Int?
    
    /// The happiness when caught by a normal Pokéball; up to 255. The higher the number, the happier the Pokémon.
    var baseHappiness: Int?
    
    /// Whether or not this is a baby Pokémon
    var isBaby: Bool?
    
    /// Initial hatch counter: one must walk 255 × (hatch_counter + 1)
    /// steps before this Pokémon's egg hatches,
    /// unless utilizing bonuses like Flame Body's
    var hatchCounter: Int?
    
    /// Whether or not this Pokémon can have different genders
    var hasGenderDifferences: Bool?
    
    /// Whether or not this Pokémon has multiple forms and can switch between them
    var formsSwitchable: Bool?
    
    /// The name of this Pokémon species listed in different languages
    var names: [PKName]?

    /// The flavor text of this flavor text listed in different languages
    var flavorTextEntries: [PKFlavorText]?
    
    public static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

/// Flavor Text
class PKFlavorText: Codable {

    /// The localized flavor text for an API resource in a specific language
    var flavorText: String?

    /// The language this name is in
    var language: PKName?

    public static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

/// Name
class PKName: Codable {

    /// The localized name for an API resource in a specific language
    var name: String?

    /// The language this name is in
    var language: PKLanguage?
}

/// Languages for translations of API resource information.
class PKLanguage: Codable {
    
    /// The identifier for this language resource
    var id: Int?
    
    /// The name for this language resource
    var name: String?
    
    /// Whether or not the games are published in this language
    var official: Bool?
    
    /// The two-letter code of the country where this language is spoken. Note that it is not unique.
    var iso639: String?
    
    /// The two-letter code of the language. Note that it is not unique.
    var iso3166: String?
    
    /// The name of this language listed in different languages
    var names: [PKName]?
}
