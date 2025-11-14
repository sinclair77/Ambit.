import SwiftUI

enum AmbitAppearanceMode: String, CaseIterable, Identifiable {
    case studio
    case nocturne
    case spectrum
    case blossom
    case atelier
    case lagoon
    case solstice

    var id: String { rawValue }

    static func resolved(from raw: String) -> AmbitAppearanceMode {
        if let modern = AmbitAppearanceMode(rawValue: raw) {
            return modern
        }
        switch raw {
        case "light": return .studio
        case "dark": return .nocturne
        case "hacker": return .spectrum
        case "sakura": return .blossom
        case "coffee": return .atelier
        case "ocean": return .lagoon
        case "sunset": return .solstice
        default: return .studio
        }
    }

    var label: String {
        switch self {
        case .studio: return "Studio Lumina"
        case .nocturne: return "Nocturne Alloy"
        case .spectrum: return "Spectrum Nexus"
        case .blossom: return "Blossom Drift"
        case .atelier: return "Atelier Clay"
        case .lagoon: return "Lagoon Mirage"
        case .solstice: return "Solstice Ember"
        }
    }

    var description: String {
        switch self {
        case .studio:
            return "Crisp daylight canvas with luminous accents for everyday work."
        case .nocturne:
            return "Deep graphite panels and electric highlights built for night sessions."
        case .spectrum:
            return "Neon command center inspired by synth labs and motion suites."
        case .blossom:
            return "Soft porcelain gradients with editorial typography and blush lighting."
        case .atelier:
            return "Earthy studio warmth with brass highlights and parchment neutrals."
        case .lagoon:
                return "Glacial blues and misted glass panels tuned for deep focus."
        case .solstice:
            return "Golden hour warmth with cinematic depth and glowing controls."
        }
    }

    var icon: String {
        switch self {
        case .studio: return "sparkles.rectangle.fill"
        case .nocturne: return "moon.stars.fill"
        case .spectrum: return "wave.3.forward"
        case .blossom: return "seal.fill"
        case .atelier: return "cube.transparent.fill"
        case .lagoon: return "drop.fill"
        case .solstice: return "sun.horizon.fill"
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .studio, .blossom, .atelier, .solstice:
            return .light
        case .nocturne, .spectrum, .lagoon:
            return .dark
        }
    }

    var accentColor: Color {
        switch self {
        case .studio:
            return Color(hex: "#7367FF") ?? .purple
        case .nocturne:
            return Color(hex: "#4EDBFF") ?? .cyan
        case .spectrum:
            return Color(hex: "#4AFFA3") ?? .green
        case .blossom:
            return Color(hex: "#F07AA8") ?? .pink
        case .atelier:
            return Color(hex: "#C98A5F") ?? .brown
        case .lagoon:
            return Color(hex: "#4AA8FF") ?? .blue
        case .solstice:
            return Color(hex: "#FF8A5C") ?? .orange
        }
    }

    var accentSecondary: Color {
        switch self {
        case .studio:
            return Color(hex: "#B8A9FF") ?? .purple.opacity(0.6)
        case .nocturne:
            return Color(hex: "#255DFF") ?? .blue
        case .spectrum:
                return Color(hex: "#B5FF6B") ?? .green
        case .blossom:
            return Color(hex: "#FFD3E2") ?? .pink.opacity(0.6)
        case .atelier:
            return Color(hex: "#F4CBA1") ?? .orange.opacity(0.7)
        case .lagoon:
            return Color(hex: "#7EE8FF") ?? .cyan
        case .solstice:
            return Color(hex: "#FFC25F") ?? .orange
        }
    }

    var previewGradient: [Color] { [accentColor, accentSecondary] }

    var backgroundColor: Color {
        switch self {
        case .studio:
            return Color(hex: "#F7F7FF") ?? Color(uiColor: .systemBackground)
        case .nocturne:
            return Color(hex: "#0D1118") ?? Color.black
        case .spectrum:
            return Color(hex: "#030B08") ?? Color.black
        case .blossom:
            return Color(hex: "#FFF8FB") ?? Color(uiColor: .systemGroupedBackground)
        case .atelier:
            return Color(hex: "#F4EDE3") ?? Color(uiColor: .systemGroupedBackground)
        case .lagoon:
            return Color(hex: "#041321") ?? Color.black
        case .solstice:
            return Color(hex: "#FFF3E5") ?? Color(uiColor: .systemGroupedBackground)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .studio:
            return Color(hex: "#6A6F88") ?? .secondary
        case .nocturne:
            return Color.white.opacity(0.72)
        case .spectrum:
            return Color(hex: "#73FFC4") ?? .green
        case .blossom:
            return Color(hex: "#A36882") ?? .pink
        case .atelier:
            return Color(hex: "#8C6A4F") ?? .brown
        case .lagoon:
            return Color(hex: "#7AB3F5") ?? .blue
        case .solstice:
            return Color(hex: "#B56C42") ?? .orange
        }
    }

    var cardBackgroundColor: Color {
        switch self {
        case .studio:
            return Color(hex: "#FFFFFF") ?? Color(uiColor: .secondarySystemBackground)
        case .nocturne:
            return Color(hex: "#161B24") ?? Color(uiColor: .secondarySystemBackground)
        case .spectrum:
            return Color(hex: "#101E16") ?? Color(uiColor: .secondarySystemBackground)
        case .blossom:
            return Color(hex: "#FFE6F1") ?? Color(uiColor: .secondarySystemBackground)
        case .atelier:
            return Color(hex: "#F1DCC5") ?? Color(uiColor: .secondarySystemBackground)
        case .lagoon:
            return Color(hex: "#0A1F33") ?? Color(uiColor: .secondarySystemBackground)
        case .solstice:
            return Color(hex: "#FFE1C6") ?? Color(uiColor: .secondarySystemBackground)
        }
    }

    var textPrimaryColor: Color {
        switch self {
        case .studio, .blossom, .atelier, .solstice:
            return .primary
        case .nocturne, .spectrum, .lagoon:
            return .white
        }
    }

    var textSecondaryColor: Color {
        switch self {
        case .studio:
            return Color(hex: "#7C809A") ?? .secondary
        case .nocturne:
            return Color.white.opacity(0.65)
        case .spectrum:
                return (Color(hex: "#66FFB4") ?? .green).opacity(0.75)
        case .blossom:
            return Color(hex: "#C28DA4") ?? .pink
        case .atelier:
            return Color(hex: "#9B7A5A") ?? .brown
        case .lagoon:
            return Color(hex: "#78BDEF") ?? .cyan
        case .solstice:
            return Color(hex: "#CB8B55") ?? .orange
        }
    }

    var isDarkStyle: Bool {
        preferredColorScheme == .dark
    }
}
