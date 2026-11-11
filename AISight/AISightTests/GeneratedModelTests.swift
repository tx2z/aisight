import Testing
import Foundation
@testable import AISight

struct GeneratedModelTests {

    @Test func fromResolvedModel_onDeviceWithFallbackReason() {
        let resolved = ResolvedLanguageModel(source: .onDevice, contextSize: 4096, fallbackReason: .quotaReached)
        #expect(GeneratedModel(resolved) == GeneratedModel(kind: .onDevice, fallbackReason: .quotaReached))
    }

    @Test func fromResolvedModel_customKeepsModelName() throws {
        let config = CustomModelConfig(
            baseURL: try #require(URL(string: "https://api.example.com/v1")),
            model: "my-model", apiKey: nil, contextSize: 4096
        )
        let model = GeneratedModel(ResolvedLanguageModel(source: .custom(config), contextSize: 4096))
        #expect(model == GeneratedModel(kind: .custom, customModelName: "my-model"))
    }

    @Test func codableRoundTrip() throws {
        let model = GeneratedModel(kind: .custom, customModelName: "m", fallbackReason: nil)
        let decoded = try JSONDecoder().decode(GeneratedModel.self, from: JSONEncoder().encode(model))
        #expect(decoded == model)
    }
}
