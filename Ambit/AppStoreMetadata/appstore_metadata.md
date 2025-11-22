# App Store Connect Metadata for Ambit

## App & Subscription Summary
- App name: Ambit
- Bundle ID: ethereal.focus.Ambit
- Apple App ID (example in code): 6755366367
- Developer ID: f84e6254-628a-49cb-9fe6-e0fe707536cc

## Subscriptions (suggested)
1) Ambit Weekly — Product ID: ethereal.focus.Ambit.weekly
   - Price: Tier corresponding to $1.99/week (use App Store pricing matrix)
   - Display name: "Ambit Weekly"
   - Developer-visible description: "Weekly access to Ambit Pro features: unlimited palette saves, premium color analysis, and export options."
   - Review notes: Offer 3-day free trial (optional).

2) Ambit Monthly — Product ID: ethereal.focus.Ambit.monthly
   - Price: Tier corresponding to $10.00/month
   - Display name: "Ambit Monthly"
   - Developer-visible description: "Monthly access to Ambit Pro features: unlimited palette saves, premium color analysis, and export options."

## Localized App Description (App Store)
- Short: "Capture, extract, and explore beautiful color palettes from photos and images."
- Full:
  "Ambit helps designers, artists, and color enthusiasts extract perfect palettes from images, preview color harmonies, and simulate common forms of color vision deficiency. Create, edit, and export palettes with precision and accessibility in mind. Unlock Pro for unlimited saves, advanced analysis, and export features."

## What's New (1.0)
- "Initial release: color extraction, palette creation, color harmony tools, accessibility analysis, and a new Pro subscription offering advanced features."

## Keywords
color, palette, design, accessibility, harmony, extract, photo

## Screenshot checklist
- Home / Palette gallery
- Color extraction flow (camera / photo import)
- Palette detail and export screen
- Accessibility/Color-vision simulation screen
- Paywall screen (showing weekly/monthly options)

## Review Notes
- Sandbox testing: use the provided product IDs in `AppStoreMetadata/product_ids.json` or create real products in App Store Connect matching those IDs.
- The app uses runtime overrides from `product_ids.json` bundled in the app to make local testing and CI easier.

## Files in this folder
- `product_ids.json` — runtime override used by the app if present in bundle.
- `Ambit.storekit` — simple StoreKit configuration for Xcode local testing (import/select in the scheme's StoreKit configuration).
- `appstore_metadata.md` — this file.

