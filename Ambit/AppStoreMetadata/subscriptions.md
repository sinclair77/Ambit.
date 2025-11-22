# App Store Connect metadata — Subscriptions

Use the content below to create two auto-renewable subscription products in App Store Connect.

Important: product IDs below are placeholders derived from the bundle id (`ethereal.focus.Ambit`). If your App Store Connect product IDs differ, either update `Ambit/Services/StoreConfig.swift` or place a `product_ids.json` in the app bundle (see README below).

---

## Product 1 — Weekly (recommended id: `ethereal.focus.Ambit.weekly`)

- Product ID: `ethereal.focus.Ambit.weekly`
- Reference name: Ambit Weekly
- Duration: 1 week (auto-renewable)
- Price: $1.99 (USD) — choose matching price tier in App Store Connect
- Subscription group: Ambit Subscriptions

Suggested App Store Connect fields:

- Name: Ambit Weekly
- Localized subtitle (optional): Try Ambit for a week — renewal every 7 days
- Promotional text (optional): Unlock all palettes & advanced analysis — cancel anytime.
- Review notes: Use sandbox tester accounts for QA. Product is time-based auto-renewing weekly.

Introductory offer (optional): 3-day free trial or 50% off first billing period — configure in App Store Connect.

---

## Product 2 — Monthly (recommended id: `ethereal.focus.Ambit.monthly`)

- Product ID: `ethereal.focus.Ambit.monthly`
- Reference name: Ambit Monthly
- Duration: 1 month (auto-renewable)
- Price: $10.00 (USD) — choose matching price tier in App Store Connect
- Subscription group: Ambit Subscriptions

Suggested App Store Connect fields:

- Name: Ambit Monthly
- Localized subtitle (optional): Full access month-to-month
- Promotional text (optional): Save when you subscribe monthly — full access to pro features.
- Review notes: Monthly subscription; no introductory offer configured by default.

---

### Localizations

Provide localized names and description strings for supported locales. Keep the description concise and focused on value:

Example (en-US description):
"Ambit Pro unlocks advanced palette generation, unlimited image analysis, and cloud sync across devices. Subscribe weekly or monthly to support development and get early features."

---

### After creating products

1. Ensure the Product IDs you create match `Ambit/Services/StoreConfig.swift` or include a `product_ids.json` in the app bundle.
2. Add sandbox tester accounts in App Store Connect → Users and Access → Sandbox Testers.
3. Install the app on a real device signed out of the App Store (or use the simulator with StoreKit testing) and test purchases with the sandbox accounts.

---

### product_ids.json (optional)

If you'd rather not edit code, create a small JSON file named `product_ids.json` and include it in the app bundle; its content should be:

```json
{
  "weekly": "ethereal.focus.Ambit.weekly",
  "monthly": "ethereal.focus.Ambit.monthly"
}
```

Drop it under `Ambit/AppStoreMetadata/` while developing and we can copy it into the bundle for local debug, or add it to your asset pipeline. The app will use the values if present.
