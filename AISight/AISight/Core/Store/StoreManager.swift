import StoreKit

@MainActor @Observable
final class StoreManager {
    private(set) var isPro: Bool = false
    private(set) var dailyQueriesUsed: Int = 0
    private(set) var errorMessage: String?

    static let dailyLimit = 20
    static let productID = "com.aisight.pro"

    private var transactionListener: Task<Void, Never>?

    var canSearch: Bool {
        isPro || remainingQueries > 0
    }

    var remainingQueries: Int {
        isPro ? .max : max(0, Self.dailyLimit - dailyQueriesUsed)
    }

    init() {
        loadDailyCounter()
        #if SETAPP
        isPro = true
        #else
        startTransactionListener()
        Task { [weak self] in
            await self?.refreshPurchaseStatus()
        }
        #endif
    }

    func recordQuery() {
        guard !isPro else { return }
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
        let storedDate = UserDefaults.standard.string(forKey: "daily_queries_date") ?? ""
        if storedDate == today {
            dailyQueriesUsed = UserDefaults.standard.integer(forKey: "daily_queries_used")
        } else {
            dailyQueriesUsed = 0
            UserDefaults.standard.set(today, forKey: "daily_queries_date")
            UserDefaults.standard.set(0, forKey: "daily_queries_used")
        }
    }

    private func saveDailyCounter() {
        UserDefaults.standard.set(dailyQueriesUsed, forKey: "daily_queries_used")
        UserDefaults.standard.set(todayString(), forKey: "daily_queries_date")
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
