# Settings & Onboarding Features

## Settings

### SearXNG URL Configuration

- Text field for entering SearXNG instance URL — **available to all users** (not PRO-gated)
- Stored in UserDefaults key `"searxng_base_url"`
- Falls back to `AppConfig.defaultSearXNGBaseURL` (`https://search.private-search-intelligence.app`)
- **Custom server unlocks all features for free** (unlimited searches, Deep Search) — no purchase needed

### Activate and Test / Use Default Server

- **"Activate and Test"** button appears when URL differs from saved value
  - Temporarily sets URL, tests connection
  - On success: saves URL permanently, activates custom server features via `storeManager.refreshCustomServerStatus()`
  - On failure: rolls back to previous URL, shows "Connection failed. Server not activated."
- **"Test Connection"** button appears when URL matches saved value (re-test existing server)
- **"Use Default Server"** button appears when URL differs from default — resets URL and re-enables paywall
- Pressing Return in the text field triggers the same action as the button

### AISight Pro Section (ProSettingsSection)

| State | Display |
|-------|---------|
| PRO purchased | "AISight Pro Active" with checkmark seal |
| Custom server (not PRO) | "All features unlocked" + "Using your own search server" + "Support AISight — Get Pro" button |
| Free user (default server) | "Searches used today: X / 10" + "Upgrade to AISight Pro" + "Restore Purchases" |

### Apple Intelligence Status

Displays whether Apple Intelligence is available on the device via `SystemLanguageModel.default.availability`.

### Deep Search Toggle

- Toggle to enable/disable Deep Search mode
- Located in the **Search tab** (below the input bar), not in Settings
- Stored in UserDefaults key `"deep_search_enabled"` (default: false)
- When enabled, shows a one-line disclaimer about the tradeoff (15-25s vs 5-10s)
- Uses `sparkle.magnifyingglass` SF Symbol icon

## Onboarding

### First-Launch Flow

- Controlled by `AppState.hasSeenOnboarding` (backed by UserDefaults `"hasSeenOnboarding"`)
- Shows on first launch only
- Introduces the app's purpose and privacy model
- After completion, sets `hasSeenOnboarding = true`
- Subsequent launches go directly to the main search screen

### Content

The onboarding explains:
- AISight answers questions using web sources and on-device AI
- All AI processing is private — data never leaves to cloud AI services
- Best for clear factual questions
- Complex research or real-time topics may be limited

## Implementation

- **SettingsView** in `Features/Settings/SettingsView.swift`
- **OnboardingView** in `Features/Onboarding/OnboardingView.swift`
- **AppState** manages `hasSeenOnboarding` and `serverAvailable` state
- Server availability checked on launch, foreground return, URL change, and manual test
