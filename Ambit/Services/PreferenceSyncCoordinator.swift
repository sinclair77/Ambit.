import Foundation
#if AMBIT_CLOUDKIT
import CloudKit
#endif

final class PreferenceSyncCoordinator: ObservableObject {
    static let shared = PreferenceSyncCoordinator()

    @Published private(set) var status: AmbitSyncStatus = .idle

    private let defaults = UserDefaults.standard
    private let lastUpdateKey = "ambitPreferenceUpdatedAt"

    private init() {}

    private var lastUpdate: Date {
        get { defaults.object(forKey: lastUpdateKey) as? Date ?? Date.distantPast }
        set { defaults.set(newValue, forKey: lastUpdateKey) }
    }

    func startSync() {
        #if AMBIT_CLOUDKIT
        syncFromCloud()
        #else
        status = .idle
        #endif
    }

    func scheduleSync() {
        #if AMBIT_CLOUDKIT
        syncToCloud()
        #endif
    }

    private func syncFromCloud() {
        #if !AMBIT_CLOUDKIT
        status = .idle
        return
        #else
        status = .syncing
        CloudSyncManager.shared.fetchLatest { record in
            guard let record else {
                self.status = .idle
                return
            }
            if record.updatedAt > self.lastUpdate {
                self.apply(record: record)
            }
            self.status = .idle
        }
        #endif
    }

    private func syncToCloud() {
        #if AMBIT_CLOUDKIT
        let record = currentPreferenceRecord()
        status = .syncing
        CloudSyncManager.shared.push(record) { result in
            switch result {
            case .success(let savedRecord):
                self.lastUpdate = savedRecord.updatedAt
                self.status = .idle
            case .failure(let error):
                self.status = .error(error)
            }
        }
        #endif
    }

    private func apply(record: AmbitPreferenceRecord) {
        defaults.set(record.paletteSegment, forKey: "paletteSegmentSelection")
        defaults.set(record.gradientSegment, forKey: "gradientSegmentSelection")
        defaults.set(record.cardSegment, forKey: "cardSegmentSelection")
        defaults.set(record.paletteSort, forKey: "paletteSortSelection")
        defaults.set(record.gradientSort, forKey: "gradientSortSelection")
        defaults.set(record.cardSort, forKey: "cardSortSelection")
        defaults.set(encode(record.recentSearches), forKey: "paletteRecentSearches")
        defaults.set(encode(record.recentSearches), forKey: "gradientRecentSearches")
        defaults.set(encode(record.recentSearches), forKey: "cardRecentSearches")
        lastUpdate = record.updatedAt
    }

    private func currentPreferenceRecord() -> AmbitPreferenceRecord {
        let paletteSegment = defaults.string(forKey: "paletteSegmentSelection") ?? "all"
        let gradientSegment = defaults.string(forKey: "gradientSegmentSelection") ?? "all"
        let cardSegment = defaults.string(forKey: "cardSegmentSelection") ?? "all"
        let paletteSort = defaults.string(forKey: "paletteSortSelection") ?? "newest"
        let gradientSort = defaults.string(forKey: "gradientSortSelection") ?? "newest"
        let cardSort = defaults.string(forKey: "cardSortSelection") ?? "newest"
        let paletteSearches = decodeSearches(forKey: "paletteRecentSearches")
        let gradientSearches = decodeSearches(forKey: "gradientRecentSearches")
        let cardSearches = decodeSearches(forKey: "cardRecentSearches")
        let mergedSearches = Array(Set(paletteSearches + gradientSearches + cardSearches))
        return AmbitPreferenceRecord(favorites: [],
                                     recentSearches: mergedSearches,
                                     paletteSort: paletteSort,
                                     gradientSort: gradientSort,
                                     cardSort: cardSort,
                                     paletteSegment: paletteSegment,
                                     gradientSegment: gradientSegment,
                                     cardSegment: cardSegment,
                                     updatedAt: Date())
    }

    private func encode(_ array: [String]) -> Data {
        (try? JSONEncoder().encode(array)) ?? Data()
    }

    private func decodeSearches(forKey key: String) -> [String] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return decoded
    }
}
