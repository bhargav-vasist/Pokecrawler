//
//  UIColorExtensions.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 21/03/23.
//

import UIKit

extension UIColor {
    
    /// SwifterSwift: Create Color from RGB values with optional transparency.
    ///
    /// - Parameters:
    ///   - red: red component.
    ///   - green: green component.
    ///   - blue: blue component.
    ///   - transparency: optional transparency value (default is 1).
    convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0, red <= 255 else { return nil }
        guard green >= 0, green <= 255 else { return nil }
        guard blue >= 0, blue <= 255 else { return nil }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
    
    /// SwifterSwift: Create Color from hexadecimal value with optional transparency.
    ///
    /// - Parameters:
    ///   - hex: hex Int (example: 0xDECEB5).
    ///   - transparency: optional transparency value (default is 1).
    convenience init?(hex: Int, transparency: CGFloat = 1) {
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(red: red, green: green, blue: blue, transparency: trans)
    }

}

/// With the help of SwifterSwift,
/// https://github.com/SwifterSwift/SwifterSwift/blob/master/Sources/SwifterSwift/Shared/ColorExtensions.swift
extension UIColor {
    /// SwifterSwift: Flat UI colors
    enum FlatUI {
        // http://flatuicolors.com.
        /// SwifterSwift: hex #1ABC9C
        public static let turquoise = UIColor(hex: 0x1ABC9C)!

        /// SwifterSwift: hex #16A085
        public static let greenSea = UIColor(hex: 0x16A085)!

        /// SwifterSwift: hex #2ECC71
        public static let emerald = UIColor(hex: 0x2ECC71)!

        /// SwifterSwift: hex #27AE60
        public static let nephritis = UIColor(hex: 0x27AE60)!

        /// SwifterSwift: hex #3498DB
        public static let peterRiver = UIColor(hex: 0x3498DB)!

        /// SwifterSwift: hex #2980B9
        public static let belizeHole = UIColor(hex: 0x2980B9)!

        /// SwifterSwift: hex #9B59B6
        public static let amethyst = UIColor(hex: 0x9B59B6)!

        /// SwifterSwift: hex #8E44AD
        public static let wisteria = UIColor(hex: 0x8E44AD)!

        /// SwifterSwift: hex #34495E
        public static let wetAsphalt = UIColor(hex: 0x34495E)!

        /// SwifterSwift: hex #2C3E50
        public static let midnightBlue = UIColor(hex: 0x2C3E50)!

        /// SwifterSwift: hex #F1C40F
        public static let sunFlower = UIColor(hex: 0xF1C40F)!

        /// SwifterSwift: hex #F39C12
        public static let flatOrange = UIColor(hex: 0xF39C12)!

        /// SwifterSwift: hex #E67E22
        public static let carrot = UIColor(hex: 0xE67E22)!

        /// SwifterSwift: hex #D35400
        public static let pumpkin = UIColor(hex: 0xD35400)!

        /// SwifterSwift: hex #E74C3C
        public static let alizarin = UIColor(hex: 0xE74C3C)!

        /// SwifterSwift: hex #C0392B
        public static let pomegranate = UIColor(hex: 0xC0392B)!

        /// SwifterSwift: hex #ECF0F1
        public static let clouds = UIColor(hex: 0xECF0F1)!

        /// SwifterSwift: hex #BDC3C7
        public static let silver = UIColor(hex: 0xBDC3C7)!

        /// SwifterSwift: hex #7F8C8D
        public static let asbestos = UIColor(hex: 0x7F8C8D)!

        /// SwifterSwift: hex #95A5A6
        public static let concrete = UIColor(hex: 0x95A5A6)!
    }

    // swiftlint:enable type_body_length
    // This is designed by manual inspection of Nintendo's official colors
    enum PokeColors {
        public static let darkBrown = UIColor(hex: 0x705848)!
        
        public static let lightBrown = UIColor(hex: 0xB8A038)!
        
        public static let beigeRegret = UIColor(hex: 0xA8A878)!
        
        public static let hotPink = UIColor(hex: 0xF85888)!

        public static let lightPink = UIColor(hex: 0xEE99AC)!
        
        public static let twitchPurple = UIColor(hex: 0x7038F8)!

        public static let grapePurple = UIColor(hex: 0x705898)!

    }
}
