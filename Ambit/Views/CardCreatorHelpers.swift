import SwiftUI
import UIKit

struct CardDesignOptions: Equatable {
    var aspect: CardAspect = .threeFour
    var title: String = ""
    var subtitle: String = ""
    var paletteLayout: PaletteLayout = .strip

    var titleSize: CGFloat = 24
    var titleWeight: Font.Weight = .bold
    var titleAlignment: TextAlignment = .center
    var subtitleSize: CGFloat = 14
    var subtitleWeight: Font.Weight = .regular
    var subtitleAlignment: TextAlignment = .center

    var frameStyle: FrameStyle = .rounded
    var cornerRadius: CGFloat = 20
    var borderWidth: CGFloat = 2
    var borderColor: Color = .primary.opacity(0.2)

    var shadowEnabled: Bool = true
    var shadowRadius: CGFloat = 8
    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 4

    var backgroundMode: BackgroundMode = .solid
    var backgroundColor1: Color = .white
    var backgroundColor2: Color = .gray.opacity(0.15)
    var imageOverlayOpacity: Double = 0.0

    var includeImage: Bool = true
    var imageCornerRadius: CGFloat = 16
    var imageHeightRatio: CGFloat = 0.45
}

extension CardDesignOptions {
    static func == (lhs: CardDesignOptions, rhs: CardDesignOptions) -> Bool {
        lhs.aspect == rhs.aspect &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.paletteLayout == rhs.paletteLayout &&
        lhs.titleSize == rhs.titleSize &&
        lhs.titleWeight == rhs.titleWeight &&
        lhs.titleAlignment == rhs.titleAlignment &&
        lhs.subtitleSize == rhs.subtitleSize &&
        lhs.subtitleWeight == rhs.subtitleWeight &&
        lhs.subtitleAlignment == rhs.subtitleAlignment &&
        lhs.frameStyle == rhs.frameStyle &&
        lhs.cornerRadius == rhs.cornerRadius &&
        lhs.borderWidth == rhs.borderWidth &&
        colorsEqual(lhs.borderColor, rhs.borderColor) &&
        lhs.shadowEnabled == rhs.shadowEnabled &&
        lhs.shadowRadius == rhs.shadowRadius &&
        lhs.shadowX == rhs.shadowX &&
        lhs.shadowY == rhs.shadowY &&
        lhs.backgroundMode == rhs.backgroundMode &&
        colorsEqual(lhs.backgroundColor1, rhs.backgroundColor1) &&
        colorsEqual(lhs.backgroundColor2, rhs.backgroundColor2) &&
        lhs.imageOverlayOpacity == rhs.imageOverlayOpacity &&
        lhs.includeImage == rhs.includeImage &&
        lhs.imageCornerRadius == rhs.imageCornerRadius &&
        lhs.imageHeightRatio == rhs.imageHeightRatio
    }

    private static func colorsEqual(_ lhs: Color, _ rhs: Color) -> Bool {
        UIColor(lhs).isEqual(UIColor(rhs))
    }

    static func preset(_ preset: PresetTemplate, currentImage: Bool) -> CardDesignOptions {
        var d = CardDesignOptions()
        switch preset {
        case .defaultMinimal:
            break
        case .posterA:
            d.aspect = .fourFive
            d.backgroundMode = .gradient
            d.backgroundColor1 = .black
            d.backgroundColor2 = .purple.opacity(0.4)
            d.titleSize = 30
            d.titleWeight = .heavy
            d.titleAlignment = .leading
            d.subtitleAlignment = .leading
            d.frameStyle = .rounded
            d.cornerRadius = 24
            d.borderWidth = 0
            d.shadowEnabled = true
            d.shadowRadius = 12
            d.shadowY = 6
            d.paletteLayout = .strip
            d.includeImage = currentImage
            d.imageHeightRatio = 0.55
        case .magazine:
            d.aspect = .threeFour
            d.backgroundMode = .solid
            d.backgroundColor1 = Color(uiColor: .secondarySystemBackground)
            d.titleSize = 28
            d.titleWeight = .black
            d.titleAlignment = .center
            d.subtitleAlignment = .center
            d.frameStyle = .polaroid
            d.cornerRadius = 12
            d.borderWidth = 1.5
            d.borderColor = .primary.opacity(0.15)
            d.shadowEnabled = false
            d.paletteLayout = .grid
            d.includeImage = currentImage
            d.imageHeightRatio = 0.4
        case .minimalTag:
            d.aspect = .square
            d.backgroundMode = .solid
            d.backgroundColor1 = .white
            d.titleSize = 22
            d.titleWeight = .bold
            d.titleAlignment = .center
            d.subtitleAlignment = .center
            d.frameStyle = .none
            d.cornerRadius = 16
            d.borderWidth = 0
            d.shadowEnabled = true
            d.shadowRadius = 6
            d.paletteLayout = .chips
            d.includeImage = currentImage
            d.imageHeightRatio = 0.35
        case .elegant:
            d.aspect = .threeFour
            d.backgroundMode = .gradient
            d.backgroundColor1 = Color(uiColor: .systemIndigo)
            d.backgroundColor2 = Color(uiColor: .systemPurple).opacity(0.6)
            d.titleSize = 26
            d.titleWeight = .semibold
            d.titleAlignment = .center
            d.subtitleAlignment = .center
            d.frameStyle = .rounded
            d.cornerRadius = 30
            d.borderWidth = 1.2
            d.borderColor = .white.opacity(0.3)
            d.shadowEnabled = true
            d.shadowRadius = 12
            d.shadowY = 8
            d.paletteLayout = .strip
            d.includeImage = currentImage
            d.imageHeightRatio = 0.42
        case .bold:
            d.aspect = .fourFive
            d.backgroundMode = .gradient
            d.backgroundColor1 = .red
            d.backgroundColor2 = .orange.opacity(0.8)
            d.titleSize = 34
            d.titleWeight = .black
            d.titleAlignment = .leading
            d.subtitleAlignment = .leading
            d.frameStyle = .rounded
            d.cornerRadius = 20
            d.borderWidth = 0
            d.shadowEnabled = true
            d.shadowRadius = 14
            d.shadowY = 10
            d.paletteLayout = .strip
            d.includeImage = currentImage
            d.imageHeightRatio = 0.5
        case .minimalist:
            d.aspect = .square
            d.backgroundMode = .solid
            d.backgroundColor1 = Color(uiColor: .secondarySystemBackground)
            d.titleSize = 24
            d.titleWeight = .medium
            d.titleAlignment = .leading
            d.subtitleAlignment = .leading
            d.frameStyle = .none
            d.cornerRadius = 18
            d.borderWidth = 0
            d.shadowEnabled = false
            d.paletteLayout = .grid
            d.includeImage = currentImage
            d.imageHeightRatio = 0.38
        case .vintage:
            d.aspect = .threeFour
            d.backgroundMode = .gradient
            d.backgroundColor1 = Color(red: 0.58, green: 0.42, blue: 0.35)
            d.backgroundColor2 = Color(red: 0.83, green: 0.72, blue: 0.60)
            d.titleSize = 28
            d.titleWeight = .semibold
            d.titleAlignment = .center
            d.subtitleAlignment = .center
            d.frameStyle = .polaroid
            d.cornerRadius = 18
            d.borderWidth = 2
            d.borderColor = Color.white.opacity(0.6)
            d.shadowEnabled = true
            d.shadowRadius = 10
            d.shadowY = 6
            d.paletteLayout = .chips
            d.includeImage = currentImage
            d.imageHeightRatio = 0.47
        case .modern:
            d.aspect = .nineSixteen
            d.backgroundMode = .gradient
            d.backgroundColor1 = Color(uiColor: .systemTeal)
            d.backgroundColor2 = Color(uiColor: .systemBlue)
            d.titleSize = 32
            d.titleWeight = .heavy
            d.titleAlignment = .leading
            d.subtitleAlignment = .leading
            d.frameStyle = .rounded
            d.cornerRadius = 30
            d.borderWidth = 0
            d.shadowEnabled = true
            d.shadowRadius = 18
            d.shadowY = 12
            d.paletteLayout = .strip
            d.includeImage = currentImage
            d.imageHeightRatio = 0.55
        case .nature:
            d.aspect = .fourFive
            d.backgroundMode = .gradient
            d.backgroundColor1 = Color(red: 0.18, green: 0.32, blue: 0.24)
            d.backgroundColor2 = Color(red: 0.52, green: 0.72, blue: 0.48)
            d.titleSize = 26
            d.titleWeight = .bold
            d.titleAlignment = .leading
            d.subtitleAlignment = .leading
            d.frameStyle = .rounded
            d.cornerRadius = 24
            d.borderWidth = 0
            d.shadowEnabled = true
            d.shadowRadius = 10
            d.shadowY = 6
            d.paletteLayout = .grid
            d.includeImage = currentImage
            d.imageHeightRatio = 0.48
        case .corporate:
            d.aspect = .threeFour
            d.backgroundMode = .solid
            d.backgroundColor1 = Color(uiColor: .systemGray6)
            d.titleSize = 24
            d.titleWeight = .semibold
            d.titleAlignment = .leading
            d.subtitleAlignment = .leading
            d.frameStyle = .rounded
            d.cornerRadius = 16
            d.borderWidth = 1
            d.borderColor = Color(uiColor: .systemGray3)
            d.shadowEnabled = false
            d.paletteLayout = .strip
            d.includeImage = currentImage
            d.imageHeightRatio = 0.4
        case .playful:
            d.aspect = .square
            d.backgroundMode = .gradient
            d.backgroundColor1 = .pink
            d.backgroundColor2 = .yellow
            d.titleSize = 30
            d.titleWeight = .bold
            d.titleAlignment = .center
            d.subtitleAlignment = .center
            d.frameStyle = .rounded
            d.cornerRadius = 28
            d.borderWidth = 0
            d.shadowEnabled = true
            d.shadowRadius = 12
            d.shadowY = 8
            d.paletteLayout = .chips
            d.includeImage = currentImage
            d.imageHeightRatio = 0.45
        }
        return d
    }
}

struct CardCreatorSection<Content: View, Trailing: View>: View {
    let title: String
    let icon: String
    let subtitle: String?
    let accent: Color
    private let trailingView: Trailing
    private let contentView: Content

    init(title: String, icon: String, subtitle: String? = nil, accent: Color = .accentColor,
         @ViewBuilder trailing: () -> Trailing,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.subtitle = subtitle
        self.accent = accent
        self.trailingView = trailing()
        self.contentView = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accent.opacity(0.14))
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(accent.opacity(0.2), lineWidth: 1)
                        )
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.title3, design: .monospaced, weight: .bold))
                        .foregroundStyle(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(.callout, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 0)
                trailingView
            }

            Rectangle()
                .fill(accent.opacity(0.1))
                .frame(height: 1)

            contentView
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(uiColor: .systemBackground).opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(accent.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
}

extension CardCreatorSection where Trailing == EmptyView {
    init(title: String, icon: String, subtitle: String? = nil, accent: Color = .accentColor,
         @ViewBuilder content: () -> Content) {
        self.init(title: title, icon: icon, subtitle: subtitle, accent: accent, trailing: { EmptyView() }, content: content)
    }
}

struct CardCreatorStatusChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(.caption, design: .monospaced, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .foregroundStyle(.primary.opacity(0.8))
            .cornerRadius(16)
    }
}

func typographyRow(weight: Binding<Font.Weight>, alignment: Binding<TextAlignment>, label: String, currentLabel: String) -> some View {
    HStack(spacing: 12) {
        Menu {
            ForEach(fontWeights, id: \.self) { weightValue in
                Button(weightLabel(weightValue)) { weight.wrappedValue = weightValue }
            }
        } label: {
            Label("\(currentLabel): \(weightLabel(weight.wrappedValue))", systemImage: "textformat")
        }

        Spacer(minLength: 0)

        SegmentedAlignmentPicker(selection: alignment, label: label)
    }
}

struct CardCreatorPaletteView: View {
    @Binding var colors: [UIColor]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active palette")
                    .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                Spacer()
                Text("\(colors.count) colors")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            if colors.isEmpty {
                Text("Add colors to see them here.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                        Circle()
                            .fill(Color(uiColor: color))
                                .frame(width: 38, height: 38)
                                .shadow(radius: 2, y: 1)
                                .contextMenu {
                                    Button("Remove", systemImage: "trash") {
                                        guard colors.indices.contains(index) else { return }
                                        colors.remove(at: index)
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }
}

struct CardCreatorTemplateCard: View {
    let template: PresetTemplate
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(template.previewGradient)
                    .frame(height: 120)
                    .overlay(alignment: .bottomLeading) {
                        HStack(spacing: 6) {
                            ForEach(Array(template.previewColors.enumerated()), id: \.offset) { _, color in
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(color)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 0.7)
                                    )
                            }
                        }
                        .padding(12)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(isSelected ? 0.35 : 0.12), lineWidth: isSelected ? 2 : 1)
                    )

                Image(systemName: template.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(12)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(template.displayName)
                    .font(.system(.headline, design: .monospaced))
                    .fontWeight(.semibold)
                Text(template.tagline)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isSelected ? Color.accentColor.opacity(0.85) : Color.white.opacity(0.07), lineWidth: isSelected ? 2.5 : 1)
        )
        .shadow(color: .black.opacity(isSelected ? 0.16 : 0.06), radius: isSelected ? 10 : 6, y: isSelected ? 6 : 2)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isSelected)
    }
}

extension PresetTemplate {
    var displayName: String { rawValue }

    var tagline: String {
        switch self {
        case .defaultMinimal:
            return "Balanced type with a centered palette ribbon."
        case .posterA:
            return "Hero-first stack that feels like an event poster."
        case .magazine:
            return "Editorial split that loves layered imagery."
        case .minimalTag:
            return "Compact tag accent with floating swatches."
        case .elegant:
            return "Soft gradients and luxe negative space."
        case .bold:
            return "High-contrast slabs built to shout."
        case .minimalist:
            return "Ultra-clean geometry with disciplined spacing."
        case .vintage:
            return "Muted film tones with tactile framing."
        case .modern:
            return "Layered panels for product-forward stories."
        case .nature:
            return "Organic rhythm tuned for earthy visuals."
        case .corporate:
            return "Structured grid for decks and recaps."
        case .playful:
            return "Rounded chips and buoyant color hits."
        }
    }

    var iconName: String {
        switch self {
        case .defaultMinimal: return "square.on.square.composite"
        case .posterA: return "rectangle.3.offgrid"
        case .magazine: return "square.split.2x2"
        case .minimalTag: return "tag.fill"
        case .elegant: return "crown.fill"
        case .bold: return "flame.fill"
        case .minimalist: return "circle.dashed"
        case .vintage: return "film"
        case .modern: return "sparkles"
        case .nature: return "leaf.fill"
        case .corporate: return "building.2.fill"
        case .playful: return "circle.grid.3x3"
        }
    }

    var previewColors: [Color] {
        switch self {
        case .defaultMinimal:
            return [.white, .gray, .black, .accentColor]
        case .posterA:
            return [.red, .orange, .accentColor, .gray]
        case .magazine:
            return [.yellow, .pink, .purple, .blue]
        case .minimalTag:
            return [.white, .gray, .black]
        case .elegant:
            return [.indigo, .pink, .white]
        case .bold:
            return [.red, .orange, .black]
        case .minimalist:
            return [.white, .gray, .black]
        case .vintage:
            return [.brown, .yellow, .pink]
        case .modern:
            return [.teal, .blue, .white]
        case .nature:
            return [.green, .brown, Color(red: 0.96, green: 0.96, blue: 0.86)]
        case .corporate:
            return [.gray, .blue, .black]
        case .playful:
            return [.mint, .pink, .orange]
        }
    }

    var previewGradient: LinearGradient {
        LinearGradient(colors: previewColors,
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }
}

struct HeightRatioModifier: ViewModifier {
    let ratio: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .frame(height: geometry.size.width * ratio)
        }
    }
}

extension View {
    func heightRatio(_ ratio: CGFloat) -> some View {
        modifier(HeightRatioModifier(ratio: ratio))
    }
}

let fontWeights: [Font.Weight] = [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black]

func weightLabel(_ w: Font.Weight) -> String {
    switch w {
    case .ultraLight: return "UltraLight"
    case .thin: return "Thin"
    case .light: return "Light"
    case .regular: return "Regular"
    case .medium: return "Medium"
    case .semibold: return "SemiBold"
    case .bold: return "Bold"
    case .heavy: return "Heavy"
    case .black: return "Black"
    default: return "Regular"
    }
}

struct SegmentedAlignmentPicker: View {
    @Binding var selection: TextAlignment
    var label: String = ""
    var body: some View {
        Picker(label, selection: $selection) {
            Image(systemName: "text.alignleft").tag(TextAlignment.leading)
            Image(systemName: "text.aligncenter").tag(TextAlignment.center)
            Image(systemName: "text.alignright").tag(TextAlignment.trailing)
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 240)
    }
}

struct SliderWithLabel: View {
    let title: String
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat>
    var step: CGFloat = 0.01
    var format: String = "%.0f"
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: format, value as CVarArg)).foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}

struct SliderWithLabelDouble: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double = 0.01
    var format: String = "%.0f"
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: format, value as CVarArg)).foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}

struct ReorderPaletteView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var colors: [UIColor]
    @State private var editMode: EditMode = .active
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                    HStack {
                        Circle().fill(Color(uiColor: color)).frame(width: 20, height: 20)
                        Text(color.toHex() ?? "#000000").font(.system(.body, design: .monospaced))
                    }
                }
                .onMove { from, to in colors.move(fromOffsets: from, toOffset: to) }
                .onDelete { idx in colors.remove(atOffsets: idx) }
            }
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItem(placement: .principal) { AppNavTitle(text: "Reorder Palette", size: 24, weight: .bold) }
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .cancellationAction) { EditButton() }
            }
        }
    }
}

struct AdvancedPaletteCardView: View {
    let image: UIImage?
    let colors: [UIColor]
    let design: CardDesignOptions

    var body: some View {
        ZStack {
            backgroundLayer
            VStack(alignment: .leading, spacing: 14) {
                if design.includeImage, let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipped()
                        .cornerRadius(design.imageCornerRadius)
                        .shadow(radius: 4, y: 2)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(design.title.isEmpty ? "Title / Headline" : design.title)
                        .font(.system(size: design.titleSize, weight: design.titleWeight, design: .monospaced))
                        .foregroundColor(.primary)
                    if !design.subtitle.isEmpty {
                        Text(design.subtitle)
                            .font(.system(size: design.subtitleSize, weight: design.subtitleWeight, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                palettePreview
                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: design.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: design.cornerRadius, style: .continuous)
                .stroke(design.borderColor.opacity(design.borderWidth > 0 ? 1 : 0), lineWidth: design.borderWidth)
        )
        .shadow(color: design.shadowEnabled ? Color.black.opacity(0.25) : .clear,
                radius: design.shadowEnabled ? design.shadowRadius : 0,
                x: design.shadowX,
                y: design.shadowY)
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        switch design.backgroundMode {
        case .solid:
            design.backgroundColor1
        case .gradient:
            LinearGradient(colors: [design.backgroundColor1, design.backgroundColor2],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .image:
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(design.imageOverlayOpacity))
            } else {
                LinearGradient(colors: [design.backgroundColor1, design.backgroundColor2],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }

    @ViewBuilder
    private var palettePreview: some View {
        switch design.paletteLayout {
        case .chips:
            WrapPalette(colors: paletteColors)
        case .grid:
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(paletteColors, id: \.self) { color in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(height: 32)
                }
            }
        default:
            HStack(spacing: 8) {
                ForEach(paletteColors, id: \.self) { color in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(height: 28)
                }
            }
        }
    }

    private var paletteColors: [Color] {
        guard !colors.isEmpty else { return [Color.gray.opacity(0.45), Color.gray.opacity(0.2)] }
        return colors.map { Color(uiColor: $0) }
    }
}

private struct WrapPalette: View {
    let colors: [Color]

    var body: some View {
        FlowLayout(items: colors) { color in
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: 60, height: 28)
        }
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View {
    let items: Data
    let content: (Data.Element) -> Content

    var body: some View {
        GeometryReader { geometry in
            let columnCount = max(Int(geometry.size.width / 70), 1)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount), spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    content(item)
                }
            }
        }
        .frame(height: 80)
    }
}
