import NaturalLanguage

nonisolated enum QuestionLanguage {
    static let minimumConfidence = 0.8

    /// Base language code of the text when it is a supported language and the detection is confident; nil otherwise.
    static func detect(_ text: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        return code(from: recognizer.languageHypotheses(withMaximum: 1))
    }

    /// Base code of the most likely hypothesis when its confidence reaches `minimumConfidence` and the language is supported.
    static func code(from hypotheses: [NLLanguage: Double]) -> String? {
        guard let top = hypotheses.max(by: { $0.value < $1.value }),
              top.value >= minimumConfidence else { return nil }
        return AppConfig.supportedLanguageCode(from: top.key.rawValue)
    }
}
