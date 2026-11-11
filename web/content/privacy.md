---
title: "Privacy Policy"
description: "Privacy Policy for AISight. We do not collect, store, or transmit your personal data. AI processing happens on your device by default."
layout: "single"
---

# Privacy Policy

*Last updated: November 11, 2026*

## Our Commitment to Privacy

AISight is built with privacy as a core principle. We do not collect, store, or transmit your personal data to any external servers we operate. There are no analytics, no tracking, no advertising, and no user accounts. Your data stays on your device. The only exceptions are the network requests and AI processing described below.

## Information We Do Not Collect

AISight does not collect:

- Personal identifiers (name, email, phone number)
- Device identifiers for tracking purposes
- Location data
- Usage analytics or telemetry
- Advertising identifiers
- Cookies or browser fingerprints

We do not sell, rent, share, or monetize any user data — ever.

## Data Stored on Your Device

AISight stores the following data locally on your device only:

**Search History:** Your search queries and AI-generated answers are saved to your device using Apple's SwiftData framework. This data never leaves your device unless you choose to share it.

**Preferences:** Your app settings (language preferences, SearXNG server URL) are stored in UserDefaults on your device.

You can delete all locally stored data at any time from Settings → Data → Delete All Data.

Custom AI provider settings: If you configure a custom AI provider, its URL, model name and context size are stored in UserDefaults on your device, and its API key is stored in the device Keychain, on this device only. Deleting all data in Settings also removes them.

## Data Transmitted Over the Network

AISight makes up to four types of network requests:

1. **Search Queries:** When you perform a search, your query is sent to the SearXNG server you have configured. AISight does not operate this server — you provide and control it. The privacy of your search queries depends on the configuration of your SearXNG instance.

2. **Web Content Fetching:** AISight fetches publicly available web pages from URLs returned by search results to extract text content for AI summarization. These are standard HTTP requests similar to visiting a website in a browser.

AISight does not add tracking parameters, custom headers, or identifying information to these requests beyond what is standard for URL loading on iOS/macOS.

3. Apple Private Cloud Compute (optional): Only if you enable it in Settings, your question, the text extracted from web sources and the AI instructions are sent to Apple's Private Cloud Compute service to write the answer.

4. Custom AI provider (optional): Only if you configure one and confirm the prompt in Settings, your question, the text extracted from web sources and the AI instructions are sent to that provider's server. Deep Search sends several requests per question. The provider's own terms and privacy practices apply.

## AI Processing

By default, all AI processing in AISight happens entirely on your device using Apple's FoundationModels framework (Apple Intelligence). Your queries, search results, and generated answers are not sent to any cloud AI service. If you choose "Apple Private Cloud Compute" in Settings → AI Model, your query and the search results needed to write an answer are instead processed on Apple's Private Cloud Compute servers, under Apple's privacy protections for that service. You can switch back to on-device at any time. If you configure a custom AI provider in Settings → AI Model and confirm the prompt, your question, the text extracted from web sources and the AI instructions are sent to that provider under its own terms; Deep Search makes several requests. The API key is stored in your device's Keychain and is only sent to that provider.

## Third-Party Services

AISight itself does not integrate with any third-party analytics, advertising, crash reporting, or data collection services.

Your self-hosted SearXNG instance may have its own data practices depending on how it is configured. We recommend reviewing the SearXNG documentation for details.

Web pages fetched during search may contain their own tracking mechanisms, but AISight only extracts plain text content and does not execute JavaScript or load tracking resources.

## Children's Privacy

AISight does not knowingly collect any personal information from anyone, including children under 13. Since we do not collect personal data, there is no children's data to manage. However, the AI-generated content may not always be appropriate for all ages. Parental guidance is recommended.

## Your Rights

Because AISight does not collect or store your personal data on any external server, many traditional data rights are satisfied by design:

- **Right to Access:** All your data is stored locally on your device and accessible to you.
- **Right to Deletion:** You can delete all app data from Settings at any time, or by deleting the app.
- **Right to Data Portability:** Your data is stored in standard formats on your device.
- **Right to Opt Out of Sale:** We never sell your data.

These rights apply to users in all jurisdictions, including under the EU General Data Protection Regulation (GDPR) and the California Consumer Privacy Act (CCPA).

## Security

Your data is protected by the security features built into your Apple device, including device encryption, app sandboxing, and biometric or passcode locks. Since AISight stores data only on your device using Apple's frameworks, your data benefits from the full security architecture of iOS and macOS.

Network requests to your SearXNG instance and source websites use standard HTTPS encryption when the server supports it.

## Data Retention

Search history is retained on your device until you explicitly delete it. No data is retained on any external server operated by us. When you delete the app, all locally stored data is removed. Deleting all data in Settings also removes your custom provider API key and settings.

## This Website

This website (private-search-intelligence.app) uses no cookies, no analytics, and no tracking. The contact form sends your message directly via email and we do not store your data on any server.

## Changes to This Policy

We may update this privacy policy from time to time. Changes will be reflected in the app with an updated "Last updated" date. Continued use of the app after changes constitutes acceptance of the updated policy.

## Contact

If you have questions about this privacy policy, please contact us at [jesus@perezpaz.es](mailto:jesus@perezpaz.es).
