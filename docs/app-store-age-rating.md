# App Store Age Rating Decisions

**App:** AISight Search
**Bundle ID:** com.tx2z.aisight
**Date:** 2026-03-25
**Calculated Rating:** 13+

## Rationale

AISight is a search/answer engine that fetches web content via SearXNG and synthesizes answers using on-device AI (Apple Intelligence). The app itself does not produce or host any mature content, but because it displays text from third-party web sources, some categories are marked "Infrequent" to honestly reflect that web results may occasionally contain such content. This is consistent with how other search apps (Google, DuckDuckGo, Perplexity) handle age ratings.

---

## Step 1: Features

| Feature | Answer | Why |
|---------|--------|-----|
| Parental Controls | No | App has no parental control features |
| Age Assurance | No | No age verification mechanism |
| Unrestricted Web Access | No | Users cannot freely browse the web; the app shows search results and AI-synthesized answers, not arbitrary web pages |
| User-Generated Content | No | No way for users to share or distribute content to other users |
| Messaging and Chat | No | No communication features between users |
| Advertising | No | No ads in the app |

## Step 2: Mature Themes

| Category | Answer | Why |
|----------|--------|-----|
| Profanity or Crude Humor | Infrequent | Web search results may occasionally contain profanity in source text |
| Horror/Fear Themes | Infrequent | News or web content could reference such topics |
| Alcohol, Tobacco, or Drug Use or References | Infrequent | Web results may reference these in news or informational content |

## Step 3: Medical or Wellness

| Category | Answer | Why |
|----------|--------|-----|
| Medical or Treatment Information | Infrequent | Users could search for medical topics and web results may contain health information |
| Health or Wellness Topics | No | The app itself does not provide health or lifestyle recommendations |

## Step 4: Sexuality or Nudity

| Category | Answer | Why |
|----------|--------|-----|
| Mature or Suggestive Themes | Infrequent | AI-synthesized text answers from web sources could reference mature topics |
| Sexual Content or Nudity | None | App displays text only, no images from web sources |
| Graphic Sexual Content and Nudity | None | No image content displayed; text answers are synthesized by on-device AI which has its own guardrails |

## Step 5: Violence

| Category | Answer | Why |
|----------|--------|-----|
| Cartoon or Fantasy Violence | None | Not applicable to a search/answer app |
| Realistic Violence | Infrequent | Web results may include news articles referencing real-world violence |
| Prolonged Graphic or Sadistic Realistic Violence | None | App shows text summaries, not graphic content |
| Guns or Other Weapons | Infrequent | News content in web results may reference weapons |

## Step 6: Chance-Based Activities

| Category | Answer | Why |
|----------|--------|-----|
| Simulated Gambling | None | No gambling features |
| Contests | None | No competition or ranking features |
| Gambling | No | No real-money wagering |
| Loot Boxes | No | No virtual item purchases |

## Step 7: Additional Information

| Setting | Answer | Why |
|---------|--------|-----|
| Age Categories Override | Not Applicable | 13+ calculated rating is appropriate |
| Age Suitability URL | (blank) | Not needed |

## Other App Store Compliance

| Question | Answer | Why |
|----------|--------|-----|
| App Encryption | None of the algorithms mentioned above | App only uses HTTPS via Apple's URLSession (OS-level encryption), no custom encryption |
| Content Rights | Yes, has necessary rights | App fetches and displays publicly available web content, similar to a browser or search engine |
