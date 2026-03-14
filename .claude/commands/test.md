Run AISight unit tests.

**Arguments:** $ARGUMENTS

If arguments are provided, parse them:
- **Platform**: `mac` or `ios`
- **Test filter**: any other argument is passed as `-only-testing:AISightTests/<TestClass>` to run a specific test suite

Examples: `/test`, `/test ios`, `/test mac`, `/test ios SearXNGServiceTests`, `/test ContentFetcherTests`

If NO arguments are provided, default to iOS.

### Steps

1. Determine destination from platform:
   - `ios` (default) → `'platform=iOS Simulator,name=iPhone 17 Pro'` (check available simulators first with `xcodebuild -showdestinations` if needed)
   - `mac` → `'platform=macOS'`

2. Build the test command:
   - Base: `xcodebuild -project AISight/AISight.xcodeproj -scheme AISight -destination '<destination>' test -only-testing:AISightTests`
   - If a test filter is provided, append `/<TestClass>` to `-only-testing:AISightTests/<TestClass>`

3. Run the tests:
   ```
   xcodebuild -project AISight/AISight.xcodeproj -scheme AISight -destination '<destination>' test -only-testing:AISightTests[/<filter>] 2>&1 | tail -50
   ```

4. Report results: count passed/failed, show any failure details.

### Available Test Suites

| Suite | Tests | Covers |
|-------|-------|--------|
| `SearXNGServiceTests` | 16 | URL normalization, RRF ranking, deduplication |
| `SearXNGResultTests` | 11 | Computed properties (engineCount, snippetLength, domain) |
| `SearXNGResponseTests` | 3 | JSON decoding |
| `ContentFetcherTests` | 17 | HTML stripping, truncation, fetch threshold |
| `SystemPromptTests` | 14 | Prompt building, language instruction |
| `CitationTextTests` | 15 | Block parsing, attribution escaping |
| `StoreManagerTests` | 5 | Daily limit, date reset, counter |
