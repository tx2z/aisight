import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class HistoryViewModel {

    var entries: [QueryEntry] = []

    func loadEntries(modelContext: ModelContext) {
        let store = QueryHistoryStore(modelContext: modelContext)
        entries = store.fetchHistory()
    }

    func deleteEntry(_ entry: QueryEntry, modelContext: ModelContext) {
        let store = QueryHistoryStore(modelContext: modelContext)
        store.deleteEntry(entry)
        loadEntries(modelContext: modelContext)
    }

    func clearAll(modelContext: ModelContext) {
        let store = QueryHistoryStore(modelContext: modelContext)
        store.clearAll()
        entries = []
    }
}
