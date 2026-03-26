# UI / Features Domain

> When to load: Modifying views, view models, or reusable UI components.

## Overview

AISight follows MVVM with SwiftUI views and `@Observable` view models. The app has 4 main screens (Search, History, Settings, Onboarding) organized under `Features/`, plus shared components in `UI/Components/`. No custom theme — uses system colors and fonts throughout.

## Key Files

### Features

| File | Key Types | Location |
|------|-----------|----------|
| SearchView.swift | `SearchView` | `Features/Search/` |
| SearchViewModel.swift | `SearchViewModel` | `Features/Search/` |
| StreamingAnswerView.swift | `StreamingAnswerView` | `Features/Search/` |
| HistoryView.swift | `HistoryView` | `Features/History/` |
| HistoryViewModel.swift | `HistoryViewModel` | `Features/History/` |
| SettingsView.swift | `SettingsView` | `Features/Settings/` |
| PrivacyPolicyView.swift | `PrivacyPolicyView` | `Features/Settings/` |
| TermsOfUseView.swift | `TermsOfUseView` | `Features/Settings/` |
| OnboardingView.swift | `OnboardingView` | `Features/Onboarding/` |
| HistoryDetailView.swift | `HistoryDetailView` | `Features/History/` |
| PaywallReason.swift | `PaywallReason` | `Features/Store/` |
| PaywallView.swift | `PaywallView` | `Features/Store/` |
| QueryLimitBannerView.swift | `QueryLimitBannerView` | `Features/Store/` |
| ProSettingsSection.swift | `ProSettingsSection` | `Features/Settings/` |

### UI Components

| File | Key Types | Location |
|------|-----------|----------|
| CitationText.swift | `CitationText` | `UI/Components/` |
| SourceCardView.swift | `SourceCardView` | `UI/Components/` |
| CitationBadge.swift | `CitationBadge` | `UI/Components/` |
| LoadingDots.swift | `LoadingDots` | `UI/Components/` |
| ShimmerEffect.swift | `ShimmerModifier` | `UI/Components/` |
| SearchSkeletonView.swift | `SearchSkeletonView` | `UI/Components/` |
| SkeletonBlock.swift | `SkeletonBlock` | `UI/Components/` |
| LegalSectionView.swift | `LegalSectionView` | `UI/Components/` |
| TypingCursor.swift | `TypingCursor` | `UI/Components/` |
| AppIconView.swift | `AppIconView` | `UI/Components/` |
| AppTheme.swift | (empty) | `UI/Theme/` |

### App

| File | Key Types | Location |
|------|-----------|----------|
| AISightApp.swift | `AISightApp` | `App/` |
| AppState.swift | `AppState` | `App/` |
| StoreManager.swift | `StoreManager` | `Core/Store/` |

## SearchViewModel

`@available(iOS 26.0, macOS 26.0, *)` `@MainActor` `@Observable`

### State

| Property | Type | Description |
|----------|------|-------------|
| `query` | `String` | Current query text (bound to TextField) |
| `sources` | `[SearXNGResult]` | Current search results for display |
| `errorMessage` | `String?` | User-facing error message |
| `answerSession` | `AnswerSession` | Owned answer session |
| `isSearching` | `Bool` | True during SearXNG search |
| `streamingText` | `String` | Forwarded from answerSession |
| `isGenerating` | `Bool` | Forwarded from answerSession |
| `deepSearchPipeline` | `DeepSearchPipeline` | Owned deep search pipeline |
| `isDeepSearch` | `Bool` | Reads from UserDefaults `"deep_search_enabled"` |
| `searchStepDescription` | `String?` | Current deep search step for UI, nil in normal mode |

### performSearch(modelContext:)

Branches based on `isDeepSearch`:

**Normal mode:**
1. Reformulate → multiSearch → AnswerSession.generateAnswer() → save to history

**Deep Search mode:**
1. Reset deep search pipeline
2. `deepSearchPipeline.execute(query:language:searchService:)` — handles all steps internally
3. Forward sources/queryGroups from returned SearchOutput
4. Map errors, save to history on success

Both modes: cancel previous task, check `Task.isCancelled` between stages.

### resetSearch()

Resets all state for a new query: cancels in-flight task, clears query/sources/errors, calls `answerSession.reset()` and `deepSearchPipeline.reset()`. Used by the "New Search" toolbar button.

### Error Mapping

Converts `SearchError` and `AnswerError` to human-readable strings. See `patterns/error-handling.md` for full mapping.

## CitationText

Parses markdown and `(via domain.com)` attribution markers, rendering formatted text with inline styled attributions.

**Architecture:** Block-level parser + inline markdown renderer.

1. **Block parsing:** Splits text into blocks — headings (`##`), list items (`-`, `1.`), code blocks (`` ``` ``), paragraphs
2. **Block rendering:** Each block type renders as a separate SwiftUI view:
   - Headings → `.title` / `.title2` / `.title3` fonts with bold weight
   - List items → `HStack` with bullet `•` or number prefix
   - Code blocks → monospaced font with `.fill.secondary` background, 12pt padding, rounded 10
   - Paragraphs → inline-rendered text with `.lineSpacing(3)`
3. **Inline rendering:** Within each block, text is parsed via `AttributedString(markdown:)` for bold/italic/code/links, then `(via domain)` placeholders are replaced with subtle italic `.caption` `.secondary` text

**Attribution escaping:** Before markdown parsing, `(via domain.com)` patterns are replaced with `\u{FFFC}` placeholders to prevent markdown interference. After parsing, placeholders are swapped back to styled inline text.

**Used in:** StreamingAnswerView, HistoryDetailView

## AppState

`@MainActor` `@Observable`

| Property | Type | Description |
|----------|------|-------------|
| `serverAvailable` | `Bool?` | nil = unchecked, true/false = checked (not shown on search screen) |
| `lastServerCheck` | `Date?` | Timestamp of last check |
| `hasSeenOnboarding` | `Bool` | UserDefaults-backed |
| `isAppleIntelligenceAvailable` | `Bool` | Computed from SystemLanguageModel |

## Design Principles

- **No custom theme:** `AppTheme.swift` is intentionally empty. Use `.primary`, `.secondary`, `.font(.body)`, numeric spacing.
- **Liquid glass:** iOS 26 automatic on TabView, NavigationStack, toolbars. Only custom glass: `.regularMaterial` on source cards and search bar.
- **No `.glassEffect()`** on content views — let the system handle it.
- **Standard components:** NavigationStack, TabView, List, TextField, ProgressView. No custom navigation.
- **No "via Engine" badges:** Source cards show domain + favicon only, no search engine attribution.
- **Animation patterns:** Spring animations for interactive state (expand/collapse), `.symbolEffect()` for SF Symbol delight (`.breathe`, `.bounce`, `.appear`, `.pulse`), `.scrollTransition` for scroll-driven fade+scale, `.contentTransition(.numericText())` for text changes, `PhaseAnimator` for repeating animations (typing cursor, loading dots).
- **Loading states:** Apple Intelligence icon with `.breathe.pulse.byLayer` + "Thinking..." text (or deep search step labels). No skeleton/shimmer for primary loading. `TypingCursor` appended to streaming text.

## Common Modifications

**Adding a new tab:** Add case to TabView in `AISightApp.swift`, create Feature folder with View + ViewModel.

**Adding a new UI component:** Create in `UI/Components/`. Use system colors and fonts. No custom theme values.

**Modifying citation rendering:** Edit `CitationText`. Block parsing is in `parseBlocks()`, inline markdown+attributions in `renderInline()`. Attribution escaping uses `\u{FFFC}` placeholders.

**Adding loading states:** Use the Apple Intelligence breathing icon pattern from SearchView's `loadingState`, or `LoadingDots` for inline indicators.

**Enabling/disabling Deep Search:** `SearchViewModel.isDeepSearch` toggled via pill button in SearchView. Deep Search description text appears below when active.

## Legal Documents (App Store Compliance)

Added for Apple App Store submission compliance:

- **PrivacyPolicyView** — 12 sections covering data practices, on-device AI, children's privacy, GDPR/CCPA rights. Contact: jesus@perezpaz.es
- **TermsOfUseView** — 15 sections including Apple EULA requirements (section 12), governing law (Spain). Contact: jesus@perezpaz.es
- **LegalSectionView** — Reusable component with `LocalizedStringKey` title and content parameters for automatic localization
- **Settings integration** — Legal section with NavigationLinks to both views, plus Contact Support (mailto:) link
- **Onboarding consent** — "By continuing, you agree to our Terms of Use and Privacy Policy" with tappable links using `aisight://` custom URL scheme and `.sheet(item:)` presentation
- **Delete All Data** — Renamed from "Clear Cache" with stronger confirmation dialog
- **AI disclaimer** — "AI-generated answers may be inaccurate..." shown after every completed answer

## Localization

- **9 languages:** en, de, fr, es, it, ja, ko, zh, pt
- **199 translated keys** in `Localizable.xcstrings` (Xcode String Catalogs)
- Legal views use `LocalizedStringKey` parameters so string literals auto-localize
- All legal document sections translated and reviewed by language-specific agents
- UI strings (Delete All Data, Legal, Contact Support, etc.) also translated

## AISight Pro (Freemium)

- **Free tier:** 10 searches/day on default SearXNG instance
- **AISight Pro** ($4.99 one-time): Unlimited searches, Deep Search on default server, support development
- **Self-hosted:** Users who configure their own SearXNG server get all features free (unlimited searches, Deep Search) — no purchase needed
- **StoreManager** (`Core/Store/`): Single `@Observable` source of truth for `isPro`, `isUsingCustomServer`, daily counter, StoreKit 2 purchase/restore
- **PaywallReason:** Enum (`.dailyLimitReached`, `.deepSearchRequiresPro`) customizes paywall messaging.
- **Paywall:** Non-aggressive sheet shown when daily limit hit or Deep Search toggled by free user. Includes "Or use your own SearXNG server" option. Auto-dismisses on purchase.
- **QueryLimitBannerView:** Small banner in search empty state when ≤ 5 searches remain
- **ProSettingsSection:** First section in Settings Form, shows Pro status, custom server status, or upgrade/restore buttons. Custom server users see "Support AISight — Get Pro" option.
- **Search Server:** Available to all users. "Activate and Test" saves and tests URL. "Use Default Server" resets. Only activates on successful connection test.
- **Search gating:** `handleSearch()` in `SearchContentView` checks `storeManager.canSearch` before calling `viewModel.performSearch()`
- **Setapp-ready:** `#if SETAPP` compile-time flag unlocks Pro with zero runtime changes. All StoreKit code wrapped in `#if !SETAPP`.
- See `domains/store-iap.md` for full architecture details.

## View Extraction (Refactor)

Views extracted into dedicated structs following single-type-per-file pattern:

- **SearchView** → `SearchContentView`, `SearchEmptyStateView`, `SearchLoadingView`, `SearchBarSection`, `SuggestionChip` (private subviews)
- **OnboardingView** → `FeatureRow` (private subview)
- **HistoryView** → `HistoryDetailView` (separate file)
- **ShimmerEffect** → `SearchSkeletonView` and `SkeletonBlock` (separate files)
- **ServerStatusView** — **REMOVED** (settings simplified)

## Recent Changes (2026-03-25)

- **Auto-focus search:** Search input auto-focuses on appear and after reset for faster UX.
- **App Store rating prompt:** `requestReview()` triggered after 3rd successful search (non-SETAPP builds only).
- **Deep Search gating:** Free users see paywall with `.deepSearchRequiresPro` when toggling Deep Search.
- **Copy Answer:** Both `StreamingAnswerView` and `HistoryDetailView` have "Copy Answer" button (platform-aware iOS/macOS clipboard).
- **AppIconView:** New `UI/Components/AppIconView.swift` — centralized app icon display with parameterized size and responsive corner radius. Used in loading/empty states and onboarding.
- **History deep search indicators:** Purple badge and colored accent bar distinguish deep search vs normal queries. Source count shows "X of Y sources" when some were unused.
- **HistoryDetailView:** Sources split into "Sources" (used) and "More Results" (expandable, unused).
- **SourceCardView:** Improved truncation detection via `onGeometryChange`, `.scrollTransition` for opacity/scale.
- **SettingsView:** Locale-aware Contact Support URL (e.g., `/es/contact/` for Spanish).
- **ProSettingsSection:** Shows "X / 10" daily query usage display.
- **OnboardingView:** Streamlined with `AppIconView(size: 80)` and simplified feature rows.
- **macOS app icon:** Properly sized macOS icon assets added (16–512px).
