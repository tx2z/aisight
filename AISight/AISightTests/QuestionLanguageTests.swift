import NaturalLanguage
import Testing
@testable import AISight

struct QuestionLanguageTests {

    @Test func code_belowThresholdIsNil() {
        #expect(QuestionLanguage.code(from: [.spanish: 0.79]) == nil)
    }

    @Test func code_atThresholdIsAccepted() {
        #expect(QuestionLanguage.code(from: [.spanish: 0.8]) == "es")
    }

    @Test func code_usesTopHypothesis() {
        #expect(QuestionLanguage.code(from: [.spanish: 0.1, .german: 0.9]) == "de")
    }

    @Test func code_chineseVariantsMapToZh() {
        #expect(QuestionLanguage.code(from: [.simplifiedChinese: 0.95]) == "zh")
        #expect(QuestionLanguage.code(from: [.traditionalChinese: 0.95]) == "zh")
    }

    @Test func code_unsupportedLanguageIsNil() {
        #expect(QuestionLanguage.code(from: [.dutch: 0.99]) == nil)
    }

    @Test func code_emptyIsNil() {
        #expect(QuestionLanguage.code(from: [:]) == nil)
    }

    @Test func detect_longSpanishSentence() {
        #expect(QuestionLanguage.detect("qué clouds europeos me recomiendas para alojar los servicios de mi empresa") == "es")
    }

    @Test func detect_longJapaneseSentence() {
        #expect(QuestionLanguage.detect("東京から京都まで新幹線で行くと何時間かかりますか") == "ja")
    }
}
