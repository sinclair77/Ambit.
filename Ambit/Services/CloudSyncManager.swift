import CloudKit
import Foundation

enum AmbitSyncStatus {
    case idle
    case syncing
    case error(Error)
}

struct AmbitPreferenceRecord: Identifiable {
    let id = "AmbitPreference"
    let favorites: [String]
    let recentSearches: [String]
    let paletteSort: String
    let gradientSort: String
    let cardSort: String
    let paletteSegment: String
    let gradientSegment: String
    let cardSegment: String
    let updatedAt: Date

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "AmbitPreference", recordID: CKRecord.ID(recordName: id))
        record["favorites"] = favorites as NSArray
        record["recentSearches"] = recentSearches as NSArray
        record["paletteSort"] = paletteSort as NSString
        record["gradientSort"] = gradientSort as NSString
        record["cardSort"] = cardSort as NSString
        record["paletteSegment"] = paletteSegment as NSString
        record["gradientSegment"] = gradientSegment as NSString
        record["cardSegment"] = cardSegment as NSString
        record["updatedAt"] = updatedAt as NSDate
        return record
    }

    init(record: CKRecord) {
        favorites = record["favorites"] as? [String] ?? []
        recentSearches = record["recentSearches"] as? [String] ?? []
        paletteSort = record["paletteSort"] as? String ?? ""
        gradientSort = record["gradientSort"] as? String ?? ""
        cardSort = record["cardSort"] as? String ?? ""
        paletteSegment = record["paletteSegment"] as? String ?? ""
        gradientSegment = record["gradientSegment"] as? String ?? ""
        cardSegment = record["cardSegment"] as? String ?? ""
        updatedAt = record["updatedAt"] as? Date ?? Date()
    }

    init(favorites: [String],
         recentSearches: [String],
         paletteSort: String,
         gradientSort: String,
         cardSort: String,
         paletteSegment: String,
         gradientSegment: String,
         cardSegment: String,
         updatedAt: Date = Date()) {
        self.favorites = favorites
        self.recentSearches = recentSearches
        self.paletteSort = paletteSort
        self.gradientSort = gradientSort
        self.cardSort = cardSort
        self.paletteSegment = paletteSegment
        self.gradientSegment = gradientSegment
        self.cardSegment = cardSegment
        self.updatedAt = updatedAt
    }
}

final class CloudSyncManager {
    static let shared = CloudSyncManager()

    private let database = CKContainer.default().privateCloudDatabase
    private let recordID = CKRecord.ID(recordName: "AmbitPreference")
    private(set) var status: AmbitSyncStatus = .idle

    private init() {}

    func fetchLatest(completion: @escaping (AmbitPreferenceRecord?) -> Void) {
        status = .syncing
        database.fetch(withRecordID: recordID) { record, error in
            if let record {
                completion(AmbitPreferenceRecord(record: record))
                self.status = .idle
                return
            }
            if let error = error, (error as NSError).code != CKError.unknownItem.rawValue {
                self.status = .error(error)
            } else {
                self.status = .idle
            }
            completion(nil)
        }
    }

    func push(_ preference: AmbitPreferenceRecord, completion: ((Result<AmbitPreferenceRecord, Error>) -> Void)? = nil) {
        status = .syncing
        let record = preference.toCKRecord()
        database.save(record) { saved, error in
            if let error = error {
                self.status = .error(error)
                completion?(.failure(error))
                return
            }
            self.status = .idle
            if let saved {
                completion?(.success(AmbitPreferenceRecord(record: saved)))
            }
        }
    }

    func reconcile(local: AmbitPreferenceRecord,
                   with remote: AmbitPreferenceRecord?,
                   merge: (AmbitPreferenceRecord) -> Void) {
        let candidate = remote ?? local
        merge(candidate)
        push(candidate)
    }
}
