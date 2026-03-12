# Settings & Onboarding Features

## Settings

### SearXNG URL Configuration

- Text field for entering SearXNG instance URL
- Stored in UserDefaults key `"searxng_base_url"`
- Falls back to `AppConfig.defaultSearXNGBaseURL` (`http://localhost:8888`)
- Changes take effect immediately for subsequent searches

### Test Connection

- Button that pings the configured SearXNG instance
- Sends a test search query to verify the server responds
- On success: shows "Connected" with response latency (e.g., "Connected - 120ms")
- On failure: shows error message

### Server Status Indicator

| State | Display |
|-------|---------|
| Reachable | Green circle, "Connected" |
| Unreachable | Red circle, "Unreachable" |
| Checking | Gray spinner, "Checking..." |
| Not configured | Orange circle, "Not set" |

### Apple Intelligence Status

Displays whether Apple Intelligence is available on the device via `SystemLanguageModel.default.availability`.

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
