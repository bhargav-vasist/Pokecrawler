# Pokecrawler
Here's the repository for the Pokecrawler App for the take home coding challenge.

## Installation
- `git clone`
- Run Pokecrawler.xcodeproj
- ????????
- Profit

## A list of cool things about this project

- Fully programmatic views, No storyboards here
- Zero use of 3rd party libraries - No Cocoapods, No SwiftPM Modules
- Separated layers of Networking Layers - Endpoints, Sessions and Network Managers
- Dependency Injection for easier tests
- Examples of Fakes, Stubs, Mocks in Network Tests
- Parallax view demo for detail page
- Adding favorites with File Persistence
- Adaptable colors for automatic dark mode support - Includes a handy toggle
- Adaptable fontsizes for different device sizes
- SwiftLint configured and ready

## Things that can be improved
- ViewModels for Reusable Views
- UI Testing for navigation and screen renders
- Async/await replacing completion handler tree nesting
- Moarr dependency injection - Composable Protocols for Networking&Storage
- Moarr unit tests - StorageManager tests, Encoding/Decoding Tests, Limit Testing StatBar values

## Resources that inspired the code
- [Swift by Sundell](https://www.swiftbysundell.com/) - A lot of the networking layers and Mock Testing
- [SwiftLee - Antoine van der Lee](https://www.avanderlee.com/) - Unit testing and adaptable colors
- [PokeAPI](https://pokeapi.co/docs/v2) - RESTful API for Pokemon Data
- [Take Home Project - Sean Allen](https://seanallen.teachable.com/p/take-home) - Directory structure and inspiration for this repo
