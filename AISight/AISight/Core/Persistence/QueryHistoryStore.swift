import Foundation
import SwiftData
import Observation

@Observable
class QueryHistoryStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(query: String, answer: String, sources: [SourceInfo]) {
        let entry = QueryEntry(query: query, answer: answer, sources: sources)
        modelContext.insert(entry)
        do {
            try modelContext.save()
        } catch {
            print("QueryHistoryStore: Failed to save entry: \(error.localizedDescription)")
        }
    }

    func fetchHistory() -> [QueryEntry] {
        let descriptor = FetchDescriptor<QueryEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("QueryHistoryStore: Failed to fetch history: \(error.localizedDescription)")
            return []
        }
    }

    func deleteEntry(_ entry: QueryEntry) {
        modelContext.delete(entry)
        do {
            try modelContext.save()
        } catch {
            print("QueryHistoryStore: Failed to delete entry: \(error.localizedDescription)")
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
            print("QueryHistoryStore: Failed to clear all entries: \(error.localizedDescription)")
        }
    }
}
