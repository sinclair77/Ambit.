import SwiftUI
import SwiftData
import UIKit

struct CardView: View {
    @AppStorage("cardSegmentSelection") private var cardSegmentRawValue = CardSegment.all.rawValue
    @AppStorage("cardSortSelection") private var cardSortRawValue = CardSortOption.newest.rawValue
    @AppStorage("cardRecentSearches") private var cardRecentSearchesData: Data = Data()
    @Environment(\.ambitAccentColor) private var accentColor
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CardViewModel()

    @State private var selectedSegment: CardSegment = .all
    @State private var sortOption: CardSortOption = .newest
    @State private var didSyncSegment = false
    @State private var didSyncSort = false
    @State private var searchText: String = ""
    @State private var shareCard: SavedCard?
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

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28) {
                        cardHero
                        segmentPicker
                        sortToolbar
                        recentSearchSection
                        cardActions

                        if !favoriteCards.isEmpty {
                            favoriteCarousel
                        }

                        if filteredCards.isEmpty {
                            CardEmptyState(generateAction: viewModel.generateRandomCard)
                        } else {
                            cardGrid
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                }
            }
            .navigationTitle("Cards")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search cards by date")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.generateRandomCard()
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
                selectedSegment = CardSegment(rawValue: cardSegmentRawValue) ?? .all
                didSyncSegment = true
            }
            if !didSyncSort {
                sortOption = CardSortOption(rawValue: cardSortRawValue) ?? .newest
                didSyncSort = true
            }
        }
        .onChange(of: selectedSegment) { _, newValue in
            cardSegmentRawValue = newValue.rawValue
            PreferenceSyncCoordinator.shared.scheduleSync()
        }
        .onChange(of: sortOption) { _, newValue in
            cardSortRawValue = newValue.rawValue
            PreferenceSyncCoordinator.shared.scheduleSync()
        }
        .onSubmit(of: .search) {
            addRecentSearch(term: searchQuery)
        }
        .sheet(isPresented: $showShareSheet) {
            if let card = shareCard, let image = card.uiImage {
                ShareSheet(items: [image])
            }
        }
    }

    private var favoriteCards: [SavedCard] { viewModel.cards.filter { $0.isFavorite } }

    private var searchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var filteredCards: [SavedCard] {
        let base: [SavedCard]
        switch selectedSegment {
        case .all:
            base = viewModel.cards
        case .favorites:
            base = favoriteCards
        case .recents:
            base = Array(viewModel.cards.prefix(8))
        }
        let sorted = sortOption.sort(base)
        let query = searchQuery
        guard !query.isEmpty else { return sorted }
        return sorted.filter { cardMatchesSearch($0, query: query) }
    }

    private func cardMatchesSearch(_ card: SavedCard, query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let dateString = card.timestamp.formatted(date: .abbreviated, time: .shortened).lowercased()
        if dateString.contains(query) { return true }
        if card.isFavorite && "favorite".contains(query) { return true }
        return false
    }

    private var cardRecentSearches: [String] {
        guard let decoded = try? JSONDecoder().decode([String].self, from: cardRecentSearchesData) else { return [] }
        return decoded
    }

    private func addRecentSearch(term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var updated = cardRecentSearches.filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        updated.insert(trimmed, at: 0)
        if updated.count > 5 { updated = Array(updated.prefix(5)) }
        if let data = try? JSONEncoder().encode(updated) {
            cardRecentSearchesData = data
            PreferenceSyncCoordinator.shared.scheduleSync()
        }
    }

    private func clearRecentCardSearches() {
        cardRecentSearchesData = Data()
    }

    private var sortToolbar: some View {
        HStack {
            Label("Sort", systemImage: "arrow.up.arrow.down")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
            Menu {
                ForEach(CardSortOption.allCases) { option in
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
            if !cardRecentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Recent searches")
                            .font(.system(.caption, design: .monospaced, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Clear") { clearRecentCardSearches() }
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(cardRecentSearches, id: \.self) { term in
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

    private var cardHero: some View {
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

            CardMetricGrid(metrics: [
                CardMetricChip(label: "Exports", value: "\(viewModel.cards.count)", icon: "square.stack.3d.up.fill"),
                CardMetricChip(label: "Favorites", value: "\(favoriteCards.count)", icon: "bookmark.fill"),
                CardMetricChip(label: "Recents", value: "\(min(viewModel.cards.count, 8))", icon: "clock"),
                CardMetricChip(label: "Last Export", value: lastExportSummary, icon: "calendar")
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

            Image(systemName: "doc.richtext.fill")
                .font(.system(size: 34))
                .foregroundColor(.white)
        }
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 8) {
            NoHyphenationLabel(
                text: "Export Gallery",
                font: UIFont.monospacedSystemFont(ofSize: 22, weight: .bold),
                color: UIColor.label
            )
            .italic()
            NoHyphenationLabel(
                text: "Your color story cards stay here—ready to favorite, duplicate, or share as assets.",
                font: UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                color: UIColor.secondaryLabel
            )
        }
    }

    private var lastExportSummary: String {
        viewModel.cards.first?.timestamp.formatted(date: .abbreviated, time: .shortened) ?? "—"
    }

    private var segmentPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(CardSegment.allCases) { segment in
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

    private var cardActions: some View {
        ViewThatFits {
            HStack(spacing: 12) { actionButtons }
            VStack(spacing: 12) { actionButtons }
        }
    }

    private var actionButtons: some View {
        Group {
            CardCapsuleActionButton(title: "Random Export", icon: "sparkles") {
                viewModel.generateRandomCard()
            }
            CardCapsuleActionButton(title: "Refresh", icon: "arrow.clockwise") {
                viewModel.loadCards()
            }
        }
    }

    private var favoriteCarousel: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardSectionHeader(title: "Pinned Cards", subtitle: "Quick share your go-to exports.")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(favoriteCards) { card in
                        FavoriteCardBadge(card: card,
                                          shareAction: { share(card) },
                                          favoriteAction: { toggleFavorite(card) },
                                          previewMinHeight: 90,
                                          previewMaxHeight: 100)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var cardGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 18)], spacing: 18) {
            ForEach(filteredCards) { card in
                CardTile(card: card,
                         shareAction: { share(card) },
                         duplicateAction: { duplicate(card) },
                         deleteAction: { delete(card) },
                         favoriteAction: { toggleFavorite(card) },
                         previewMinHeight: previewMinHeight,
                         previewMaxHeight: previewMaxHeight)
            }
        }
    }

    private func share(_ card: SavedCard) {
        shareCard = card
        showShareSheet = true
        HapticManager.instance.impact(style: .soft)
    }

    private func delete(_ card: SavedCard) {
        viewModel.deleteCard(card)
        HapticManager.instance.notification(type: .warning)
    }

    private func duplicate(_ card: SavedCard) {
        viewModel.duplicateCard(card)
        HapticManager.instance.notification(type: .success)
    }

    private func toggleFavorite(_ card: SavedCard) {
        card.isFavorite.toggle()
        try? modelContext.save()
        viewModel.loadCards()
        HapticManager.instance.impact(style: .light)
    }
}

private enum CardSegment: String, CaseIterable, Identifiable {
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

private struct CardTile: View {
    let card: SavedCard
    let shareAction: () -> Void
    let duplicateAction: () -> Void
    let deleteAction: () -> Void
    let favoriteAction: () -> Void

    let previewMinHeight: CGFloat
    let previewMaxHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            cardPreview
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
            Button("Duplicate", systemImage: "plus.square.on.square", action: duplicateAction)
            Button("Favorite", systemImage: "bookmark", action: favoriteAction)
            Button("Delete", role: .destructive, action: deleteAction)
        }
    }

    private var cardPreview: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = card.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(minHeight: previewMinHeight, maxHeight: previewMaxHeight)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.gray.opacity(0.2))
                        .frame(minHeight: previewMinHeight, maxHeight: previewMaxHeight)
                        .overlay(
                            Image(systemName: "doc.richtext")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.secondary)
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 6)

            Button(action: favoriteAction) {
                Image(systemName: card.isFavorite ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(card.isFavorite ? accentColor : .white)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(10)
            .buttonStyle(.plain)
        }
    }
    @Environment(\.ambitAccentColor) private var accentColor

    private var metaInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Color Card")
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            Text(card.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            NoHyphenationLabel(
                text: "Tap share to export or duplicate from the Library.",
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
        Button(action: shareAction) {
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

private struct FavoriteCardBadge: View {
    let card: SavedCard
    let shareAction: () -> Void
    let favoriteAction: () -> Void
    let previewMinHeight: CGFloat
    let previewMaxHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Export")
                    .font(.system(.headline, design: .monospaced, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer()
                Button(action: favoriteAction) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(card.isFavorite ? accentColor : .gray)
                }
                .buttonStyle(.plain)
            }

            Group {
                if let image = card.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(minHeight: previewMinHeight, maxHeight: previewMaxHeight)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.gray.opacity(0.2))
                        .frame(minHeight: previewMinHeight, maxHeight: previewMaxHeight)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button(action: shareAction) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
        }
        .padding(16)
        .frame(width: 200, alignment: .leading)
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

private struct CardCapsuleActionButton: View {
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

private struct CardEmptyState: View {
    let generateAction: () -> Void
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(accentColor)
            Text("No cards yet")
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .italic()
            NoHyphenationLabel(
                text: "Generate a new export to see it here ready for share and favorites.",
                font: UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .multilineTextAlignment(.center)
            Button("Generate Card", action: generateAction)
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

private struct CardMetricChip: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String
}

private enum CardSortOption: String, CaseIterable, Identifiable {
    case newest
    case oldest
    case favoritesFirst

    var id: String { rawValue }

    var label: String {
        switch self {
        case .newest: return "Newest"
        case .oldest: return "Oldest"
        case .favoritesFirst: return "Favorites First"
        }
    }

    func sort(_ cards: [SavedCard]) -> [SavedCard] {
        switch self {
        case .newest:
            return cards.sorted { $0.timestamp > $1.timestamp }
        case .oldest:
            return cards.sorted { $0.timestamp < $1.timestamp }
        case .favoritesFirst:
            return cards.sorted {
                if $0.isFavorite == $1.isFavorite {
                    return $0.timestamp > $1.timestamp
                }
                return $0.isFavorite && !$1.isFavorite
            }
        }
    }
}

private struct CardMetricGrid: View {
    let metrics: [CardMetricChip]
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            ForEach(metrics) { metric in
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.18))
                            .frame(width: 36, height: 36)
                        Image(systemName: metric.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(accentColor)
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

private struct CardSectionHeader: View {
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
