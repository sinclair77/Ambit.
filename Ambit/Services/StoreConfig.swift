import Foundation

/// Centralized store configuration. Update these identifiers to match App Store Connect.
enum StoreConfig {
    /// App Store numeric Apple ID (optional, used for storefront links/screenshots)
    static let appAppleID = "6755366367"

    // Derived product identifiers based on provided bundle id.
    // If your product ids in App Store Connect differ, replace these with the exact IDs.
    static let weeklySubscription = "ethereal.focus.Ambit.weekly"
    static let monthlySubscription = "ethereal.focus.Ambit.monthly"
}
