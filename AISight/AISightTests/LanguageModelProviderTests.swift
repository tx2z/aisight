import Testing
@testable import AISight

struct LanguageModelProviderTests {

    private func select(
        _ preference: LanguageModelKind,
        cloudStatus: CloudModelStatus = .usable,
        canUseCloudModel: Bool = true,
        customConfigured: Bool = true
    ) -> ModelSelection {
        LanguageModelProvider.select(
            preference: preference, cloudStatus: cloudStatus,
            canUseCloudModel: canUseCloudModel, customConfigured: customConfigured
        )
    }

    @Test func onDevicePreference_alwaysOnDeviceWithoutReason() {
        #expect(select(.onDevice) == ModelSelection(kind: .onDevice, fallbackReason: nil))
    }

    @Test func cloudPreference_usable_usesCloud() {
        #expect(select(.appleCloud) == ModelSelection(kind: .appleCloud, fallbackReason: nil))
    }

    @Test func cloudPreference_notOffered_reportsNotOffered() {
        #expect(select(.appleCloud, cloudStatus: .notOffered) == ModelSelection(kind: .onDevice, fallbackReason: .notOfferedOnDevice))
    }

    @Test func cloudPreference_withoutPro_reportsRequiresPro() {
        #expect(select(.appleCloud, canUseCloudModel: false) == ModelSelection(kind: .onDevice, fallbackReason: .requiresPro))
    }

    @Test func cloudPreference_unavailable_reportsUnavailable() {
        #expect(select(.appleCloud, cloudStatus: .unavailable) == ModelSelection(kind: .onDevice, fallbackReason: .cloudUnavailable))
    }

    @Test func cloudPreference_quotaReached_reportsQuota() {
        #expect(select(.appleCloud, cloudStatus: .quotaReached) == ModelSelection(kind: .onDevice, fallbackReason: .quotaReached))
    }

    @Test func customPreference_configured_usesCustom() {
        #expect(select(.custom) == ModelSelection(kind: .custom, fallbackReason: nil))
    }

    @Test func customPreference_ignoresProAndCloudState() {
        #expect(select(.custom, cloudStatus: .notOffered, canUseCloudModel: false).kind == .custom)
    }

    @Test func customPreference_notConfigured_reportsNotConfigured() {
        #expect(select(.custom, customConfigured: false) == ModelSelection(kind: .onDevice, fallbackReason: .customNotConfigured))
    }
}
