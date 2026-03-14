Build AISight.

**Arguments:** $ARGUMENTS

If arguments are provided, parse them:
- **Platform**: `mac` or `ios`
- **Distribution**: `setapp` or `appstore`

Examples: `/build ios`, `/build mac setapp`, `/build ios appstore`

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

3. Run the build:
   ```
   xcodebuild -project AISight/AISight.xcodeproj -scheme AISight -destination '<destination>' [SETAPP flag if needed] build 2>&1 | tail -30
   ```

4. Report BUILD SUCCEEDED or show the errors if it failed.
