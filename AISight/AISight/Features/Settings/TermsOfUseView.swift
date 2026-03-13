import SwiftUI

struct TermsOfUseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Use")
                    .font(.largeTitle.bold())

                Text("Last updated: March 13, 2026")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("By using AISight, you agree to these terms. Please read them carefully.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Group {
                    LegalSectionView(
                        title: "1. Acceptance of Terms",
                        content: """
                        By downloading, installing, or using AISight ("the App"), you agree to be bound by these \
                        Terms of Use. If you do not agree, do not use the App.
                        """
                    )

                    LegalSectionView(
                        title: "2. Description of Service",
                        content: """
                        AISight is an answer engine that searches the web via a user-configured SearXNG server \
                        and generates answers on-device using Apple Intelligence (FoundationModels framework). \
                        The App is provided free of charge with no in-app purchases or subscriptions.
                        """
                    )

                    LegalSectionView(
                        title: "3. AI-Generated Content Disclaimer",
                        content: """
                        AISight uses on-device artificial intelligence to generate answers based on web search results. \
                        You acknowledge and agree that:\n\n\
                        \u{2022} AI-generated answers may contain inaccuracies, errors, or outdated information.\n\
                        \u{2022} Answers are not a substitute for professional advice of any kind, including but not \
                        limited to medical, legal, financial, or safety advice.\n\
                        \u{2022} You are solely responsible for verifying the accuracy of any information before \
                        relying on it.\n\
                        \u{2022} Citations and sources are provided for reference; you should review original sources \
                        to confirm accuracy.\n\n\
                        The App provides information on an "as is" basis. We make no warranties regarding the \
                        accuracy, completeness, reliability, or suitability of AI-generated content for any purpose.
                        """
                    )

                    LegalSectionView(
                        title: "4. SearXNG Server Configuration",
                        content: """
                        AISight requires a SearXNG server to function. You are responsible for:\n\n\
                        \u{2022} Providing and maintaining your own SearXNG server or using one you have \
                        authorization to access.\n\
                        \u{2022} Ensuring your SearXNG server complies with applicable laws and the terms \
                        of service of the search engines it queries.\n\
                        \u{2022} The security and privacy configuration of your SearXNG instance.\n\n\
                        We do not provide, operate, or guarantee any SearXNG server.
                        """
                    )

                    LegalSectionView(
                        title: "5. Acceptable Use",
                        content: """
                        You agree not to use AISight to:\n\n\
                        \u{2022} Violate any applicable laws or regulations.\n\
                        \u{2022} Generate content that is harmful, threatening, abusive, or otherwise objectionable.\n\
                        \u{2022} Infringe on the intellectual property rights of others.\n\
                        \u{2022} Attempt to circumvent the on-device AI safety measures.\n\
                        \u{2022} Misrepresent AI-generated content as human-authored work.
                        """
                    )
                }

                Group {
                    LegalSectionView(
                        title: "6. Intellectual Property",
                        content: """
                        The App and its original content, features, and functionality are owned by the developer \
                        and are protected by international copyright, trademark, and other intellectual property laws.\n\n\
                        Content fetched from third-party websites remains the property of their respective owners. \
                        AISight displays excerpts for informational purposes, similar to how a search engine \
                        displays snippets. You should respect the intellectual property rights of content owners \
                        when using information obtained through the App.
                        """
                    )

                    LegalSectionView(
                        title: "7. Limitation of Liability",
                        content: """
                        To the maximum extent permitted by applicable law, the developer shall not be liable for \
                        any indirect, incidental, special, consequential, or punitive damages, or any loss of \
                        profits or revenues, whether incurred directly or indirectly, or any loss of data, use, \
                        goodwill, or other intangible losses resulting from:\n\n\
                        \u{2022} Your use or inability to use the App.\n\
                        \u{2022} Any inaccuracy in AI-generated content.\n\
                        \u{2022} Unauthorized access to or alteration of your data.\n\
                        \u{2022} Any third-party content or conduct.\n\
                        \u{2022} Any issues with your SearXNG server configuration.
                        """
                    )

                    LegalSectionView(
                        title: "8. Disclaimer of Warranties",
                        content: """
                        The App is provided on an "AS IS" and "AS AVAILABLE" basis, without warranties of any \
                        kind, either express or implied, including but not limited to implied warranties of \
                        merchantability, fitness for a particular purpose, and non-infringement.
                        """
                    )

                    LegalSectionView(
                        title: "9. Changes to Terms",
                        content: """
                        We reserve the right to modify these terms at any time. Changes will be reflected within \
                        the App with an updated date. Your continued use of the App after changes constitutes \
                        acceptance of the revised terms.
                        """
                    )

                    LegalSectionView(
                        title: "10. Termination",
                        content: """
                        You may stop using the App at any time by deleting it from your device. \
                        We reserve the right to modify or discontinue the App at any time without notice.
                        """
                    )
                }

                Group {
                    LegalSectionView(
                        title: "11. Indemnification",
                        content: """
                        You agree to indemnify, defend, and hold harmless the developer from and against any \
                        claims, liabilities, damages, losses, and expenses, including reasonable legal fees, \
                        arising out of or in any way connected with: your use of the App, your violation of \
                        these Terms, your violation of any rights of any third party, or your configuration \
                        and use of any SearXNG instance in connection with the App.
                        """
                    )

                    LegalSectionView(
                        title: "12. Apple App Store Terms",
                        content: """
                        This agreement is between you and the developer of AISight, not with Apple Inc. \
                        The developer, not Apple, is solely responsible for the App and its content.\n\n\
                        The license granted to you is limited to a non-transferable license to use the App on \
                        any Apple-branded products that you own or control, as permitted by the Usage Rules set \
                        forth in the Apple Media Services Terms and Conditions.\n\n\
                        The developer is solely responsible for providing maintenance and support for the App. \
                        Apple has no obligation to furnish any maintenance and support services.\n\n\
                        The developer, not Apple, is solely responsible for any product warranties, whether \
                        express or implied by law, to the extent not effectively disclaimed.\n\n\
                        The developer, not Apple, is responsible for addressing any claims relating to the App, \
                        including product liability claims, claims that the App fails to conform to legal or \
                        regulatory requirements, or claims arising under consumer protection or similar legislation.\n\n\
                        In the event of any third-party claim that the App infringes a third party\u{2019}s intellectual \
                        property rights, the developer, not Apple, will be solely responsible for the investigation, \
                        defense, settlement, and discharge of any such claim.\n\n\
                        You must comply with applicable third-party terms of agreement when using the App \
                        (for example, your SearXNG instance\u{2019}s terms of service and your wireless data service agreement).\n\n\
                        You acknowledge and agree that Apple and its subsidiaries are third-party beneficiaries \
                        of these Terms of Use, and that upon your acceptance of these terms, Apple will have the \
                        right (and will be deemed to have accepted the right) to enforce these terms against you \
                        as a third-party beneficiary.
                        """
                    )

                    LegalSectionView(
                        title: "13. Severability",
                        content: """
                        If any provision of these Terms is held to be unenforceable or invalid, that provision \
                        will be enforced to the maximum extent possible, and the other provisions will remain \
                        in full force and effect.
                        """
                    )

                    LegalSectionView(
                        title: "14. Governing Law",
                        content: """
                        These terms shall be governed by and construed in accordance with the laws of Spain, \
                        without regard to its conflict of law provisions.
                        """
                    )

                    LegalSectionView(
                        title: "15. Contact",
                        content: """
                        For questions about these Terms of Use, please contact us at:\n\n\
                        Email: jesus@perezpaz.es
                        """
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Use")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        TermsOfUseView()
    }
}
