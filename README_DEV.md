# Development & App Store readiness guide

This file collects the exact steps to build, test StoreKit purchases in sandbox, and prepare App Store Connect metadata for Ambit.

Follow these steps to get the app ready for the App Store and to test purchases locally.

1) Quick local build (Simulator)

 - Clean + build for iPhone 17 simulator (zsh):

```bash
xcodebuild -scheme Ambit -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' clean build
```

 - Install & launch on booted simulator (path may vary):

```bash
xcrun simctl boot "iPhone 17" || true
APP="/Users/$(whoami)/Library/Developer/Xcode/DerivedData/Ambit-*/Build/Products/Debug-iphonesimulator/Ambit.app"
xcrun simctl install booted "$APP"
xcrun simctl launch booted ethereal.focus.Ambit
```

2) Use `product_ids.json` during development

- A `product_ids.json` file exists at `Ambit/AppStoreMetadata/product_ids.json`. The app loads this file at runtime (if present in the app bundle) and will override the default IDs in `Ambit/Services/StoreConfig.swift`.
- To include it in the app bundle for debug:
  - Drag `Ambit/AppStoreMetadata/product_ids.json` into the Xcode project (Ambit target) and ensure "Copy items if needed" is checked and the file is included in **Copy Bundle Resources**.
  - Alternatively you can add it to the target's Build Phases → Copy Bundle Resources.

3) Local StoreKit testing (Xcode StoreKit testing)

- Xcode provides StoreKit configuration files and StoreKit testing in the local environment. For quick iteration, you can:
  - Create a StoreKit Configuration in Xcode (`File > New > File... > StoreKit Configuration File`) and add product IDs matching `product_ids.json`.
  - Select the configuration in the scheme editor (Edit Scheme > Run > Options > StoreKit Configuration) and run the app. Xcode will simulate purchases locally.

4) App Store Connect product creation (required for real sandbox & production)

- In App Store Connect create an auto-renewable subscription group and add two products:
  - Weekly: Product ID = (match `StoreConfig.weeklySubscription` or update `product_ids.json`) — Duration: 1 week — Price: $1.99 USD (choose the matching price tier)
  - Monthly: Product ID = (match `StoreConfig.monthlySubscription` or update `product_ids.json`) — Duration: 1 month — Price: $10 USD
- Fill in localized metadata (see `Ambit/AppStoreMetadata/subscriptions.md` for suggested copy).

5) Sandbox testing on a device (recommended)

- Create Sandbox Testers in App Store Connect → Users and Access → Sandbox Testers.
- On a real device:
  - Sign out of your Apple ID in the App Store settings.
  - Install the build from Xcode (Product > Run) or via TestFlight if using external testers later.
  - When attempting a purchase, sign in with the Sandbox Tester account when prompted.

6) Receipts & verification

- The app uses StoreKit v2 purchase() APIs. Verify the purchase returns a successful transaction and that your app unlocks the correct feature (hasUnlockedPro AppStorage flag in-store manager).
- For server-side receipt validation, collect the `Transaction.current` or the latest `StoreKit` transaction and send to App Store servers (if you run server verification).

7) Replace product IDs for production

- When you create products in App Store Connect, copy the exact product IDs and either:
  - Update `Ambit/Services/StoreConfig.swift` constants and rebuild, or
  - Update `Ambit/AppStoreMetadata/product_ids.json` and include it in the app bundle for debug builds.

8) Privacy & Info.plist

- The project uses generated Info.plist entries (GENERATE_INFOPLIST_FILE = YES) and already contains friendly non-empty privacy strings for:
  - NSCameraUsageDescription
  - NSPhotoLibraryUsageDescription
  - NSPhotoLibraryAddUsageDescription

9) What I changed for you (already committed & pushed)

- `Ambit/Services/StoreConfig.swift`: supports runtime override via `product_ids.json` and contains `appAppleID` and `developerID` you provided.
- `Ambit/AppStoreMetadata/`:
  - `subscriptions.md` — App Store Connect metadata for the two subscriptions.
  - `product_ids.json` — sample product id overrides (included in the repo; add to Copy Bundle Resources to use).

10) Remaining manual steps (must be done by you or your Apple account admin)

- Create the two auto-renewable subscription products in App Store Connect (IDs must match the app at test time).
- Create Sandbox tester accounts and/or configure Xcode's StoreKit testing.
- Test purchases on a real device signed out of the App Store (recommended) or use Xcode’s StoreKit configuration for simulated purchases.

If you want, I can now:

- A) Create and commit a StoreKit configuration file (.storekit) that contains the two subscription products (this will let you run simulated purchases in Xcode without creating App Store Connect products). Tell me if you want that and what localized display names/prices to use.
- B) Commit `product_ids.json` into the app bundle (I added it to the repo, but I can add it to Copy Bundle Resources in the Xcode project file if you want me to edit the pbxproj). That will make the app pick up product IDs automatically when run from Xcode.
- C) Walk through App Store Connect product creation with precise copy to paste into the web form.
