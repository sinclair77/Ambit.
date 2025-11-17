import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct PaletteView: View {
    @AppStorage("paletteSegmentSelection") private var paletteSegmentRawValue = PaletteSegment.all.rawValue
    @AppStorage("paletteSortSelection") private var paletteSortRawValue = PaletteSortOption.newest.rawValue
    @AppStorage("paletteRecentSearches") private var paletteRecentSearchesData: Data = Data()
    @Environment(\.ambitAccentColor) private var accentColor
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = PaletteViewModel()

    @State private var selectedSegment: PaletteSegment = .all
    @State private var sortOption: PaletteSortOption = .newest
    @State private var didSyncSegment = false
    @State private var didSyncSort = false
    @State private var searchText: String = ""
    // share handled through ShareLink
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedPsychologyColor: Color = .accentColor
    @AppStorage("palettePreviewAspect") private var palettePreviewAspectRawValue = PalettePreviewAspect.medium.rawValue
    @AppStorage("paletteColorOrdering") private var paletteColorOrderRawValue = PaletteColorOrder.original.rawValue

    private var previewAspect: PalettePreviewAspect {
        PalettePreviewAspect(rawValue: palettePreviewAspectRawValue) ?? .medium
    }

    private var colorOrder: PaletteColorOrder {
        PaletteColorOrder(rawValue: paletteColorOrderRawValue) ?? .original
    }

    private var previewMinHeight: CGFloat { previewAspect.minHeight }
    private var previewMaxHeight: CGFloat { previewAspect.maxHeight }

    var body: some View {
        NavigationStack {
            ZStack {
                // Liquid glass-style scene background
                LinearGradient(colors: [accentColor.opacity(0.18), accentColor.opacity(0.06)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                    .overlay(.ultraThinMaterial)

                ScrollView {
                    VStack(spacing: 28) {
                        Group {
                            paletteHero
                            segmentPicker
                            sortToolbar
                            layoutControls
                            recentSearchSection
                            importActionRow
                        }
                        colorPsychologySection
                        palettesContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                }
            }
            .liquidGlassTopLayer(tint: accentColor, height: 110)
            .navigationTitle("Palettes")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search palettes or HEX")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.generateRandomPalette()
                        HapticManager.instance.impact(style: .soft)
                    } label: {
                        Label("Generate", systemImage: "sparkles")
                    }
                }
            }
        }
        .onAppear {
            viewModel.setContext(modelContext)
            if !didSyncSegment {
                selectedSegment = PaletteSegment(rawValue: paletteSegmentRawValue) ?? .all
                didSyncSegment = true
            }
            if !didSyncSort {
                sortOption = PaletteSortOption(rawValue: paletteSortRawValue) ?? .newest
                didSyncSort = true
            }
        }
        .onChange(of: selectedSegment) { _, newValue in
            paletteSegmentRawValue = newValue.rawValue
            PreferenceSyncCoordinator.shared.scheduleSync()
        }
        .onChange(of: sortOption) { _, newValue in
            paletteSortRawValue = newValue.rawValue
            PreferenceSyncCoordinator.shared.scheduleSync()
        }
        .onSubmit(of: .search) {
            addRecentSearch(term: searchQuery)
        }
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newValue in
            guard let image = newValue else { return }
            viewModel.addPaletteFromImage(image)
            selectedImage = nil
        }
        // removed old sheet (ShareSheet) in favor of native ShareLink
    }

    private var paletteRecentSearches: [String] {
        guard let decoded = try? JSONDecoder().decode([String].self, from: paletteRecentSearchesData) else { return [] }
        return decoded
    }

    private func addRecentSearch(term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var updated = paletteRecentSearches.filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        updated.insert(trimmed, at: 0)
        if updated.count > 5 { updated = Array(updated.prefix(5)) }
        if let data = try? JSONEncoder().encode(updated) {
            paletteRecentSearchesData = data
            PreferenceSyncCoordinator.shared.scheduleSync()
        }
    }

    private func clearRecentSearches() {
        paletteRecentSearchesData = Data()
    }

    private var favoritePalettes: [SavedPalette] { viewModel.palettes.filter { $0.isFavorite } }

    private var searchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var filteredPalettes: [SavedPalette] {
        var base: [SavedPalette] = []
        switch selectedSegment {
        case .all:
            base = viewModel.palettes
        case .favorites:
            base = favoritePalettes
        case .imports:
            base = Array(viewModel.palettes.prefix(20))
        }

        let sortedPalettes = sortOption.sort(base)
        let query = searchQuery
        if query.isEmpty {
            return sortedPalettes
        }
        var filtered: [SavedPalette] = []
        for palette in sortedPalettes {
            if paletteMatchesSearch(palette, query: query) {
                filtered.append(palette)
            }
        }
        return filtered
    }

    private func paletteMatchesSearch(_ palette: SavedPalette, query: String) -> Bool {
        guard !query.isEmpty else { return true }
        if palette.name.lowercased().contains(query) {
            return true
        }
        if palette.hexCodes.contains(where: { $0.lowercased().contains(query) }) {
            return true
        }
        return false
    }

    private var sortToolbar: some View {
        HStack {
            Label("Sort", systemImage: "arrow.up.arrow.down")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
            Menu {
                ForEach(PaletteSortOption.allCases) { option in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            sortOption = option
                        }
                    } label: {
                        Label(option.label, systemImage: option == sortOption ? "checkmark" : "")
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    NoHyphenationLabel(
                        text: sortOption.label,
                        font: UIFont.monospacedSystemFont(ofSize: 14, weight: .semibold),
                        color: UIColor.label,
                        numberOfLines: 1,
                        lineBreakMode: .byTruncatingTail
                    )
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            }
            Spacer()
        }
    }

    private var layoutControls: some View {
        HStack(spacing: 12) {
            Menu {
                ForEach(PalettePreviewAspect.allCases) { aspect in
                    Button {
                        palettePreviewAspectRawValue = aspect.rawValue
                        HapticManager.instance.impact(style: .soft)
                    } label: {
                        Label(aspect.label, systemImage: aspect == previewAspect ? "checkmark" : "")
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "rectangle.grid.1x2")
                    Text(previewAspect.label)
                }
                .font(.system(.caption, design: .monospaced, weight: .semibold))
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            }

            Menu {
                ForEach(PaletteColorOrder.allCases) { order in
                    Button {
                        paletteColorOrderRawValue = order.rawValue
                        HapticManager.instance.impact(style: .soft)
                    } label: {
                        Label(order.label, systemImage: order == colorOrder ? "checkmark" : "")
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease")
                    Text(colorOrder.label)
                }
                .font(.system(.caption, design: .monospaced, weight: .semibold))
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
            }

            Spacer()
        }
    }

    private var recentSearchSection: some View {
        Group {
            if !paletteRecentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Recent searches")
                            .font(.system(.caption, design: .monospaced, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Clear") { clearRecentSearches() }
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(paletteRecentSearches, id: \.self) { term in
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        searchText = term
                                    }
                                } label: {
                                    NoHyphenationLabel(
                                        text: term,
                                        font: UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold),
                                        color: UIColor.label,
                                        numberOfLines: 1,
                                        lineBreakMode: .byTruncatingTail
                                    )
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 10)
                                        .background(
                                            Capsule()
                                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
            }
        }
    }

    private var paletteHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            ViewThatFits {
                HStack(spacing: 18) {
                    heroBadge
                    heroCopy
                }
                VStack(spacing: 16) {
                    heroBadge
                    heroCopy
                }
            }

            Divider().blendMode(.overlay)

            PaletteMetricGrid(metrics: [
                PaletteMetricChip(label: "Palettes", value: "\(viewModel.palettes.count)", icon: "paintpalette.fill"),
                PaletteMetricChip(label: "Favorites", value: "\(favoritePalettes.count)", icon: "bookmark.fill"),
                PaletteMetricChip(label: "Imports", value: "\(min(viewModel.palettes.count, 20))", icon: "tray.and.arrow.down.fill"),
                PaletteMetricChip(label: "Last Save", value: lastSaveSummary, icon: "clock"
                )
            ])
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassContainer(cornerRadius: 32, tint: accentColor, intensity: 0.18, strokeOpacity: 0.18)
    }

    private var heroBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [accentColor.opacity(0.35), accentColor.opacity(0.15)],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .frame(width: 92, height: 92)

            Image(systemName: "paintpalette")
                .font(.system(size: 36))
                .foregroundColor(.white)
        }
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 8) {
            NoHyphenationLabel(
                text: "Palette Studio",
                font: UIFont.monospacedSystemFont(ofSize: 22, weight: .bold),
                color: UIColor.label
            )
            .italic()
            NoHyphenationLabel(
                text: "Import, favorite, and remix every color story. These palettes stay synced and ready for export.",
                font: UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                color: UIColor.secondaryLabel
            )
        }
    }

    private var lastSaveSummary: String {
        viewModel.palettes.first?.timestamp.formatted(date: .abbreviated, time: .shortened) ?? "—"
    }

    private var segmentPicker: some View {
    ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PaletteSegment.allCases) { segment in
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            selectedSegment = segment
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: segment.icon)
                            NoHyphenationLabel(
                                text: segment.label,
                                font: UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold),
                                color: UIColor.label,
                                numberOfLines: 1,
                                lineBreakMode: .byTruncatingTail
                            )
                        }
                        .font(.system(.caption, design: .monospaced, weight: .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(
                            Capsule()
                                .fill(selectedSegment == segment
                                      ? accentColor.opacity(0.18)
                                      : Color(uiColor: .secondarySystemGroupedBackground))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedSegment == segment
                                        ? accentColor.opacity(0.4)
                                        : Color.primary.opacity(0.05),
                                        lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
    }
    // Ensure inner horizontal scroll takes gesture priority over the outer vertical scroll
    .highPriorityGesture(DragGesture(minimumDistance: 1))
    }

    private var importActionRow: some View {
        ViewThatFits {
            HStack(spacing: 12) { importActions }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) { importActions }
                    .padding(.horizontal, 2)
            }
        }
    }

    @ViewBuilder
    private var importActions: some View {
        Button { showImagePicker = true } label: {
            LargeActionButton(title: "Import Image", icon: "photo", tint: .mint)
        }
        Button {
            viewModel.generateRandomPalette()
            HapticManager.instance.impact(style: .soft)
        } label: {
            LargeActionButton(title: "Random Palette", icon: "wand.and.stars", tint: .purple)
        }
        Button {
            let base = UIColor(Color(.sRGB, red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), opacity: 1))
            viewModel.addPalette(name: "Custom Blend", colors: [base.adjustedBrightness(by: 1.1), base, base.adjustedBrightness(by: 0.8)])
        } label: {
            LargeActionButton(title: "New Manual", icon: "plus.square.on.square", tint: .orange)
        }
    }

    private var favoritesCarousel: some View {
        VStack(alignment: .leading, spacing: 16) {
            PaletteSectionHeader(title: "Pinned Palettes", subtitle: "Tap any favorite to share or duplicate instantly.")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(favoritePalettes) { palette in
                        FavoritePaletteCard(palette: palette,
                                            favoriteAction: { toggleFavorite(palette) })
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var paletteGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 18)], spacing: 18) {
            ForEach(filteredPalettes) { palette in
                PaletteTile(palette: palette,
                            duplicateAction: { duplicate(palette) },
                            deleteAction: { delete(palette) },
                            favoriteAction: { toggleFavorite(palette) },
                            previewMinHeight: previewMinHeight,
                            previewMaxHeight: previewMaxHeight,
                            colorOrder: colorOrder)
            }
        }
    }

    private var palettesContent: some View {
        Group {
            if !favoritePalettes.isEmpty {
                favoritesCarousel
            }
            if filteredPalettes.isEmpty {
                PaletteEmptyState(importAction: { showImagePicker = true },
                                  generateAction: viewModel.generateRandomPalette)
            } else {
                paletteGrid
            }
        }
    }

    private var colorPsychologySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color Psychology")
                .font(.system(.headline, design: .monospaced, weight: .bold))
            ColorPicker("Choose a color for psychology", selection: $selectedPsychologyColor, supportsOpacity: false)
                .frame(maxWidth: 320)
        }
        .padding(16)
        .glassContainer(cornerRadius: 18, tint: accentColor, intensity: 0.12, strokeOpacity: 0.18)
    }

    // Share is now handled by ShareLink inline; no explicit presentShare required

    private func duplicate(_ palette: SavedPalette) {
        viewModel.addPalette(name: palette.name + " Copy", colors: palette.uiColors, image: palette.uiImage)
    }

    private func delete(_ palette: SavedPalette) {
        viewModel.deletePalette(palette)
        HapticManager.instance.notification(type: .warning)
    }

    private func toggleFavorite(_ palette: SavedPalette) {
        palette.isFavorite.toggle()
        try? modelContext.save()
        viewModel.loadPalettes()
        HapticManager.instance.impact(style: .soft)
    }
}

private enum PaletteSegment: String, CaseIterable, Identifiable {
    case all, favorites, imports

    var id: String { rawValue }
    var label: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        case .imports: return "Recent"
        }
    }
    var icon: String {
        switch self {
        case .all: return "rectangle.grid.2x2"
        case .favorites: return "bookmark"
        case .imports: return "clock"
        }
    }
}

private enum PalettePreviewAspect: String, CaseIterable, Identifiable {
    case compact
    case medium
    case tall

    var id: String { rawValue }

    var label: String {
        switch self {
        case .compact: return "Compact"
        case .medium: return "Standard"
        case .tall: return "Tall"
        }
    }

    var minHeight: CGFloat {
        switch self {
        case .compact: return 120
        case .medium: return 160
        case .tall: return 220
        }
    }

    var maxHeight: CGFloat {
        switch self {
        case .compact: return 180
        case .medium: return 260
        case .tall: return 320
        }
    }
}

private enum PaletteColorOrder: String, CaseIterable, Identifiable {
    case original
    case lightToDark
    case darkToLight

    var id: String { rawValue }

    var label: String {
        switch self {
        case .original: return "Color Order"
        case .lightToDark: return "Light → Dark"
        case .darkToLight: return "Dark → Light"
        }
    }

    func apply(to colors: [UIColor]) -> [UIColor] {
        switch self {
        case .original:
            return colors
        case .lightToDark:
            return colors.sorted { $0.relativeLuminance < $1.relativeLuminance }
        case .darkToLight:
            return colors.sorted { $0.relativeLuminance > $1.relativeLuminance }
        }
    }
}

private struct PaletteMetricChip: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String?
}

private enum PaletteSortOption: String, CaseIterable, Identifiable {
    case newest
    case oldest
    case nameAZ
    case nameZA

    var id: String { rawValue }

    var label: String {
        switch self {
        case .newest: return "Newest"
        case .oldest: return "Oldest"
        case .nameAZ: return "Name A-Z"
        case .nameZA: return "Name Z-A"
        }
    }

    func sort(_ palettes: [SavedPalette]) -> [SavedPalette] {
        switch self {
        case .newest:
            return palettes.sorted { ($0.timestamp) > ($1.timestamp) }
        case .oldest:
            return palettes.sorted { ($0.timestamp) < ($1.timestamp) }
        case .nameAZ:
            return palettes.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameZA:
            return palettes.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        }
    }
}

private struct PaletteMetricGrid: View {
    let metrics: [PaletteMetricChip]
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            ForEach(metrics) { metric in
                HStack(spacing: 10) {
                    if let icon = metric.icon {
                        ZStack {
                            Circle()
                                .fill(accentColor.opacity(0.18))
                                .frame(width: 36, height: 36)
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(accentColor)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(metric.value)
                            .font(.system(.headline, design: .monospaced, weight: .bold))
                        Text(metric.label)
                            .font(.system(.caption, design: .monospaced, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassContainer(cornerRadius: 20, tint: accentColor, intensity: 0.12, strokeOpacity: 0.18)
            }
        }
    }
}

private struct PaletteSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .italic()
            NoHyphenationLabel(
                text: subtitle,
                font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct FavoritePaletteCard: View {
    let palette: SavedPalette
    let favoriteAction: () -> Void
    @Environment(\.ambitAccentColor) private var accentColor

    private let previewMinHeight: CGFloat = 140
    private let previewMaxHeight: CGFloat = 180

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(palette.name)
                    .font(.system(.headline, design: .monospaced, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button(action: favoriteAction) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(palette.isFavorite ? accentColor : .gray)
                }
                .buttonStyle(.plain)
            }

            Group {
                if let image = palette.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(minHeight: previewMinHeight, maxHeight: previewMaxHeight)
                        .clipped()
                } else {
                    LinearGradient(colors: palette.uiColors.isEmpty ? [.gray.opacity(0.4), .gray.opacity(0.2)] : palette.uiColors.map { Color(uiColor: $0) },
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .frame(minHeight: previewMinHeight, maxHeight: previewMaxHeight)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 5)

            ShareLink(item: palette.shareSummary) {
                Label("Share HEX Story", systemImage: "square.and.arrow.up")
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
        }
        .padding(16)
        .frame(width: 220, alignment: .leading)
        .glassContainer(cornerRadius: 24, tint: accentColor, intensity: 0.14, strokeOpacity: 0.18)
    }
}

private struct PaletteTile: View {
    let palette: SavedPalette
    let duplicateAction: () -> Void
    let deleteAction: () -> Void
    let favoriteAction: () -> Void

    let previewMinHeight: CGFloat
    let previewMaxHeight: CGFloat
    let colorOrder: PaletteColorOrder

    @Environment(\.ambitAccentColor) private var accentColor

    private var orderedColors: [UIColor] {
        colorOrder.apply(to: palette.uiColors)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            palettePreview
            colorCapsules
            metaInfo
            actionRow
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassContainer(cornerRadius: 24, tint: accentColor, intensity: 0.14, strokeOpacity: 0.18)
    }

    private var palettePreview: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = palette.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(minHeight: previewMinHeight, maxHeight: previewMaxHeight)
                        .clipped()
                } else {
                    let colors = orderedColors.isEmpty ? [UIColor.gray.withAlphaComponent(0.4), UIColor.gray.withAlphaComponent(0.2)] : orderedColors
                    LinearGradient(colors: colors.map { Color(uiColor: $0) },
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .frame(minHeight: previewMinHeight, maxHeight: previewMaxHeight)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 6)

            Button(action: favoriteAction) {
                Image(systemName: palette.isFavorite ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(palette.isFavorite ? accentColor : .white)
                    .padding(8)
            }
            .padding(10)
            .buttonStyle(.plain)
        }
    }

    private var colorCapsules: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(orderedColors.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(uiColor: orderedColors[index]))
                        .frame(width: 48, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 6)
        }
        .frame(height: 36)
        .padding(.vertical, 4)
        .highPriorityGesture(DragGesture(minimumDistance: 1))
    }

    private var metaInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(palette.name)
                .font(.system(.headline, design: .monospaced, weight: .semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)
            Text("Saved \(palette.timestamp.formatted(date: .abbreviated, time: .shortened))")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            NoHyphenationLabel(
                text: palette.shareSummary,
                font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .lineLimit(2)
        }
    }

    private var actionRow: some View {
        ViewThatFits {
            HStack(spacing: 10) { actionButtons }
            VStack(alignment: .leading, spacing: 10) { actionButtons }
        }
        .font(.system(.caption, design: .monospaced, weight: .semibold))
    }

    @ViewBuilder
    private var actionButtons: some View {
        ShareLink(item: palette.shareSummary) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.borderedProminent)
        .tint(.primary)

        Button(action: duplicateAction) {
            Label("Duplicate", systemImage: "plus.square.on.square")
        }
        .buttonStyle(.bordered)

        Button(role: .destructive, action: deleteAction) {
            Label("Delete", systemImage: "trash")
        }
        .buttonStyle(.bordered)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

private struct LargeActionButton: View {
    let title: String
    let icon: String
    let tint: Color

    var body: some View {
        GeometryReader { geo in
            let showText = geo.size.width > 140
            HStack(spacing: 10) {
                Image(systemName: icon)
                if showText {
                    NoHyphenationLabel(
                        text: title,
                        font: UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold),
                        color: UIColor.label,
                        numberOfLines: 1,
                        lineBreakMode: .byTruncatingTail
                    )
                }
            }
            .font(.system(.caption, design: .monospaced, weight: .semibold))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(tint.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(tint.opacity(0.3), lineWidth: 1)
            )
        }
        .frame(height: 44)
    }
}

private struct PaletteEmptyState: View {
    let importAction: () -> Void
    let generateAction: () -> Void
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "paintbrush.pointed")
                .font(.system(size: 46, weight: .bold))
                .foregroundColor(accentColor)
            Text("No palettes yet")
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .italic()
            NoHyphenationLabel(
                text: "Import a photo or spin up a random palette to get started.",
                font: UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                Button("Import Image", action: importAction)
                    .buttonStyle(.borderedProminent)
                Button("Random Palette", action: generateAction)
                    .buttonStyle(.bordered)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .glassContainer(cornerRadius: 30, tint: accentColor, intensity: 0.16, strokeOpacity: 0.2)
    }
}
