# AISight Manual Test Plan

This document provides a checklist for manually testing the AISight app. Run through these scenarios before each release to verify core functionality.

---

## 1. Happy Path — Factual Query End-to-End

- [ ] Launch the app and enter a simple factual query: **"What is the capital of France?"**
- [ ] Verify the loading indicator appears while searching
- [ ] Verify search results are fetched from SearXNG (source cards appear)
- [ ] Verify the on-device AI generates a streamed response mentioning "Paris"
- [ ] Verify the response completes without errors
- [ ] Verify the query is saved to history

**Expected result:** A clear, streamed answer stating Paris is the capital of France, with at least one citation linking to a source.

---

## 2. Multi-Source Citation Rendering

- [ ] Enter a query that produces multiple sources: **"What are the health benefits of green tea?"**
- [ ] Verify citation badges `[1]`, `[2]`, etc. appear inline within the answer text
- [ ] Verify each badge number corresponds to a source in the source list
- [ ] Tap a citation badge and verify it links to or highlights the correct source
- [ ] Verify at least 2 distinct sources are cited

**Expected result:** Inline citation badges render correctly, are numbered sequentially, and map to the listed sources.

---

## 3. Source Cards Display

- [ ] Run any query that returns results
- [ ] Verify source cards appear below or alongside the answer
- [ ] Verify each source card shows: title, URL/domain, and engine badge (e.g., Google, Bing, DuckDuckGo)
- [ ] Tap a source card and verify it opens the URL (in-app browser or Safari)
- [ ] Verify engine badges display the correct search engine name

**Expected result:** Source cards render with title, domain, and engine badge. Tapping opens the source URL.

---

## 4. SearXNG Server Unreachable

- [ ] Open Settings in the app
- [ ] Enter an invalid SearXNG URL: **`https://invalid.example.com`**
- [ ] Save the setting and run a query
- [ ] Verify a clear error message appears (not a crash or blank screen)
- [ ] Verify the error message indicates the search server could not be reached

**Expected result:** A user-facing error message explaining the search server is unreachable. No crash.

---

## 5. SearXNG URL Override in Settings

- [ ] Open Settings and note the current SearXNG URL
- [ ] Change the URL to a different valid SearXNG instance
- [ ] Run a query and verify results come back successfully
- [ ] Change the URL back to the original and verify queries still work

**Expected result:** The app uses the custom SearXNG URL for searches. Changing it takes effect immediately.

---

## 6. "Test Connection" Button

### 6a. Valid URL
- [ ] Open Settings and enter a valid SearXNG URL
- [ ] Tap "Test Connection"
- [ ] Verify a success indicator appears showing the server latency (e.g., "Connected - 120ms")

### 6b. Invalid URL
- [ ] Enter an invalid URL: **`https://not-a-real-server.example.com`**
- [ ] Tap "Test Connection"
- [ ] Verify an error message appears (e.g., "Connection failed")

### 6c. Timeout
- [ ] Enter a URL that will time out (e.g., a non-responsive server or `https://10.255.255.1`)
- [ ] Tap "Test Connection"
- [ ] Verify the button shows a loading state, then displays a timeout error

**Expected result:** Test Connection provides clear feedback for success (with latency), failure (with error), and timeout scenarios.

---

## 7. Snippet-Only vs Full Page Fetch

### 7a. Short snippets (snippet-only path)
- [ ] Enter a simple query where SearXNG snippets are sufficient: **"What year was the Eiffel Tower built?"**
- [ ] Verify the answer is generated quickly (no full page fetch needed)
- [ ] Verify the answer is accurate based on snippet content

### 7b. Long/complex query (full page fetch path)
- [ ] Enter a query requiring more context: **"Explain the differences between TCP and UDP protocols"**
- [ ] Verify the app fetches full page content from source URLs
- [ ] Verify the answer is more detailed than snippet-only responses
- [ ] Verify the loading time is slightly longer due to content fetching

**Expected result:** The app correctly chooses between snippet-only and full page fetch paths based on content length and query complexity.

---

## 8. Apple Intelligence Disabled

- [ ] On a supported device, disable Apple Intelligence in system Settings > Apple Intelligence & Siri
- [ ] Launch AISight and run a query
- [ ] Verify the app shows a clear error message indicating Apple Intelligence is required
- [ ] Verify the app does not crash

**Expected result:** A clear, non-technical error message telling the user to enable Apple Intelligence. No crash.

---

## 9. Offline / Airplane Mode

- [ ] Enable Airplane Mode on the device
- [ ] Launch AISight and run a query
- [ ] Verify an offline error message appears promptly (not after a long timeout)
- [ ] Verify the message clearly states internet connectivity is required
- [ ] Disable Airplane Mode and verify queries work again without restarting the app

**Expected result:** An immediate offline message. Recovery works without app restart.

---

## 10. History Persistence

- [ ] Run 3 different queries and note them
- [ ] Force-quit the app completely (swipe up from app switcher)
- [ ] Relaunch the app and navigate to History
- [ ] Verify all 3 queries appear in the history list in reverse chronological order
- [ ] Verify tapping a history entry shows the original answer

**Expected result:** History persists across app restarts via SwiftData. All queries and answers are preserved.

---

## 11. History Delete

### 11a. Single item delete
- [ ] Navigate to History with at least 2 entries
- [ ] Swipe left on one history entry
- [ ] Tap Delete
- [ ] Verify the entry is removed
- [ ] Verify other entries remain

### 11b. Clear all
- [ ] Navigate to History with at least 2 entries
- [ ] Tap the "Clear All" button
- [ ] Verify a confirmation prompt appears
- [ ] Confirm deletion
- [ ] Verify the history list is empty

**Expected result:** Single swipe-delete removes one entry. Clear All removes everything after confirmation.

---

## 12. Long Query / Context Overflow

- [ ] Enter an extremely long query (200+ words) or a topic that returns many large sources
- [ ] Verify the app does not crash
- [ ] Verify the AI still produces a response (possibly truncated or noting it could not process all content)
- [ ] Check that the response acknowledges limitations if context was truncated

**Expected result:** The app handles context overflow gracefully. No crash. The AI may produce a shorter answer or indicate truncation.

---

## 13. Non-English Query

- [ ] Open Settings and change the language to a non-English language (e.g., Spanish, French, Japanese)
- [ ] Enter a query in that language: e.g., **"Quelle est la population de Tokyo?"** (French)
- [ ] Verify SearXNG returns results in or relevant to that language
- [ ] Verify the AI response is in the same language as the query
- [ ] Verify citations still render correctly

**Expected result:** The app handles non-English queries. The AI responds in the query language. Citations work as expected.

---

## 14. Onboarding Flow

- [ ] Delete the app and reinstall (or reset via Settings/simulator)
- [ ] Launch the app for the first time
- [ ] Verify the onboarding screen appears
- [ ] Complete onboarding and verify it transitions to the main screen
- [ ] Force-quit and relaunch the app
- [ ] Verify onboarding does NOT appear again

**Expected result:** Onboarding shows only on first launch. Subsequent launches go straight to the main screen.

---

## 15. Dark Mode / Light Mode

- [ ] Set the device to Light Mode (Settings > Display & Brightness)
- [ ] Launch AISight and verify all screens are readable and properly styled
- [ ] Switch to Dark Mode
- [ ] Verify all screens adapt: text is legible, backgrounds are dark, no contrast issues
- [ ] Check: query input, answer view, source cards, settings, history, onboarding

**Expected result:** All UI elements adapt correctly to both Light and Dark mode. No illegible text or broken layouts.

---

## 16. Tab Bar Minimizes on Scroll

- [ ] Navigate to a screen with scrollable content (e.g., a long answer)
- [ ] Scroll down through the content
- [ ] Verify the tab bar minimizes or hides during scroll
- [ ] Scroll back to the top
- [ ] Verify the tab bar reappears

**Expected result:** The tab bar collapses on scroll down and reappears on scroll up, following standard iOS 26 behavior.

---

## Notes

- All tests should be run on a physical device with iPhone 15 Pro or newer (Apple Intelligence requires A17 Pro or later)
- Simulator testing is useful for layout checks but cannot test Apple Intelligence features
- Keep the SearXNG instance running and accessible during the full test pass
