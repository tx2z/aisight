# App Store Connect Metadata & ASO Guide — AISight

> **Purpose**: Complete reference for all App Store Connect fields, character limits, ASO best practices, and launch strategy.
> **Workflow**: Fill in English first, then localize to: DE, ES, FR, IT, JA, KO, PT, ZH.

---

## Table of Contents

1. [App Identity](#1-app-identity)
2. [Version-Level Metadata](#2-version-level-metadata)
3. [Visual Assets](#3-visual-assets)
4. [General App Information](#4-general-app-information)
5. [In-App Purchases](#5-in-app-purchases)
6. [Privacy & Compliance](#6-privacy--compliance)
7. [App Review Information](#7-app-review-information)
8. [ASO Cheat Sheet](#8-aso-cheat-sheet)
9. [Custom Product Pages & A/B Testing](#9-custom-product-pages--ab-testing)
10. [In-App Events](#10-in-app-events)
11. [Ratings & Reviews Strategy](#11-ratings--reviews-strategy)
12. [Localization Checklist](#12-localization-checklist)
13. [AISight-Specific Recommendations](#13-aisight-specific-recommendations)
14. [Launch Timeline](#14-launch-timeline)
15. [Quick Reference — Character Limits](#15-quick-reference--character-limits)

---

## 1. App Identity

These are set at the app level. **Can be changed with each version submission** (not permanently locked).

| Field | Char Limit | Localizable | Required | Needs New Version |
|-------|-----------|-------------|----------|-------------------|
| **App Name** | **30** | Yes | Yes | Yes |
| **Subtitle** | **30** | Yes | Yes | Yes |
| **Bundle ID** | N/A | No | Yes | Cannot change after first submission |
| **SKU** | N/A | No | Yes | Internal reference, not visible to users |
| **Primary Language** | N/A | No | Yes | Default language for your listing |

### ASO Tips — App Name (30 chars — highest ranking weight)
- **Brand name first**, then a keyword-rich descriptor separated by a dash or colon.
- Example: `AISight — AI Answer Engine` or `AISight: Search Smarter`
- Keywords in the name carry the **highest ranking weight** of any field.
- Don't repeat words already in the Subtitle or Keyword field — Apple combines them automatically.
- Avoid generic terms that won't differentiate you.
- Changing a well-established name resets some ASO equity — be deliberate.
- **Avoid**: trademark symbols, emoji, or special punctuation (dashes and colons are safe).

### ASO Tips — Subtitle (30 chars — second highest ranking weight)
- Use for **complementary keywords** not in the name.
- Focus on your core value proposition or differentiator.
- Example: `Private On-Device AI Search`
- This appears in search results directly below the name — it's your elevator pitch.
- A/B test different subtitles across versions to optimize tap-through rate.

---

## 2. Version-Level Metadata

Updated with each new version submission (except Promotional Text, which can be changed anytime).

| Field | Char Limit | Localizable | Required | Needs New Version | Notes |
|-------|-----------|-------------|----------|-------------------|-------|
| **Keywords** | **100** | Yes | Yes | Yes | Comma-separated. Hidden from users. No spaces after commas. |
| **Description** | **4,000** | Yes | Yes | Yes | NOT indexed by Apple for search. Conversion-focused. |
| **Promotional Text** | **170** | Yes | No | **No** (update anytime) | Appears above description. No review needed. |
| **What's New** | **4,000** | Yes | Yes (on update) | Yes | Release notes shown on Updates tab. |
| **Support URL** | URL | Yes | Yes | Yes | Must be a working URL. |
| **Marketing URL** | URL | Yes | No | Yes | Optional link to your marketing site. |
| **Copyright** | No strict limit | No | Yes | Yes | Format: `© 2026 Legal Entity Name` (must match developer account). |
| **Version Number** | N/A | No | Yes | Yes | Semantic versioning: `1.0.0` |
| **Build** | N/A | No | Yes | Yes | Must be unique per upload. |

### ASO Tips — Keywords Field (100 chars)
- **Most underestimated field**. Every character matters.
- Separate with commas, **no spaces** after commas (saves characters).
- **Never repeat** words already in the App Name or Subtitle — Apple automatically combines all three fields.
- Use **singular forms** only (Apple matches plurals automatically).
- Avoid: prepositions, articles, the word "app", your own app name, category name.
- Don't include competitor trademarked names (Apple may reject or pull the app).
- **Strategic example for AISight:**
  ```
  alternative,perplexity,private,answer,engine,source,citation,on-device,no-tracking,browse,query,intelligence,web
  ```
  (Note: "alternative" is a high-intent keyword; includes competitor for discoverability; drops vanity adjectives like "smart" or "fast")
- **Free keyword research hack**: Create an Apple Search Ads account (free) to access Apple's keyword popularity scores (1-100 scale).
- **Advanced — Locale backfill indexing**: Apple indexes keywords from certain secondary locales even for your primary market. For example, en-GB and en-AU keyword fields are also indexed for US App Store searches. This gives you bonus keyword slots.

### ASO Tips — Description (4,000 chars)
- **Apple does NOT index the description** for search ranking. It's purely for **conversion**.
- **Above-the-fold (~167 chars on iPhone)**: Only the first 3 lines are visible before "More" — this is your highest-leverage text.

#### Recommended Framework: PAS (Problem-Agitate-Solve)
For a privacy-focused app, PAS is the most effective copywriting structure:

1. **Problem** (first 2 lines): "Tired of search engines that track every query and bury answers in ads?"
2. **Agitate**: "Your search history is sold to advertisers. AI assistants send your questions to remote servers."
3. **Solve**: "AISight searches the web and generates answers entirely on your device using Apple Intelligence. No cloud. No tracking."

#### Full Description Structure
1. **Hook** (first 3 lines, ~167 chars): Core value proposition. This must work standalone.
2. **Key Features** (bullet list): Use Unicode bullets (●, ▸). Lead with benefits, not features.
3. **How It Works** (brief): 2-3 sentences.
4. **Privacy/Trust Statement**: Critical for a search app.
5. **Freemium Disclosure**: Clearly explain free vs. Pro tiers (Apple requires this per Guideline 3.1.1).
6. **Social Proof**: Awards, press mentions, milestones.
7. **Closing CTA**: "Download AISight and search privately today."

- Use line breaks and short paragraphs for scannability.
- **Do not keyword-stuff** — hurts conversion without helping ranking.

### ASO Tips — Promotional Text (170 chars)
- **Can be updated anytime without a new app version or review** — your most agile marketing lever.
- Not indexed for search — purely conversion-focused.
- Appears **above** the description in bold.

#### Rotation Templates
- **Launch**: `NEW: The answer engine that never leaves your device. Private AI search powered by Apple Intelligence.`
- **Feature update**: `NEW in v1.1: Deep Search with expanded sources. Your data still never leaves your device.`
- **Milestone**: `10,000 questions answered privately. Join the movement.`
- **Seasonal**: `New year, new search engine. Start 2027 without trackers watching every query.`

### ASO Tips — What's New (4,000 chars)
- Users see this on the Updates tab — it affects **update conversion**.
- **Lead with the most exciting change** — users scan the first line and decide whether to read further.
- Apply the **"So what?" test**: Not "Added new animation" but "Search results now load with smooth animations so you can start reading faster."
- Use bullet points for scannability.
- **Personality matters**: Conversational tone in release notes builds loyalty (see Bear, Carrot Weather, Overcast).
- Include a **forward-looking hook**: "Coming next: multi-language search" builds anticipation.
- Don't just say "Bug fixes and improvements" — list actual changes.
- First ~3-4 lines are visible before truncation. Front-load the most compelling change.

---

## 3. Visual Assets

### Screenshots

| Device | Required Size (px) | Orientation | Min | Max |
|--------|-------------------|-------------|-----|-----|
| **iPhone 6.9"** (mandatory) | 1290 x 2796 | Portrait | 1 | 10 |
| **iPhone 6.9"** (mandatory) | 2796 x 1290 | Landscape | 1 | 10 |
| **iPad 13"** (mandatory if universal app) | 2064 x 2752 | Portrait | 1 | 10 |
| **iPad 13"** (mandatory if universal app) | 2752 x 2064 | Landscape | 1 | 10 |
| **Mac** (required for Mac App Store) | varies | — | 1 | 10 |

- **Format**: PNG (recommended for sharpness) or JPEG.
- **Auto-scaling**: Apple scales the 6.9" screenshots down to 6.7", 6.1", 5.5" etc.
- **Localizable**: Yes — provide different screenshots per language.
- **Mac screenshots**: Since AISight targets macOS 26, Mac App Store screenshots are **required** separately.

#### ASO Tips — Screenshots
- **First 3 screenshots** are visible in search results — they determine tap-through rate.
- Screenshot 1 should communicate your **#1 value proposition** immediately.

**Caption/overlay best practices:**
- **Headline formula**: [Outcome verb] + [what user gets] — e.g., "Get answers, not links" (NOT "AI-powered search engine").
- Large benefit headline: **5-7 words max**, minimum ~60pt font at 1290px width (must be legible as a thumbnail in search results).
- Optional smaller subtext under 15 words.
- Device frame showing the app in action with real content, not empty states.

**Recommended screenshot sequence for AISight:**
1. "Ask anything. Get real answers." — query with streamed AI answer + citations
2. "Your search never leaves your device." — privacy/on-device badge
3. "Real sources, not hallucinations." — cited sources with domain cards
4. "No account. No subscription. No tracking." — clean, ad-free UI
5. "Powered by Apple Intelligence." — Apple Intelligence branding

- Use consistent visual style across all screenshots.
- Consider a **panoramic/continuous design** that flows across the first 3.
- **Test via Product Page Optimization** (see Section 9).

**Localization note**: In Japan, information-dense screenshots with more text outperform minimal Western style. In Korea, character/mascot-driven designs perform well. Adapt per market.

### App Previews (Videos)

| Spec | Requirement |
|------|------------|
| **Duration** | 15–30 seconds |
| **Max per localization** | 3 videos |
| **Max file size** | 500 MB |
| **Format** | .mov, .mp4, .m4v |
| **Codec** | H.264 or ProRes 422 (HQ) |
| **Audio** | AAC |
| **Resolution** | Must match device display resolution |
| **Content** | Primarily screen recordings. Hands interacting with device are allowed if focus is on the app. No unrelated live-action footage. |

#### ASO Tips — App Previews
- Videos **autoplay muted** in search results — use text overlays (no reliance on audio).
- Show the most impressive feature in the **first 5 seconds** (also serves as poster frame).
- A good preview can increase conversion by 20-30%.
- Show 2-3 key features max — don't overload.
- If you use in-app purchases or subscriptions, you must disclose this.

### App Icon

| Spec | Requirement |
|------|------------|
| **Size** | 1024 x 1024 px |
| **Format** | PNG |
| **Shape** | Square (Apple applies corner radius) |
| **Transparency** | Not allowed |
| **Layers** | Flat, no alpha channel |

- Keep it simple — legible at 29px on the home screen.
- Use distinct, contrasting colors. No photos or excessive detail.
- Icon should communicate "search" or "AI" at a glance without text.
- Test icon variants via **Product Page Optimization** (Section 9).

---

## 4. General App Information

| Field | Notes |
|-------|-------|
| **Primary Category** | Choose the most relevant. Affects browse/chart rankings. |
| **Secondary Category** | Optional but recommended. Second chart to appear in. |
| **Content Rights** | Declare if your app contains third-party content. |
| **Age Rating** | Questionnaire-based. Standard tiers: **4+, 9+, 12+, 17+**. |
| **Price / Pricing Schedule** | Free, paid, or freemium with IAPs. |
| **Availability** | Select territories (default: all 175). |
| **App Clips** (optional) | Separate metadata if applicable. |

### Age Rating Questionnaire (Updated 2025)
Must be completed by **January 31, 2026**. New questions cover:
- In-app controls (parental tools)
- Capabilities (chat, web access, **AI-generated content**)
- Medical/wellness topics
- Violent themes

Standard App Store tiers: **4+, 9+, 12+, 17+**.

> **AISight will almost certainly be 17+**: Unrestricted web access = automatic 17+ in the questionnaire. AI-generated content from arbitrary web sources adds another 17+ trigger. No content filtering exists in the codebase. Accept 17+ and plan marketing accordingly, or implement SafeSearch/content filtering before submission.

### Category Selection Tips
- **Primary recommendation for AISight**: `Reference` — less competitive than Utilities, natural fit for an answer engine.
- **Secondary**: `Productivity`
- "Utilities" is extremely competitive. "Reference" may yield higher chart rankings with fewer downloads.
- Category changes require a new version submission.

---

## 5. In-App Purchases

AISight has a non-consumable IAP (`com.aisight.pro`) that unlocks Pro features (unlimited queries, deep search) on the default server. Users who configure their own SearXNG server get all features for free.

### IAP Metadata Fields in App Store Connect

| Field | Required | Notes |
|-------|----------|-------|
| **Reference Name** | Yes | Internal name (e.g., "AISight Pro Unlock"). Not visible to users. |
| **Product ID** | Yes | `com.aisight.pro` — must match StoreKit configuration. |
| **Type** | Yes | Non-consumable. |
| **Price Tier** | Yes | Select from Apple's price tiers. |
| **Display Name** | Yes | User-visible. **Indexed for ASO** (low weight). Localizable. |
| **Description** | Yes | User-visible. Explain what the purchase unlocks. Localizable. |
| **Review Screenshot** | Yes | Screenshot of the purchase flow for Apple review. |
| **Family Sharing** | Optional | Whether to enable Family Sharing for the IAP. |

### Compliance Notes
- **Guideline 3.1.1**: All digital features must use Apple's IAP system (already done via StoreKit).
- **Description must disclose freemium model**: Clearly explain free tier (10 queries/day), Pro tier, and self-hosted server option in the App Store description.
- IAP display names are indexed — use relevant keywords.

---

## 6. Privacy & Compliance

| Field | Required | Notes |
|-------|----------|-------|
| **Privacy Policy URL** | Yes | Must be publicly accessible (not behind login). Must clearly explain data collection. |
| **App Privacy (Nutrition Labels)** | Yes | Declare ALL data types collected, even if not shared. |
| **Data Collection Types** | Yes | Contact info, location, identifiers, usage data, etc. |
| **Tracking Declaration** | Yes | Whether you use ATT / IDFA for tracking. |
| **Export Compliance (Encryption)** | Yes | Must answer questionnaire or provide ERN. |
| **Terms of Use / EULA** | Recommended | Apple provides a default EULA. Custom EULA optional for apps with IAP. |

### For AISight Specifically

**Privacy Nutrition Labels — Critical Nuance:**
- Search queries are sent to a network server (SearXNG instance). Even though it's "self-hosted," **data leaves the device over the network**.
- Apple requires you to declare **"Usage Data > Search History"** at minimum.
- To claim "No Data Collected": You must argue that queries sent to a user-configured server they control don't constitute data collection *by the developer*. This is defensible but risky — prepare a justification in Notes for Review.
- **Guideline 2.3.7**: Apple cross-references privacy labels with description and actual app behavior. Inconsistency = rejection. Do not claim "No Data Collected" if the description mentions connecting to a search server.

**Export Compliance (Encryption):**
- AISight uses only HTTPS via `URLSession` (no custom encryption).
- Qualifies for exemption under Category 5, Part 2 of the EAR.
- **Add `ITSAppUsesNonExemptEncryption = NO`** to Info.plist to skip this question on every submission.

**Tracking:**
- No third-party analytics, no ads, no IDFA = declare "No" for tracking.

---

## 7. App Review Information

| Field | Required | Visible to Users | Notes |
|-------|----------|-----------------|-------|
| **Contact First Name** | Yes | No | For Apple review team only. |
| **Contact Last Name** | Yes | No | For Apple review team only. |
| **Contact Phone** | Yes | No | Must be reachable — Apple may call during review. |
| **Contact Email** | Yes | No | Must be reachable. |
| **Demo Account** | If login required | No | AISight has no login — not needed. |
| **Notes for Review** | No (highly recommended) | No | Explain non-obvious behavior to prevent rejection. |

### Recommended Notes for Review — AISight Template

> "AISight uses Apple's FoundationModels framework (Apple Intelligence) to generate answers on-device. No data is sent to third-party AI services.
>
> Web search results are fetched from a self-hosted SearXNG instance (open-source metasearch engine) at a user-configured URL. A default URL (search.private-search-intelligence.app) is pre-configured and functional for testing.
>
> No user account is required. The app requires a device that supports Apple Intelligence (iPhone 16+, iPad with M-series, Mac with M-series) running iOS 26.0 / macOS 26.0 or later.
>
> Free tier: 10 searches per day. Pro unlock (non-consumable IAP) removes this limit and enables Deep Search."

### Common Rejection Risks for AISight
1. **Guideline 4.2 (Minimum Functionality)**: AI-powered search apps wrapping a search API + LLM can be rejected. Emphasize unique features: on-device AI, privacy, Deep Search, citation system, history.
2. **Guideline 5.1.1(v) (Account Sign-In)**: The SearXNG URL configuration is effectively a "server setup." The default URL **must work out of the box** during review.
3. **Privacy label mismatch**: Most likely rejection reason. Ensure labels match actual network behavior.
4. **Apple Intelligence unavailability**: What happens if the reviewer's device doesn't support Apple Intelligence? The app must degrade gracefully.
5. **SearXNG unreachable**: What happens if the server is down during review? Handle gracefully, don't crash.

---

## 8. ASO Cheat Sheet

### Indexed Fields (Affect Search Ranking)

| Field | Weight | Char Limit |
|-------|--------|-----------|
| App Name | Highest | 30 |
| Subtitle | High | 30 |
| Keywords | High | 100 |
| IAP display names | Low | — |
| Developer name | Low | — |

> **Total indexable characters: 160** (30 + 30 + 100). Every character counts.
> **Advanced**: Locale backfill can give you bonus keyword slots (en-GB, en-AU indexed for US market).

### Non-Indexed Fields (Affect Conversion Only)

| Field | Purpose |
|-------|---------|
| Description | Convince users to download |
| Promotional Text | Time-sensitive announcements (no review needed) |
| What's New | Encourage updates |
| Screenshots | Visual conversion (#1 conversion factor) |
| App Previews | Video conversion |
| Ratings & Reviews | Social proof (organic) |

### Keyword Strategy Rules
1. **Never duplicate** words across Name, Subtitle, and Keywords fields.
2. Use **singular** forms — Apple matches plurals.
3. **No spaces** after commas in keyword field.
4. Avoid: "app", "free", prepositions, articles, your app name, category name.
5. Target **long-tail keywords** for less competition.
6. Update keywords **every 4-6 weeks** based on performance data.
7. Use Apple Search Ads keyword popularity scores for research (free with an account).
8. **Locale backfill**: Fill en-GB and en-AU keyword fields even if you only target US — they're indexed for the US market too.

### Conversion Optimization
1. **Screenshots > Description** for conversion impact. Invest design time here.
2. Ratings above **4.0** are critical — below 3.5 is an emergency.
3. App Preview videos can boost conversion **20-30%**.
4. Promotional text is your **most agile** conversion tool (no review needed).
5. **"No Data Collected"** privacy label is a competitive differentiator for search apps.

### Search Ads Integration
- Apple Search Ads (ASA) uses the same keyword index. Your ASO keyword strategy directly affects paid acquisition costs.
- **ASA Basic** ($5/day budget): Apple picks keywords, you set a CPI target. Cheapest paid acquisition channel.
- Use ASA impression share data to find keywords you rank for but don't convert on — then improve screenshots/subtitle for those terms.

---

## 9. Custom Product Pages & A/B Testing

### Custom Product Pages (CPPs)
Apple allows up to **35 Custom Product Pages** per app. Each has its own:
- Screenshots
- App Previews
- Promotional text

**Use cases for AISight:**
- **Privacy-focused CPP**: Linked from privacy subreddits, DuckDuckGo forums, privacy blogs. Lead with "No tracking, no cloud" messaging.
- **AI-focused CPP**: Linked from AI/tech communities. Lead with "On-device AI search" messaging.
- **Apple ecosystem CPP**: Lead with "Powered by Apple Intelligence" for Apple-centric audiences.

CPPs can be linked to specific ad campaigns, web URLs, or marketing channels. Track conversion per page.

### Product Page Optimization (PPO) — A/B Testing
Apple's native A/B testing for the **default** product page:
- Test up to **3 treatments** against your default.
- Testable elements: **icon, screenshots, app preview videos**.
- Free, runs inside App Store Connect.

**Recommended test sequence:**
1. **First test** (post-launch): Screenshot order — highest conversion impact.
2. **Second test**: Privacy-first vs. AI-first messaging in screenshot 1.
3. **Third test**: Icon variants.

---

## 10. In-App Events

Apple's In-App Events appear in search results, editorial, the Today tab, and your product page. They are **free visibility**.

| Spec | Requirement |
|------|------------|
| **Event name** | 30 chars |
| **Short description** | 50 chars |
| **Long description** | 120 chars |
| **Event card image** | Required (various sizes) |
| **Duration** | Up to 31 days |
| **Max active events** | 5 |

**Event ideas for AISight:**
- "Privacy Week: 7 days of tracker-free searching"
- "New Language Support: Now answering in Japanese"
- "Apple Intelligence Showcase: See on-device AI in action"

In-App Events are indexed and can drive significant organic traffic.

---

## 11. Ratings & Reviews Strategy

For a new app with zero reviews, this is **existential**. A real strategy is required.

### SKStoreReviewController Timing
- **Apple limits**: 3 prompts per 365-day period per device. Make each count.
- **When to prompt**: After the user's **3rd-5th successful search** (proven engagement, likely satisfied). Or after tapping a "helpful" indicator on an answer.
- **Never prompt**: On first launch, during onboarding, after errors, immediately after backgrounding.
- **Spacing**: Minimum 60 days between prompts. Track last prompt date in UserDefaults.

### Pre-Launch
- Enroll **TestFlight beta testers** and ask them to leave a review on day one. Even 5-10 reviews gives social proof that compounds.

### Responding to Reviews
- **Respond to every review** in App Store Connect, especially negatives.
- Visible to all users — signals active, responsive development.
- Professional, helpful tone. Address specific concerns. Thank positive reviewers.

### Rating Recovery
- Apps below **4.0** see significant conversion drops. Below **3.5** is critical.
- Consider a **rating reset** when shipping a major update (available in App Store Connect).

---

## 12. Localization Checklist

AISight supports 9 languages. Each needs its own set of localized metadata.

| Language | Code | Locale | Market Notes |
|----------|------|--------|-------------|
| English | en | en-US | Primary market. Also fill en-GB, en-AU for keyword backfill. |
| German | de | de-DE | Compound words save keyword chars but eat name/subtitle chars. |
| Spanish | es | es-MX (priority) | Latin America is larger mobile market than Spain. |
| French | fr | fr-FR | — |
| Italian | it | it-IT | — |
| Japanese | ja | ja-JP | Users search in katakana, hiragana, AND romaji. Cover all forms. |
| Korean | ko | ko-KR | Compound words without spaces are common search terms. |
| Portuguese | pt | pt-BR (priority) | Brazil is top-5 global mobile market. |
| Chinese (Simplified) | zh | zh-Hans | 2-char terms replace 15-char English phrases — max keyword density. |

### Fields to Localize Per Language

- [ ] App Name (30 chars)
- [ ] Subtitle (30 chars)
- [ ] Keywords (100 chars) — **research keywords per locale, don't just translate!**
- [ ] Description (4,000 chars)
- [ ] Promotional Text (170 chars)
- [ ] What's New (4,000 chars)
- [ ] Screenshots (with localized text overlays)
- [ ] App Preview videos (if applicable)
- [ ] IAP Display Name and Description
- [ ] Support URL (locale-specific if available)
- [ ] Marketing URL (locale-specific if available)

### Localization ASO Tips
- **Don't just translate keywords** — research what users actually search in each language.
- **Japanese**: "AI" might be searched as "AI", "エーアイ", or "人工知能". Include all forms in the keyword field.
- **Korean**: Spacing rules differ; compound words without spaces are common search terms.
- **Chinese**: A single 2-character term can replace a 15-character English phrase. Exploit this for maximum keyword density in 100 characters.
- **German**: Compound words cut both ways — "Privatsuchmaschine" (private search engine) is one keyword, not three. But they eat name/subtitle chars fast.
- **Portuguese**: pt-BR vs pt-PT have different keyword rankings. Prioritize pt-BR (Brazil is massive).
- **Spanish**: es-MX vs es-ES have divergent search behavior. Latin American markets are significantly larger.
- **Screenshot adaptation**: Japan prefers information-dense screenshots with more text. Korea responds well to character/mascot-driven designs. Adapt per market.

### Automation Tip
For 9 localizations, consider using the **App Store Connect API** or **Fastlane Deliver** to manage metadata programmatically rather than manual entry.

---

## 13. AISight-Specific Recommendations

### Competitive Positioning — Lead With These Angles

**1. "No cloud AI, no data leaves your device"** — Nuclear differentiator.
Every competitor (Perplexity, ChatGPT, Arc Search, Google AI Overviews) sends queries to their servers. AISight does not. Lead every piece of copy with this.

**2. "No account required"** — Zero-friction onboarding.
Most AI tools require sign-up. This removes the biggest conversion barrier.

**3. "One-time purchase, not a subscription"** — Price advantage.
Perplexity is $20/mo. ChatGPT Plus is $20/mo. AISight Pro is a one-time purchase.

**4. "Powered by Apple Intelligence"** — Native platform citizen.
Positions AISight as part of the Apple ecosystem, not a wrapper around OpenAI.

**5. Anti-positioning** — Define what AISight is NOT.
"Not another chatbot. Not another browser. A search engine that actually answers your question — privately."

### Category Strategy
- **Primary**: `Reference` — less competitive, natural fit for an answer engine.
- **Secondary**: `Productivity`
- Test rankings in both and adjust post-launch.

### Age Rating
- AISight will be **17+** due to unrestricted web access and AI-generated content from arbitrary web sources.
- No content filtering in the codebase. Accept 17+ and plan accordingly.
- To potentially lower this: implement SafeSearch / content filtering and document it in Notes for Review.

### Privacy Labels
- Be careful with "No Data Collected" claim — search queries do leave the device (to SearXNG server).
- Safest approach: Declare "Usage Data > Search History" with "Data Not Linked to You" and "Data Not Used to Track You".
- This is still a strong privacy story — much better than competitors.

### Apple Featuring Strategy
AISight is an ideal candidate for Apple featuring because it:
- Uses FoundationModels (Apple Intelligence) — Apple's own AI framework
- Has zero external dependencies
- Uses liquid glass UI (iOS 26 design language)
- Has strong privacy story

**Actions:**
- Submit a **self-nomination** via the Apple Developer App Store Feature Request Form, 6-8 weeks before launch.
- Prepare **2732x2048 promotional artwork** for featured placements.
- Mention "Built with Apple Intelligence" and "On-device AI" explicitly.
- Time launch around Apple Intelligence announcements or iOS 26 public release for maximum editorial attention.

---

## 14. Launch Timeline

| When | Action |
|------|--------|
| **T-8 weeks** | Submit Apple feature nomination. Start TestFlight beta. Begin ASO keyword research. |
| **T-4 weeks** | Finalize all metadata, screenshots, previews. Set up Apple Search Ads account (free keyword data). |
| **T-2 weeks** | Localize all metadata (9 languages). Prepare press kit / landing page. |
| **T-1 week** | Submit for review with **"Manual Release"** selected. Prepare launch-day posts. |
| **T-0 (Launch Day)** | Release the app (**Tuesday or Wednesday** — best for editorial attention). Post on Hacker News, Product Hunt, Reddit (/r/apple, /r/privacy, /r/artificial). Update promotional text. Email beta testers asking for reviews. |
| **T+1 week** | Respond to all reviews. Check keyword rankings. Adjust promotional text. Run first PPO test. |
| **T+2 weeks** | Start Apple Search Ads Basic ($5/day). Analyze impression share data. |
| **T+4 weeks** | First keyword iteration based on Search Ads data. Ship first update with "What's New". |
| **Ongoing** | Ship updates every 2-4 weeks. Regular updates signal to Apple's algorithm that the app is actively maintained. Each update = opportunity to refresh keywords. |

### Timing Tips
- **Best launch days**: Tuesday or Wednesday. Apple editorial picks early in the week.
- **Avoid**: WWDC week, iPhone launch week, mid-December holiday period. Store is flooded.
- **Best timing for AISight**: Align with Apple Intelligence announcements or iOS 26 public release.

---

## 15. Quick Reference — Character Limits

| Field | Limit | Indexed | Localizable | Needs Version Update |
|-------|-------|---------|-------------|---------------------|
| App Name | 30 | Yes (highest) | Yes | Yes |
| Subtitle | 30 | Yes (high) | Yes | Yes |
| Keywords | 100 | Yes (high) | Yes | Yes |
| Promotional Text | 170 | No | Yes | **No** |
| Description | 4,000 | No | Yes | Yes |
| What's New | 4,000 | No | Yes | Yes |
| Copyright | No strict limit | No | No | Yes |
| IAP Display Name | — | Yes (low) | Yes | Yes |
| In-App Event Name | 30 | Yes | Yes | N/A |
| In-App Event Short Desc | 50 | — | Yes | N/A |
| In-App Event Long Desc | 120 | — | Yes | N/A |

---

*Sources: [Apple Developer — Platform Version Info](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/), [Apple Developer — Screenshot Specs](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/), [Apple Developer — App Previews](https://developer.apple.com/app-store/app-previews/), [Apple Developer — Age Ratings](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/), [Apple Developer — Creating Your Product Page](https://developer.apple.com/app-store/product-page/), [SplitMetrics — App Store Description Guide](https://splitmetrics.com/blog/app-store-description-guide/), [AppRadar — Apple ASO Guide](https://appradar.com/academy/apple-app-store-optimization-aso), [ASO Mobile — Promotional Text](https://asomobile.net/en/blog/app-store-promotional-text-and-aso-small-field-big-impact/), [MobileAction — App Store vs Play Store 2026](https://www.mobileaction.co/blog/app-store-vs-play-store/), [AppTweak — ASO Guide 2026](https://www.apptweak.com/en/aso-blog/what-is-app-store-optimization-and-why-is-aso-important)*
