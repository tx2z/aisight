import Testing
@testable import AISight

struct QueryReformulatorTests {

    private func build(_ question: String, _ output: String, languageCode: String? = nil) -> [String] {
        QueryReformulator.buildQueries(question: question, modelOutput: output, year: 2026, languageCode: languageCode)
    }

    // MARK: - cleanLine

    @Test func cleanLine_stripsNumbering() {
        #expect(QueryReformulator.cleanLine("1. best cloud europe") == "best cloud europe")
        #expect(QueryReformulator.cleanLine("2) best cloud europe") == "best cloud europe")
        #expect(QueryReformulator.cleanLine("３、东京 京都") == "东京 京都")
    }

    @Test func cleanLine_stripsBullets() {
        #expect(QueryReformulator.cleanLine("- cloud europe") == "cloud europe")
        #expect(QueryReformulator.cleanLine("• cloud europe") == "cloud europe")
        #expect(QueryReformulator.cleanLine("* cloud europe") == "cloud europe")
        #expect(QueryReformulator.cleanLine("・東京 天気") == "東京 天気")
    }

    @Test func cleanLine_keepsLeadingNumbersAndSymbolsOfTheQuery() {
        #expect(QueryReformulator.cleanLine("3.5 mm jack") == "3.5 mm jack")
        #expect(QueryReformulator.cleanLine("3.5mm jack") == "3.5mm jack")
        #expect(QueryReformulator.cleanLine("+44 phone code") == "+44 phone code")
        #expect(QueryReformulator.cleanLine("#hashtag trends") == "#hashtag trends")
    }

    @Test func cleanLine_removesBoldMarkersOnly() {
        #expect(QueryReformulator.cleanLine("**cloud europe**") == "cloud europe")
        #expect(QueryReformulator.cleanLine("C* algebra") == "C* algebra")
    }

    @Test func cleanLine_stripsWrappingQuotes() {
        #expect(QueryReformulator.cleanLine("\"cloud europe\"") == "cloud europe")
        #expect(QueryReformulator.cleanLine("“cloud europe”") == "cloud europe")
        #expect(QueryReformulator.cleanLine("«cloud europe»") == "cloud europe")
        #expect(QueryReformulator.cleanLine("'cloud europe'") == "cloud europe")
    }

    @Test func cleanLine_keepsQuotesThatAppearInside() {
        #expect(QueryReformulator.cleanLine("\"Dune\" vs \"Foundation\"") == "\"Dune\" vs \"Foundation\"")
    }

    @Test func cleanLine_dropsUnusableLines() {
        #expect(QueryReformulator.cleanLine("   ") == nil)
        #expect(QueryReformulator.cleanLine("Here are the queries:") == nil)
        #expect(QueryReformulator.cleanLine("以下は検索クエリ：") == nil)
        #expect(QueryReformulator.cleanLine(String(repeating: "a", count: 200)) == nil)
    }

    // MARK: - standalone numbers

    @Test func standaloneNumbers_exemptsNumbersGluedToLetters() {
        #expect(QueryReformulator.standaloneNumbers(in: "COVID-19 5G Web3 iPhone15").isEmpty)
        #expect(QueryReformulator.standaloneNumbers(in: "iPhone 15") == ["15"])
    }

    @Test func standaloneNumbers_normalizesWidthAndThousandsSeparators() {
        #expect(QueryReformulator.standaloneNumbers(in: "１７") == ["17"])
        #expect(QueryReformulator.standaloneNumbers(in: "100,000 and 100.000 and 100\u{202F}000") == ["100000"])
        #expect(QueryReformulator.standaloneNumbers(in: "3.5 mm") == ["3.5"])
    }

    // MARK: - buildQueries

    @Test func buildQueries_capsModelLines() {
        let queries = build("what is the best cloud provider in Europe", "one query\ntwo query\nthree query")
        #expect(queries == ["what is the best cloud provider in Europe", "one query", "two query"])
        #expect(queries.count == QueryReformulator.keywordQueryCount + 1)
    }

    @Test func buildQueries_dropsForeignNumbersBeforeCap() {
        let queries = build("what is the best phone", "best phone 2024\niPhone 15 Pro\nbest phone review\nphone ranking\nphone guide")
        #expect(queries == ["what is the best phone", "best phone review", "phone ranking"])
    }

    @Test func buildQueries_keepsNumbersFromQuestion() {
        #expect(build("chi ha vinto Sanremo 2024", "Sanremo 2024 vincitore") == ["chi ha vinto Sanremo 2024", "Sanremo 2024 vincitore"])
        #expect(build("iPhone 17 の価格は", "iPhone １７ 価格\niPhone １５ 価格") == ["iPhone 17 の価格は", "iPhone １７ 価格"])
    }

    @Test func buildQueries_keepsDecimalsAndGluedNumbers() {
        #expect(build("does this laptop have a 3.5 mm jack", "3.5 mm jack laptop") == ["does this laptop have a 3.5 mm jack", "3.5 mm jack laptop"])
        #expect(build("how do vaccines affect the virus", "COVID-19 vaccine") == ["how do vaccines affect the virus", "COVID-19 vaccine"])
    }

    @Test func buildQueries_thousandsSeparatorsCompareEqual() {
        #expect(build("is 100,000 euros enough to retire", "100000 euros retire") == ["is 100,000 euros enough to retire", "100000 euros retire"])
    }

    @Test func buildQueries_dedupesAgainstOriginalCaseInsensitively() {
        let queries = build(
            "Best  cloud providers in Europe",
            "best cloud providers in europe\n2. cloud   providers europe\n3. third query"
        )
        #expect(queries == ["Best cloud providers in Europe", "cloud providers europe", "third query"])
    }

    @Test func buildQueries_dedupesBeforeCap() {
        let queries = build("what is the best cloud provider in Europe", "cloud europe\ncloud europe\nsecond query")
        #expect(queries == ["what is the best cloud provider in Europe", "cloud europe", "second query"])
    }

    @Test func buildQueries_dedupesModelLinesAmongThemselves() {
        let queries = build("how do I start a journal", "journal habit\nJournal  Habit!\njournal tips")
        #expect(queries == ["how do I start a journal", "journal habit", "journal tips"])
    }

    @Test func buildQueries_accentAndPunctuationOnlyEchoIsDeduped() {
        let queries = build("Qué es el mejor cloud europeo?", "Que es el mejor cloud europeo\nCloud europeo")
        #expect(queries == ["Qué es el mejor cloud europeo?", "Cloud europeo"])
    }

    @Test func buildQueries_splitsCRLFLines() {
        let queries = build("how do I start a journal", "journal habit\r\njournal tips\r\n")
        #expect(queries == ["how do I start a journal", "journal habit", "journal tips"])
    }

    @Test func buildQueries_keepsDistinctQuotedLinesIntact() {
        let queries = build("which book should I read first", "\"Dune\" vs \"Foundation\"")
        #expect(queries == ["which book should I read first", "\"Dune\" vs \"Foundation\""])
    }

    // MARK: - year

    @Test func year_appendsToFirstModelLineOnly() {
        let queries = build(
            "what is the latest iPhone model", "latest iPhone model\niPhone newest release", languageCode: "en")
        #expect(queries == ["what is the latest iPhone model", "latest iPhone model 2026", "iPhone newest release"])
    }

    @Test func year_fallbackStripsQuestionPunctuation() {
        #expect(build("¿Cuál es el último iPhone?", "", languageCode: "es") == ["¿Cuál es el último iPhone?", "Cuál es el último iPhone 2026"])
        #expect(build("¿Cuál es el último iPhone?", "¿Cuál es el último iPhone?", languageCode: "es")
                == ["¿Cuál es el último iPhone?", "Cuál es el último iPhone 2026"])
    }

    @Test func year_echoDedupedThenFirstModelLineGetsYear() {
        let question = "¿Cuál es el último iPhone?"
        #expect(build(question, "Cuál es el último iPhone\niPhone nuevo", languageCode: "es") == [question, "iPhone nuevo 2026"])
    }

    @Test func year_shortRecencyQuestionGetsYear() {
        #expect(build("latest  iPhone model", "", languageCode: "en") == ["latest iPhone model", "latest iPhone model 2026"])
        #expect(build("swift concurrency guide", "") == ["swift concurrency guide"])
    }

    @Test func year_questionYearAddsNothing() {
        #expect(build("latest news about Sanremo 2024", "Sanremo 2024 news", languageCode: "en")
                == ["latest news about Sanremo 2024", "Sanremo 2024 news"])
    }

    // MARK: - recency

    @Test(arguments: [
        ("en", "what is the latest iPhone"),
        ("en", "who is the champion right now"),
        ("es", "¿Cuál es el último iPhone?"),
        ("es", "cuales son los ultimos modelos"),
        ("es", "qué película se estrena actualmente"),
        ("fr", "quel temps fait-il aujourd’hui"),
        ("fr", "quelles sont les dernières nouvelles"),
        ("de", "was sind die aktuellen Preise"),
        ("de", "wie spät ist es jetzt"),
        ("it", "quali sono gli ultimi film"),
        ("pt", "qual é o preço agora"),
        ("pt", "notícias recentes sobre o clima"),
        ("ja", "現在の東京の天気"),
        ("ko", "현재 서울 날씨"),
        ("zh", "东京今年的天气怎么样")
    ])
    func recency_positive(languageCode: String, question: String) {
        #expect(QueryReformulator.needsCurrentYear(question: question, languageCode: languageCode))
    }

    @Test(arguments: [
        ("en", "what is the actual difference between baking soda and baking powder"),
        ("en", "how does alternating current work"),
        ("en", "how to start a journaling habit"),
        ("en", "tell me about knowledge of unknown things"),
        ("es", "cómo actualizar iOS"),
        ("it", "ultimatum history"),
        ("it", "attualità")
    ])
    func recency_negative(languageCode: String, question: String) {
        #expect(!QueryReformulator.needsCurrentYear(question: question, languageCode: languageCode))
    }

    @Test func recency_fullWidthYearInQuestionIsDetected() {
        #expect(!QueryReformulator.needsCurrentYear(question: "２０２５年の最新モデル", languageCode: "ja"))
    }

    @Test func recency_cuesOfOtherLanguagesAreIgnored() {
        #expect(!QueryReformulator.needsCurrentYear(question: "the actual price", languageCode: "en"))
        #expect(QueryReformulator.needsCurrentYear(question: "el precio actual", languageCode: "es"))
    }

    @Test func recency_nilLanguageChecksAllCues() {
        #expect(QueryReformulator.needsCurrentYear(question: "最新"))
        #expect(QueryReformulator.needsCurrentYear(question: "the latest news"))
    }

    // MARK: - wordCount

    @Test func wordCount_fourWordsIsNotShort() {
        #expect(QueryReformulator.wordCount("best cloud providers europe") > 3)
    }

    @Test func wordCount_ignoresPunctuation() {
        #expect(QueryReformulator.wordCount("swift, concurrency... guide?!") == 3)
    }

    @Test func wordCount_longChineseQuestionIsNotShort() {
        #expect(QueryReformulator.wordCount("请问从北京到上海坐高铁需要多长时间呢") > 3)
    }

    @Test func wordCount_longJapaneseQuestionIsNotShort() {
        #expect(QueryReformulator.wordCount("東京から京都まで新幹線で行くと何時間かかりますか") > 3)
    }

    @Test func wordCount_shortJapaneseQueryIsShort() {
        #expect(QueryReformulator.wordCount("東京 天気") <= 3)
    }

    // MARK: - instructions

    @Test func instructions_interpolatesQueryCountAndLanguage() {
        let named = QueryReformulator.instructions(languageName: "Spanish")
        #expect(named.contains("into \(QueryReformulator.keywordQueryCount) web search queries"))
        #expect(named.contains("The question is in Spanish."))
        let fallback = QueryReformulator.instructions(languageName: nil)
        #expect(fallback.contains("Write the queries in the same language as the question"))
        #expect(!fallback.contains("The question is in"))
    }
}
