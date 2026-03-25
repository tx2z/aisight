# Testing: AISight Pro — StoreKit 2 IAP + Daily Query Limit

## Prerequisites

- Xcode 26+ with iOS 26.2 simulator
- StoreKit Configuration file (`Products.storekit`) set up in the scheme (see Setup below)
- No physical device required — all testing works in the simulator

## StoreKit Configuration Setup

1. In Xcode, go to **File > New > File** and choose **StoreKit Configuration File**
2. Save as `AISight/AISight/Resources/Products.storekit`
3. Add a product:
   - **Type:** Non-Consumable
   - **Product ID:** `com.aisight.pro`
   - **Reference Name:** AISight Pro
   - **Price:** $4.99
4. In the scheme editor (**Product > Scheme > Edit Scheme > Run > Options**), set **StoreKit Configuration** to `Products.storekit`

## Test Scenarios

### 1. Free Tier — Daily Limit Enforcement

**Steps:**
1. Launch the app (fresh install or reset daily counter — see Tips below)
2. Perform searches one at a time
3. After each search, note the counter in **Settings > AISight Pro** section shows `N / 20`

**Expected:**
- Searches 1–10 succeed normally
- On the 11th search attempt, a paywall sheet appears instead of searching
- The paywall shows "You've used all 10 free searches today"
- Dismissing the paywall returns to the search screen without searching

### 2. Query Limit Banner (≤ 5 remaining)

**Steps:**
1. Use 15 searches (or set `daily_queries_used` to 15 in UserDefaults — see Tips)
2. Return to the search empty state

**Expected:**
- A banner reading "5 searches remaining today" appears below the "Powered by Apple Intelligence" text
- The banner updates after each search (4, 3, 2, 1)
- At 0 remaining, the banner disappears (paywall takes over instead)

### 3. Purchase Flow (StoreKit Sandbox)

**Steps:**
1. Exhaust daily limit (or just open paywall from Settings)
2. Tap **"Unlock for $4.99"**
3. Approve the StoreKit sandbox purchase dialog

**Expected:**
- Purchase completes successfully
- Paywall auto-dismisses via `onChange(of: storeManager.isPro)`
- `isPro` is now `true` — unlimited searches work
- Settings shows "AISight Pro Active" with checkmark seal icon
- Search Server URL field becomes editable

### 4. Purchase Cancellation

**Steps:**
1. Open paywall
2. Tap "Unlock for $4.99"
3. Cancel the StoreKit dialog

**Expected:**
- Paywall remains open
- No error message shown
- User can retry or dismiss

### 5. Restore Purchases

**Steps:**
1. Complete a purchase (scenario 3)
2. Delete and reinstall the app (in simulator: delete app, rebuild)
3. Go to **Settings > AISight Pro** section
4. Tap **"Restore Purchases"**

**Expected:**
- Pro status is restored
- Settings updates to show "AISight Pro Active"
- Search Server URL becomes editable

**Negative test:**
1. Fresh install, no prior purchase
2. Tap "Restore Purchases"

**Expected:**
- Error message: "No previous purchase found."

### 6. Settings — Pro Section

**Free user:**
- Shows "Searches used today: N / 20"
- "Upgrade to AISight Pro" button opens paywall sheet
- "Restore Purchases" button available

**Pro user:**
- Shows "AISight Pro Active" label with accent-colored checkmark seal
- No upgrade or restore buttons

### 7. Search Server URL Gating

**Free user:**
- Search Server section shows disabled (grayed out) URL field with default URL
- Caption text: "Upgrade to AISight Pro to use a custom search server"
- No "Test Connection" or "Reset to Default" buttons

**Pro user:**
- URL field is editable
- "Test Connection" and "Reset to Default" buttons visible
- Full existing server configuration functionality works

### 8. Daily Counter Reset

**Steps:**
1. Use some searches (e.g., 5)
2. Change device date to the next day:
   - **Simulator:** Settings app > General > Date & Time > turn off "Set Automatically" > set to tomorrow
   - **Or:** Use the UserDefaults trick below to set `daily_queries_date` to yesterday
3. Return to the app and trigger a search

**Expected:**
- Counter resets to 0
- Settings shows "0 / 10"
- All 10 searches available again

### 9. Paywall UI

**Verify the paywall contains:**
- [ ] Navigation title "AISight Pro"
- [ ] Close button (top-left, cancellation placement)
- [ ] Star icon header
- [ ] "You've used all 10 free searches today" subtitle
- [ ] Three feature rows with icons:
  - Magnifying glass + "Unlimited searches"
  - Sparkle magnifying glass + "Deep Search"
  - Server rack + "Custom search server"
  - Gift + "Future features included"
- [ ] "Unlock for $4.99" prominent button
- [ ] "Restore Purchases" link
- [ ] "Or come back tomorrow" caption at bottom
- [ ] Scrollable if content overflows (small devices / large Dynamic Type)

### 10. Accessibility

- [ ] All text scales with Dynamic Type (no fixed font sizes)
- [ ] VoiceOver reads all elements meaningfully (buttons have labels, not just icons)
- [ ] Paywall is navigable with VoiceOver
- [ ] Banner view reads correctly ("N searches remaining today")

### 11. Pro Users Skip All Limits

**Steps:**
1. Purchase Pro
2. Search repeatedly (20+ times)

**Expected:**
- No paywall ever appears
- No banner shown (remaining = `.max`)
- `recordQuery()` is a no-op (daily counter stays at 0)
- Settings shows "AISight Pro Active" permanently

## Tips for Faster Testing

### Reset Daily Counter via Xcode

In the debugger console or by adding temporary code:

```swift
UserDefaults.standard.set(0, forKey: "daily_queries_used")
UserDefaults.standard.set("1970-01-01", forKey: "daily_queries_date")
```

### Set Counter Near Limit

To quickly test the banner (≤ 5) or paywall (≥ 20):

```swift
UserDefaults.standard.set(18, forKey: "daily_queries_used")  // 2 remaining
UserDefaults.standard.set(todayString, forKey: "daily_queries_date")
```

### StoreKit Transaction Manager

Xcode's **Debug > StoreKit > Manage Transactions** window lets you:
- View all sandbox transactions
- Delete transactions (to test restore flow)
- Simulate interrupted purchases
- Test "Ask to Buy" scenarios

### Simulate StoreKit Failures

In the StoreKit Configuration file editor:
- Enable **"Fail Transactions"** to test purchase error handling
- Enable **"Interrupted Purchases"** to test the pending state

## SETAPP Build Variant

To test the Setapp compile-time flag, use the Claude Code command:

```
/build ios setapp
/build mac setapp
/run ios setapp
/run mac setapp
```

Or build manually: pass `SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) SETAPP'` to xcodebuild.

**Expected:**
- `isPro` is `true` immediately on launch
- No StoreKit code executes (no transaction listener, no purchase/restore)
- Paywall never appears
- All Pro features unlocked
- Settings shows "AISight Pro Active"
- No "Restore Purchases" buttons visible anywhere

To switch back to the App Store build, just use `/build` or `/run` without `setapp`.

## Production Checklist

Before submitting to App Store:

- [ ] Product registered in App Store Connect with matching ID `com.aisight.pro`
- [ ] Price set to $4.99 (Tier 5) in all territories
- [ ] StoreKit Configuration file removed from scheme Run options (use production App Store)
- [ ] Test with TestFlight sandbox account
- [ ] Verify receipt validation works with Apple's production servers
- [ ] Screenshot paywall for App Store review notes
