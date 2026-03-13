import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle.bold())

                Text("Last updated: March 13, 2026")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Group {
                    LegalSectionView(
                        title: "Our Commitment to Privacy",
                        content: """
                        AISight is built with privacy as a core principle. We do not collect, store, or transmit \
                        your personal data to any external servers we operate. There are no analytics, no tracking, \
                        no advertising, and no user accounts. Your data stays on your device.
                        """
                    )

                    LegalSectionView(
                        title: "Information We Do Not Collect",
                        content: """
                        AISight does not collect:\n\
                        \u{2022} Personal identifiers (name, email, phone number)\n\
                        \u{2022} Device identifiers for tracking purposes\n\
                        \u{2022} Location data\n\
                        \u{2022} Usage analytics or telemetry\n\
                        \u{2022} Advertising identifiers\n\
                        \u{2022} Cookies or browser fingerprints\n\n\
                        We do not sell, rent, share, or monetize any user data \u{2014} ever.
                        """
                    )

                    LegalSectionView(
                        title: "Data Stored on Your Device",
                        content: """
                        AISight stores the following data locally on your device only:\n\n\
                        Search History: Your search queries and AI-generated answers are saved to your device \
                        using Apple's SwiftData framework. This data never leaves your device unless you choose \
                        to share it.\n\n\
                        Preferences: Your app settings (language preferences, SearXNG server URL) are stored \
                        in UserDefaults on your device.\n\n\
                        You can delete all locally stored data at any time from Settings \u{2192} Data \u{2192} Delete All Data.
                        """
                    )

                    LegalSectionView(
                        title: "Data Transmitted Over the Network",
                        content: """
                        AISight makes two types of network requests:\n\n\
                        1. Search Queries: When you perform a search, your query is sent to the SearXNG server \
                        you have configured. AISight does not operate this server \u{2014} you provide and control it. \
                        The privacy of your search queries depends on the configuration of your SearXNG instance.\n\n\
                        2. Web Content Fetching: AISight fetches publicly available web pages from URLs returned \
                        by search results to extract text content for AI summarization. These are standard HTTP \
                        requests similar to visiting a website in a browser.\n\n\
                        AISight does not add tracking parameters, custom headers, or identifying information to \
                        these requests beyond what is standard for URL loading on iOS/macOS.
                        """
                    )
                }

                Group {
                    LegalSectionView(
                        title: "On-Device AI Processing",
                        content: """
                        All AI processing in AISight happens entirely on your device using Apple's FoundationModels \
                        framework (Apple Intelligence). Your queries, search results, and generated answers are \
                        never sent to any cloud AI service. The AI model runs locally on your device's neural engine.
                        """
                    )

                    LegalSectionView(
                        title: "Third-Party Services",
                        content: """
                        AISight itself does not integrate with any third-party analytics, advertising, crash \
                        reporting, or data collection services.\n\n\
                        Your self-hosted SearXNG instance may have its own data practices depending on how \
                        it is configured. We recommend reviewing the SearXNG documentation for details.\n\n\
                        Web pages fetched during search may contain their own tracking mechanisms, but AISight \
                        only extracts plain text content and does not execute JavaScript or load tracking resources.
                        """
                    )

                    LegalSectionView(
                        title: "Children\u{2019}s Privacy",
                        content: """
                        AISight does not knowingly collect any personal information from anyone, including children \
                        under 13. Since we do not collect personal data, there is no children\u{2019}s data to manage. \
                        However, the AI-generated content may not always be appropriate for all ages. Parental \
                        guidance is recommended.
                        """
                    )

                    LegalSectionView(
                        title: "Your Rights",
                        content: """
                        Because AISight does not collect or store your personal data on any external server, \
                        many traditional data rights are satisfied by design:\n\n\
                        \u{2022} Right to Access: All your data is stored locally on your device and accessible to you.\n\
                        \u{2022} Right to Deletion: You can delete all app data from Settings at any time, or by \
                        deleting the app.\n\
                        \u{2022} Right to Data Portability: Your data is stored in standard formats on your device.\n\
                        \u{2022} Right to Opt Out of Sale: We never sell your data.\n\n\
                        These rights apply to users in all jurisdictions, including under the EU General Data \
                        Protection Regulation (GDPR) and the California Consumer Privacy Act (CCPA).
                        """
                    )

                    LegalSectionView(
                        title: "Security",
                        content: """
                        Your data is protected by the security features built into your Apple device, including \
                        device encryption, app sandboxing, and biometric or passcode locks. Since AISight stores \
                        data only on your device using Apple\u{2019}s frameworks, your data benefits from the full \
                        security architecture of iOS and macOS.\n\n\
                        Network requests to your SearXNG instance and source websites use standard HTTPS \
                        encryption when the server supports it.
                        """
                    )

                    LegalSectionView(
                        title: "Data Retention",
                        content: """
                        Search history is retained on your device until you explicitly delete it. \
                        No data is retained on any external server operated by us. When you delete the app, \
                        all locally stored data is removed.
                        """
                    )

                    LegalSectionView(
                        title: "Changes to This Policy",
                        content: """
                        We may update this privacy policy from time to time. Changes will be reflected in the \
                        app with an updated "Last updated" date. Continued use of the app after changes \
                        constitutes acceptance of the updated policy.
                        """
                    )

                    LegalSectionView(
                        title: "Contact",
                        content: """
                        If you have questions about this privacy policy, please contact us at:\n\n\
                        Email: jesus@perezpaz.es
                        """
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
