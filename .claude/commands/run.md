Build and run AISight.

**Arguments:** $ARGUMENTS

If arguments are provided, parse them:
- **Platform**: `mac` or `ios`
- **Distribution**: `setapp` or `appstore`

Examples: `/run ios`, `/run mac setapp`, `/run ios appstore`

If NO arguments are provided, ask the user interactively:
1. "Which platform?" → iOS or macOS
2. "Which distribution?" → App Store or Setapp

### Steps

1. Determine destination from platform:
   - `ios` → `'platform=iOS Simulator,name=iPhone 17 Pro'` (check available simulators first with `xcodebuild -showdestinations`)
   - `mac` → `'platform=macOS'`

2. Determine compilation conditions from distribution:
   - App Store → no extra flags
   - Setapp → add `SWIFT_ACTIVE_COMPILATION_CONDITIONS='$(inherited) SETAPP'`

3. For iOS: boot the simulator if needed:
   ```
   xcrun simctl boot "iPhone 17 Pro" 2>/dev/null; open -a Simulator
   ```

4. Run the build:
   ```
   xcodebuild -project AISight/AISight.xcodeproj -scheme AISight -destination '<destination>' [SETAPP flag if needed] build 2>&1 | tail -30
   ```

5. If build succeeded, launch the app:
   - iOS: `xcrun simctl launch booted com.aisight.app`
   - macOS: `open ~/Library/Developer/Xcode/DerivedData/AISight-*/Build/Products/Debug/AISight.app`

6. Report success or show errors.
