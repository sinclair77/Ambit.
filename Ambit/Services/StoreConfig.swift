import Foundation

/// Centralized store configuration. Update these identifiers to match App Store Connect.
///
/// This file provides two ways to configure product identifiers:
/// 1. Edit the constants below (weekly/monthly).
/// 2. Drop a `product_ids.json` file into the app bundle (useful for swapping IDs without code changes).
enum StoreConfig {
    /// App Store numeric Apple ID (optional, used for storefront links/screenshots)
    static let appAppleID = "6755366367"
    
    /// Developer identifier (useful for App Store / CI / metadata reference)
    /// Provided by the user: UUID string representing the developer account
    static let developerID = "f84e6254-628a-49cb-9fe6-e0fe707536cc"

    // Default (derived) product identifiers based on the bundle id.
    // Replace these with your real App Store Connect product IDs if they differ.
    private static let defaultWeekly = "ethereal.focus.Ambit.weekly"
    private static let defaultMonthly = "ethereal.focus.Ambit.monthly"

    /// If a `product_ids.json` file exists in the app bundle, its keys will override the defaults.
    /// Expected JSON shape:
    /// {
    ///   "weekly": "com.example.app.weekly",
    ///   "monthly": "com.example.app.monthly"
    /// }
    private static func overrideIDsFromBundle() -> (weekly: String?, monthly: String?) {
        guard let url = Bundle.main.url(forResource: "product_ids", withExtension: "json") else {
            return (nil, nil)
        }

        do {
            let data = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: String] {
                return (json["weekly"], json["monthly"])
            }
        } catch {
            // If parsing fails, fall back to defaults silently.
        }

        return (nil, nil)
    }

    private static var overrides: (weekly: String?, monthly: String?) = overrideIDsFromBundle()

    static var weeklySubscription: String {
        return overrides.weekly ?? defaultWeekly
    }

    static var monthlySubscription: String {
        return overrides.monthly ?? defaultMonthly
    }
}
