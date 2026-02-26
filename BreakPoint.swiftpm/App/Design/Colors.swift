import SwiftUI

extension Color {
    // MARK: - Semantic Colors
    // Slightly softer, pastel versions for light mode
    static let bugWarm = Color(red: 1.0, green: 0.6, blue: 0.5) // Soft Peach/Orange
    static let fixCool = Color(red: 0.4, green: 0.7, blue: 0.9) // Soft Sky Blue
    
    // MARK: - Dynamic Adaptive Colors
    static var adaptiveBackground: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor(hex: "0A0C12") 
                : UIColor(hex: "F8FAFF")
        })
    }
    
    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor(hex: "1C1C1E") 
                : .white
        })
    }
    
    static var glassBackground: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor.white.withAlphaComponent(0.12) 
                : UIColor.white.withAlphaComponent(0.6)
        })
    }
    
    static var glassBorder: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor.white.withAlphaComponent(0.15) 
                : UIColor.white.withAlphaComponent(0.4)
        })
    }
    
    static var backgroundGradientStart: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor(hex: "0F111A") 
                : UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1.0)
        })
    }
    
    static var backgroundGradientEnd: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor(hex: "080A10") 
                : UIColor(red: 0.92, green: 0.92, blue: 0.98, alpha: 1.0)
        })
    }
    
    static var textPrimary: Color {
        Color(UIColor.label)
    }
    
    static var textSecondary: Color {
        Color(UIColor.secondaryLabel)
    }
    
    static var textTertiary: Color {
        Color(UIColor.tertiaryLabel)
    }
    
    // MARK: - WWDC / World Background Colors
    static var loopBgCenter: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor(hex: "121520") 
                : UIColor(hex: "F7F9FF")
        })
    }
    
    static var loopBgEdge: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark 
                ? UIColor(hex: "0A0C14") 
                : UIColor(hex: "E9EEF6")
        })
    }
    
    // MARK: - Loop Legacy Colors
    static let loopGradientStart = Color(red: 0.2, green: 0.4, blue: 1.0)
    static let loopGradientEnd = Color(red: 0.6, green: 0.2, blue: 1.0)
    static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let loopRingPurple = Color(hex: "AF52DE")
    static let loopRingPink = Color(hex: "FF2D55")
    static let loopRingBlue = Color(hex: "007AFF")
    
    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
    
    static var currentStyle: UIUserInterfaceStyle {
        UITraitCollection.current.userInterfaceStyle
    }
}
