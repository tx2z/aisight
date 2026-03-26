import StoreKit

@MainActor @Observable
final class StoreManager {
    private(set) var isPro: Bool = false
    private(set) var dailyQueriesUsed: Int = 0
    private(set) var errorMessage: String?

    /// Whether the user has configured a custom SearXNG server (not using the default).
    private(set) var isUsingCustomServer: Bool = false

    static let dailyLimit = 10
    static let productID = "com.aisight.pro"

    private var transactionListener: Task<Void, Never>?
    private let defaults: UserDefaults

    /// Users with a custom server or PRO can always search.
    var canSearch: Bool {
        isUsingCustomServer || isPro || remainingQueries > 0
    }

    /// Deep Search is available to PRO users or anyone using their own server.
    var canDeepSearch: Bool {
        isUsingCustomServer || isPro
    }

    var remainingQueries: Int {
        (isUsingCustomServer || isPro) ? .max : max(0, Self.dailyLimit - dailyQueriesUsed)
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadDailyCounter()
        refreshCustomServerStatus()
        #if SETAPP
        isPro = true
        #else
        startTransactionListener()
        Task { [weak self] in
            await self?.refreshPurchaseStatus()
        }
        #endif
    }

    /// Re-evaluates whether the user has a custom server configured. Call after saving or resetting the server URL.
    func refreshCustomServerStatus() {
        guard let stored = defaults.string(forKey: "searxng_base_url"),
              let url = URL(string: stored),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            isUsingCustomServer = false
            return
        }
        isUsingCustomServer = stored != AppConfig.defaultSearXNGBaseURL
    }

    func recordQuery() {
        guard !isPro && !isUsingCustomServer else { return }
        dailyQueriesUsed += 1
        saveDailyCounter()
    }

    #if !SETAPP
    func purchase() async {
        errorMessage = nil
        do {
            guard let product = try await Product.products(for: [Self.productID]).first else {
                errorMessage = String(localized: "Product not found. Please try again later.")
                return
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPro = true
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                errorMessage = String(localized: "Purchase is pending approval.")
            @unknown default:
                break
            }
        } catch {
            errorMessage = String(localized: "Purchase failed. Please try again.")
        }
    }

    func restorePurchases() async {
        errorMessage = nil
        await refreshPurchaseStatus()
        if !isPro {
            errorMessage = String(localized: "No previous purchase found.")
        }
    }
    #endif

    // MARK: - Private

    #if !SETAPP
    private func startTransactionListener() {
        // Detached to avoid blocking MainActor while awaiting Transaction.updates
        transactionListener = Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if let transaction = try? self.checkVerified(result) {
                    await MainActor.run { self.isPro = true }
                    await transaction.finish()
                }
            }
        }
    }

    private func refreshPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.productID {
                isPro = true
                return
            }
        }
    }

    private nonisolated func checkVerified(_ result: VerificationResult<Transaction>) throws -> Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified:
            throw StoreError.unverified
        }
    }
    #endif

    private func loadDailyCounter() {
        let today = todayString()
        let storedDate = defaults.string(forKey: "daily_queries_date") ?? ""
        if storedDate == today {
            dailyQueriesUsed = defaults.integer(forKey: "daily_queries_used")
        } else {
            dailyQueriesUsed = 0
            defaults.set(today, forKey: "daily_queries_date")
            defaults.set(0, forKey: "daily_queries_used")
        }
    }

    private func saveDailyCounter() {
        defaults.set(dailyQueriesUsed, forKey: "daily_queries_used")
        defaults.set(todayString(), forKey: "daily_queries_date")
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private func todayString() -> String {
        Self.dayFormatter.string(from: Date.now)
    }
}

private enum StoreError: Error {
    case unverified
}
