import SwiftUI
import SwiftData
import UIKit

struct GradientView: View {
    @AppStorage("gradientSegmentSelection") private var gradientSegmentRawValue = GradientSegment.all.rawValue
    @AppStorage("gradientSortSelection") private var gradientSortRawValue = GradientSortOption.newest.rawValue
    @AppStorage("gradientRecentSearches") private var gradientRecentSearchesData: Data = Data()
    @Environment(\.ambitAccentColor) private var accentColor
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = GradientViewModel()

    @State private var selectedSegment: GradientSegment = .all
    @State private var sortOption: GradientSortOption = .newest
    @State private var didSyncSegment = false
    @State private var didSyncSort = false
    @State private var searchText: String = ""
    @State private var shareGradient: SavedGradient?
    @State private var showShareSheet = false

    // Unified preview sizing
    private let previewMinHeight: CGFloat = 140
    private let previewMaxHeight: CGFloat = 180

    var body: some View {
        NavigationStack {
            ZStack {
                // Uniform glassy scene background
                LinearGradient(colors: [accentColor.opacity(0.18), accentColor.opacity(0.06)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                    .overlay(.ultraThinMaterial)

                ScrollView {
                    VStack(spacing: 28) {
                        gradientHero
                        segmentPicker
                        sortToolbar
                        recentSearchSection
                        gradientActions

                        if !favoriteGradients.isEmpty {
                            favoriteCarousel
                        }

                        if filteredGradients.isEmpty {
                            GradientEmptyState(generateAction: viewModel.generateRandomGradient)
                        } else {
                            gradientGrid
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                }
            }
            .navigationTitle("Gradients")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search gradients or HEX")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.generateRandomGradient()
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
                selectedSegment = GradientSegment(rawValue: gradientSegmentRawValue) ?? .all
                didSyncSegment = true
            }
            if !didSyncSort {
                sortOption = GradientSortOption(rawValue: gradientSortRawValue) ?? .newest
                didSyncSort = true
            }
        }
        .onChange(of: selectedSegment) { _, newValue in
            gradientSegmentRawValue = newValue.rawValue
            PreferenceSyncCoordinator.shared.scheduleSync()
        }
        .onChange(of: sortOption) { _, newValue in
            gradientSortRawValue = newValue.rawValue
            PreferenceSyncCoordinator.shared.scheduleSync()
        }
        .onSubmit(of: .search) {
            addRecentSearch(term: searchQuery)
        }
        .sheet(isPresented: $showShareSheet) {
            if let gradient = shareGradient {
                ShareSheet(items: [gradientShareSummary(gradient)])
            }
        }
    }

    private var favoriteGradients: [SavedGradient] { viewModel.gradients.filter { $0.isFavorite } }

    private var searchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var filteredGradients: [SavedGradient] {
        let base: [SavedGradient]
        switch selectedSegment {
        case .all:
            base = viewModel.gradients
        case .favorites:
            base = favoriteGradients
        case .recents:
            base = Array(viewModel.gradients.prefix(10))
        }
        let sorted = sortOption.sort(base)
        let query = searchQuery
        guard !query.isEmpty else { return sorted }
        return sorted.filter { gradientMatchesSearch($0, query: query) }
    }

    private func gradientMatchesSearch(_ gradient: SavedGradient, query: String) -> Bool {
        guard !query.isEmpty else { return true }
        if gradient.name.lowercased().contains(query) { return true }
        if gradient.colors.map({ $0.hexString.lowercased() }).contains(where: { $0.contains(query) }) { return true }
        if gradient.style.lowercased().contains(query) { return true }
        return false
    }

    private var gradientRecentSearches: [String] {
        guard let decoded = try? JSONDecoder().decode([String].self, from: gradientRecentSearchesData) else { return [] }
        return decoded
    }

    private func addRecentSearch(term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var updated = gradientRecentSearches.filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        updated.insert(trimmed, at: 0)
        if updated.count > 5 { updated = Array(updated.prefix(5)) }
        if let data = try? JSONEncoder().encode(updated) {
            gradientRecentSearchesData = data
            PreferenceSyncCoordinator.shared.scheduleSync()
        }
    }

    private func clearRecentGradientSearches() {
        gradientRecentSearchesData = Data()
    }

    private var sortToolbar: some View {
        HStack {
            Label("Sort", systemImage: "arrow.up.arrow.down")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
            Menu {
                ForEach(GradientSortOption.allCases) { option in
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

    private var recentSearchSection: some View {
        Group {
            if !gradientRecentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Recent searches")
                            .font(.system(.caption, design: .monospaced, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Clear") { clearRecentGradientSearches() }
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(gradientRecentSearches, id: \.self) { term in
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

    private var gradientHero: some View {
        VStack(alignment: .leading, spacing: 16) {
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

            GradientMetricGrid(metrics: [
                GradientMetric(label: "Systems", value: "\(viewModel.gradients.count)", icon: "chart.bar.fill"),
                GradientMetric(label: "Favorites", value: "\(favoriteGradients.count)", icon: "bookmark.fill"),
                GradientMetric(label: "Angles", value: uniqueAnglesLabel, icon: "angle"),
                GradientMetric(label: "Last Save", value: lastSaveSummary, icon: "clock")
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

            Image(systemName: "aqi.medium")
                .font(.system(size: 36))
                .foregroundColor(.white)
        }
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 8) {
            NoHyphenationLabel(
                text: "Gradient Lab",
                font: UIFont.monospacedSystemFont(ofSize: 22, weight: .bold),
                color: UIColor.label
            )
            .italic()
            NoHyphenationLabel(
                text: "Blend ramps, keep motion-friendly variants, and favorite the systems that anchor your UI kit.",
                font: UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                color: UIColor.secondaryLabel
            )
        }
    }

    private var uniqueAnglesLabel: String {
        let values = Set(viewModel.gradients.map { Int($0.angle) })
        return values.isEmpty ? "—" : "\(values.count) angles"
    }

    private var lastSaveSummary: String {
        viewModel.gradients.first?.timestamp.formatted(date: .abbreviated, time: .shortened) ?? "—"
    }

    private var segmentPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(GradientSegment.allCases) { segment in
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
    }

    private var gradientActions: some View {
        ViewThatFits {
            HStack(spacing: 12) { actionButtons }
            VStack(spacing: 12) { actionButtons }
        }
    }

    private var actionButtons: some View {
        Group {
            GradientCapsuleActionButton(title: "Random Gradient", icon: "wand.and.rays") {
                viewModel.generateRandomGradient()
            }
            GradientCapsuleActionButton(title: "Duplicate Latest", icon: "rectangle.on.rectangle") {
                guard let first = viewModel.gradients.first else { return }
                viewModel.addGradient(name: first.name + " Copy",
                                      colors: first.colors,
                                      locations: first.locations,
                                      startPoint: first.startPoint,
                                      endPoint: first.endPoint,
                                      style: first.style,
                                      angle: first.angle)
            }
        }
    }

    private var favoriteCarousel: some View {
        VStack(alignment: .leading, spacing: 16) {
            GradientSectionHeader(title: "Pinned Systems",
                                  subtitle: "Swipe through your go-to ramps.")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(favoriteGradients) { gradient in
                        FavoriteGradientBadge(gradient: gradient,
                                               shareAction: { share(gradient) },
                                               favoriteAction: { toggleFavorite(gradient) },
                                               previewMinHeight: 90,
                                               previewMaxHeight: 100)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var gradientGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 18)], spacing: 18) {
            ForEach(filteredGradients) { gradient in
                GradientTile(gradient: gradient,
                             shareAction: { share(gradient) },
                             deleteAction: { delete(gradient) },
                             favoriteAction: { toggleFavorite(gradient) },
                             previewMinHeight: previewMinHeight,
                             previewMaxHeight: previewMaxHeight)
            }
        }
    }

    private func share(_ gradient: SavedGradient) {
        shareGradient = gradient
        showShareSheet = true
        HapticManager.instance.impact(style: .soft)
    }

    private func delete(_ gradient: SavedGradient) {
        viewModel.deleteGradient(gradient)
        HapticManager.instance.notification(type: .warning)
    }

    private func toggleFavorite(_ gradient: SavedGradient) {
        gradient.isFavorite.toggle()
        try? modelContext.save()
        viewModel.loadGradients()
        HapticManager.instance.impact(style: .light)
    }

    private func gradientShareSummary(_ gradient: SavedGradient) -> String {
        let codes = gradient.colors.map { $0.hexString }.joined(separator: ", ")
        return "Gradient: \(gradient.name)\nStops: \(codes)\nAngle: \(Int(gradient.angle))°"
    }
}

private enum GradientSegment: String, CaseIterable, Identifiable {
    case all, favorites, recents
    var id: String { rawValue }
    var label: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        case .recents: return "Recent"
        }
    }
    var icon: String {
        switch self {
        case .all: return "rectangle.grid.2x2"
        case .favorites: return "bookmark"
        case .recents: return "clock"
        }
    }
}

private struct GradientTile: View {
    let gradient: SavedGradient
    let shareAction: () -> Void
    let deleteAction: () -> Void
    let favoriteAction: () -> Void

    let previewMinHeight: CGFloat
    let previewMaxHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            gradientPreview
            metaInfo
            actionRow
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground).opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .contextMenu {
            Button("Share", systemImage: "square.and.arrow.up", action: shareAction)
            Button("Favorite", systemImage: "bookmark", action: favoriteAction)
            Button("Delete", role: .destructive, action: deleteAction)
        }
    }
    @Environment(\.ambitAccentColor) private var accentColor

    private var gradientPreview: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(colors: gradient.colors.map { Color(uiColor: $0) },
                           startPoint: gradient.startPoint,
                           endPoint: gradient.endPoint)
            .frame(minHeight: previewMinHeight, maxHeight: previewMaxHeight)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 6)

            Button(action: favoriteAction) {
                Image(systemName: gradient.isFavorite ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(gradient.isFavorite ? accentColor : .white)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(10)
            .buttonStyle(.plain)
        }
    }

    private var metaInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(gradient.name)
                .font(.system(.headline, design: .monospaced, weight: .semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)
            Text("Stops \(gradient.colors.count) · \(Int(gradient.angle))°")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            NoHyphenationLabel(
                text: gradient.colors.map { $0.hexString }.joined(separator: " · "),
                font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .lineLimit(2)
        }
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            Button(action: shareAction) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)

            Button(role: .destructive, action: deleteAction) {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(.bordered)
        }
        .font(.system(.caption, design: .monospaced, weight: .semibold))
    }
}

private struct FavoriteGradientBadge: View {
    let gradient: SavedGradient
    let shareAction: () -> Void
    let favoriteAction: () -> Void
    let previewMinHeight: CGFloat
    let previewMaxHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(gradient.name)
                    .font(.system(.headline, design: .monospaced, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button(action: favoriteAction) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(gradient.isFavorite ? accentColor : .gray)
                }
                .buttonStyle(.plain)
            }

            LinearGradient(colors: gradient.colors.map { Color(uiColor: $0) },
                           startPoint: gradient.startPoint,
                           endPoint: gradient.endPoint)
            .frame(minHeight: previewMinHeight, maxHeight: previewMaxHeight)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button(action: shareAction) {
                Label("Share Stops", systemImage: "square.and.arrow.up")
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
        }
        .padding(16)
        .frame(width: 220, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
    @Environment(\.ambitAccentColor) private var accentColor
}

private struct GradientMetric: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String?
}

private enum GradientSortOption: String, CaseIterable, Identifiable {
    case newest
    case oldest
    case nameAZ

    var id: String { rawValue }

    var label: String {
        switch self {
        case .newest: return "Newest"
        case .oldest: return "Oldest"
        case .nameAZ: return "Name A-Z"
        }
    }

    func sort(_ gradients: [SavedGradient]) -> [SavedGradient] {
        switch self {
        case .newest:
            return gradients.sorted { $0.timestamp > $1.timestamp }
        case .oldest:
            return gradients.sorted { $0.timestamp < $1.timestamp }
        case .nameAZ:
            return gradients.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }
}

private struct GradientMetricGrid: View {
    let metrics: [GradientMetric]
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
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(uiColor: .systemBackground).opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.primary.opacity(0.04), lineWidth: 1)
                )
            }
        }
    }
}

private struct GradientSectionHeader: View {
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

private struct GradientCapsuleActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        GeometryReader { geo in
            let showText = geo.size.width > 120
            Button(action: action) {
                HStack(spacing: 8) {
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
                        .fill(accentColor.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .frame(height: 44)
        .buttonStyle(.plain)
    }
}

private struct GradientEmptyState: View {
    let generateAction: () -> Void
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "aqi.medium")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(accentColor)
            Text("No gradients yet")
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .italic()
            NoHyphenationLabel(
                text: "Generate a fresh blend or duplicate an existing ramp to save it here.",
                font: UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .multilineTextAlignment(.center)
            Button("Generate Gradient", action: generateAction)
                .buttonStyle(.borderedProminent)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(colors: [accentColor.opacity(0.14), accentColor.opacity(0.06)],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
        )
    }
}
