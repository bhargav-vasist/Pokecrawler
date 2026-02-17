//
//  PokemonOfTheDay.swift
//  PokemonOfTheDay
//
//  Created by bhargavvasist on 16/02/26.
//

import WidgetKit
import SwiftUI

// MARK: - Models

struct WidgetPokemon {
    let id: Int
    let name: String
    let typeName: String
    let typeColor: Color
    let imageData: Data?
    
    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    var formattedId: String {
        String(format: "#%03d", id)
    }
    
    static let placeholder = WidgetPokemon(
        id: 25,
        name: "pikachu",
        typeName: "electric",
        typeColor: .yellow,
        imageData: nil
    )
}

// MARK: - Pokemon Type Colors

extension String {
    var pokemonTypeColor: Color {
        switch self.lowercased() {
        case "normal": return Color(red: 0.66, green: 0.65, blue: 0.48)
        case "fire": return Color(red: 0.93, green: 0.51, blue: 0.19)
        case "water": return Color(red: 0.39, green: 0.56, blue: 0.94)
        case "electric": return Color(red: 0.97, green: 0.82, blue: 0.17)
        case "grass": return Color(red: 0.47, green: 0.78, blue: 0.30)
        case "ice": return Color(red: 0.59, green: 0.85, blue: 0.84)
        case "fighting": return Color(red: 0.76, green: 0.18, blue: 0.16)
        case "poison": return Color(red: 0.64, green: 0.24, blue: 0.63)
        case "ground": return Color(red: 0.89, green: 0.75, blue: 0.40)
        case "flying": return Color(red: 0.66, green: 0.56, blue: 0.95)
        case "psychic": return Color(red: 0.98, green: 0.33, blue: 0.53)
        case "bug": return Color(red: 0.65, green: 0.72, blue: 0.10)
        case "rock": return Color(red: 0.71, green: 0.63, blue: 0.21)
        case "ghost": return Color(red: 0.45, green: 0.34, blue: 0.59)
        case "dragon": return Color(red: 0.44, green: 0.21, blue: 0.99)
        case "dark": return Color(red: 0.44, green: 0.34, blue: 0.27)
        case "steel": return Color(red: 0.72, green: 0.72, blue: 0.82)
        case "fairy": return Color(red: 0.84, green: 0.52, blue: 0.68)
        default: return Color.gray
        }
    }
}

// MARK: - API Response Models (outside actor to avoid nesting warnings)

private struct WidgetAPIResponse: Codable {
    let id: Int
    let name: String
    let types: [WidgetTypeSlot]
    let sprites: WidgetSprites
}

private struct WidgetTypeSlot: Codable {
    let type: WidgetTypeInfo
}

private struct WidgetTypeInfo: Codable {
    let name: String
}

private struct WidgetSprites: Codable {
    let other: WidgetOtherSprites?
}

private struct WidgetOtherSprites: Codable {
    let home: WidgetHomeSprites?
}

private struct WidgetHomeSprites: Codable {
    let frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

// MARK: - Seeded Random Generator

private struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: Int) {
        self.state = UInt64(truncatingIfNeeded: seed)
    }
    
    mutating func next() -> UInt64 {
        // Simple xorshift algorithm
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

// MARK: - Network Service

actor PokemonWidgetService {
    static let shared = PokemonWidgetService()
    
    func fetchRandomPokemon() async -> WidgetPokemon {
        // Random Pokemon ID (1-1010 covers most Pokemon)
        let randomId = Int.random(in: 1...1010)
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(randomId)") else {
            return .placeholder
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(WidgetAPIResponse.self, from: data)
            
            let typeName = response.types.first?.type.name ?? "normal"
            
            // Fetch the image
            var imageData: Data?
            if let imageUrlString = response.sprites.other?.home?.frontDefault,
               let imageUrl = URL(string: imageUrlString) {
                let (imgData, _) = try await URLSession.shared.data(from: imageUrl)
                imageData = imgData
            }
            
            return WidgetPokemon(
                id: response.id,
                name: response.name,
                typeName: typeName,
                typeColor: typeName.pokemonTypeColor,
                imageData: imageData
            )
        } catch {
            print("Widget fetch error: \(error)")
            return .placeholder
        }
    }
    
    /// Get Pokemon of the Day - same Pokemon for the entire day
    func getPokemonOfTheDay() async -> WidgetPokemon {
        // Use the day of year as seed for consistent daily Pokemon
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let year = calendar.component(.year, from: Date())
        let seed = year * 1000 + dayOfYear
        
        // Deterministic "random" based on date using seeded generator
        var generator = SeededRandomGenerator(seed: seed)
        let pokemonId = Int.random(in: 1...1010, using: &generator)
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)") else {
            return .placeholder
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(WidgetAPIResponse.self, from: data)
            
            let typeName = response.types.first?.type.name ?? "normal"
            
            var imageData: Data?
            if let imageUrlString = response.sprites.other?.home?.frontDefault,
               let imageUrl = URL(string: imageUrlString) {
                let (imgData, _) = try await URLSession.shared.data(from: imageUrl)
                imageData = imgData
            }
            
            return WidgetPokemon(
                id: response.id,
                name: response.name,
                typeName: typeName,
                typeColor: typeName.pokemonTypeColor,
                imageData: imageData
            )
        } catch {
            print("Widget fetch error: \(error)")
            return .placeholder
        }
    }
}

// MARK: - Timeline Provider

struct PokemonEntry: TimelineEntry {
    let date: Date
    let pokemon: WidgetPokemon
}

struct PokemonProvider: TimelineProvider {
    func placeholder(in context: Context) -> PokemonEntry {
        PokemonEntry(date: Date(), pokemon: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (PokemonEntry) -> Void) {
        Task {
            let pokemon = await PokemonWidgetService.shared.getPokemonOfTheDay()
            let entry = PokemonEntry(date: Date(), pokemon: pokemon)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PokemonEntry>) -> Void) {
        Task {
            let pokemon = await PokemonWidgetService.shared.getPokemonOfTheDay()
            let currentDate = Date()
            
            // Calculate next midnight for refresh
            let calendar = Calendar.current
            let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
            
            let entry = PokemonEntry(date: currentDate, pokemon: pokemon)
            let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
            completion(timeline)
        }
    }
}

// MARK: - Widget Views

struct PokemonOfTheDayEntryView: View {
    var entry: PokemonEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(pokemon: entry.pokemon)
        case .systemMedium:
            MediumWidgetView(pokemon: entry.pokemon)
        case .systemLarge:
            LargeWidgetView(pokemon: entry.pokemon)
        default:
            SmallWidgetView(pokemon: entry.pokemon)
        }
    }
}

struct SmallWidgetView: View {
    let pokemon: WidgetPokemon
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [pokemon.typeColor, pokemon.typeColor.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(spacing: 4) {
                    // Pokemon image
                    if let imageData = pokemon.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width * 0.65, height: geo.size.width * 0.65)
                    } else {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    // Name
                    Text(pokemon.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    // ID
                    Text(pokemon.formattedId)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(8)
            }
        }
    }
}

struct MediumWidgetView: View {
    let pokemon: WidgetPokemon
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [pokemon.typeColor, pokemon.typeColor.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                HStack(spacing: 12) {
                    // Pokemon image
                    if let imageData = pokemon.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.height * 0.85)
                    } else {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Pokémon of the Day")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .textCase(.uppercase)
                        
                        Text(pokemon.displayName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        Text(pokemon.formattedId)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        // Type badge
                        Text(pokemon.typeName.capitalized)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
        }
    }
}

struct LargeWidgetView: View {
    let pokemon: WidgetPokemon
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [pokemon.typeColor, pokemon.typeColor.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack(spacing: 8) {
                    Text("Pokémon of the Day")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .textCase(.uppercase)
                        .tracking(1.5)
                    
                    Spacer()
                    
                    // Pokemon image
                    if let imageData = pokemon.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width * 0.6)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    } else {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 100))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    // Name and details
                    VStack(spacing: 4) {
                        Text(pokemon.displayName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(pokemon.formattedId)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                        
                        // Type badge
                        Text(pokemon.typeName.capitalized)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 8)
                }
                .padding(20)
            }
        }
    }
}

// MARK: - Widget Configuration

struct PokemonOfTheDay: Widget {
    let kind: String = "PokemonOfTheDay"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PokemonProvider()) { entry in
            if #available(iOS 17.0, *) {
                PokemonOfTheDayEntryView(entry: entry)
                    .containerBackground(entry.pokemon.typeColor.gradient, for: .widget)
            } else {
                PokemonOfTheDayEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Pokémon of the Day")
        .description("Discover a new Pokémon every day!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    PokemonOfTheDay()
} timeline: {
    PokemonEntry(date: .now, pokemon: .placeholder)
}

#Preview(as: .systemMedium) {
    PokemonOfTheDay()
} timeline: {
    PokemonEntry(date: .now, pokemon: .placeholder)
}

#Preview(as: .systemLarge) {
    PokemonOfTheDay()
} timeline: {
    PokemonEntry(date: .now, pokemon: .placeholder)
}
