# Store / IAP Domain

> When to load: Modifying purchase logic, paywall UI, daily query limits, or Setapp integration.

## Overview

AISight uses a freemium model: free users get 10 searches/day, AISight Pro ($4.99 one-time) unlocks unlimited searches, Deep Search, and custom SearXNG URL. Built with StoreKit 2 (non-consumable). Setapp-ready via `#if SETAPP` compile-time flag.

## Key Files

| File | Key Types | Location |
|------|-----------|----------|
| StoreManager.swift | `StoreManager` | `Core/Store/` |
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
| `canSearch` | `Bool` (computed) | `isPro \|\| remainingQueries > 0` |
| `remainingQueries` | `Int` (computed) | `isPro ? .max : max(0, 20 - dailyQueriesUsed)` |

### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `dailyLimit` | `20` | Free tier daily search cap |
| `productID` | `"com.aisight.pro"` | App Store product identifier |

### Methods

| Method | Description |
|--------|-------------|
| `recordQuery()` | Increments daily counter, no-op if Pro |
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

## Paywall

Shown as a `.sheet` when free user hits the daily limit. Non-aggressive design:
- Star icon, feature list (3 `Label` rows), purchase button, restore link
- "Or come back tomorrow" caption
- Auto-dismisses via `.onChange(of: storeManager.isPro)` on successful purchase
- All purchase UI wrapped in `#if !SETAPP`

## Common Modifications

**Changing the daily limit:** Update `StoreManager.dailyLimit`.

**Changing the product ID:** Update `StoreManager.productID` and the StoreKit Configuration file.

**Adding Pro features:** Check `storeManager.isPro` in the relevant view. The gate pattern is always in the view layer via `@Environment(StoreManager.self)`.

**Adding Setapp support:** Add `SETAPP` to build settings, add Setapp SDK init in the `#if SETAPP` block of `StoreManager.init()`.
