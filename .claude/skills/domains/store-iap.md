# Store / IAP Domain

> When to load: Modifying purchase logic, paywall UI, daily query limits, or Setapp integration.

## Overview

AISight uses a freemium model: free users get 10 searches/day on the default server. AISight Pro ($4.99 one-time) unlocks unlimited searches and Deep Search on the default server. Users who configure their own SearXNG server get all features for free (unlimited searches, Deep Search) — no purchase needed. Built with StoreKit 2 (non-consumable). Setapp-ready via `#if SETAPP` compile-time flag.

## Key Files

| File | Key Types | Location |
|------|-----------|----------|
| StoreManager.swift | `StoreManager` | `Core/Store/` |
| PaywallReason.swift | `PaywallReason` | `Features/Store/` |
| PaywallView.swift | `PaywallView` | `Features/Store/` |
| QueryLimitBannerView.swift | `QueryLimitBannerView` | `Features/Store/` |
| ProSettingsSection.swift | `ProSettingsSection` | `Features/Settings/` |

## StoreManager

`@MainActor` `@Observable`

Single source of truth for Pro status and daily query tracking.

### State

| Property | Type | Description |
|----------|------|-------------|
| `isPro` | `Bool` | True if purchased or `#if SETAPP` |
| `dailyQueriesUsed` | `Int` | Counter for today's searches |
| `errorMessage` | `String?` | User-facing purchase error |
| `isUsingCustomServer` | `Bool` | True if user has configured a non-default SearXNG URL |
| `canSearch` | `Bool` (computed) | `isUsingCustomServer \|\| isPro \|\| remainingQueries > 0` |
| `canDeepSearch` | `Bool` (computed) | `isUsingCustomServer \|\| isPro` |
| `remainingQueries` | `Int` (computed) | `(isUsingCustomServer \|\| isPro) ? .max : max(0, 10 - dailyQueriesUsed)` |

### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `dailyLimit` | `10` | Free tier daily search cap |
| `productID` | `"com.aisight.pro"` | App Store product identifier |

### Methods

| Method | Description |
|--------|-------------|
| `refreshCustomServerStatus()` | Re-checks if user has a custom server URL. Call after saving/resetting the URL |
| `recordQuery()` | Increments daily counter, no-op if Pro or custom server |
| `purchase()` | StoreKit 2 `Product.purchase()` flow |
| `restorePurchases()` | Refreshes from `Transaction.currentEntitlements` |

### Daily Counter

Uses UserDefaults keys `daily_queries_used` (Int) and `daily_queries_date` (String, `yyyy-MM-dd`). Resets automatically when the stored date differs from today. `DateFormatter` is cached as a static property to avoid repeated allocation.

### Dependency Injection

`StoreManager` accepts an optional `UserDefaults` parameter (`init(defaults: UserDefaults = .standard)`). Production code uses the default (`.standard`). Tests pass an isolated `UserDefaults(suiteName:)` to avoid shared state pollution between test runs.

### StoreKit 2 Integration

- **Transaction listener:** `Task.detached` listening to `Transaction.updates` (detached to avoid blocking MainActor)
- **Purchase verification:** `VerificationResult<Transaction>` — only `.verified` transactions accepted
- **Entitlement refresh:** Iterates `Transaction.currentEntitlements` on init and restore

### Setapp Readiness

All StoreKit code wrapped in `#if !SETAPP`. The init sets `isPro = true` under `#if SETAPP`. Adding Setapp later requires:
1. Add `SETAPP` to Active Compilation Conditions
2. Add Setapp SDK initialization in the `#if SETAPP` block

No other changes needed — the rest of the app reads `isPro` uniformly.

## Environment Injection

`StoreManager` is owned via `@State` in `AISightApp` and injected via `.environment(storeManager)`. Consumed via `@Environment(StoreManager.self)` in:
- `SearchContentView` — gates searches, shows paywall
- `SettingsView` — gates Search Server URL field
- `ProSettingsSection` — shows Pro status / upgrade
- `PaywallView` — purchase/restore actions

## Search Gating Pattern

The gate lives in the **view layer** (not ViewModel):

```swift
// In SearchContentView
private func handleSearch() {
    if storeManager.canSearch {
        storeManager.recordQuery()
        viewModel.performSearch(modelContext: modelContext)
    } else {
        showPaywall = true
    }
}
```

Both search triggers (search bar submit and suggestion chip tap) call `handleSearch()`.

## PaywallReason

`enum PaywallReason` — determines paywall messaging context:

| Case | Trigger | Subtitle |
|------|---------|----------|
| `.dailyLimitReached` | Free user exhausts 10 daily searches | "10 free searches exhausted today" + "come back tomorrow" |
| `.deepSearchRequiresPro` | Free user toggles Deep Search | "Deep Search is a Pro feature" |

## Paywall

Shown as a `.sheet` with `reason: PaywallReason` parameter. Non-aggressive design:
- Star icon, feature list (Unlimited searches, Deep Search, Support development, Future features), purchase button, restore link
- "Or use your own SearXNG server" section with self-hosted option explanation
- "Or come back tomorrow" shown only for `.dailyLimitReached` reason
- Auto-dismisses via `.onChange(of: storeManager.isPro)` on successful purchase
- All purchase UI wrapped in `#if !SETAPP`

## Common Modifications

**Changing the daily limit:** Update `StoreManager.dailyLimit`.

**Changing the product ID:** Update `StoreManager.productID` and the StoreKit Configuration file.

**Adding Pro features:** Check `storeManager.isPro` in the relevant view. The gate pattern is always in the view layer via `@Environment(StoreManager.self)`.

**Adding Setapp support:** Add `SETAPP` to build settings, add Setapp SDK init in the `#if SETAPP` block of `StoreManager.init()`.

## Recent Changes (2026-03-26)

- **Custom server = all features free:** Users who configure their own SearXNG server get unlimited searches and Deep Search without purchasing PRO. New `isUsingCustomServer` stored property on `StoreManager`, with `refreshCustomServerStatus()` method called after URL save/reset.
- **Server URL unlocked for all users:** No longer PRO-gated. "Activate and Test" button saves URL only on successful connection (rolls back on failure). "Use Default Server" button resets to default.
- **Support purchase for custom server users:** "Support AISight — Get Pro" button in ProSettingsSection for custom server users who want to support development.
- **PaywallView updated:** "Custom search server" replaced with "Support AISight development". New "Or use your own SearXNG server" section.
- **Test coverage expanded:** 18 StoreManager tests (custom server unlock/reset, invalid URL rejection, refresh reactivity), 29 SearXNGService tests (edge cases), 7 AppConfig tests. Total ~90 tests.

## Recent Changes (2026-03-25)

- **Daily limit reduced:** 20 → 10 free searches/day.
- **Deep Search gating:** New `canDeepSearch` computed property — returns `true` only for Pro users.
- **PaywallReason enum:** New `PaywallReason.swift` with `.dailyLimitReached` and `.deepSearchRequiresPro` cases for contextual paywall messaging.
- **PaywallView:** Now accepts `reason: PaywallReason` parameter. Feature list expanded to 4 items. "Come back tomorrow" only shown for daily limit reason.
