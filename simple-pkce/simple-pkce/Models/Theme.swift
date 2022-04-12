import SwiftUI

enum Theme: String {
    case main
    case black
    case blue
    case red
    
    var accentColor: Color {
        switch self {
        case .main, .black, .blue, .red: return .white
        }
    }
    var mainColor: Color {
        Color(rawValue)
    }
}
