import SwiftUI

enum AmbitAppearanceMode: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }

    static func resolved(from raw: String) -> AmbitAppearanceMode {
        AmbitAppearanceMode(rawValue: raw) ?? .light
    }

    var label: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var description: String {
        switch self {
        case .light:
            return "Bright canvas tuned for day‑to‑day work."
        case .dark:
            return "Deep, low‑glare interface for night sessions."
        }
    }

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.stars.fill"
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }

    var backgroundColor: Color {
        switch self {
        case .light:
            return Color(uiColor: .systemBackground)
        case .dark:
            return Color(uiColor: .systemBackground)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .light:
            return .secondary
        case .dark:
            return .secondary
        }
    }

    var cardBackgroundColor: Color {
        switch self {
        case .light:
            return Color(uiColor: .secondarySystemBackground)
        case .dark:
            return Color(uiColor: .secondarySystemBackground)
        }
    }

    var textPrimaryColor: Color {
        .primary
    }

    var textSecondaryColor: Color {
        .secondary
    }

    var isDarkStyle: Bool {
        preferredColorScheme == .dark
    }
}
