# Manual Test Plan

Run through these 21 scenarios before each release. All tests require a physical device with iPhone 15 Pro+ and Apple Intelligence enabled unless noted otherwise.

---

## 1. Happy Path — Factual Query

**Steps:** Enter "What is the capital of France?" → wait for results.

**Expected:** Loading indicator appears. Source cards show. Streamed answer mentions "Paris" with at least one citation. Query saved to history.

---

## 2. Multi-Source Citation Rendering

**Steps:** Enter "What are the health benefits of green tea?"

**Expected:** Answer contains inline `[1]`, `[2]` badges. Each badge number maps to a source in the list. At least 2 distinct sources cited.

---

## 3. Source Cards Display

**Steps:** Run any query that returns results.

**Expected:** Source cards show title, domain, and engine badge. Tapping a card opens the URL. Engine badges display correct names.

---

## 4. SearXNG Server Unreachable

**Steps:** Set SearXNG URL to `https://invalid.example.com` in Settings. Run a query.

**Expected:** Clear error message about search server being unreachable. No crash.

---

## 5. SearXNG URL Override

**Steps:** Change SearXNG URL to a different valid instance. Run a query. Change back.

**Expected:** App uses the custom URL immediately. Switching back works without issues.

---

## 6. Test Connection Button

**6a — Valid URL:** Enter valid URL → tap Test Connection.
**Expected:** Success indicator with latency (e.g., "Connected - 120ms").

**6b — Invalid URL:** Enter `https://not-a-real-server.example.com` → tap Test Connection.
**Expected:** Error message (e.g., "Connection failed").

**6c — Timeout:** Enter non-responsive address → tap Test Connection.
**Expected:** Loading state, then timeout error.

---

## 7. Snippet-Only vs Full Page Fetch

**7a — Short query:** "What year was the Eiffel Tower built?"
**Expected:** Quick answer from snippets.

**7b — Complex query:** "Explain the differences between TCP and UDP protocols"
**Expected:** Longer answer with more detail from full page content.

---

## 8. Apple Intelligence Disabled

**Steps:** Disable Apple Intelligence in system Settings. Launch app and query.

**Expected:** Clear error message about Apple Intelligence requirement. No crash.

---

## 9. Offline / Airplane Mode

**Steps:** Enable Airplane Mode. Run a query.

**Expected:** Immediate offline message. Disable Airplane Mode → queries work without restart.

---

## 10. History Persistence

**Steps:** Run 3 queries. Force-quit app. Relaunch → History tab.

**Expected:** All 3 queries appear in reverse chronological order. Tapping shows original answer.

---

## 11. History Delete

**11a — Single:** Swipe left on one entry → Delete.
**Expected:** Entry removed, others remain.

**11b — Clear All:** Tap Clear All → Confirm.
**Expected:** Confirmation prompt. After confirming, history list empty.

---

## 12. Long Query / Context Overflow

**Steps:** Enter a 200+ word query.

**Expected:** No crash. AI produces a response (possibly shorter or noting limitations).

---

## 13. Non-English Query

**Steps:** Change language in Settings. Enter query in that language (e.g., "Quelle est la population de Tokyo?").

**Expected:** Results relevant to that language. AI responds in the query language. Citations work.

---

## 14. Onboarding Flow

**Steps:** Delete and reinstall app. Launch.

**Expected:** Onboarding appears on first launch. After completing, main screen shows. Second launch skips onboarding.

---

## 15. Dark Mode / Light Mode

**Steps:** Switch between Light and Dark mode in device Settings.

**Expected:** All screens adapt correctly. Text legible, no contrast issues. Check: search, answer, source cards, settings, history, onboarding.

---

## 16. Tab Bar Scroll Behavior

**Steps:** Navigate to scrollable content. Scroll down, then back up.

**Expected:** Tab bar minimizes on scroll down, reappears on scroll up (standard iOS 26 behavior).

---

## 17. Custom Server — Feature Unlock

**Steps:** Enter a valid custom SearXNG URL → tap "Activate and Test" → wait for success.

**Expected:** "Connected (Xms)" shown. ProSettingsSection shows "All features unlocked" + "Using your own search server". Deep Search toggle no longer shows "PRO" badge. Daily search counter hidden. "Use Default Server" button visible.

---

## 18. Custom Server — Failed Connection

**Steps:** Enter an invalid URL (e.g., `https://not-real.example.com`) → tap "Activate and Test".

**Expected:** "Connection failed. Server not activated." shown. Previous server URL restored. Features NOT unlocked. No state change.

---

## 19. Custom Server — Reset to Default

**Steps:** After activating a custom server → tap "Use Default Server".

**Expected:** URL resets to default. Daily limit re-activates. ProSettingsSection shows upgrade prompt again. Deep Search shows "PRO" badge.

---

## 20. Custom Server — Unlimited Searches

**Steps:** Activate a custom server → perform 15+ searches.

**Expected:** No daily limit warning. No paywall shown. All searches succeed. Counter stays at 0.

---

## 21. Support Purchase (Custom Server User)

**Steps:** With custom server active → tap "Support AISight — Get Pro" in Settings.

**Expected:** Paywall opens with "Or use your own SearXNG server" messaging. Can purchase or dismiss. Features remain unlocked regardless.

---

## Testing Notes

- **Physical device required** for scenarios involving Apple Intelligence (all except layout tests)
- **Simulator** useful for layout checks, dark/light mode, navigation flow
- **Keep SearXNG running** during the full test pass
- See `AISight/TESTING.md` for the original detailed test plan
