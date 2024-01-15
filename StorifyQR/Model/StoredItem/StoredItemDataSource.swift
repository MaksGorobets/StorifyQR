//
//  StoredItemDataSource.swift
//  StorifyQR
//
//  Created by Maks Winters on 05.01.2024.
//
// https://dev.to/jameson/swiftui-with-swiftdata-through-repository-36d1
//

import Foundation
import SwiftData

final class StoredItemDataSource {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @MainActor
    static let shared = StoredItemDataSource()

    @MainActor
    private init() {
        self.modelContainer = try! ModelContainer(for: StoredItem.self)
        self.modelContext = modelContainer.mainContext
    }
    
    func appendTagToItem(item: StoredItem, tags: [Tag]) {
        item.tags = tags
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func appendItem(item: StoredItem) {
        modelContext.insert(item)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetchItems() -> [StoredItem] {
        do {
            return try modelContext.fetch(FetchDescriptor<StoredItem>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func removeItem(_ item: StoredItem) {
        modelContext.delete(item)
    }
}
