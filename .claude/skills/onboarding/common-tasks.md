# Common Development Tasks

> When to load: How-to guide for frequent modifications to AISight.

## Adding a New Search Engine

Edit `AppConfig.searchEngines` to add the engine name:

```swift
static let searchEngines = "google,bing,brave,duckduckgo"
```

SearXNG handles the rest — no other code changes needed. The engine must be enabled in your SearXNG instance configuration.

## Modifying the System Prompt

Edit `SystemPrompt.swift` → `build()` method. The prompt is in the `## Rules` section.

**Constraint:** Keep total system prompt under ~500 tokens to leave room for sources (~2000 tokens) and answer (~1000 tokens) within the ~4096 token context window.

## Adding a New Setting

1. Choose a UserDefaults key name
2. Add default value in `AppConfig` if needed
3. Add UI control in `SettingsView.swift`
4. Read the value where needed: `UserDefaults.standard.string(forKey: "key") ?? default`

Example: `AppConfig.effectiveSearXNGBaseURL` shows the pattern (computed property with UserDefaults fallback).

## Adding a New SwiftData Model

1. Create model file in `Core/Persistence/`
2. Add `@Model` annotation to the class
3. Register in SwiftData container in `AISightApp.swift`

```swift
@Model
class NewModel {
    var id: UUID
    var name: String
    // ...
}
```

## Changing Content Fetching Behavior

Edit `ContentFetcher.swift` (it's an actor — respect isolation):

- **HTML stripping:** Modify `stripHTML()` — regex-based, removes script/style/nav/header/footer blocks
- **Snippet threshold:** Change `AppConfig.snippetThreshold` (default 150 chars)
- **Max content length:** Change `AppConfig.maxSnippetLength` (default 1600 chars)
- **Timeout:** Change init parameter (default 10s)

## Adding a New UI Component

1. Create file in `UI/Components/`
2. Use system colors: `.primary`, `.secondary`
3. Use system fonts: `.font(.body)`, `.font(.caption)`
4. Use numeric spacing directly
5. **No custom theme values** — `AppTheme.swift` is intentionally empty

## Adding a New Tab/Screen

1. Create a new folder under `Features/` (e.g., `Features/NewFeature/`)
2. Create `NewFeatureView.swift` and `NewFeatureViewModel.swift`
3. Add tab case to TabView in `AISightApp.swift`

## Modifying Citation Rendering

Edit `CitationText.swift` → `parseCitations()`. The parser scans character-by-character, looking for `[N]` patterns and rendering them as blue `AttributedString` badges.

## Modifying Error Messages

1. For search errors: Edit `SearchViewModel.userFacingMessage(for: SearchError)`
2. For AI errors: Edit `SearchViewModel.userFacingMessage(for: AnswerError)`
3. For generation errors: Edit the `catch` block in `AnswerSession.generateAnswer()`

## Testing on Physical Device

1. Must be iPhone 15 Pro+ with Apple Intelligence enabled
2. Change SearXNG URL from `localhost` to your Mac's local IP in app Settings
3. Simulator can test layout but **cannot** test FoundationModels features
4. See `AISight/TESTING.md` for the full 16-scenario manual test plan

## Debugging SearXNG Issues

```bash
# Check if Docker container is running
docker ps

# View SearXNG logs
cd searxng && docker compose logs -f

# Test SearXNG directly
curl "http://localhost:8888/search?q=test&format=json&engines=google"
```

## Key Rules to Follow

- Never remove `@MainActor` from `@Observable` classes
- Always add `@available(iOS 26.0, macOS 26.0, *)` on FoundationModels code
- No `try!` or force unwraps in production code
- No external Swift packages
- Build via Xcode project, not `Package.swift`
- Use `URLComponents` for URL building, never string interpolation
