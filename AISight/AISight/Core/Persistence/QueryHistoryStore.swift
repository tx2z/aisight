import Foundation
import OSLog
import SwiftData

@MainActor
final class QueryHistoryStore {
    private let modelContext: ModelContext
    private let logger = Logger(subsystem: "com.aisight", category: "QueryHistoryStore")

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(query: String, answer: String, sources: [SourceInfo], isDeepSearch: Bool = false) {
        let entry = QueryEntry(query: query, answer: answer, sources: sources, isDeepSearch: isDeepSearch)
        modelContext.insert(entry)
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save entry: \(error.localizedDescription)")
        }
    }

    func fetchHistory() -> [QueryEntry] {
        let descriptor = FetchDescriptor<QueryEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch history: \(error.localizedDescription)")
            return []
        }
    }

    func deleteEntry(_ entry: QueryEntry) {
        modelContext.delete(entry)
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to delete entry: \(error.localizedDescription)")
        }
    }

    func clearAll() {
        let entries = fetchHistory()
        for entry in entries {
            modelContext.delete(entry)
        }
        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to clear all entries: \(error.localizedDescription)")
        }
    }
}
